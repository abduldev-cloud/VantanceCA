from pydantic import BaseModel

class CreateClassesSchema(BaseModel):
    institute_id: str
    class_name: str
    invite_code: str | None = None
    max_learners: int | None = None
    grade_name: str | None = None
    description: str | None = None
    term: str | None = None
    academic_year: int | None = None
    created_by: str
    teacher_id: str | None = None


class CreateKeycloakGroupSchema(BaseModel):
    institute_id: str
    class_id: str
    grade_name: str | None = None
    class_name: str
    