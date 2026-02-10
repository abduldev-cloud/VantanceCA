from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator
from typing import Optional
from enum import Enum

class InvitePersona(str, Enum):
    TEACHER = "teacher"
    SCHOOL = "institute_admin"
    LEARNER = "learner"

class InviteSource(str, Enum):
    MANUAL = "manual"
    MIDDLEWARE = "middleware"
    STAGING = "staging"
    
class InviteUserSchema(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    school_name: Optional[str] = None
    school_type: Optional[str] = None
    school_district: Optional[str] = None
    email_domain: Optional[str] = None
    institute_id: Optional[str] = None
    invite_persona: InvitePersona = InvitePersona.SCHOOL
    teacher_name: Optional[str] = None
    source_id: Optional[str] = None
    source_user_id: Optional[str] = None
    model_config = ConfigDict(extra="ignore")
    is_demo_school: Optional[str] = "N"

    @model_validator(mode="after")
    def check_required_fields(self) -> "InviteUserSchema":
        missing_fields = []

        if self.invite_persona == InvitePersona.SCHOOL:
            required = ["school_name", "school_type", "school_district", "email_domain"]
        elif self.invite_persona in (InvitePersona.TEACHER):
            required = ["school_name", "teacher_name", "institute_id"]
            
        else:
            required = ["school_name"]

        for field in required:
            if not getattr(self, field):
                missing_fields.append(field)

        if missing_fields:
            raise ValueError(f"{', '.join(missing_fields)} required for this type of invite")

        return self

class CreateUserInviteSchema(BaseModel):
    email: EmailStr
    role: str
    created_by: str
    source: InviteSource = InviteSource.MANUAL
    additional_details: InviteUserSchema = None

class AcceptInviteSchema(BaseModel):
    user_id: str
    password: str
    first_name: str
    last_name: str
    phone_number: str = None
    salutation: str = None
    email: EmailStr
    invite_persona: InvitePersona = InvitePersona.SCHOOL

class AcceptInviteGoogleSchema(BaseModel):
    user_id: str
    google_token: str
    
class UpdateUserSchema(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    phone_number: str
    password: str = None


class CreateUserSchema(BaseModel):
    salutation: Optional[str] = Field(None, example="Mr.")
    first_name: str
    last_name: str
    email: EmailStr
    keycloak_user_id: str
    created_by: str
    
class CreateKeycloakUserSchema(BaseModel):
    username: str
    email: EmailStr
    password: str
    role: str
    first_name: str
    last_name: str
    phone_number: str
    
class LoginSchema(BaseModel):
    username: str
    password: str

class UpdateUserStatusSchema(BaseModel):
    keycloak_user_id: str = Field(..., description="Keycloak user id.")
    user_id: str = Field(..., description="Binary Success platform user id.")
    status: str = Field(..., description="New status for the user (e.g., 'active', 'inactive', 'archived').")
    updated_by: str = Field(..., description="Binary Success platform user id of the updating user e.g. platform admin")
