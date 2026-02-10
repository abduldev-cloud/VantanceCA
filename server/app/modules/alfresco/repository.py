import re
from typing import Optional, List, Dict
import httpx, requests
from fastapi import HTTPException
from app.core.config import settings
from app.common.crud_base import CRUDBase

class AlfrescoRepository:
    """
    Repository for interacting with Alfresco's REST API.
    Handles sites, folders, files, users, groups, and workflows.
    """

    def __init__(self):
        self.base_url: str = settings.ALFRESCO_API_BASE
        self.workflow_base: str = settings.ALFRESCO_WORKFLOW_BASE
        self.user: str = settings.ALFRESCO_USER
        self.password: str = settings.ALFRESCO_PASS
        self.client = httpx.Client(auth=(self.user, self.password), timeout=30.0)
        self.crud = CRUDBase()
    # -------------------------
    # Helpers
    # -------------------------
    def get_institute_details_by_site(self, site_id: str):
        query = """
            SELECT INSTITUTE_ID, ADMIN_USER_ID
            FROM BINARY_SUCCESS_PLATFORM_INSTITUTES
            WHERE ALFRESCO_SITE_ID = :site_id
        """
        params = {"site_id": site_id}
        return self.crud.fetch_one(query, params)

    def _handle_response(self, res: httpx.Response, error_msg: str = "Request failed") -> dict:
        """Validate response and return JSON or raise HTTPException."""
        if res.status_code in (200, 201):
            return res.json()
        raise HTTPException(status_code=res.status_code, detail=f"{error_msg}: {res.text}")

    def _auth(self):
        """Requests-compatible auth tuple."""
        return (self.user, self.password)

    # -------------------------
    # Sites & Folders
    # -------------------------
    def get_site_document_library_node(self, site_id: str) -> str:
        """Return the documentLibrary node ID for a given site."""
        url = f"{self.base_url}/sites/{site_id}/containers/documentLibrary"
        res = self.client.get(url)
        data = self._handle_response(res, f"Site '{site_id}' not found")
        return data["entry"]["id"]

    def get_or_create_folder_chain(self, site_id: str, folder_path: str) -> str:
        """Ensure the folder path exists under the site and return its node ID."""
        current_node_id = self.get_site_document_library_node(site_id)
        for part in [p for p in folder_path.strip("/").split("/") if p]:
            children_url = f"{self.base_url}/nodes/{current_node_id}/children"
            resp = self.client.get(children_url)
            entries = self._handle_response(resp, "Failed to list children").get("list", {}).get("entries", [])

            # Check if folder already exists
            folder_entry = next(
                (e for e in entries if e["entry"]["name"] == part and e["entry"]["nodeType"] == "cm:folder"),
                None,
            )

            if folder_entry:
                current_node_id = folder_entry["entry"]["id"]
            else:
                create_url = f"{self.base_url}/nodes/{current_node_id}/children"
                payload = {"name": part, "nodeType": "cm:folder"}
                resp = self.client.post(create_url, json=payload)
                current_node_id = self._handle_response(resp, f"Failed to create folder '{part}'")["entry"]["id"]

        return current_node_id

    def find_node_id_by_name(self, folder_node_id: str, filename: str) -> Optional[str]:
        """Find a child node ID inside a folder by filename."""
        url = f"{self.base_url}/nodes/{folder_node_id}/children"
        resp = self.client.get(url)
        if resp.status_code == 200:
            children = resp.json().get("list", {}).get("entries", [])
            for child in children:
                if child["entry"].get("name") == filename:
                    return child["entry"].get("id")
        return None

    # -------------------------
    # File Operations
    # -------------------------
    def update_node_content(self, node_id: str, content: bytes, mime_type: str = "text/csv") -> dict:
        """Update existing file content in Alfresco."""
        url = f"{self.base_url}/nodes/{node_id}/content"
        headers = {"Content-Type": mime_type}
        resp = self.client.put(url, data=content, headers=headers)

        if resp.status_code not in (200, 201):
            raise HTTPException(status_code=resp.status_code, detail=f"Update failed: {resp.text}")

        return resp.json()

    def upload_file_to_alfresco(self, site_id: str, folder_path: str, filename: str, content: bytes, mime_type: str):
        folder_node_id = self.get_or_create_folder_chain(site_id, folder_path)
        existing_node_id = self.find_node_id_by_name(folder_node_id, filename)

        if existing_node_id:
            url = f"{self.base_url}/nodes/{existing_node_id}/content"
            headers = {"Content-Type": mime_type}
            resp = self.client.put(url, data=content, headers=headers)
            if resp.status_code not in (200, 201):
                raise HTTPException(status_code=resp.status_code, detail=f"Failed to update existing file: {resp.text}")
            return resp.json()["entry"]["id"]

        upload_url = f"{self.base_url}/nodes/{folder_node_id}/children"
        files = {"filedata": (filename, content, mime_type)}
        data = {"name": filename, "nodeType": "cm:content"}
        resp = requests.post(upload_url, auth=self._auth(), files=files, data=data)
        if resp.status_code not in (200, 201):
            raise HTTPException(status_code=resp.status_code, detail=f"Failed to upload file: {resp.text}")
        return resp.json()["entry"]["id"]

    def upload_file(
        self,
        site_id: str,
        folder_path: str,
        filename: str,
        content: bytes,
        mime_type: str = "text/csv",
        overwrite: bool = False,
    ) -> dict:
        """Upload a file to Alfresco, updating if overwrite=True."""
        folder_node_id = self.get_or_create_folder_chain(site_id, folder_path)
        existing_node_id = self.find_node_id_by_name(folder_node_id, filename)

        if existing_node_id and overwrite:
            return self.update_node_content(existing_node_id, content, mime_type)

        upload_url = f"{self.base_url}/nodes/{folder_node_id}/children"
        files = {"filedata": (filename, content, mime_type)}
        data = {"name": filename, "nodeType": "cm:content"}

        resp = self.client.post(upload_url, files=files, data=data)
        if resp.status_code not in (200, 201):
            raise HTTPException(status_code=resp.status_code, detail=f"Upload failed: {resp.text}")

        return resp.json()

    async def download_file(self, site_id: str, folder_path: str, filename: str) -> bytes:
        """Download a file's binary content by name from a site/folder."""
        folder_node_id = self.get_or_create_folder_chain(site_id, folder_path)
        file_node_id = self.find_node_id_by_name(folder_node_id, filename)
        if not file_node_id:
            raise HTTPException(status_code=404, detail=f"File '{filename}' not found")

        content_url = f"{self.base_url}/nodes/{file_node_id}/content"
        async with httpx.AsyncClient(auth=(self.user, self.password)) as client:
            r_content = await client.get(content_url, timeout=None)
            if r_content.status_code != 200:
                raise HTTPException(status_code=r_content.status_code, detail="Failed to download file content")
            return r_content.content

    def rename_node(self, node_id: str, new_name: str) -> bool:
        """Rename a node (file or folder)."""
        url = f"{self.base_url}/nodes/{node_id}"
        payload = {"name": new_name}
        resp = self.client.put(url, json=payload)
        return resp.status_code in (200, 201)

    def download_node_content(self, node_id: str) -> Optional[str]:
        """Download and return file content as text (HTML in this case)."""
        content_url = f"{self.base_url}/nodes/{node_id}/content"
        resp = self.client.get(content_url)
        if resp.status_code == 200:
            return resp.text
        return None

    # -------------------------
    # Users, Groups, Sites
    # -------------------------
    def get_user_full_name(self, user_id: str) -> str:
        """Return the full name of a user by ID."""
        url = f"{self.base_url}/people/{user_id}"
        resp = self.client.get(url)
        if resp.status_code == 200:
            entry = resp.json().get("entry", {})
            return f"{entry.get('firstName', '')} {entry.get('lastName', '')}".strip()
        return ""

    def user_exists(self, user_id: str) -> bool:
        """Check if a user exists."""
        url = f"{self.base_url}/people/{user_id}"
        resp = self.client.get(url)
        return resp.status_code == 200

    def create_user(self, user_payload: dict) -> httpx.Response:
        """Create a new Alfresco user."""
        url = f"{self.base_url}/people"
        return self.client.post(url, json=user_payload)

    def create_site(self, site_payload: dict) -> httpx.Response:
        """Create a new Alfresco site."""
        url = f"{self.base_url}/sites"
        return self.client.post(url, json=site_payload)

    def add_site_member(self, site_id: str, user_id: str, role: str = "SiteManager") -> httpx.Response:
        """Add a member to a site with a given role."""
        url = f"{self.base_url}/sites/{site_id}/members"
        payload = {"id": user_id, "role": role}
        return self.client.post(url, json=payload)

    def create_group(self, group_payload: dict) -> httpx.Response:
        """Create a new group."""
        url = f"{self.base_url}/groups"
        return self.client.post(url, json=group_payload)

    # -------------------------
    # Workflow
    # -------------------------
    def get_first_task_id(self, process_id: str) -> Optional[str]:
        """Fetch the first task ID from a workflow process."""
        tasks_url = f"{self.workflow_base}/processes/{process_id}/tasks"
        resp = self.client.get(tasks_url)
        if resp.status_code == 200:
            task_entries = resp.json().get("list", {}).get("entries", [])
            if task_entries:
                return task_entries[0]["entry"]["id"]
        return None

    # -------------------------
    # Misc
    # -------------------------
    def list_student_submissions(self, folder_node_id: str) -> List[Dict[str, str]]:
        """List all student submissions (files) in a folder."""
        url = f"{self.base_url}/nodes/{folder_node_id}/children"
        resp = self.client.get(url)
        data = self._handle_response(resp, "Failed to list student submissions")
        return [{"student_id": e["entry"]["name"], "node_id": e["entry"]["id"]}
                for e in data.get("list", {}).get("entries", [])]

    def generate_site_id(self, name: str) -> str:
        """Generate a site ID from a name (lowercase, hyphenated)."""
        site_id = name.lower().replace(" ", "-")
        return re.sub(r"[^a-z0-9-]", "", site_id)


