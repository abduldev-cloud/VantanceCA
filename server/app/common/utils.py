import secrets
import httpx
from jose import jwt

from app.core.config import settings

def decode_jwt_token(access_token: str) -> dict:
    return jwt.decode(
    access_token,
    key="", 
    options={
        "verify_signature": False,
        "verify_aud": False,  
    }
)

async def send_notification( data: dict) -> dict:
    url = f"{settings.NOTIFICATION_SERVICE_URL}/notifications/send"
    payload, headers = data, {"accept": "application/json", "Content-Type": "application/json"}
    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.post(url, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()
    
def generate_secure_code(length: int = 20) -> str:
    return secrets.token_urlsafe(length)[:length]