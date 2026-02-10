# ============================================================
# Imports
# ============================================================
from fastapi import APIRouter, FastAPI, HTTPException, Query, UploadFile, File
from uuid import uuid4
from typing import Optional , List
from starlette.responses import StreamingResponse
from fastapi.responses import StreamingResponse
from urllib.parse import quote
import requests
import re
import pandas as pd
from datetime import datetime
from datetime import timezone
import io

# ------------------------------------------------------------
# Local modules
# ------------------------------------------------------------
from app.modules.alfresco.repository import AlfrescoRepository, GradeRepository
from app.modules.alfresco.schemas import (
    CreateStudentsRequest,
    TeacherCreateRequest,
    AssignWorkflowRequest,
    CreateClassRequest,
    CreateSiteWithAdminRequest,
    AddStudentsToClassRequest,
    StudentTaskStatus,
)

from app.core.config import settings


# ============================================================
# Configuration & Constants
# ============================================================
ALFRESCO_API_BASE = settings.ALFRESCO_API_BASE
API_BASE = settings.API_BASE
ALFRESCO_WORKFLOW_BASE = settings.ALFRESCO_WORKFLOW_BASE
ALFRESCO_USER = settings.ALFRESCO_USER
ALFRESCO_PASS = settings.ALFRESCO_PASS
ORACLE_DB_URL = settings.ORACLE_DB_URL


# ============================================================
# Helper: Authentication
# ============================================================
def _auth():
    """Return Alfresco authentication tuple."""
    return (ALFRESCO_USER, ALFRESCO_PASS)


