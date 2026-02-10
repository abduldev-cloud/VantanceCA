import httpx
from app.common.crud_helper import CRUDHelper
from app.core.config import settings
from app.modules.teacher.schemas import CreateTeacherSchema

class TeacherRepository:
    def __init__(self):
        self.BASE_URL = settings.ORACLE_DB_URL + "/teacher"
        self.crud_helper = CRUDHelper()

    async def create_teacher(self, data: CreateTeacherSchema) -> str:
        url = f"{self.BASE_URL}/create_teacher"
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=data.model_dump())
            response.raise_for_status()
            response_data = response.json()

        if response_data.get("out_status") == "SUCCESS":
            return response_data.get("out_teacher_id")
        else:
            raise Exception(f"Failed to create teacher: {response_data}")

    async def enroll_teachers(self, source: str, source_id: str, lms_teacher_id: str):
        url = f"{self.BASE_URL}/"
        params = {}
        if source == "staging":
            url += "import_teacher_enrollments/"
            params.update({"bulk_upload_id": source_id})
        else:
            url += "lms_teacher_enrollments/"
            params.update({"middleware_id": source_id})

        if lms_teacher_id:
            params.update({"lms_teacher_id": lms_teacher_id})

        async with httpx.AsyncClient() as client:
            response = await client.post(url, params=params)
            response.raise_for_status()
            response_data = response.json()

        if response_data.get("out_status") != "SUCCESS":
            raise Exception(f"Failed to enroll teacher: {response_data}")

        return response.json().get("enrollment_results")

        
    