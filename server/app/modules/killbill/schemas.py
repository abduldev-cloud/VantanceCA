from pydantic import BaseModel, EmailStr

class CreateAccountSchema(BaseModel):
    name: str
    email: EmailStr
    currency: str
    company: str
    phone: str

class CreateSubscriptionSchema(BaseModel):
    accountId: str
    planName: str = "Essentials"