# ============================================================
# Service Layer: AlfrescoService
# ============================================================
class AlfrescoService:
    """
    Service class to handle Alfresco operations like:
    - Site creation
    - Class/group management
    - Draft/submit workflows
    - File upload/download
    - Grading
    """

    def __init__(self):
        self.repo = AlfrescoRepository()

    # --------------------------------------------------------
    # 1. Create site with admin
    # --------------------------------------------------------
    def create_site_with_admin(self, schema: CreateSiteWithAdminRequest):
        """Create a site with an admin user and assign SiteManager role."""

        # Ensure admin exists
        if not self.repo.user_exists(schema.admin_user_id):
            res = self.repo.create_user({
                "id": schema.admin_user_id,
                "firstName": schema.admin_first_name,
                "lastName": schema.admin_last_name,
                "email": schema.admin_email,
                "password": schema.admin_password,
            })
            if res.status_code not in (200, 201):
                raise HTTPException(status_code=res.status_code,
                                    detail=f"Failed to create admin user: {res.text}")

        # Create site
        site_id = self.repo.generate_site_id(schema.site_name)
        res = self.repo.create_site({
            "id": site_id,
            "title": schema.site_name,
            "description": schema.site_description,
            "visibility": schema.site_visibility,
        })
        if res.status_code != 201:
            raise HTTPException(status_code=res.status_code,
                                detail=f"Failed to create site: {res.text}")

        # Add admin as SiteManager
        member_resp = self.repo.add_site_member(site_id, schema.admin_user_id, "SiteManager")
        if member_resp.status_code not in (200, 201):
            raise HTTPException(status_code=member_resp.status_code,
                                detail=f"Failed to add admin to site: {member_resp.text}")

        return {
            "site_id": site_id,
            "site_name": schema.site_name,
            "admin_user_id": schema.admin_user_id,
            "alfresco_site_response": res.json(),
            "admin_added_status": member_resp.status_code,
        }

    # --------------------------------------------------------
    # 2. Create a class/group
    # --------------------------------------------------------
    def create_class(self, schema: CreateClassRequest):
        """Create a group (class) in Alfresco."""
        class_id = f"GROUP_{schema.class_name.lower().replace(' ', '-')}-{uuid4().hex[:8].upper()}"
        res = self.repo.create_group({"id": class_id, "displayName": schema.class_name})

        if res.status_code not in (201, 409):
            raise HTTPException(status_code=res.status_code, detail=res.text)

        return {
            "class_id": class_id,
            "group_creation_status": res.status_code,
            "group_creation_response": res.json(),
        }

    # --------------------------------------------------------
    # 3. Upload/Download CSV files
    # --------------------------------------------------------
    async def upload_csv_to_alfresco(self, site_id: str, folder_path: str, file: UploadFile, user_id: str):
        from app.modules.bulk_upload.services import BulkUploadService  # <-- lazy import here

        file_content = await file.read()
        filename = file.filename

        resp = self.repo.upload_file(
            site_id,
            folder_path,
            filename,
            file_content,
            mime_type="text/csv",
            overwrite=True
        )

        institute_details = self.repo.get_institute_details_by_site(site_id)
        if not institute_details:
            raise HTTPException(status_code=404, detail=f"No institute found for site_id {site_id}")

        # normalize keys to lowercase
        institute_id = institute_details.get("INSTITUTE_ID") or institute_details.get("institute_id")
        institute_admin_user_id = institute_details.get("ADMIN_USER_ID") or institute_details.get("admin_user_id")

        if not institute_id or not institute_admin_user_id:
            raise HTTPException(status_code=500, detail=f"Invalid institute details returned for site_id {site_id}")

        print("DEBUG institute_details:", institute_details)

        bulk_upload_service = BulkUploadService()
        bulk_resp = await bulk_upload_service.upload_data_from_file(
            institute_id=institute_details["institute_id"],
            institute_admin_user_id=institute_details["admin_user_id"],
            alfresco_site_id=site_id,
            file_name=filename
        )

        return {
            "user_id": user_id,
            "filename": filename,
            "message": "Upload successful & bulk upload triggered",
            "alfresco_response": resp,
            "bulk_upload_response": bulk_resp,
        }

    async def download_csv_from_alfresco(self, site_id: str, folder_path: str, filename: str):
        """Download CSV file via repository."""
        return await self.repo.download_file(site_id, folder_path, filename)

    # --------------------------------------------------------
    # 4. Draft/Submit operations
    # --------------------------------------------------------
    @staticmethod
    def save_draft(site_id, folder_path, task_id, student_id, file: UploadFile):
        """Save a draft file upload into Alfresco."""
        filename = f"{task_id}_{file.filename}" if file.filename else f"{task_id}.html"
        repo = AlfrescoRepository()

        # Ensure folder exists
        folder_node_id = repo.get_or_create_folder_chain(site_id, folder_path)

        # Upload/overwrite draft file
        node_id = repo.upload_file_to_alfresco(
            site_id=site_id,
            folder_path=folder_path,
            filename=filename,
            content=file.file.read(),   # raw file bytes
            mime_type=file.content_type # keep uploaded mime type
        )

        return {
            "student_id": student_id,
            "task_id": task_id,
            "file_name": filename,
            "status": "draft_saved",
            "node_id": node_id
        }

    @staticmethod
    def submit(site_id, folder_path, task_id, student_id, teacher_id, file: UploadFile):
        """Submit file upload into Alfresco."""
        filename = f"{task_id}_{file.filename}" if file.filename else f"{task_id}.html"
        repo = AlfrescoRepository()

        # Ensure folder exists
        folder_node_id = repo.get_or_create_folder_chain(site_id, folder_path)

        # Upload/overwrite submitted file
        node_id = repo.upload_file_to_alfresco(
            site_id=site_id,
            folder_path=folder_path,
            filename=filename,
            content=file.file.read(),
            mime_type=file.content_type
        )

        # Lookup user names
        student_name = repo.get_user_full_name(student_id)
        teacher_name = repo.get_user_full_name(teacher_id)

        return {
            "student_id": student_id,
            "student_name": student_name,
            "teacher_id": teacher_id,
            "teacher_name": teacher_name,
            "task_id": task_id,
            "file_name": filename,
            "status": "submitted",
            "node_id": node_id
        }

    # --------------------------------------------------------
    # 5. Teacher & Student management
    # --------------------------------------------------------
    @staticmethod
    def create_teacher(req: TeacherCreateRequest):
        """Create a teacher (if not exists), add them to site as SiteManager."""

        # Check if user exists
        user_url = f"{ALFRESCO_API_BASE}/people/{req.username}"
        resp_check = requests.get(user_url, auth=_auth())

        if resp_check.status_code == 404:
            payload_user = {
                "id": req.username,
                "firstName": req.first_name,
                "lastName": req.last_name,
                "email": req.email,
                "password": req.password
            }
            r_user = requests.post(f"{ALFRESCO_API_BASE}/people", json=payload_user, auth=_auth())
            if r_user.status_code not in [200, 201]:
                raise HTTPException(status_code=r_user.status_code,
                                    detail=f"Failed to create teacher: {r_user.text}")
        else:
            r_user = resp_check  # teacher already exists

        # Add teacher to site
        member_url = f"{ALFRESCO_API_BASE}/sites/{req.site_id}/members"
        payload_member = {"id": req.username, "role": req.site_role}
        r_site_member = requests.post(member_url, json=payload_member, auth=_auth())

        if r_site_member.status_code not in [200, 201]:
            raise HTTPException(status_code=r_site_member.status_code,
                                detail=f"Failed to add teacher to site: {r_site_member.text}")

        return {
            "teacher_id": req.username,
            "user_creation_status": r_user.status_code,
            "site_add_status": r_site_member.status_code
        }

    @staticmethod
    def create_students(req: CreateStudentsRequest):
        """Create student accounts and add them to site."""
        results = []

        for student in req.students:
            # Create student if missing
            student_url = f"{ALFRESCO_API_BASE}/people/{student.user_id}"
            resp_check = requests.get(student_url, auth=_auth())

            if resp_check.status_code == 404:
                payload_user = {
                    "id": student.user_id,
                    "firstName": student.first_name,
                    "lastName": student.last_name,
                    "email": student.email,
                    "password": student.password
                }
                r_user = requests.post(f"{ALFRESCO_API_BASE}/people", json=payload_user, auth=_auth())
            else:
                r_user = resp_check  # student already exists

            # Add student to site
            member_url = f"{ALFRESCO_API_BASE}/sites/{req.site_id}/members"
            payload_member = {"id": student.user_id, "role": student.role}
            r_site = requests.post(member_url, json=payload_member, auth=_auth())

            results.append({
                "student_id": student.user_id,
                "user_creation_status": r_user.status_code,
                "site_add_status": r_site.status_code
            })

        return {"site_id": req.site_id, "students": results}

    @staticmethod
    def add_students_to_class(req: AddStudentsToClassRequest):
        """Add existing students to a class group."""
        student_results = []
        class_id = f"GROUP_{req.class_id}"
        url_group_member = f"{ALFRESCO_API_BASE}/groups/{class_id}/members"

        for student_id in req.students:
            student_check_url = f"{ALFRESCO_API_BASE}/people/{student_id}"
            resp_student = requests.get(student_check_url, auth=_auth())

            if resp_student.status_code == 404:
                student_results.append({
                    "student_id": student_id,
                    "group_add_status": None,
                    "error": "Student not found"
                })
                continue

            payload_group_member = {"id": student_id, "memberType": "PERSON"}
            r_group = requests.post(url_group_member, json=payload_group_member, auth=_auth())
            student_results.append({
                "student_id": student_id,
                "group_add_status": r_group.status_code
            })

        return {
            "class_id": req.class_id,
            "students_added": student_results
        }

    # --------------------------------------------------------
    # 6. Assign workflow with folder
    # --------------------------------------------------------
    @staticmethod
    def assign_workflow_with_folder(req: AssignWorkflowRequest):
        """Assign workflow to students in a class with folder setup."""

        workflow_key = req.workflow_definition or "activitiAdhoc"
        repo = AlfrescoRepository()

        # -------------------------------
        # Create folder path
        # -------------------------------
        final_folder_id = repo.get_or_create_folder_chain(req.site_id, req.folder_path)

        # -------------------------------
        # Get teacher info
        # -------------------------------
        teacher_url = f"{ALFRESCO_API_BASE}/people/{req.teacher_id}"
        teacher_resp = requests.get(teacher_url, auth=_auth())
        if teacher_resp.status_code != 200:
            raise HTTPException(status_code=teacher_resp.status_code, detail=teacher_resp.text)
        teacher_data = teacher_resp.json().get("entry", {})
        teacher_name = f"{teacher_data.get('firstName', '')} {teacher_data.get('lastName', '')}".strip()

        # -------------------------------
        # Get students in class/group
        # -------------------------------
        group_full_id = f"GROUP_{req.class_id}"
        members_url = f"{ALFRESCO_API_BASE}/groups/{group_full_id}/members"
        members_resp = requests.get(members_url, auth=_auth())
        if members_resp.status_code != 200:
            raise HTTPException(status_code=members_resp.status_code, detail=members_resp.text)

        members_data = members_resp.json().get("list", {}).get("entries", [])
        students = [m["entry"] for m in members_data if m["entry"]["memberType"] == "PERSON"]

        workflow_url = f"{ALFRESCO_WORKFLOW_BASE}/processes"
        student_tasks = []

        # -------------------------------
        # Parse due_date for Alfresco
        # -------------------------------
        due_date_iso = None
        if req.due_date:
            try:
                dt_obj = datetime.fromisoformat(req.due_date.replace("Z", "+00:00"))
                due_date_iso = dt_obj.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000+0000")
            except ValueError:
                raise HTTPException(
                    status_code=400,
                    detail="Invalid due_date format. Use ISO8601 like '2025-09-30T23:59:59.000+0000'"
                )

        # -------------------------------
        # Start workflow for each student
        # -------------------------------
        for student in students:
            student_id = student["id"].replace("USER_", "")
            student_name = repo.get_user_full_name(student_id)

            payload = {
                "processDefinitionKey": workflow_key,
                "variables": {
                    "bpm_assignee": student_id,
                    "bpm_packageActionGroup": "edit_package",
                    "bpm_workflowDescription": req.description,
                    "bpm_package": {"nodeRef": f"workspace://SpacesStore/{final_folder_id}"},
                    "bpm_workflowTitle": req.title,
                }
            }

            if due_date_iso:
                payload["variables"]["bpm_workflowDueDate"] = due_date_iso

            wf_resp = requests.post(workflow_url, json=payload, auth=_auth())
            if wf_resp.status_code not in (200, 201):
                raise HTTPException(
                    status_code=wf_resp.status_code,
                    detail=f"Workflow start failed for {student_id}: {wf_resp.text}"
                )

            process_id = wf_resp.json().get("entry", {}).get("id")
            task_id = repo.get_first_task_id(process_id)

            # Update task-level due date
            if due_date_iso and task_id:
                task_update_url = f"{ALFRESCO_WORKFLOW_BASE}/tasks/{task_id}"
                task_update_payload = {"dueAt": due_date_iso}
                task_update_resp = requests.put(task_update_url, json=task_update_payload, auth=_auth())
                if task_update_resp.status_code not in (200, 201):
                    raise HTTPException(
                        status_code=task_update_resp.status_code,
                        detail=f"Failed to set due date for task {task_id}: {task_update_resp.text}"
                    )

            student_tasks.append({
                "student_id": student_id,
                "task_id": task_id,  # Alfresco-generated task ID
                "due_date": due_date_iso
            })

        # -------------------------------
        # Update Oracle DB with assignment and student task IDs
        # -------------------------------
        update_payload = {
            "task_id": req.task_id,  # Assignment-level reference
            "folder_path": req.folder_path,
            "students": student_tasks
        }

        update_url = f"{ORACLE_DB_URL}/teacher/update_alfresco_task_id/"
        update_resp = requests.post(update_url, json=update_payload, headers={"Content-Type": "application/json"})
        if update_resp.status_code not in (200, 201):
            raise HTTPException(
                status_code=update_resp.status_code,
                detail=f"Update task API failed: {update_resp.text}"
            )

        # -------------------------------
        # Final API response
        # -------------------------------
        return {
            "message": "Workflow assigned successfully, folder created, due date set, and task IDs updated",
            "teacher": {"id": req.teacher_id, "name": teacher_name},
            "task_id": req.task_id,
            "site_id": req.site_id,
            "folder_path": req.folder_path,
            "class_id": req.class_id,
            "workflow_used": workflow_key,
            "students": student_tasks,
            "update_status": update_resp.json()
        }

    # --------------------------------------------------------
    # 7. Fetch task content
    # --------------------------------------------------------
    @staticmethod
    def get_student_task_content(site_id: str = Query(...), folder_path: str = Query(...), task_id: str = Query(...)):
        """Fetch a student's submitted task content (HTML)."""
        repo = AlfrescoRepository()
        filename = f"{task_id}.html"

        folder_node_id = repo.get_or_create_folder_chain(site_id, folder_path)
        file_node_id = repo.find_node_id_by_name(folder_node_id, filename)
        if not file_node_id:
            raise HTTPException(status_code=404, detail=f"File '{filename}' not found in folder '{folder_path}'")

        content = repo.download_node_content(file_node_id)
        if not content:
            raise HTTPException(status_code=500, detail="Failed to download file content")

        return content

    # --------------------------------------------------------
    # 8. Grading operations
    # --------------------------------------------------------
    @staticmethod
    def save_grade(student_id, task_id, grade, teacher_id, comments=None):
        """Save a grade for a student-task pair."""
        repo = GradeRepository()
        repo.save_grade(student_id, task_id, grade, teacher_id, comments)
        return {"message": f"Grade stored: {grade} for student {student_id} on task {task_id}"}

    @staticmethod
    def get_grade(student_id, task_id):
        """Get grade for a student-task pair."""
        repo = GradeRepository()
        record = repo.get_grade(student_id, task_id)
        if not record:
            raise HTTPException(status_code=404, detail="Grade not found")
        return record

    @staticmethod
    def get_student_task_content_with_grade(student_id, task_id, site_id, folder_path):
        """Get student's submission content along with grade info."""
        repo = AlfrescoRepository()
        grade_repo = GradeRepository()
        filename = f"{task_id}.html"

        folder_node_id = repo.get_or_create_folder_chain(site_id, folder_path)
        file_node_id = repo.find_node_id_by_name(folder_node_id, filename)
        if not file_node_id:
            raise HTTPException(status_code=404, detail=f"File '{filename}' not found")

        content = repo.download_node_content(file_node_id)
        if not content:
            raise HTTPException(status_code=500, detail="Failed to download file content")

        grade_record = grade_repo.get_grade(student_id, task_id)

        return {
            "student_id": student_id,
            "task_id": task_id,
            "content_html": content,
            "grade": grade_record.get("grade") if grade_record else None,
            "teacher_id": grade_record.get("teacher_id") if grade_record else None,
            "comments": grade_record.get("comments") if grade_record else None,
        }
    
    @staticmethod
    def get_student_task_status(task_id: str) -> StudentTaskStatus:
        """
        Fetch the task info from Alfresco workflow API and determine status.
        """
        url = f"{ALFRESCO_WORKFLOW_BASE}/tasks/{task_id}"
        resp = requests.get(url, auth=(settings.ALFRESCO_USER, settings.ALFRESCO_PASS))
        if resp.status_code != 200:
            raise Exception(f"Failed to fetch task {task_id}: {resp.text}")

        task = resp.json().get("entry", {})

        # Determine status
        state = task.get("state", "").lower()
        # Map Alfresco state to simple status
        if state == "claimed":
            status = "assigned"
        elif state == "completed":
            status = "submitted"
        elif state == "graded":
            status = "graded"
        else:
            status = "draft"

        return StudentTaskStatus(
            task_id=task.get("id"),
            assignee=task.get("assignee"),
            status=status,
            started_at=task.get("startedAt"),
            due_at=task.get("dueAt")
        )