import httpx
import pandas as pd
import os
import io
import re

from fastapi import HTTPException

from app.modules.bulk_upload.repository import BulkUploadRepository
from app.modules.bulk_upload.schemas import *
from app.modules.data_sync.services import DataSyncService
from app.modules.alfresco.services import AlfrescoService


class BulkUploadService:
    def __init__(self):
        self.bulk_upload_repository = BulkUploadRepository()
        self.data_sync_service = DataSyncService("staging")
        self.alfresco_service = AlfrescoService()
        self.dfs = {}

        # Map sheet names with DB table, schema, required fields, either_required groups, and duplicate keys
        self.sheet_validation_map = {
            "Classes": {
                "table": "BINARY_SUCCESS_STG_BULK_UPLOAD_CLASSES",
                "schema": CreateBulkUploadClass,
                "required_fields": ["Class ID", "Class Name", "Grade"],
                "either_required": None,
                "unique_checks": [["Class ID"], ["Class Name", "Grade"]],
            },
            "Teachers": {
                "table": "BINARY_SUCCESS_STG_BULK_UPLOAD_TEACHERS",
                "schema": CreateBulkUploadTeacher,
                "required_fields": ["Teacher ID", "First Name", "Last Name", "Email"],
                "either_required": None,
                "unique_checks": [["Teacher ID"], ["Email"]],
            },
            "Learners": {
                "table": "BINARY_SUCCESS_STG_BULK_UPLOAD_LEARNERS",
                "schema": CreateBulkUploadLearner,
                "required_fields": ["Learner ID", "First Name", "Last Name", "Email"],
                "either_required": None,
                "unique_checks": [["Learner ID"], ["Email"]],
            },
            "Teacher Enrollments": {
                "table": "BINARY_SUCCESS_STG_BULK_TEACHER_ENROLLMENTS",
                "schema": CreateBulkTeacherEnrollment,
                "required_fields": ["Class ID"],
                "either_required": [["Teacher ID", "Email"]],
                "unique_checks": [["Class ID", "Teacher ID", "Email"]],
            },
            "Learner Enrollments": {
                "table": "BINARY_SUCCESS_STG_BULK_LEARNER_ENROLLMENTS",
                "schema": CreateBulkLearnerEnrollment,
                "required_fields": ["Class ID"],
                "either_required": [["Learner ID", "Email"]],
                "unique_checks": [["Class ID", "Learner ID", "Email"]],
            }
        }

    # Validate data before upload
    def validate_data(self, df: pd.DataFrame, required_fields=None, either_required=None,
                      unique_checks=None) -> pd.DataFrame:

        # Convert all NaNs to None, and add error message and process status columns
        df = df.astype(object).where(pd.notna(df), None)
        df['ERROR_MESSAGE'] = df.get('ERROR_MESSAGE', "")
        df['PROCESS_STATUS'] = df.get('PROCESS_STATUS', "PENDING")

        # Duplicate checks
        for cols in unique_checks or []:
            duplicates = df.duplicated(subset=cols, keep=False)
            if duplicates.any():
                df.loc[duplicates, 'ERROR_MESSAGE'] += f"Duplicate {', '.join(cols)}. "

        # Row-level validations
        for idx, row in df.iterrows():
            errors = []
            row_dict = row.to_dict()

            # Required fields check
            for field in required_fields or []:
                if field not in row_dict or pd.isna(row_dict[field]) or row_dict[field] == "":
                    errors.append(f"Missing {field}.")

            # Either/or fields check
            for group in either_required or []:
                if not any(row_dict.get(f) not in (None, "") and not pd.isna(row_dict.get(f)) for f in group):
                    errors.append(f"Provide either {', '.join(group)}.")

            # Email validation
            if 'Email' in row_dict and row_dict['Email'] not in (None, ""):
                if not re.fullmatch(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                                    str(row_dict['Email']).strip()):
                    errors.append("Invalid email format.")

            # Set the error message and processing status
            df.at[idx, 'ERROR_MESSAGE'] += " ".join(errors) if errors else ""
            df.at[idx, 'PROCESS_STATUS'] = 'ERROR' if df.at[idx, 'ERROR_MESSAGE'] else 'PENDING'

        return df

    # Get the uploaded file from Alfresco
    async def start_sync(self, institute_id: str, bulk_upload_id: str):
        await self.data_sync_service.start_sync(institute_id=institute_id, source_id=bulk_upload_id)

    # Get the uploaded file from Alfresco
    async def get_file_from_alfresco(self, alfresco_site_id: str, file_name: str) -> bytes:
        file_bytes = await self.alfresco_service.download_csv_from_alfresco(alfresco_site_id, "bulk_upload", file_name)
        if not file_bytes:
            raise HTTPException(status_code=404,
                                detail=f"File {file_name} from site {alfresco_site_id} is empty or not found.")

        return file_bytes

    # Idenitfy the file type
    def get_file_type(self, file_name: str) -> str:
        _, ext = os.path.splitext(file_name)
        ext = ext.lower()
        if ext in ['.xlsx', '.xls']:
            return 'excel'
        elif ext == '.csv':
            return 'csv'
        else:
            return 'unknown'

    # Load data from the file for processing
    def load_data(self, file_name: str, file_bytes: bytes) -> str:
        file_type = self.get_file_type(file_name)
        if file_type == 'excel':
            xls = pd.ExcelFile(io.BytesIO(file_bytes))
            for sheet_name in self.sheet_validation_map.keys():
                if sheet_name in xls.sheet_names:
                    self.dfs[sheet_name] = pd.read_excel(xls, sheet_name=sheet_name)

            # If no valid sheets were found
            if not self.dfs:
                raise ValueError(
                    f"No matching sheets found in the Excel file. "
                    f"Expected one of: {list(self.sheet_validation_map.keys())}. "
                    f"Found sheets: {xls.sheet_names}"
                )
        elif file_type == 'csv':
            df = pd.read_csv(io.BytesIO(file_bytes))

            # Identify what data is being uploaded based on file name
            sheet_name = next(
                (name for name in self.sheet_validation_map
                 if name.lower() in file_name.lower()),
                None
            )

            if not sheet_name:
                raise ValueError(
                    f"Cannot identify type of data from file name: {file_name}. "
                    f"Expected one of: {', '.join(self.sheet_validation_map.keys())}"
                )

            self.dfs = {sheet_name: df}
        else:
            raise ValueError("Unsupported file type")

    # Get bulk upload excel/csv file with institute data from Alfresco and insert into staging tables for processing
    async def upload_data_from_file(self, institute_id: str, institute_admin_user_id: str, alfresco_site_id: str,
                                 file_name: str):
        try:
            # Get file from Alfresco
            file_bytes = await self.get_file_from_alfresco(alfresco_site_id, file_name)

            # Load data from file
            self.load_data(file_name, file_bytes)

            # Validate all loaded data based on the mapping
            for sheet_name, config in self.sheet_validation_map.items():
                if sheet_name in self.dfs:
                    self.dfs[sheet_name] = self.validate_data(
                        self.dfs[sheet_name],
                        required_fields=config.get("required_fields"),
                        either_required=config.get("either_required"),
                        unique_checks=config.get("unique_checks")
                    )

            bulk_upload_id = None
            try:
                # Insert into BINARY_SUCCESS_STG_BULK_UPLOAD
                bulk_upload_data = CreateBulkUpload(
                    institute_id=institute_id,
                    uploaded_by=institute_admin_user_id,
                    file_name=file_name
                )
                bulk_upload_id = await self.bulk_upload_repository.insert_bulk_upload(bulk_upload_data)

                # Insert sheet data into respective staging tables
                for sheet_name, df in self.dfs.items():
                    config = self.sheet_validation_map[sheet_name]
                    schema = config["schema"]

                    # Normalize dataframe columns to match the schema for loading
                    df.columns = [col.strip().lower().replace(" ", "_") for col in df.columns]

                    records = []
                    for _, row in df.iterrows():
                        row_data = row.to_dict()
                        row_data["bulk_upload_id"] = bulk_upload_id
                        records.append(schema(**row_data))

                    await self.bulk_upload_repository.bulk_insert_records(config["table"], records)

                    # Insert Integration Log
                    await self.bulk_upload_repository.insert_integration_log(
                            CreateIntegrationLog(
                                message=f"Bulk Upload: Downloaded {sheet_name} data for processing.",
                                bulk_upload_id=bulk_upload_id
                                ))
            except Exception as e:
                if bulk_upload_id:
                    await self.bulk_upload_repository.update_bulk_upload_error(bulk_upload_id, str(e))
                    await self.bulk_upload_repository.insert_integration_log(
                        CreateIntegrationLog(
                            message=f"Bulk Upload: Error while downloading data for processing.",
                            bulk_upload_id=bulk_upload_id
                        ))
                raise

            # Start processing the uploaded data in the background
            await self.start_sync(institute_id=institute_id, bulk_upload_id=bulk_upload_id)

            return {
                "message": "Upload successfully completed. Processing uploaded data in the background",
                "bulk_upload_id": bulk_upload_id
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to bulk upload: {str(e)}")
