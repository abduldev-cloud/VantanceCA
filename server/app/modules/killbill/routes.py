from fastapi import APIRouter, HTTPException, Query
from app.modules.killbill.schemas import CreateAccountSchema, CreateSubscriptionSchema
from app.modules.killbill.services import KillBillService
from app.modules.killbill.stripe_service import StripeService  # make sure this is the correct import path

from app.core.config import settings
KILLBILL_SCHOOL_BILLING_BASE_URL = settings.KILLBILL_SCHOOL_BILLING_BASE_URL

router = APIRouter(prefix="/killbill", tags=["KillBill"])

@router.get("/user-plan")
async def get_user_plan(email: str = Query(...)):
    killbill = KillBillService()

    # Find account by email
    existing_account = await killbill.check_email_exists(email)
    if not existing_account:
        raise HTTPException(status_code=404, detail="No account found with this email")

    account_id = existing_account["accountId"]

    # Get current plan
    plan = await killbill.get_current_subscription_plan(account_id)
    if not plan:
        raise HTTPException(status_code=404, detail="No active subscription found")

    return {
        "accountId": account_id,
        "plan": plan
    }

@router.post("/initiate-subscription")
async def initiate_subscription(data: CreateAccountSchema, plan: str = Query(default="Basic")):
    killbill = KillBillService()
    stripe = StripeService()

    # 1. Check if email already exists in KillBill
    existing = await killbill.check_email_exists(data.email)
    if existing:
        account_id = existing['accountId']

        # Check if user already has the same plan
        current_plan = await killbill.get_current_subscription_plan(account_id)
        if current_plan and current_plan.lower() == plan.lower():
            raise HTTPException(status_code=400, detail="You already have this plan")

        # Optional: Check for outstanding invoices
        if await killbill.has_outstanding_invoices(account_id):
            raise HTTPException(status_code=400, detail="Outstanding invoices exist for this user")

    else:
        # 2. Create new KillBill account
        created = await killbill.create_account(data)
        account_id = created["accountId"]

    # ⚡ PLAN LOGIC
    if plan.lower() == "basic":
        # Directly create subscription in KillBill (no payment needed)
        await killbill.create_subscription(CreateSubscriptionSchema(accountId=account_id, planName="Basic"))

        success_url = f"{KILLBILL_SCHOOL_BILLING_BASE_URL}/success?account-id={account_id}&planName=Basic"

        return {
            "killbillAccountId": account_id,
            "checkoutUrl": success_url,  # Direct success, no Stripe
            "message": "Basic plan activated successfully"
        }

    elif plan.lower() == "essentials":
        # 3. Create Stripe customer
        customer = await stripe.create_customer(name=data.name, email=data.email)

        # 4. Map plan to Stripe Price ID
        plan_price_map = {
            "Essentials": "price_1RoMKgK9J1r2gCsuJejRzqd6"
        }
        price_id = plan_price_map.get(plan)
        if not price_id:
            raise HTTPException(status_code=400, detail="Invalid plan name")

        success_url = f"{KILLBILL_SCHOOL_BILLING_BASE_URL}/success?account-id={account_id}&planName={plan}"
        cancel_url = f"{KILLBILL_SCHOOL_BILLING_BASE_URL}/fail?account-id={account_id}&planName={plan}"
        
        # 5. Create Stripe Checkout Session
        session = await stripe.create_checkout_session(
            customer_id=customer["id"],
            price_id=price_id,
            success_url=success_url,
            cancel_url=cancel_url
        )

        return {
            "killbillAccountId": account_id,
            "stripeCustomerId": customer["id"],
            "checkoutUrl": session["url"],
            "message": "Proceed to Stripe checkout"
        }

    else:
        raise HTTPException(status_code=400, detail="Plan must be either Basic or Essentials")

@router.post("/finalize-subscription")
async def finalize_subscription(
    account_id: str = Query(...),
    plan: str = Query(...),
    currency: str = Query(...)
):
    """
    After Stripe payment success, create KillBill subscription and register external payment.
    """
    killbill = KillBillService()

    # Step 1: Create subscription in KillBill
    await killbill.create_subscription(CreateSubscriptionSchema(accountId=account_id, planName=plan))

    # Step 2: Create and assign external payment method
    await killbill.create_payment_method(account_id)

    # Step 3: Get default payment method ID
    payment_method_id = await killbill.get_payment_method_id(account_id)

    # Step 4: Apply the payment to the invoice
    invoice_id = await killbill.get_latest_invoice_id(account_id)
    if not invoice_id:
        raise HTTPException(status_code=404, detail="No invoice found for account")

    # Step 5: Apply the payment to the invoice
    await killbill.apply_payment_to_invoice(invoice_id, account_id, payment_method_id, currency)

    return {"message": "Subscription and payment successfully processed in KillBill"}
