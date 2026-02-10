import httpx
from app.common.crud_base import CRUDBase
from app.common.crud_helper import CRUDHelper
from app.core.config import settings
from app.modules.schools.schemas import CreateInstituteSchema

class SchoolRepository:
    def __init__(self):
        self.BASE_URL = settings.ORACLE_DB_URL + "/institute"
        self.crud = CRUDBase()
        self.crud_helper = CRUDHelper()

    async def create_institute(self, data: CreateInstituteSchema) -> str:
        url = f"{self.BASE_URL}/create_institute"
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=data.model_dump())
            response.raise_for_status()
            response_data = response.json()

        if response_data.get("out_status") == "SUCCESS":
            return response_data.get("out_institute_id")
        else:
            raise Exception(f"Failed to create institute: {response_data}")

    def checkBulkConsentApproved(self, institute_id: str) -> bool:
        result = self.crud_helper.select_one("binary_success_platform_institutes", {"institute_id": institute_id}, ["bulk_consent_given"])
        if not result:
            return False
        return result.get("bulk_consent_given") == "Y"

    #update bulk consent
    def updateBulkConsent(self, institute_id: str, bulk_consent_given: bool) -> None:
        self.crud_helper.update(
            table="binary_success_platform_institutes",
            data={"bulk_consent_given": bulk_consent_given},
            where={"institute_id": institute_id}
        )

    def get_institute_admin(self, institute_id: str, with_name: bool = False, with_alfresco_site_id: bool = False):
        columns = ["admin_user_id", "admin_email"]
        if with_name:
            columns.append("institute_name")
        if with_alfresco_site_id:
            columns.append("alfresco_site_id")

        result = self.crud_helper.select_one(
            "binary_success_platform_institutes",
            {"institute_id": institute_id},
            columns,
        )
        if not result:
            return None

        # Build response dynamically
        response = {"admin_user_id": result.get("admin_user_id"), "admin_email": result.get("admin_email")}
        if with_name:
            response["institute_name"] = result.get("institute_name")
        if with_alfresco_site_id:
            response["alfresco_site_id"] = result.get("alfresco_site_id")

        return response if (with_name or with_alfresco_site_id) else response["admin_user_id"]


    def update_alfresco_site_id(self, institute_id: str, alfresco_site_id: str) -> None:
        return self.crud_helper.update(
            table="binary_success_platform_institutes",
            data={"alfresco_site_id": alfresco_site_id},
            where={"institute_id": institute_id},
        )

    def update_crm_account_id(self, institute_id: str, crm_account_id: str) -> None:
        return self.crud_helper.update(
            table="binary_success_platform_institutes",
            data={"crm_account_id": crm_account_id},
            where={"institute_id": institute_id},
        )