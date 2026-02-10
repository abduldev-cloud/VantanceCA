import requests
import time
from fastapi import HTTPException
from app.core.config import settings


class TokenManager:
    """Handles OAuth2 token generation & caching"""

    _access_token = None
    _expires_at = 0

    @classmethod
    def get_token(cls):
        # If token exists and not expired → reuse
        if cls._access_token and cls._expires_at > time.time():
            return cls._access_token

        # Fetch new token
        response = requests.post(
            settings.CRM_TOKEN_URL,
            data={"grant_type": "client_credentials", "scope": "profile api"},
            auth=(settings.CRM_CLIENT_ID, settings.CRM_CLIENT_SECRET),
        )

        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Token fetch failed: {response.text}"
            )

        token_data = response.json()
        cls._access_token = token_data.get("access_token")
        expires_in = token_data.get("expires_in", 3600)  # fallback: 1 hour
        cls._expires_at = time.time() + expires_in - 30  # refresh 30s early
        return cls._access_token

    @classmethod
    def get_headers(cls):
        return {
            "Authorization": f"Bearer {cls.get_token()}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
