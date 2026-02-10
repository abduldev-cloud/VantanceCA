from app.common.crud_base import CRUDBase
from app.core.logger import logger

class UtilsRepository:
    def __init__(self):
        self.crud = CRUDBase()

    def get_role_id_by_name(self, role_name: str) -> str | None:
        query = """
            SELECT role_id FROM binary_success_roles
            WHERE role_name = :role_name
        """
        return self.crud.fetch_one(query, {"role_name": role_name.upper()})
