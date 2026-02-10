import base64
import httpx
from fastapi import HTTPException
from app.core.config import settings


class StripeService:
    def __init__(self):
        secret = settings.STRIPE_SECRET_KEY
        self.auth_header = {
            "Authorization": f"Bearer {secret}",
            "Content-Type": "application/x-www-form-urlencoded"
        }

    async def create_customer(self, name: str, email: str, description: str = "Customer for Binary Success"):
        url = settings.KILLBILL_CUSTOMER_URL
        payload = {
            "name": name,
            "email": email,
            "description": description
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=self.auth_header, data=payload)

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to create Stripe customer")

        return response.json()  # includes id: cus_xxx

    async def create_checkout_session(self, customer_id: str, price_id: str, success_url: str, cancel_url: str):
        url = settings.KILLBILL_SESSIONS_URL
        payload = {
            "customer": customer_id,
            "mode": "subscription",
            "line_items[0][price]": price_id,
            "line_items[0][quantity]": 1,
            "success_url": success_url,
            "cancel_url": cancel_url
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=self.auth_header, data=payload)

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to create Stripe session")

        return response.json()  # includes session.url
