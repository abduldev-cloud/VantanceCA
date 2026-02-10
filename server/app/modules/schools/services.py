from app.common.crud_base import CRUDBase
from app.modules.keycloak.services import KeycloakService
from app.modules.schools.repository import SchoolRepository
from app.modules.schools.schemas import CreateInstituteSchema


class SchoolsService:
    def __init__(self):
        self.keycloak_service = KeycloakService()
        self.crud_service = CRUDBase()
        self.school_repo = SchoolRepository()

    async def create_school(self, data: CreateInstituteSchema):
        return await self.school_repo.create_institute(data)


    def update_bulk_consent(self, institute_id: str, bulk_consent_given: bool):
        return self.school_repo.updateBulkConsent(institute_id, bulk_consent_given)

    def get_school_admin_user_id(self, institute_id: str, with_name: bool = False) -> str | None:
        return self.school_repo.get_institute_admin(institute_id, with_name)