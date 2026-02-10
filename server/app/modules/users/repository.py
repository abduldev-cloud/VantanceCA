import httpx

from app.common.crud_base import CRUDBase
from app.common.crud_helper import CRUDHelper
from app.core.config import settings

class UserRepository:
    def __init__(self):
        self.BASE_URL = settings.ORACLE_DB_URL + "/users"
        self.crud_helper = CRUDHelper()
        self.crud = CRUDBase()

    async def get_user_details_by_id(self, user_id: str) -> str:
        return self.crud_helper.select_one(
            table="binary_success_platform_users",
            where={"user_id": user_id},
            columns=["first_name", "last_name", "email"]
        )

    async def get_user_by_id(self, user_id: str) -> str:
        url = f"{self.BASE_URL}/get_user_id/{user_id}"
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            response.raise_for_status()
            data = response.json()

        # Assuming the structure: {"items": [{"user_id": "..."}, ...]}
        return data["items"][0]["user_id"] if data.get("items") else None
    
    def update_alfresco_id(self, keycloak_user_id: str, alfresco_user_id: str) -> None:
        return self.crud_helper.update(
            table="binary_success_user_role_mapping",
            data={"alfresco_user_id": alfresco_user_id},
            where={"keycloak_user_id": keycloak_user_id},
        )

    def get_user_and_entity_id_by_lms_id(self, lms_entity_id: str) -> str:
        return self.crud_helper.select_one(
            table="binary_success_user_role_mapping",
            where={"lms_entity_id": lms_entity_id},
            columns=["user_id", "role_entity_id", "keycloak_user_id", "alfresco_user_id"]
        )

    def update_crm_contact_id(self, keycloak_user_id: str, crm_contact_id: str) -> None:
        return self.crud_helper.update(
            table="binary_success_user_role_mapping",
            data={"crm_contact_id": crm_contact_id},
            where={"keycloak_user_id": keycloak_user_id},
        )

    def update_user_status(self, platform_user_id: str, status: str, updated_by: str) -> None:
        query = f"""
                    UPDATE BINARY_SUCCESS_PLATFORM_USERS
                    SET STATUS_ID = (
                        SELECT status_id FROM binary_success_statuses WHERE UPPER(status_code) = upper(:status)
                    ), updated_at = CURRENT_TIMESTAMP, updated_by = :updated_by
                    WHERE user_id = :user_id
                """
        params = {"user_id": platform_user_id, "status": status, "updated_by": updated_by}
        self.crud.execute(query, params)