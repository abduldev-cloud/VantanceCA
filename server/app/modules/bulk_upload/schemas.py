from typing import Optional
from pydantic import BaseModel


# For BINARY_SUCCESS_STG_BULK_UPLOAD
class CreateBulkUpload(BaseModel):
    institute_id: str
    uploaded_by: str
    file_name: str


# For BINARY_SUCCESS_STG_BULK_UPLOAD_CLASSES
class CreateBulkUploadClass(BaseModel):
    bulk_upload_id: str
    class_id: Optional[str] = None
    class_name: Optional[str] = None
    term: Optional[str] = None
    grade: Optional[str] = None
    process_status: str = "PENDING"
    error_message: Optional[str] = None


# For BINARY_SUCCESS_STG_BULK_UPLOAD_TEACHERS
class CreateBulkUploadTeacher(BaseModel):
    bulk_upload_id: str
    teacher_id: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    process_status: str = "PENDING"
    error_message: Optional[str] = None


# For BINARY_SUCCESS_STG_BULK_UPLOAD_LEARNERS
class CreateBulkUploadLearner(BaseModel):
    bulk_upload_id: str
    learner_id: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    process_status: str = "PENDING"
    error_message: Optional[str] = None


# For BINARY_SUCCESS_STG_BULK_TEACHER_ENROLLMENTS
class CreateBulkTeacherEnrollment(BaseModel):
    bulk_upload_id: str
    class_id: Optional[str] = None
    teacher_id: Optional[str] = None
    email: Optional[str] = None
    process_status: str = "PENDING"
    error_message: Optional[str] = None


# For BINARY_SUCCESS_STG_BULK_LEARNER_ENROLLMENTS
class CreateBulkLearnerEnrollment(BaseModel):
    bulk_upload_id: str
    class_id: Optional[str] = None
    learner_id: Optional[str] = None
    email: Optional[str] = None
    process_status: str = "PENDING"
    error_message: Optional[str] = None


# For BINARY_SUCCESS_INTEGRATION_LOGS
class CreateIntegrationLog(BaseModel):
    message: Optional[str] = None
    bulk_upload_id: Optional[str] = None
