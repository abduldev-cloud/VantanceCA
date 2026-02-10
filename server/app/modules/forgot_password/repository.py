from app.common.crud_base import CRUDBase
from datetime import datetime, timedelta, timezone

class ForgotPasswordRepository:
    def __init__(self):
        self.crud = CRUDBase()

    def check_existing_valid_reset(self, user_id: str) -> bool:
        query = """
            SELECT 1 FROM password_reset_tokens
            WHERE keycloak_user_id = :user_id
              AND used = 0
              AND expires_at > CURRENT_TIMESTAMP
            FETCH FIRST 1 ROWS ONLY
        """
        result = self.crud.fetch_one(query, {"user_id": user_id})
        return result is not None


    def get_token_by_code(self, token_code: str):
        query = """
            SELECT token, email, keycloak_user_id, used, expires_at
            FROM password_reset_tokens
            WHERE token = :token_code
        """
        result = self.crud.fetch_one(query, {"token_code": token_code})
        if not result:
            return None
        expires_at = result.get("expires_at")

        if expires_at:
            if expires_at.tzinfo is None:
                expires_at = expires_at.replace(tzinfo=timezone.utc)
            if expires_at <= datetime.now(timezone.utc):
                return {"error": "Token expired"}
        return result

    def mark_token_as_used(self, token_code: str):
        query = """
        UPDATE password_reset_tokens
        SET used = 1, updated_at = CURRENT_TIMESTAMP
        WHERE token = :token_code
        AND used = 0
        AND expires_at > CURRENT_TIMESTAMP
        """
        self.crud.execute(query, {"token_code": token_code})
    
    def create_reset_token(self, email: str, user_id: str, token_code: str):
        expires_at = datetime.now(timezone.utc) + timedelta(hours=1)
        query = """
            INSERT INTO password_reset_tokens (email, keycloak_user_id, token, expires_at)
            VALUES (:email, :user_id, :token_code, :expires_at)
        """
        self.crud.execute(query, {
            "email": email,
            "user_id": user_id,
            "token_code": token_code,
            "expires_at": expires_at
        })