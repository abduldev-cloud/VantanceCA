import json
from datetime import datetime, timedelta, timezone
from app.common.crud_base import CRUDBase
from app.core.logger import logger
from app.modules.utils.repository import UtilsRepository
from app.modules.users.schemas import CreateUserInviteSchema
class InvitationRepository:
    def __init__(self):
        self.crud = CRUDBase()
        self.role_repo= UtilsRepository()
        
    def get_existing_valid_invite(self, user_id: str):
        query = """
            SELECT invite_code, email, expires_at
            FROM binary_success_user_invites
            WHERE keycloak_user_id = :user_id
            AND used = 0
            AND expires_at > CURRENT_TIMESTAMP
            FETCH FIRST 1 ROWS ONLY
        """
        return self.crud.fetch_one(query, {"user_id": user_id})

    def create_invite(self, user_id:str, invite_code:str, schema:CreateUserInviteSchema):
        expires_at = datetime.now(timezone.utc) + timedelta(hours=48)
        role_id = self.role_repo.get_role_id_by_name(schema.role).get("role_id")
        if not role_id:
            raise ValueError(f"Role '{schema.role}' does not exist")
        query = """
                INSERT INTO binary_success_user_invites (
                    email, invite_code,
                    keycloak_user_id, role_id,
                    expires_at, created_by, additional_details, source
                ) VALUES (
                    :email, :invite_code,
                    :user_id, :role_id,
                    :expires_at, :created_by, :additional_details, :source
                )
            """ 
        try:
            self.crud.execute(query, {
                "email": schema.email,
                "invite_code": invite_code,
                "user_id": user_id,
                "role_id": role_id,
                "expires_at": expires_at,
                "created_by": schema.created_by,
                "source": schema.source,
                "additional_details": json.dumps(schema.additional_details.model_dump(exclude_none=True)) if schema.additional_details else None,

            })
        except Exception as e:
            logger.error("Failed to create invite: %s", str(e))
            raise

    def update_additional_details(self, email: str, keycloak_user_id: str, invite_code: str, additional_details: CreateUserInviteSchema):
        query = """
            UPDATE binary_success_user_invites
            SET additional_details = :additional_details,
                updated_at = CURRENT_TIMESTAMP
            WHERE email = :email
              AND keycloak_user_id = :keycloak_user_id
              AND invite_code = :invite_code
        """
        try:
            self.crud.execute(query, {
                "additional_details": json.dumps(additional_details.model_dump(exclude_none=True)) if additional_details else None,
                "email": email,
                "keycloak_user_id": keycloak_user_id,
                "invite_code": invite_code
            })
        except Exception as e:
            logger.error("Failed to update additional details in user invite: %s", str(e))
            raise

    def delete_invite_by_user_id(self, user_id: str):
        query = "DELETE FROM binary_success_user_invites WHERE keycloak_user_id = :user_id"
        self.crud.execute(query, {"user_id": user_id})

    def mark_invite_as_used(self, invite_code: str):
        query = """
        UPDATE binary_success_user_invites
        SET used = 1, updated_at = CURRENT_TIMESTAMP, used_at = CURRENT_TIMESTAMP
        WHERE invite_code = :invite_code
        AND used = 0
        AND expires_at > CURRENT_TIMESTAMP
        """
        self.crud.execute(query, {"invite_code": invite_code})

    def get_invite_by_code(self, invite_code: str):
        query = """
            SELECT invite_id, email, invite_code,
                keycloak_user_id, used, source,
                additional_details, expires_at, created_at, created_by
            FROM binary_success_user_invites
            WHERE invite_code = :invite_code
        """
        result = self.crud.fetch_one(query, {"invite_code": invite_code})
        if not result:
            return None

        expires_at = result.get("expires_at")

        if expires_at:
            if expires_at.tzinfo is None:
                expires_at = expires_at.replace(tzinfo=timezone.utc)
            if expires_at <= datetime.now(timezone.utc):
                return {"error": "Invite expired"}

        additional = result.get("additional_details")
        if additional:
            try:
                result["additional_details"] = json.loads(additional)
            except json.JSONDecodeError:
                result["additional_details"] = None

        return result




