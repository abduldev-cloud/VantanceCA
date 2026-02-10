from fastapi import HTTPException
from app.common.utils import generate_secure_code, send_notification
from app.core.config import settings
from app.core.logger import logger
from app.modules.alfresco.schemas import CreateSiteWithAdminRequest
from app.modules.alfresco.services import AlfrescoService
from app.modules.invitation.repository import InvitationRepository
from app.modules.keycloak.services import KeycloakService
from app.modules.learner.services import LearnerService
from app.modules.learner.schemas import CreateLearnerSchema
from app.modules.schools.repository import SchoolRepository
from app.modules.schools.schemas import CreateInstituteSchema
from app.modules.teacher.schemas import CreateTeacherSchema
from app.modules.teacher.services import TeacherService
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import AcceptInviteGoogleSchema, AcceptInviteSchema, CreateUserInviteSchema, CreateUserSchema, InvitePersona, InviteSource, InviteUserSchema
from app.modules.crm.services import CRMService
from app.modules.crm.schemas import SchoolCreate, ContactCreate
import httpx

class InvitationService:
    def __init__(self):
        self.notification_service_url = settings.NOTIFICATION_SERVICE_URL
        self.invite_repo = InvitationRepository()
        self.school_repo = SchoolRepository() 
        self.keycloak_service = KeycloakService()
        self.teacher_service = TeacherService()
        self.learner_service = LearnerService()
        self.alfresco_service = AlfrescoService()
        self.user_repo = UserRepository()

    async def send_invite(self, user_id: str, schema: CreateUserInviteSchema):
        try:
            invite = self.invite_repo.get_existing_valid_invite(user_id)

            if invite:
                # Reuse existing invite code
                invite_code = invite["invite_code"]
                # Update invite additional details in case of change
                self.invite_repo.update_additional_details(schema.email, user_id, invite_code, schema.additional_details)
            else:
                # Create a new invite
                invite_code = generate_secure_code()
                self.invite_repo.create_invite(user_id, invite_code, schema)

            invite_persona = schema.additional_details.invite_persona
            success = await self.send_invite_email(schema.email, invite_code, invite_persona)

            if not success:
                raise HTTPException(status_code=500, detail="Failed to send invite email")

        except Exception as e:
            logger.error("Error sending invite: %s", str(e))
            raise HTTPException(status_code=500, detail="Failed to send invite")

        return {
            "message": "User invite successfully sent",
            "user_id": user_id
        }
    
    # Get invite by code
    async def get_invite_by_code(self, invite_code: str):
        invite = self.invite_repo.get_invite_by_code(invite_code)

        if not invite:
            raise HTTPException(status_code=404, detail="Invite not found")

        # Handle expired invite
        if isinstance(invite, dict) and invite.get("error") == "Invite expired":
            raise HTTPException(status_code=410, detail="Invite has expired")  # 410 Gone

        # Handle already used invite
        if invite.get("used"):
            raise HTTPException(status_code=410, detail="Invite has already been used")

        user_id = invite.get("keycloak_user_id")
        if not user_id:
            raise HTTPException(status_code=400, detail="User ID not found in invite")

        user_details = await self.keycloak_service.get_user_details(user_id)

        return {
            "invite": invite,
            "user_details": user_details
        }

    async def _handle_school_invite(self, schema: AcceptInviteSchema, user_id, created_by, additional_details):
        data = CreateInstituteSchema(
            admin_email=schema.email,
            admin_first_name=schema.first_name,
            admin_last_name=schema.last_name,
            keycloak_user_id=user_id,
            institute_name=additional_details.school_name,
            created_by=created_by,
            email_domain=additional_details.email_domain,
            institute_district=additional_details.school_district,
            institute_type=additional_details.school_type,
            max_ai_prompts_allowed=5,
            is_demo_school=additional_details.is_demo_school,
        )
        result = await self.school_repo.create_institute(data)
        alfresco_user_id= f'{schema.email}-{user_id}'
        
        # Call Alfresco service to create site
        alfresco_result = self.alfresco_service.create_site_with_admin(
            CreateSiteWithAdminRequest(
                admin_email=schema.email,
                admin_first_name=schema.first_name,
                admin_last_name=schema.last_name,
                admin_user_id=alfresco_user_id,
                admin_password=alfresco_user_id,
                site_name=f'{additional_details.school_name.replace(" ", "")}-{result}',
            )
        )
        site_id = alfresco_result.get("site_id")
        admin_user_id = alfresco_result.get("admin_user_id")

        if not site_id or not admin_user_id:
            raise HTTPException(
                status_code=500, 
                detail=f"Failed to create Alfresco site for user {schema.email}"
            )

        self.school_repo.update_alfresco_site_id(result, site_id)
        self.user_repo.update_alfresco_id(keycloak_user_id=user_id, alfresco_user_id=alfresco_user_id)

        if additional_details.is_demo_school == "N":
            # Only create CRM school account and school admin contact for non-demo schools
            await self.create_crm_account_contact(additional_details, result, schema, user_id)

        title = "School Admin Accepted Invite"
        message = (
            f"The school admin '{schema.first_name} {schema.last_name}' has accepted the invite "
            f"and the school '{additional_details.school_name}' has been successfully created."
        )
        return result, title, message

    async def create_crm_account_contact(self, additional_details, institute_id: str, schema: AcceptInviteSchema, keycloak_user_id):
        # Call CRM service to create an account for the school
        school_account = CRMService.create_school(SchoolCreate(
            account_name=additional_details.school_name,
            phone="",
            billing_city="",
            billing_state="",
            billing_postal_code="",
            billing_country="",
            billing_street="",
        ))
        crm_account_id = (school_account.get("response") or {}).get("recordID")
        if not crm_account_id:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to create an account for institute {institute_id} in CRM."
            )
        self.school_repo.update_crm_account_id(institute_id, crm_account_id)

        # Call CRM service to create a contact for school admin
        admin_contact = CRMService.create_contact(ContactCreate(
            first_name=schema.first_name,
            last_name=schema.last_name,
            email=schema.email,
            phone="",
            account_id=crm_account_id
        ))
        admin_contact_id = (admin_contact.get("response") or {}).get("recordID")
        if not admin_contact_id:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to create a contact for user {schema.email} in CRM."
            )
        self.user_repo.update_crm_contact_id(keycloak_user_id, admin_contact_id)

    async def _handle_teacher_invite(self, schema: AcceptInviteSchema, user_id, created_by, additional_details: InviteUserSchema, source: InviteSource):
        data = CreateTeacherSchema(
            first_name=schema.first_name,
            last_name=schema.last_name,
            email=schema.email,
            keycloak_user_id=user_id,
            created_by=created_by,
            institute_id=additional_details.institute_id,
            source=source,
            source_id=additional_details.source_id,
            lms_entity_id=additional_details.source_user_id
        )
        result = await self.teacher_service.create_teacher(data, additional_details, source)
        title = "Teacher Accepted Invite"
        message = (
            f"The teacher '{schema.first_name} {schema.last_name}' has accepted the invite "
            f"and has been successfully created."
        )
        return result, title, message

    async def _handle_learner_invite(self, schema: AcceptInviteSchema, user_id, created_by, additional_details: InviteUserSchema, source: InviteSource):
        data = CreateLearnerSchema(
            first_name=schema.first_name,
            last_name=schema.last_name,
            email=schema.email,
            keycloak_user_id=user_id,
            created_by=created_by,
            institute_id=additional_details.institute_id,
            source=source,
            source_id=additional_details.source_id,
            lms_entity_id=additional_details.source_user_id
        )
        result = await self.learner_service.create_learner(data, additional_details, source)
        title = "Learner Accepted Invite"
        message = (
            f"The learner '{schema.first_name} {schema.last_name}' has accepted the invite "
            f"and has been successfully created."
        )
        return result, title, message

    async def accept_invite(self, schema: AcceptInviteSchema, invite_code: str):
        invite = self.invite_repo.get_invite_by_code(invite_code)
        if not invite:
            raise HTTPException(status_code=404, detail="Invite not found")

        user_id = invite.get("keycloak_user_id")
        if not user_id:
            raise HTTPException(status_code=400, detail="User ID not found in invite")

        if invite.get("used"):
            raise HTTPException(status_code=410, detail="Invite has already been used")

        additional_details_raw = invite.get("additional_details")
        additional_details = InviteUserSchema.model_validate(additional_details_raw)

        try:
            # Update Keycloak user
            await self.keycloak_service.update_user_details(user_id, schema)

            created_by = invite.get("created_by")
            source = invite.get("source")
            persona = schema.invite_persona
           

            if persona == InvitePersona.SCHOOL:
                result, title, message = await self._handle_school_invite(schema, user_id, created_by, additional_details)
            elif persona == InvitePersona.TEACHER:
                result, title, message = await self._handle_teacher_invite(schema, user_id, created_by, additional_details, source)
            elif persona == InvitePersona.LEARNER:
                result, title, message = await self._handle_learner_invite(schema, user_id, created_by, additional_details, source)
            else:
                raise HTTPException(status_code=400, detail="Invalid invite persona")

            if not result:
                raise HTTPException(
                    status_code=500, detail=f"Failed to create {persona.value.lower()} in database"
                )

            await send_notification({
                "user_id": created_by,
                "title": title,
                "message": message
            })

            self.invite_repo.mark_invite_as_used(invite_code)

        except HTTPException:
            raise

        return {"message": "Invite accepted and user created successfully"}
    
    
        
    async def accept_invite_google(self, schema: AcceptInviteGoogleSchema, invite_code: str):
        invite =  self.invite_repo.get_invite_by_code(invite_code)
        if not invite:
            raise HTTPException(status_code=404, detail="Invite not found")
        # Check if invite is already used
        if invite.get("used"):
            raise HTTPException(status_code=410, detail="Invite has already been used")
        user_id = invite.get("keycloak_user_id")
        if not user_id:
            raise HTTPException(status_code=400, detail="User ID not found in invite")

        # Create user in Keycloak with Google token
        try:
            await self.keycloak_service.update_user_with_google(user_id, schema.google_token)
            self.invite_repo.mark_invite_as_used(invite_code)
        except HTTPException as e:
            raise e

        return {
            "message": "Invite accepted and user created successfully with Google"
        }

    async def send_invite_email(self, email: str, invite_code: str, invite_persona: str) -> dict:
        url = f"{self.notification_service_url}/email/send-invite"
        payload, headers = {"email": email, "invite_code": invite_code, "invite_persona": invite_persona}, {"accept": "application/json", "Content-Type": "application/json"}
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()

    async def send_consent_req_email(self, email: str, admin_name: str, source: str, source_id: str, csv_bytes: bytes) -> dict:
        url = f"{self.notification_service_url}/email/send_admin_consent_email"
        learner_data = {
            "admin_email": email,
            "admin_name": admin_name,
            "source": source,
            "source_id": source_id
        }
        files = None
        if csv_bytes:
            files = {
                "file": ("New_students_list.csv", csv_bytes, "application/octet-stream")
            }

        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(url, data=learner_data, files=files)
            response.raise_for_status()
            return response.json()