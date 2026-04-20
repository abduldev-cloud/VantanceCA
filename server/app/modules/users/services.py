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
            # Check if we should bypass Keycloak
            if not self.keycloak_service.base_url or "localhost" in self.keycloak_service.base_url or "127.0.0.1" in self.keycloak_service.base_url:
                # Insert directly into DB (MySQL)
                from app.core.database_mysql import get_mysql_connection
                import uuid
                
                conn = get_mysql_connection()
                cursor = conn.cursor()
                try:
                    # Check if user exists
                    cursor.execute("SELECT 1 FROM BINARY_SUCCESS_PLATFORM_USERS WHERE email = %s OR username = %s", 
                                (schema.email, schema.username))
                    if cursor.fetchone():
                        raise HTTPException(status_code=409, detail="User already exists")

                    user_id = str(uuid.uuid4())
                    
                    # Get role_id
                    cursor.execute("SELECT role_id FROM BINARY_SUCCESS_ROLES WHERE LOWER(role_name) = %s", (schema.role.lower(),))
                    role_row = cursor.fetchone()
                    role_id = role_row[0] if role_row else None

                    # Insert user
                    cursor.execute("""
                        INSERT INTO BINARY_SUCCESS_PLATFORM_USERS 
                        (user_id, keycloak_id, username, email, password, first_name, last_name, role_id, enabled)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 1)
                    """, (user_id, user_id, schema.username, schema.email, schema.password, 
                        schema.first_name, schema.last_name, role_id))
                    
                    # Also insert into student/teacher stub so they don't crash when querying role_entity_id
                    if schema.role.lower() == 'learner':
                        cursor.execute("INSERT INTO BINARY_SUCCESS_LEARNERS (learner_id, user_id) VALUES (%s, %s)", 
                                    (str(uuid.uuid4()), user_id))
                    elif schema.role.lower() == 'teacher':
                        cursor.execute("INSERT INTO BINARY_SUCCESS_TEACHERS (teacher_id, user_id) VALUES (%s, %s)", 
                                    (str(uuid.uuid4()), user_id))
                                    
                    conn.commit()
                except HTTPException:
                    raise
                except Exception as e:
                    conn.rollback()
                    raise HTTPException(status_code=500, detail=str(e))
                finally:
                    cursor.close()
                    conn.close()
                    
                tokens = {"access_token": "mock-token", "refresh_token": "mock-refresh"}
            else:
                user_id = await self.keycloak_service.create_user(schema)
                tokens = await self.keycloak_service.login_user(schema.username, schema.password)
        except HTTPException as e:
            if e.status_code == 409:
                raise HTTPException(status_code=409, detail="User already exists in Keycloak")
            raise

        return {
            "message": "User successfully created in Keycloak (or DB mock)",
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