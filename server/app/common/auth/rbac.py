from jose import jwt
from fastapi import HTTPException


class RBAC:
    def __init__(self, token: str):
        self.token = token
        self.payload = self._decode_token()

    def _decode_token(self):
        try:
            return jwt.get_unverified_claims(self.token)
        except Exception:
            raise HTTPException(status_code=401, detail="Invalid token")

    def get_roles(self):
        return self.payload.get("realm_access", {}).get("roles", [])

    def has_role(self, role: str) -> bool:
        return role in self.get_roles()

    def is_teacher(self): return self.has_role("teacher")
    def is_student(self): return self.has_role("student")
    def is_it_team(self): return self.has_role("it-team")
    def is_school_admin(self): return self.has_role("school-admin")
    def is_product_owner(self): return self.has_role("product-owner")
