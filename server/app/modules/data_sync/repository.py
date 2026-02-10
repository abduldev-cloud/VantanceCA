from app.common.crud_base import CRUDBase
from app.common.crud_helper import CRUDHelper
from typing import List, Dict


class DataSyncRepository:
    def __init__(self):
        self.crud = CRUDBase()
        self.crud_helper = CRUDHelper()

    def get_middleware_data(self, table: str, fields: list[str], additional_filters: List[str] = None,
                            filter_values: Dict = None, status: str = "PENDING"):
        """
        Generic fetch method for middleware tables.
        table: name of the table (without 'binary_success_middleware_' prefix if you prefer).
        fields: list of fields to select (e.g., ["class_name", "term"]).
        additional_filters: list of SQL conditions, e.g., ["BULK_UPLOAD_ID = :bulk_upload_id", "class_id IS NOT NULL"].
        filter_values: dict of parameter bindings, e.g., {"bulk_upload_id": "123"}.
        """
        columns = ", ".join(fields)
        query = f"""
            SELECT {columns}
            FROM {table}
            WHERE process_status = :status
        """
        params = {"status": status}

        if additional_filters and filter_values:
            query += " AND " + " AND ".join(additional_filters)
            params.update(filter_values)

        return self.crud.fetch_all(query, params)

    def update_middleware_binary_success_id(self, table: str, id_field: str, binary_success_id: str, entity_id: str,
                                     middleware_id: str, status: str = "SUCCESS"):
        """
        Generic update for setting binary_success_id in middleware tables.
        table: name of the table.
        id_field: the primary key column (e.g., 'class_id', 'teacher_id', 'student_id').
        """
        query = f"""
            UPDATE {table}
            SET binary_success_id = :binary_success_id, 
                process_status = :status,
                updated_at = CURRENT_TIMESTAMP 
            WHERE {id_field} = :entity_id AND MIDDLEWARE_ID = :middleware_id
        """
        return self.crud.execute(query, {"binary_success_id": binary_success_id, "entity_id": entity_id, "status": status,
                                         "middleware_id": middleware_id})

    def update_process_status(self, table: str, id_field: str, entity_id: str, status: str, error_message: str = None,
                              additional_filters: List[str] = None, filter_values: Dict = None):
        """
        Update the process status and error message for a specific entity in a middleware table.
        """
        query = f"""
            UPDATE {table}
            SET process_status = :status, 
                error_message = :error_message,
                updated_at = CURRENT_TIMESTAMP 
            WHERE {id_field} = :entity_id
        """
        params = {"entity_id": entity_id, "status": status, "error_message": error_message}

        if additional_filters and filter_values:
            query += " AND " + " AND ".join(additional_filters)
            params.update(filter_values)
        return self.crud.execute(query, params)

    def get_middleware_data_by_id(self, table: str, where: dict, columns: list[str] = None):
        return self.crud_helper.select_one(table, where, columns)

    def update_bulk_upload_status(self, bulk_upload_id: str):
       return self.crud.call_procedure(
            sp_name="ADMIN.UPDATE_BULK_UPLOAD_STATUS",
            in_params={"p_bulk_upload_id": bulk_upload_id}
        )

    def insert_integration_log(self, message: str, source: str, source_id: str) -> str:
        if not source or not source_id:
            return

        column = "BULK_UPLOAD_ID" if source == "staging" else "MIDDLEWARE_ID"
        query = f"""
                INSERT INTO BINARY_SUCCESS_INTEGRATION_LOGS (MESSAGE, {column})
                VALUES (:message, :source_id)
            """

        params = {
            "message": message,
            "source_id": source_id,
        }

        self.crud.execute(query, params)

    # get institute details using source id
    def get_institute_details_by_source_id(self, table: str, id_column: str, id_column_value: str):
        query = f"""
            SELECT p.INSTITUTE_ID, p.INSTITUTE_NAME, p.ADMIN_USER_ID
            FROM BINARY_SUCCESS_PLATFORM_INSTITUTES p
            JOIN {table} d ON d.INSTITUTE_ID = p.INSTITUTE_ID
            WHERE d.{id_column} = :id_column_value
        """
        return self.crud.fetch_one(query, {"id_column_value": id_column_value})
    
    # get teacher's enrolled classes
    def get_teachers_enrolled_classes(self, middleware_id: str):
        query = f"""
            SELECT class_id, binary_success_id, user_id 
            FROM BINARY_SUCCESS_MIDDLEWARE_TEACHERS t
            JOIN BINARY_SUCCESS_CLASSES c ON c.TEACHER_ID = t.BINARY_SUCCESS_ID
            WHERE MIDDLEWARE_ID = :middleware_id
                AND t.STATUS = 'INACTIVE'
                AND t.PROCESS_STATUS = 'PENDING'
                AND t.BINARY_SUCCESS_ID IS NOT NULL
        """
        return self.crud.fetch_all(query, {"middleware_id": middleware_id})
    
    # get keycloak user ids for teacher or student
    def get_keycloak_user_ids(self, table:str, middleware_id: str):
        query = f"""
            SELECT m.binary_success_id, keycloak_user_id, m.user_id
            FROM {table} m
            JOIN BINARY_SUCCESS_USER_ROLE_MAPPING rm ON rm.ROLE_ENTITY_ID = m.BINARY_SUCCESS_ID
            WHERE m.MIDDLEWARE_ID = :middleware_id 
                AND m.STATUS = 'INACTIVE'
                AND m.PROCESS_STATUS = 'PENDING'
                AND m.BINARY_SUCCESS_ID IS NOT NULL
        """
        return self.crud.fetch_all(query, {"middleware_id": middleware_id})
    
    def process_inactive_entities(self, sp_name: str, middleware_id: str):
        return self.crud.call_procedure(
            sp_name=sp_name,
            in_params={"p_middleware_id": middleware_id},
            out_params={"o_status": str}
        )

    def update_inactive_status_to_fail(self, table: str, id_field: str, entity_id: str, error_message: str = None):
        """
        Update the process status and error message for a specific entity in a middleware table.
        """
        query = f"""
            UPDATE {table}
            SET process_status = :status, 
                error_message = :error_message,
                updated_at = CURRENT_TIMESTAMP 
            WHERE {id_field} = :entity_id 
            AND process_status = :process_status
            AND status = :status_filter
        """
        params = {"entity_id": entity_id, "status": "FAILED", "error_message": error_message,
                  "process_status": "PENDING", "status_filter": "INACTIVE"}
        return self.crud.execute(query, params)
