from pydantic import BaseModel, EmailStr, Field
from typing import Optional


class CreateInstituteSchema(BaseModel):
    admin_salutation: Optional[str] = Field(None, example="Mr.")
    admin_first_name: str
    admin_last_name: str
    admin_email: EmailStr
    keycloak_user_id: str
    institute_name: str
    institute_type: str
    institute_district: str
    institute_address: Optional[str] = Field(None, example="123 Main Street, Los Angeles, CA")
    email_domain: str
    created_by: str
    max_ai_prompts_allowed: int
    is_demo_school: Optional[str] = Field('N', description="Indicates if the school is a demo school: Y or N")