# ==================================================
# Global Helper Functions
# ==================================================
def fetch_file_node_id(site_id: str, folder_path: str, filename: str) -> str:
    """Find file node ID in given folder using AlfrescoRepository."""
    repo = AlfrescoRepository()
    folder_node_id = repo.get_or_create_folder_chain(site_id, folder_path)

    children_url = f"{repo.base_url}/nodes/{folder_node_id}/children"
    resp = requests.get(children_url, auth=repo._auth())
    if resp.status_code != 200:
        raise HTTPException(status_code=resp.status_code, detail="Failed to list folder children")

    entries = resp.json().get("list", {}).get("entries", [])
    target_file = next((e for e in entries if e["entry"]["name"].lower() == filename.lower()), None)
    if not target_file:
        raise HTTPException(status_code=404, detail=f"File '{filename}' not found in folder '{folder_path}'")
    return target_file["entry"]["id"]


def download_file_content(file_node_id: str) -> str:
    """Download file content by node ID."""
    repo = AlfrescoRepository()
    content_url = f"{repo.base_url}/nodes/{file_node_id}/content"
    content_resp = requests.get(content_url, auth=repo._auth())
    if content_resp.status_code != 200:
        raise HTTPException(status_code=content_resp.status_code, detail="Failed to download file content")
    return content_resp.text


# ==================================================
# Grade Repository (in-memory for now)
# ==================================================
class GradeRepository:
    """Temporary in-memory grade repository."""

    _grades: Dict[tuple, Dict] = {}  # shared storage for all instances

    def save_grade(self, student_id: str, task_id: str, grade: str, teacher_id: str, comments: Optional[str] = None):
        GradeRepository._grades[(student_id, task_id)] = {
            "student_id": student_id,
            "task_id": task_id,
            "teacher_id": teacher_id,
            "grade": grade,
            "comments": comments,
        }

    def get_grade(self, student_id: str, task_id: str) -> Optional[Dict]:
        return GradeRepository._grades.get((student_id, task_id))
