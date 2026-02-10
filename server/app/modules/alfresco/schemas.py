from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional, Literal


# ===============================================================
# 1. SITE MODELS
# ===============================================================
class CreateSiteWithAdminRequest(BaseModel):
    admin_user_id: str = Field(..., description="User ID of the admin")
    admin_first_name: str = Field(..., description="Admin first name")
    admin_last_name: str = Field(..., description="Admin last name")
    admin_email: EmailStr = Field(..., description="Admin email")
    admin_password: str = Field(..., description="Admin password")
    
    site_name: str = Field(..., description="The name of the site to create")
    site_description: str = Field("Default site description", description="Site description")
    site_visibility: str = Field("PUBLIC", description="Site visibility: PUBLIC, PRIVATE, MODERATED")


class SiteMember(BaseModel):
    user_id: str
    role: Literal["SiteManager", "SiteCollaborator", "SiteContributor", "SiteConsumer"]


class AddSiteMemberRequest(BaseModel):
    site_id: str
    user_id: str
    role: Literal["SiteManager", "SiteCollaborator", "SiteContributor", "SiteConsumer"]


# ===============================================================
# 2. CLASS / GROUP MODELS
# ===============================================================
class CreateClassRequest(BaseModel):
    class_name: str


class CreateGroupRequest(BaseModel):
    group_id: str
    display_name: str


class ClassByTeacherRequest(BaseModel):
    class_id: str
    class_display_name: str
    teacher_id: str  # teacher creating the class


class AddClassMembersRequest(BaseModel):
    class_group_id: str  # e.g., GROUP_mathematicsprecalculus-UUID
    teacher_id: str
    students: List["MemberInfo"]


class GroupMemberRequest(BaseModel):
    group_id: str
    user_id: str


class ClassCreateRequest(BaseModel):
    class_id: str
    class_name: str


# ===============================================================
# 3. USER MODELS (TEACHER / STUDENT)
# ===============================================================
class MemberInfo(BaseModel):
    user_id: str
    role: Literal["SiteCollaborator", "SiteConsumer", "SiteContributor"] = "SiteCollaborator"


class TeacherCreateRequest(BaseModel):
    username: str
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    site_id: str
    site_role: str = "SiteManager"


class StudentCreateRequest(BaseModel):
    user_id: str
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    site_id: str
    role: str = "SiteCollaborator"

class CreateStudentsRequest(BaseModel):
    site_id: str
    students: list[StudentCreateRequest]


class AddStudentsToClassRequest(BaseModel):
    class_id: str   # Alfresco group/class id
    students: list[str]   # list of student user_ids


class StudentCreateInfo(BaseModel):
    user_id: str
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    role: Literal["SiteCollaborator", "SiteConsumer", "SiteContributor"] = "SiteCollaborator"


class CreateStudentsRequest(BaseModel):
    site_id: str
    students: List[StudentCreateInfo]


class StudentTaskContentRequest(BaseModel):
    site_id: str
    folder_path: str
    task_id: str

class StudentTaskContentResponse(BaseModel):
    task_id: str
    content: str
    
# ===============================================================
# 4. FOLDER / WORKFLOW MODELS
# ===============================================================
class CreateFolderInSiteRequest(BaseModel):
    site_id: str
    folder_name: str
    relative_path: Optional[str] = ""


class AssignWorkflowRequest(BaseModel):
    site_id: str
    class_id: str
    teacher_id: str
    workflow_definition: str = "activitiAdhoc"
    folder_path: str
    title: str
    description: str
    due_date: str  # ISO8601 string
    task_id: str  # Assignment-level ID for Oracle DB reference

class StudentTaskStatus(BaseModel):
    task_id: str
    assignee: str
    status: str  # assigned, submitted, graded, draft
    started_at: str
    due_at: str

class AssignmentStatusResponse(BaseModel):
    task_id: str
    student_task: StudentTaskStatus


# ===============================================================
# 5. TASK / ASSIGNMENT MODELS
# ===============================================================
class SaveDraftRequest(BaseModel):
    site_id: str
    folder_path: str
    task_id: str
    student_id: str
    content_html: str


class SubmitRequest(BaseModel):
    site_id: str
    folder_path: str
    task_id: str
    student_id: str
    teacher_id: str
    filename: Optional[str] = None  # Optional, if not provided, will use task_id as filename
    content_html: str


# ===============================================================
# 6. GRADE MODELS
# ===============================================================
class GradeRequest(BaseModel):
    student_id: str
    task_id: str
    grade: int
    teacher_id: Optional[str] = None
    comments: Optional[str] = None



