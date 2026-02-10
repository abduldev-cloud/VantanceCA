import json
from fastapi import APIRouter, Query, HTTPException, UploadFile, File, Form
import requests
from app.core.auth import TokenManager
from app.modules.crm import schemas, services
from app.core.config import settings
from typing import Optional
from app.modules.crm.services import CRMService
from fastapi.responses import StreamingResponse  # <- import StreamingResponse
from app.modules.crm.repository import CRMRepository 


router = APIRouter(prefix="/crm", tags=["CRM"])
crm_repo = CRMRepository()
repo = CRMRepository()

# ================== SCHOOLS ==================
@router.post("/schools/create")
def create_school(req: schemas.SchoolCreate):
    return services.CRMService.create_school(req)

# ================== CONTACTS ==================
@router.post("/contacts/create")
def create_contact(req: schemas.ContactCreate):
    return services.CRMService.create_contact(req)

# ================== CREATE TICKET WITH FILE ==================
@router.post("/tickets/create-with-details")
async def create_ticket_with_account_contact(
    ticket_data: str = Form(...),   # raw JSON string
    file: Optional[UploadFile] = File(None)
):
    try:
        # 1️⃣ Parse ticket data
        try:
            ticket_dict = json.loads(ticket_data)
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="Invalid JSON in ticket_data")

        # 2️⃣ Handle file upload
        if file:
            ticket_dict["file_id"] = repo.upload_file(settings.CRM_TICKET_MODULE_ID, file)
        else:
            ticket_dict["file_id"] = None

        # 3️⃣ Create ticket
        created_ticket = services.CRMService.create_ticket(ticket_dict)
        record_id = created_ticket["response"]["recordID"]

        # 4️⃣ Fetch minimal Account + Contact details
        account_name = None
        contact_name = None

        if ticket_dict.get("account_id"):
            account = services.repo.get_record(
                module_id=settings.CRM_SCHOOL_MODULE_ID,
                record_id=ticket_dict["account_id"]
            ).get("response", {})
            if account:
                vals = {v["name"]: v.get("value") for v in account.get("values", [])}
                account_name = vals.get("AccountName")

        if ticket_dict.get("contact_id"):
            contact = services.repo.get_record(
                module_id=settings.CRM_CONTACT_MODULE_ID,
                record_id=ticket_dict["contact_id"]
            ).get("response", {})
            if contact:
                vals = {v["name"]: v.get("value") for v in contact.get("values", [])}
                first = vals.get("FirstName", "")
                last = vals.get("LastName", "")
                contact_name = f"{first} {last}".strip()

        # 5️⃣ Return
        return {
            "message": "Ticket created successfully",
            "ticket": created_ticket,
            "account": {"AccountName": account_name} if account_name else None,
            "contact": {"FullName": contact_name} if contact_name else None
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    
# ================== GET TICKETS ==================
@router.get("/tickets/platform-admin")
def get_tickets(
    supplied_name: Optional[str] = Query(None, description="School Admin / Supplied Name")
):
    return {"tickets": services.CRMService.fetch_tickets(supplied_name)}

@router.get("/tickets/{ticket_id}")
def get_ticket(ticket_id: str):
    return services.CRMService.fetch_ticket(ticket_id)

# ================== TICKETS ==================
@router.post("/tickets/reply/support")
def reply_ticket_support(case_id: str, description: str):
    data = schemas.TicketReplyCreate(
        case_id=case_id,
        description=description,
        type="SupportTeam"
    )
    return services.CRMService.reply_to_ticket(data)


@router.post("/tickets/reply/customer")
def reply_ticket_customer(case_id: str, description: str):
    data = schemas.TicketReplyCreate(
        case_id=case_id,
        description=description,
        type="Customer"
    )
    return services.CRMService.reply_to_ticket(data)

@router.get("/tickets/{record_id}/replies")
def get_ticket_replies(record_id: str):
    return services.CRMService.get_ticket_replies(record_id)


# ================== GET CONTACT BY ID ==================
@router.get("/contacts/{contact_id}", summary="Get contact details by ID")
def get_contact(contact_id: str):
    try:
        contact = services.repo.get_record(
            module_id=services.settings.CRM_CONTACT_MODULE_ID,
            record_id=contact_id,
        ).get("response", {})

        if not contact:
            raise HTTPException(status_code=404, detail="Contact not found")

        contact_data = {val["name"]: val.get("value") for val in contact.get("values", [])}
        contact_data["recordID"] = contact.get("recordID")
        return {"contact": contact_data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ================== GET ACCOUNT BY ID ==================
@router.get("/accounts/{account_id}", summary="Get account details by ID")
def get_account(account_id: str):
    try:
        account = services.repo.get_record(
            module_id=services.settings.CRM_SCHOOL_MODULE_ID,
            record_id=account_id,
        ).get("response", {})

        if not account:
            raise HTTPException(status_code=404, detail="Account not found")

        account_data = {val["name"]: val.get("value") for val in account.get("values", [])}
        account_data["recordID"] = account.get("recordID")
        return {"account": account_data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/records/{record_id}/files")
def get_record_files(record_id: str, module_id: str = Query(..., description="Module ID of the record")):
    return CRMService.list_files(record_id, module_id)

# ---------------- Change Priority ----------------
@router.post("/tickets/{record_id}/priority")
def update_ticket_priority(record_id: str, priority: str = Query(..., description="New priority value")):
    # 1️⃣ Fetch existing ticket
    ticket = crm_repo.get_ticket_by_id(record_id)
    if not ticket or "response" not in ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    # 2️⃣ Build new values list, only update Priority
    values = ticket["response"]["values"]
    updated_values = [
        {**v, "value": priority} if v["name"] == "Priority" else v
        for v in values
    ]

    # 3️⃣ Update ticket in CRM
    updated_ticket = crm_repo.update_ticket(record_id, updated_values)
    return {"detail": "Priority updated successfully", "ticket": updated_ticket}

# ---------------- Change Status ----------------
@router.post("/tickets/{record_id}/status")
def update_ticket_status(record_id: str, status: str = Query(..., description="New status value")):
    # 1️⃣ Fetch existing ticket
    ticket = crm_repo.get_ticket_by_id(record_id)
    if not ticket or "response" not in ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    # 2️⃣ Build new values list, only update Status
    values = ticket["response"]["values"]
    updated_values = [
        {**v, "value": status} if v["name"] == "Status" else v
        for v in values
    ]

    # Optional: close ticket if status is 'Closed'
    if status.lower() == "closed":
        # check if "IsClosed" exists, otherwise add
        if not any(v["name"] == "IsClosed" for v in updated_values):
            updated_values.append({"name": "IsClosed", "value": "1"})
        else:
            for v in updated_values:
                if v["name"] == "IsClosed":
                    v["value"] = "1"

    # 3️⃣ Update ticket in CRM
    updated_ticket = crm_repo.update_ticket(record_id, updated_values)
    return {"detail": "Status updated successfully", "ticket": updated_ticket}

@router.get("/accounts", summary="Get all accounts")
def get_all_accounts(limit: int = 50, offset: int = 0):
    try:
        response = repo.list_records(module_id=settings.CRM_SCHOOL_MODULE_ID, limit=limit, offset=offset)
        accounts = []
        for record in response.get("response", {}).get("set", []):
            account_data = {val["name"]: val.get("value") for val in record.get("values", [])}
            account_data["recordID"] = record.get("recordID")
            accounts.append(account_data)
        return {"accounts": accounts}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/contacts", summary="Get all contacts")
def get_all_contacts(limit: int = 50, offset: int = 0):
    try:
        response = services.repo.list_records(
            module_id=services.settings.CRM_CONTACT_MODULE_ID,
            query="",
            limit=limit,
            offset=offset
        ).get("response", {})
        
        contacts = []
        for record in response.get("set", []):
            contact_data = {val["name"]: val.get("value") for val in record.get("values", [])}
            contact_data["recordID"] = record.get("recordID")
            contacts.append(contact_data)
        
        return {"contacts": contacts}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/account/{account_id}/records")
def get_account_records(account_id: str, limit: Optional[int] = None, offset: int = 0):
    try:
        query = f"(AccountId='{account_id}')"

        response = services.repo.list_records(
            module_id=services.settings.CRM_TICKET_MODULE_ID,
            query=query,
            limit=limit,
            offset=offset
        )

        records = []
        for record in response.get("response", {}).get("set", []):
            record_data = {val["name"]: val.get("value") for val in record.get("values", [])}
            record_data["recordID"] = record.get("recordID")
            records.append(record_data)

        return {"records": records}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch records: {str(e)}")


@router.get("/contacts/{contact_id}/records", summary="Get all records for a contact")
def get_contact_records(contact_id: str, limit: int = 50, offset: int = 0):
    try:
        # Query by exact field name used in CRM
        query = f"(ContactId='{contact_id}')"

        response = services.repo.list_records(
            module_id=services.settings.CRM_TICKET_MODULE_ID,
            query=query,
            limit=limit,
            offset=offset
        )

        records = []
        for record in response.get("response", {}).get("set", []):
            record_data = {val["name"]: val.get("value") for val in record.get("values", [])}
            record_data["recordID"] = record.get("recordID")
            records.append(record_data)

        return {"records": records}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch records: {str(e)}")

@router.get("/accounts/{account_id}/records", summary="Get all records for an account with related info")
def get_account_records(
    account_id: str,
    limit: int = 50,
    offset: int = 0,
    status: str = Query("", description="Filter by status: Open, Closed, or leave empty for all")
):
    try:
        # 1️⃣ Fetch tickets for this account
        query = f"(AccountId='{account_id}')"
        response = services.repo.list_records(
            module_id=services.settings.CRM_TICKET_MODULE_ID,
            query=query,
            limit=limit,
            offset=offset
        )

        records_raw = response.get("response", {}).get("set", [])
        records = []
        status_counts = {"open": 0, "closed": 0, "all": 0}

        # Collect unique account & contact IDs
        account_ids = set()
        contact_ids = set()
        for record in records_raw:
            vals = {val["name"]: val.get("value") for val in record.get("values", [])}
            if vals.get("AccountId"):
                account_ids.add(vals["AccountId"])
            if vals.get("ContactId"):
                contact_ids.add(vals["ContactId"])

        # 2️⃣ Bulk fetch accounts
        accounts_map = {}
        for acc_id in account_ids:
            try:
                acc_info = services.repo.get_record(
                    module_id=services.settings.CRM_SCHOOL_MODULE_ID,
                    record_id=acc_id
                ).get("response", {})
                acc_vals = {val["name"]: val.get("value") for val in acc_info.get("values", [])}
                accounts_map[acc_id] = acc_vals.get("AccountName")
            except Exception:
                accounts_map[acc_id] = None

        # 3️⃣ Bulk fetch contacts
        contacts_map = {}
        for con_id in contact_ids:
            try:
                con_info = services.repo.get_record(
                    module_id=services.settings.CRM_CONTACT_MODULE_ID,
                    record_id=con_id
                ).get("response", {})
                con_vals = {val["name"]: val.get("value") for val in con_info.get("values", [])}
                first_name = con_vals.get("FirstName") or con_vals.get("firstName") or ""
                last_name = con_vals.get("LastName") or con_vals.get("lastName") or ""
                full_name = f"{first_name} {last_name}".strip()
                contacts_map[con_id] = full_name if full_name else None
            except Exception:
                contacts_map[con_id] = None

        # 4️⃣ Build final records
        for record in records_raw:
            record_data = {val["name"]: val.get("value") for val in record.get("values", [])}
            record_data["recordID"] = record.get("recordID")
            record_data["createdAt"] = record.get("createdAt")
            record_data["updatedAt"] = record.get("updatedAt")

            # Status counts
            ticket_status = (record_data.get("Status") or "").lower()
            if ticket_status == "open":
                status_counts["open"] += 1
            elif ticket_status == "closed":
                status_counts["closed"] += 1
            status_counts["all"] += 1

            # Apply status filter
            if status and status.lower() != ticket_status:
                continue

            # Add account & contact names from pre-fetched maps
            record_data["AccountName"] = accounts_map.get(record_data.get("AccountId"))
            record_data["ContactName"] = contacts_map.get(record_data.get("ContactId"))

            records.append(record_data)

        return {
            "records": records,
            "status_counts": status_counts
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch records: {str(e)}")

    

@router.get("/records/all", summary="Get all tickets across all accounts (fast)")
def get_all_account_records(
    limit: Optional[int] = None,
    offset: int = 0,
    status: str = Query("", description="Filter by status: Open, Closed, or leave empty for all")
):
    try:
        # 1️⃣ Fetch all tickets
        response = services.repo.list_records(
            module_id=services.settings.CRM_TICKET_MODULE_ID,
            limit=limit,
            offset=offset
        )

        tickets = response.get("response", {}).get("set", [])

        # 2️⃣ Extract all unique AccountIds and ContactIds
        account_ids = set()
        contact_ids = set()
        for t in tickets:
            vals = {v["name"]: v.get("value") for v in t.get("values", [])}
            if vals.get("AccountId"):
                account_ids.add(vals["AccountId"])
            if vals.get("ContactId"):
                contact_ids.add(vals["ContactId"])

        # 3️⃣ Fetch all accounts in bulk
        account_lookup = {}
        for account_id in account_ids:
            try:
                acc_info = services.repo.get_record(
                    module_id=services.settings.CRM_SCHOOL_MODULE_ID,
                    record_id=account_id
                ).get("response", {})
                acc_vals = {v["name"]: v.get("value") for v in acc_info.get("values", [])}
                account_lookup[account_id] = acc_vals.get("AccountName")
            except Exception:
                account_lookup[account_id] = None

        # 4️⃣ Fetch all contacts in bulk
        contact_lookup = {}
        for contact_id in contact_ids:
            try:
                contact_info = services.repo.get_record(
                    module_id=services.settings.CRM_CONTACT_MODULE_ID,
                    record_id=contact_id
                ).get("response", {})
                contact_vals = {v["name"]: v.get("value") for v in contact_info.get("values", [])}
                first_name = contact_vals.get("FirstName") or contact_vals.get("firstName") or ""
                last_name = contact_vals.get("LastName") or contact_vals.get("lastName") or ""
                contact_lookup[contact_id] = f"{first_name} {last_name}".strip() or None
            except Exception:
                contact_lookup[contact_id] = None

        # 5️⃣ Build final ticket list with enriched fields
        records = []
        status_counts = {"open": 0, "closed": 0, "all": 0}
        for t in tickets:
            record_data = {v["name"]: v.get("value") for v in t.get("values", [])}
            record_data["recordID"] = t.get("recordID")

            # ✅ Include createdAt if exists
            record_data["createdAt"] = t.get("createdAt") or record_data.get("createdAt") or record_data.get("CreatedAt")


            # Count status
            ticket_status = (record_data.get("Status") or "").lower()
            if ticket_status == "open":
                status_counts["open"] += 1
            elif ticket_status == "closed":
                status_counts["closed"] += 1
            status_counts["all"] += 1

            if status and status.lower() != ticket_status:
                continue

            # Attach names using lookup
            record_data["AccountName"] = account_lookup.get(record_data.get("AccountId"))
            record_data["ContactName"] = contact_lookup.get(record_data.get("ContactId"))

            records.append(record_data)

        return {"records": records, "status_counts": status_counts}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch records: {str(e)}")
