from pyparsing import Optional
from app.modules.crm.repository import CRMRepository
from app.modules.crm import schemas
from app.core.config import settings
from app.core.auth import TokenManager
from fastapi import HTTPException, UploadFile
from typing import Optional, List, Dict

repo = CRMRepository()


class CRMService:
    repo = CRMRepository() 
    @staticmethod
    def create_school(data: schemas.SchoolCreate):
        payload = {
            "values": [
                {"name": "AccountName", "value": data.account_name},
                {"name": "Phone", "value": data.phone},
                {"name": "BillingCity", "value": data.billing_city},
                {"name": "BillingState", "value": data.billing_state},
                {"name": "BillingPostalCode", "value": data.billing_postal_code},
                {"name": "BillingCountry", "value": data.billing_country},
                {"name": "BillingStreet", "value": data.billing_street},
            ]
        }
        return repo.create_record(settings.CRM_SCHOOL_MODULE_ID, payload)

    @staticmethod
    def create_contact(data: schemas.ContactCreate):
        payload = {
            "values": [
                {"name": "FirstName", "value": data.first_name},
                {"name": "LastName", "value": data.last_name},
                {"name": "Email", "value": data.email},
                {"name": "Phone", "value": data.phone},
                {"name": "AccountId", "value": data.account_id},
            ]
        }
        return repo.create_record(settings.CRM_CONTACT_MODULE_ID, payload)

    @staticmethod
    def create_ticket(ticket: dict):
        # fallback to default owner if not provided
        owner_id = ticket.get("owner_id") or settings.CRM_DEFAULT_OWNER

        values = [
            {"name": "Type", "value": ticket["ticket_type"]},
            {"name": "Description", "value": ticket["description"]},
            {"name": "Priority", "value": ticket["priority"]},
            {"name": "Subject", "value": ticket["subject"]},
            {"name": "Status", "value": ticket["status"]},
            {"name": "OwnerId", "value": owner_id},
            {"name": "AccountId", "value": ticket["account_id"]},
            {"name": "ContactId", "value": ticket["contact_id"]},
        ]

        if ticket.get("file_id"):
            values.append({"name": "File", "value": ticket["file_id"]})

        payload = {"values": values, "records": [], "meta": {}}
        return repo.create_record(settings.CRM_TICKET_MODULE_ID, payload)



    @staticmethod
    def school_reply_to_ticket(record_id: str, reply: str):
        ticket_reply = schemas.TicketReply(record_id=record_id, reply=reply, status="")  # status ignored
        return CRMService.reply_ticket(ticket_reply, is_school=True)
    
    @staticmethod
    def school_reply_to_ticket(record_id: str, reply: str, status: str):
        """
        Shortcut for school admin replies.
        """
        ticket_reply = schemas.TicketReply(record_id=record_id, reply=reply, status=status)
        return CRMService.reply_ticket(ticket_reply, is_school=True)

    @staticmethod
    def fetch_ticket(ticket_id: str):
        data = repo.get_ticket_by_id(ticket_id).get("response", {})
        ticket_data = {"recordID": data.get("recordID")}
        for val in data.get("values", []):
            ticket_data[val["name"]] = val["value"]
        ticket_data["createdAt"] = data.get("createdAt") or data.get("createdTime")
        return ticket_data

    @staticmethod
    def fetch_tickets(supplied_name: Optional[str] = None):
        if supplied_name:
            data = repo.get_tickets_by_supplied_name(supplied_name)
        else:
            data = repo.get_all_tickets()

        tickets = []
        for record in data.get("response", {}).get("set", []):
            ticket_data = {"recordID": record.get("recordID")}
            for val in record.get("values", []):
                name = val.get("name")
                value = val.get("value")  # safely get value
                if name:  # only include valid entries
                    ticket_data[name] = value
            tickets.append(ticket_data)
        return tickets



    
    @staticmethod
    def reply_to_ticket(data: schemas.TicketReplyCreate):
        payload = {
            "values": [
                  {"name": "Description", "value": f"<p>{data.description}</p>"},
                  {"name": "Type", "value": data.type},
                  {"name": "CaseId", "value": data.case_id},
            ]
        }
        return repo.create_record(settings.CRM_REPLY_MODULE_ID, payload)
    
    @staticmethod
    def get_ticket_replies(case_id: str):
        result = repo.get_replies(case_id)

        replies = []
        for record in result.get("response", {}).get("set", []):
            reply_data = {
                "recordID": record["recordID"],
                "createdAt": record.get("createdAt"),
            }
            for val in record.get("values", []):
                reply_data[val["name"]] = val.get("value")
            replies.append(reply_data)

        return {"replies": replies}
    

    @staticmethod
    def list_files(record_id: str, module_id: str):
        record = CRMService.repo.get_record(module_id, record_id)

        file_ids = [
            v["value"] for v in record["response"]["values"] if v["name"] == "File"
        ]

        files = []
        for fid in file_ids:
            meta = CRMService.repo.get_file_meta(fid)
            files.append({
                "file_id": fid,
                "name": meta["response"]["name"],
                "url": f"{settings.CRM_BASE_URL}{meta['response']['url']}",
                "mimetype": meta["response"]["meta"]["original"]["mimetype"],
                "size": meta["response"]["meta"]["original"]["size"],
                "createdAt": meta["response"]["createdAt"]
            })
        return files
    

        