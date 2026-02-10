import requests
from fastapi import HTTPException , UploadFile
from app.core.config import settings
from app.core.auth import TokenManager
from typing import Optional
from bs4 import BeautifulSoup

class CRMRepository:
    def __init__(self):
        self.base_url = settings.CRM_BASE_URL
        self.namespace_id = settings.CRM_NAMESPACE_ID
        self.ticket_module_id = settings.CRM_TICKET_MODULE_ID

    def _headers(self):
        return TokenManager.get_headers()

    def _handle(self, response, msg="CRM Request failed"):
        if response.status_code in (200, 201):
            return response.json()
        raise HTTPException(
            status_code=response.status_code,
            detail=f"{msg}: {response.text}",
        )

    def create_record(self, module_id: str, payload: dict):
        url = f"{self.base_url}/namespace/{self.namespace_id}/module/{module_id}/record/"
        res = requests.post(url, json=payload, headers=self._headers())
        return self._handle(res, "Create record failed")

    def update_record(self, module_id: str, record_id: str, payload: dict):
        url = f"{self.base_url}/namespace/{self.namespace_id}/module/{module_id}/record/{record_id}"
        res = requests.post(url, json=payload, headers=self._headers())  # ✅ CRM expects POST
        return self._handle(res, "Update record failed")


    def get_record(self, module_id: str, record_id: str):
        url = f"{self.base_url}/namespace/{self.namespace_id}/module/{module_id}/record/{record_id}"
        res = requests.get(url, headers=self._headers())
        return self._handle(res, "Fetch record failed")

    def query_records(self, module_id: str, query: str):
        url = f"{self.base_url}/namespace/{self.namespace_id}/module/{module_id}/record/"
        res = requests.get(url, headers=self._headers(), params={"query": query})
        return self._handle(res, "Query records failed")

    # Ticket helpers
    def get_ticket_by_id(self, ticket_id: str):
        return self.get_record(self.ticket_module_id, ticket_id)

    def get_tickets_by_supplied_name(self, supplied_name: str):
        query = f"(SuppliedName='{supplied_name}')"
        return self.query_records(self.ticket_module_id, query)
    
    def get_all_tickets(self):
        query = ""  # No filter — fetch all records
        return self.query_records(self.ticket_module_id, query)

    def update_ticket(self, record_id: str, values: list):
        return self.update_record(self.ticket_module_id, record_id, {"values": values})

    
    def upload_file(self, module_id: str, file: UploadFile, field_name: str = "File"):
        """
        Uploads a file to CRM and returns attachmentID.
        """
        url = f"{self.base_url}/namespace/{self.namespace_id}/module/{module_id}/record/attachment"
        files = {
            "fieldName": (None, field_name),
            "upload": (file.filename, file.file, file.content_type),
        }
        res = requests.post(url, files=files, headers={"Authorization": f"Bearer {TokenManager.get_token()}"})
        data = self._handle(res, "Upload file failed")
        return data["response"]["attachmentID"]
    
    def get_replies(self, case_id: str):
        """
        Fetch replies for a given ticket (CaseId).
        """
        url = (
            f"{settings.CRM_BASE_URL}/namespace/{settings.CRM_NAMESPACE_ID}"
            f"/module/{settings.CRM_REPLY_MODULE_ID}/record/"
        )

        query = f"(CaseId = {case_id})"
        params = {
            "query": query,
            "deleted": 0,
            "limit": 20,
            "incTotal": "false",
            "incPageNavigation": "false",
            "sort": "createdAt",
        }

        headers = TokenManager.get_headers()
        headers.update({"content-language": "en"})

        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        return response.json()
    
    
    def update_ticket_status(self, record_id: str, status: str = "Closed"):
        url = f"{self.base_url}/namespace/{self.namespace_id}/module/{self.ticket_module_id}/record/{record_id}"
        payload = {
            "values": [
                {"name": "Status", "value": status},
                {"name": "IsClosed", "value": "1"}
            ]
        }
        res = requests.post(url, json=payload, headers=self._headers())
        return self._handle(res, "Update ticket failed")

    
    def get_file_meta(self, file_id: str):
        """Get metadata for a single file"""
        url = f"{self.base_url}/namespace/{self.namespace_id}/attachment/record/{file_id}"
        res = requests.get(url, headers=self._headers())
        return self._handle(res, "Get file metadata failed")
    
    def list_records(self, module_id: str, query: str = "", limit: int = 50, offset: int = 0):
        """
        Fetch records from a CRM module with pagination.
        """
        url = f"{settings.CRM_BASE_URL}/namespace/{settings.CRM_NAMESPACE_ID}/module/{module_id}/record/"
        params = {
            "query": query,
            "deleted": 0,
            "limit": limit,
            "offset": offset,
            "incTotal": True,
            "incPageNavigation": False,
            "sort": "createdAt DESC"
        }

        headers = TokenManager.get_headers()  # <- use your OAuth token manager

        resp = requests.get(url, headers=headers, params=params)
        if resp.status_code != 200:
            raise Exception(f"Failed to fetch records: {resp.status_code} {resp.text}")

        return resp.json()