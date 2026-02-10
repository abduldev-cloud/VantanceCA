from pydantic import BaseModel, EmailStr
from typing import Optional
from app.core.config import settings
from fastapi import UploadFile


class SchoolCreate(BaseModel):
    account_name: str
    phone: str
    billing_city: str
    billing_state: str
    billing_postal_code: str
    billing_country: str
    billing_street: str = ""


class ContactCreate(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone: str
    account_id: str


class TicketCreate(BaseModel):
    type: str
    description: str
    priority: str
    subject: str
    status: str                    # must be given by user
    owner_id: Optional[str] = None # optional
    account_id: str
    contact_id: str
    file_id: Optional[str] = None


class TicketReplyCreate(BaseModel):
    case_id: str
    description: str
    type: str  # "SupportTeam" or "Customer"

