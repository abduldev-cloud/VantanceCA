from fastapi import HTTPException
import httpx
from app.common.utils import generate_secure_code
from app.core.logger import logger
from app.modules.forgot_password.repository import ForgotPasswordRepository
from app.core.config import settings
from app.modules.keycloak.services import KeycloakService

class ForgotPasswordService:
    def __init__(self):
        self.forgot_password_repo = ForgotPasswordRepository()
        self.keycloak_service = KeycloakService()
        self.notification_service_url = settings.NOTIFICATION_SERVICE_URL

    async def request_password_reset(self, user_id: str, email: str):
        if self.forgot_password_repo.check_existing_valid_reset(user_id):
            raise HTTPException(status_code=409, detail="Token already sent")

        try:
            token_code = generate_secure_code()
            self.forgot_password_repo.create_reset_token(email, user_id, token_code)
            success = await self.send_forgot_password_email(email, token_code)
            if not success:
                raise HTTPException(status_code=500, detail="Failed to send reset email")
        except Exception as e:
            logger.error("Error sending reset email: %s", str(e))
            raise HTTPException(status_code=500, detail="Failed to send reset email")

        return {
            "message": "User reset email successfully sent",
            "user_id": user_id
        }

    async def send_forgot_password_email(self, email: str, token_code: str) -> dict:
        url = f"{self.notification_service_url}/email/send-forgot-password"
        payload, headers = {"email": email, "reset_token": token_code}, {"accept": "application/json", "Content-Type": "application/json"}
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()
    
    async def get_forgot_password_token(self, token: str):
        reset_info = self.forgot_password_repo.get_token_by_code(token)
        if not reset_info:
            raise HTTPException(status_code=404, detail="Reset token not found")
        if isinstance(reset_info, dict) and reset_info.get("error") == "Token expired":
            raise HTTPException(status_code=410, detail="Token has expired")  # 410 Gone

        return reset_info
    
    async def reset_user_password(self, user_id: str, new_password: str, token: str) -> dict:
        try:
            await self.keycloak_service.reset_user_password(user_id, new_password)
        except Exception:
            raise HTTPException(status_code=502, detail="Failed to reset password in identity service")
        try:
            self.forgot_password_repo.mark_token_as_used(token)
        except Exception:
            raise HTTPException(status_code=500, detail="Password reset succeeded, but token update failed")

        return {"message": "Password successfully reset"}
