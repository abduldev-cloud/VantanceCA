from fastapi import HTTPException
from app.modules.forgot_password.services import ForgotPasswordService
from app.modules.invitation.services import InvitationService
from app.modules.keycloak.services import KeycloakService
from app.modules.schools.repository import SchoolRepository
from app.modules.users.schemas import AcceptInviteGoogleSchema, AcceptInviteSchema, CreateKeycloakUserSchema, \
    CreateUserInviteSchema, CreateKeycloakUserSchema, InvitePersona, UpdateUserStatusSchema
from app.modules.users.repository import UserRepository

class UsersService:
    def __init__(self):
        self.keycloak_service = KeycloakService()
        self.invitation_service = InvitationService()
        self.forgot_password_service = ForgotPasswordService()
        self.school_repository = SchoolRepository()
        self.user_repository = UserRepository()

    async def invite_user(self, schema: CreateUserInviteSchema, isBulkConsentChecked: bool = False):
        try:
            is_learner =  schema.additional_details.invite_persona == InvitePersona.LEARNER
            # if is_learner and not isBulkConsentChecked:
            #     #check consent from school admin available
            #     if not self.school_repository.checkBulkConsentApproved(schema.additional_details.institute_id):
            #         raise HTTPException(status_code=400, detail="Bulk consent not given by school admin.")

            user_id = await self.keycloak_service.invite_user(schema)
        except HTTPException as e:
            if e.status_code != 409:
                raise e

            user_id = await self.keycloak_service.get_user_id_by_username(schema.email)
            if await self.keycloak_service.is_user_enabled(user_id):
                raise HTTPException(status_code=400, detail="User is already active. Cannot resend invite.")

        return await self.invitation_service.send_invite(user_id, schema)

    
    async def get_invite_by_code(self, invite_code: str):
        invite = await self.invitation_service.get_invite_by_code(invite_code)
        if not invite:
            raise HTTPException(status_code=404, detail="Invite not found")
        return invite
    
    async def accept_invite(self, schema: AcceptInviteSchema, invite_code: str):
        return await self.invitation_service.accept_invite(schema, invite_code)
    
    async def accept_invite_google(self, schema: AcceptInviteGoogleSchema, invite_code: str):
        return await self.invitation_service.accept_invite_google(schema, invite_code)

    async def create_user(self, schema: CreateKeycloakUserSchema):
        try:
            user_id = await self.keycloak_service.create_user(schema)
        except HTTPException as e:
            if e.status_code == 409:
                raise HTTPException(status_code=409, detail="User already exists in Keycloak")
            raise

        tokens = await self.keycloak_service.login_user(schema.username, schema.password)

        return {
            "message": "User successfully created in Keycloak",
            "user_id": user_id,
            "access_token": tokens["access_token"],
            "refresh_token": tokens["refresh_token"]
        }

    async def login_user(self, username: str, password: str) -> dict:
        return await self.keycloak_service.login_user(username, password)

    async def refresh_token(self, refresh_token: str) -> dict:
        try:
            tokens = await self.keycloak_service.refresh_token(refresh_token)
            return tokens
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)
        
    async def login_user_with_google(self, token: str) -> dict:
        try:
            return await self.keycloak_service.login_user_with_google(token)
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)
        
    async def logout_user(self, refresh_token: str) -> dict:
        try:
            await self.keycloak_service.logout_user(refresh_token)
            return {"message": "User successfully logged out"}
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)

    async def impersonate_user(self, user_id: str) -> dict:
        try:
            return await self.keycloak_service.impersonate_token(user_id)
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)
        
    async def change_password(self, email: str, new_password: str) -> dict:
        try:
            user_id = await self.keycloak_service.get_user_id_by_username(email)
            if not user_id:
                raise HTTPException(status_code=404, detail="User not found")
            await self.keycloak_service.reset_user_password(user_id, new_password)
            return {"message": "Password successfully changed"}
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    async def forgot_password(self, email: str) -> dict:
        try:
            user_id = await self.keycloak_service.get_user_id_by_username(email)
            if not user_id:
                raise HTTPException(status_code=404, detail="User not found")
            await self.forgot_password_service.request_password_reset(user_id, email)
            return {"message": "Password reset email sent successfully"}
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    async def get_forgot_password_token(self, token: str) -> dict:
        try:
            reset_info = await self.forgot_password_service.get_forgot_password_token(token)
            if not reset_info:
                raise HTTPException(status_code=404, detail="Reset token not found")
            return reset_info
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    async def reset_password(self, token: str, new_password: str) -> dict:
        # Step 1: Fetch token details
        reset_info = await self.forgot_password_service.get_forgot_password_token(token)
        if not reset_info:
            raise HTTPException(status_code=404, detail="Reset token not found")
        # Step 2: Validate token
        if reset_info.get("used"):
            raise HTTPException(status_code=410, detail="Token has already been used")
        # Step 3: Reset password
        try:
            return await self.forgot_password_service.reset_user_password(
                reset_info['keycloak_user_id'], new_password, token
            )
        except HTTPException as e:
            raise e
        except Exception:
            raise HTTPException(status_code=500, detail="Unexpected error while resetting password")

    async def update_user_status(self, schema: UpdateUserStatusSchema):
        try:
            # Disable user in Keycloak
            enabled = False if schema.status.lower() != "active" else True
            await self.keycloak_service.update_user_status([schema.keycloak_user_id], status=enabled)

            # Update User status to inactive in DB
            self.user_repository.update_user_status(schema.user_id, schema.status, schema.updated_by)
        except HTTPException as e:
            raise HTTPException(status_code=e.status_code, detail=e.detail)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))