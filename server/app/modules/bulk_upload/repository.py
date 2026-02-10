from app.common.crud_base import CRUDBase
from app.modules.bulk_upload.schemas import *


class BulkUploadRepository:
    def __init__(self):
        self.crud = CRUDBase()

    async def insert_bulk_upload(self, data: CreateBulkUpload) -> str:
        query = """
        INSERT INTO BINARY_SUCCESS_STG_BULK_UPLOAD (INSTITUTE_ID, UPLOADED_BY, FILE_NAME)
        VALUES (:institute_id, :uploaded_by, :file_name)
        """
        params = {
            "institute_id": data.institute_id,
            "uploaded_by": data.uploaded_by,
            "file_name": data.file_name,
        }
        result = self.crud.insert_and_return_id(query, params, "BULK_UPLOAD_ID")
        return result["bulk_upload_id"]

    async def bulk_insert_records(self, table: str, records: list[BaseModel]) -> None:
        if not records:
            return
        columns = records[0].model_dump().keys()
        col_str = ", ".join(columns)
        val_str = ", ".join([f":{col}" for col in columns])
        query = f"INSERT INTO {table} ({col_str}) VALUES ({val_str})"

        self.crud.bulk_insert(query, [r.model_dump() for r in records])

    async def update_bulk_upload_error(self, bulk_upload_id: str, error_msg: str) -> None:
        query = """
            UPDATE BINARY_SUCCESS_STG_BULK_UPLOAD
            SET ERROR_MESSAGE = :error_msg,
                UPDATED_AT = SYSTIMESTAMP
            WHERE BULK_UPLOAD_ID = :bulk_upload_id
        """
        params = {"bulk_upload_id": bulk_upload_id, "error_msg": error_msg}
        self.crud.execute(query, params)

    async def insert_integration_log(self, data: CreateIntegrationLog) -> str:
        query = """
        INSERT INTO BINARY_SUCCESS_INTEGRATION_LOGS (MESSAGE, BULK_UPLOAD_ID)
        VALUES (:message, :bulk_upload_id)
        """
        params = {
            "message": data.message,
            "bulk_upload_id": data.bulk_upload_id,
        }
        self.crud.execute(query, params)
