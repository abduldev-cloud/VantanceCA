from fastapi import APIRouter, Query, UploadFile, File, Form , HTTPException
import requests
from fastapi.responses import StreamingResponse
from app.modules.alfresco.services import AlfrescoService
from app.modules.alfresco.schemas import (
    CreateSiteWithAdminRequest,
    CreateClassRequest,
    SaveDraftRequest,  
    SubmitRequest,
    CreateStudentsRequest,
    TeacherCreateRequest,
    AssignWorkflowRequest,  
    GradeRequest,
    MemberInfo,
    StudentCreateInfo,
    AddStudentsToClassRequest,
    StudentTaskStatus,
    AssignmentStatusResponse,
)
from typing import List, Optional
from app.core.config import settings


router = APIRouter(prefix="/alfresco", tags=["Alfresco"])
alfresco_service = AlfrescoService()


# ===============================================================
# 1. CREATE SITE
# ===============================================================
@router.post("/create-site-with-admin")
def create_site_with_admin(schema: CreateSiteWithAdminRequest):
    return alfresco_service.create_site_with_admin(schema)


# ===============================================================
# 2. CREATE CLASS
# ===============================================================
@router.post("/create-class")
def create_class(schema: CreateClassRequest):
    return alfresco_service.create_class(schema)


# ===============================================================
# 3. CREATE STUDENTS
# ===============================================================
@router.post("/create-students")
def create_students(req: CreateStudentsRequest):
    return AlfrescoService.create_students(req)


# ===============================================================
# 4. CREATE TEACHER WITH STUDENTS
# ===============================================================
@router.post("/create-teacher")
def create_teacher(req: TeacherCreateRequest):
    return AlfrescoService.create_teacher(req)

@router.post("/add-students-to-class")
def add_students_to_class(req: AddStudentsToClassRequest):
    return AlfrescoService.add_students_to_class(req)

# ===============================================================
# 5. ASSIGN WORKFLOW (BY TEACHER)
# ===============================================================
@router.post("/assign-workflow/by-teacher")
def assign_workflow_with_folder(req: AssignWorkflowRequest):
    return AlfrescoService.assign_workflow_with_folder(req)

@router.get("/student-task-status/{task_id}", response_model=AssignmentStatusResponse)
def get_student_task_status(task_id: str):
    """
    Get Alfresco status of a student task by task_id.
    """
    try:
        student_task = alfresco_service.get_student_task_status(task_id)
        return AssignmentStatusResponse(task_id=task_id, student_task=student_task)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
# ===============================================================
# 6. SAVE DRAFT
# ===============================================================
@router.post("/save-draft")
def save_draft(
    site_id: str = Form(...),
    folder_path: str = Form(...),
    task_id: str = Form(...),
    student_id: str = Form(...),
    file: UploadFile = File(...)
):
    return AlfrescoService.save_draft(site_id, folder_path, task_id, student_id, file)


# ===============================================================
# 7. SUBMIT ASSIGNMENT
# ===============================================================
@router.post("/submit")
def submit(
    site_id: str = Form(...),
    folder_path: str = Form(...),
    task_id: str = Form(...),
    student_id: str = Form(...),
    teacher_id: str = Form(...),
    file: UploadFile = File(...)
):
    return AlfrescoService.submit(site_id, folder_path, task_id, student_id, teacher_id, file)



# ===============================================================
# 8. GET STUDENT CONTENT + GRADE
# ===============================================================
@router.get("/student-task-content")
def get_student_task_content_route(site_id: str, folder_path: str, task_id: str):
    service = AlfrescoService()
    content = service.get_student_task_content(site_id, folder_path, task_id)
    return content


@router.get("/student/{student_id}/task/{task_id}/content-with-grade")
def get_student_task_content_with_grade(
    student_id: str,
    task_id: str,
    site_id: str = Query(...),
    folder_path: str = Query(...),
):
    return AlfrescoService.get_student_task_content_with_grade(student_id, task_id, site_id, folder_path)


# ===============================================================
# 9. SAVE GRADE (Teacher gives grade to student)
# ===============================================================
@router.post("/grade")
def submit_grade(req: GradeRequest):
    return AlfrescoService.save_grade(req.student_id, req.task_id, req.grade, req.teacher_id, req.comments)


# ===============================================================
# 10. GET GRADE (Student or Teacher fetch grade only)
# ===============================================================
@router.get("/grade/{student_id}/{task_id}")
def get_grade(student_id: str, task_id: str):
    return AlfrescoService.get_grade(student_id, task_id)


# ===============================================================
# 11. UPLOAD FILE
# ===============================================================
@router.post("/upload")
async def upload_file(
    site_id: str = Query(...),
    user_id: str = Query(...),
    folder_path: str = Query(...),
    file: UploadFile = File(...),
):
    return await alfresco_service.upload_csv_to_alfresco(
        site_id=site_id,
        folder_path=folder_path,
        file=file,
        user_id=user_id,
    )


# ===============================================================
# 12. DOWNLOAD FILE
# ===============================================================
@router.get("/download")
async def download_file(
    site_id: str = Query(...),
    folder_path: str = Query(...),
    filename: str = Query(...),
):
    file_bytes = await alfresco_service.download_csv_from_alfresco(
        site_id=site_id,
        folder_path=folder_path,
        filename=filename,
    )
    return StreamingResponse(
        iter([file_bytes]),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename={filename}"},
    )



