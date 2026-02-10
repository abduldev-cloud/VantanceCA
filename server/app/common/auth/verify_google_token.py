from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from fastapi import HTTPException
from app.core.config import settings

def verify_google_id_token(id_token_str: str) -> dict:
    try:
        id_info = id_token.verify_oauth2_token(
            id_token_str,
            google_requests.Request(),
            audience=settings.GOOGLE_CLIENT_ID
        )

        if not id_info.get("email_verified"):
            raise HTTPException(status_code=400, detail="Email not verified")

        # Fallback logic for first and last names
        full_name = id_info.get("name", "")
        given_name = id_info.get("given_name") or full_name.split(" ")[0]
        family_name = id_info.get("family_name") or " ".join(full_name.split(" ")[1:]) or None

        return {
            "sub": id_info["sub"],
            "email": id_info["email"],
            "firstname": given_name,
            "lastname": family_name,
            "picture": id_info.get("picture"),
        }

    except ValueError as e:
        raise HTTPException(status_code=401, detail=f"Invalid ID token: {str(e)}")
