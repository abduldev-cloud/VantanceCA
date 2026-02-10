import base64
import httpx
from fastapi import HTTPException
from app.core.config import settings
from app.modules.killbill.schemas import CreateAccountSchema, CreateSubscriptionSchema
import re

class KillBillService:
    def __init__(self):
        self.base_url = settings.KILLBILL_BASE_URL
        self.headers = {
            "X-Killbill-ApiKey": settings.KILLBILL_API_KEY,
            "X-Killbill-ApiSecret": settings.KILLBILL_API_SECRET,
            "X-Killbill-CreatedBy": settings.KILLBILL_CREATED_BY,
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": f"Basic {self._encode_basic_auth(settings.KILLBILL_USERNAME, settings.KILLBILL_PASSWORD)}"
        }

    def _encode_basic_auth(self, username: str, password: str) -> str:
        auth_str = f"{username}:{password}"
        return base64.b64encode(auth_str.encode()).decode()

    async def create_account(self, data: CreateAccountSchema):
        url = f"{self.base_url}/accounts/"
        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=self.headers, json=data.model_dump())

        if response.status_code not in [200, 201]:
            raise HTTPException(status_code=response.status_code, detail=response.text)

        location = response.headers.get("location")
        if not location:
            raise HTTPException(status_code=500, detail="Account created but no Location header returned")

        # Extract accountId from location
        account_id_match = re.search(r"/accounts/([a-f0-9\-]+)", location)
        if not account_id_match:
            raise HTTPException(status_code=500, detail="Could not extract account ID from Location header")

        account_id = account_id_match.group(1)
        return {
            "accountId": account_id,
            "message": "Account successfully created"
        }

    async def create_subscription(self, data: CreateSubscriptionSchema):
        url = f"{self.base_url}/subscriptions"
        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=self.headers, json=data.model_dump())

        if response.status_code == 201:
            return {
                "message": "Subscription successfully created"
            }
        raise HTTPException(status_code=response.status_code, detail=response.text)
    
    async def check_email_exists(self, email: str):
        """
        Returns account dict if email matches any account from /accounts/pagination.
        Returns None if not found.
        """
        url = f"{self.base_url}/accounts/pagination"
        
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=self.headers)

        if response.status_code not in [200, 201]:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch account list")

        account_list = response.json()

        # Search for matching email (case-insensitive match)
        for account in account_list:
            if account.get("email", "").lower() == email.lower():
                return account  # Found matching account

        return None  # Email not found


    async def has_outstanding_invoices(self, account_id: str) -> bool:
        url = f"{self.base_url}/accounts/{account_id}/invoices"
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=self.headers)

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to retrieve invoices")

        invoices = response.json()
        for inv in invoices:
            if inv.get("balance", 0) > 0:
                return True
        return False

    async def create_payment_method(self, account_id: str):
        url = f"{self.base_url}/accounts/{account_id}/paymentMethods?isDefault=true"
        payload = {"pluginName": "__EXTERNAL_PAYMENT__"}

        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=self.headers, json=payload)

        if response.status_code in [200, 201]:
            return {"message": "Payment method created"}

        try:
            error_data = response.json()
        except Exception:
            error_data = {}

        if (
            response.status_code == 400
            and error_data.get("code") == 7023
        ):
            return {"message": "Payment method already exists, using existing one"}

        raise HTTPException(
            status_code=response.status_code,
            detail=f"Failed to create payment method: {response.text}",
        )


    async def get_payment_method_id(self, account_id: str) -> str:
        url = f"{self.base_url}/accounts/{account_id}/paymentMethods"
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=self.headers)

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch payment method ID")

        methods = response.json()
        if not methods:
            raise HTTPException(status_code=404, detail="No payment methods found")

        return methods[0]["paymentMethodId"]

    async def apply_payment_to_invoice(self, invoice_id: str, account_id: str, payment_method_id: str, currency: str):
        url = f"{self.base_url}/invoices/{invoice_id}/payments"
        payload = {
            "accountId": account_id,
            "paymentMethodId": payment_method_id,
            "currency": currency
        }
        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=self.headers, json=payload)

        if response.status_code not in [200, 201]:
            raise HTTPException(status_code=response.status_code, detail="Failed to apply payment")

        return {"message": "Payment applied to invoice"}
    
    async def get_latest_invoice_id(self, account_id: str) -> str | None:
        url = f"{self.base_url}/accounts/{account_id}/invoices"
        headers = self.headers | {"X-Killbill-CreatedBy": settings.KILLBILL_CREATED_BY}

        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers)

        if response.status_code != 200:
            # logger.error(f"Failed to fetch invoices: {response.status_code}")
            return None

        invoices = response.json()
        if not invoices:
            return None

        # Assuming the latest invoice is the first one in the list
        latest_invoice = invoices[0]
        return latest_invoice.get("invoiceId")

    async def get_current_subscription_plan(self, account_id: str) -> str | None:
        url = f"{self.base_url}/accounts/{account_id}/bundles"
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=self.headers)

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch subscription bundles")

        bundles = response.json()
        if not bundles:
            return None

        for bundle in bundles:
            subscriptions = bundle.get("subscriptions", [])
            for sub in subscriptions:
                if sub.get("state") == "ACTIVE":
                    return sub.get("planName")  # e.g., "Essential", "Unlimited"

        return None
