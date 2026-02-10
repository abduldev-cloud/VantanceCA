import httpx
from app.common.crud_base import CRUDBase
from app.common.crud_helper import CRUDHelper
from app.core.config import settings
from app.modules.learner.schemas import CreateLearnerSchema


class LearnerRepository:
    def __init__(self):
        self.BASE_URL = settings.ORACLE_DB_URL + "/learner"
        self.crud = CRUDBase()
        self.crud_helper = CRUDHelper()

    async def create_learner(self, data: CreateLearnerSchema) -> str:
        url = f"{self.BASE_URL}/create_learner"
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=data.model_dump())
            response.raise_for_status()
            response_data = response.json()

        if response_data.get("out_status") == "SUCCESS":
            return response_data.get("out_learner_id")
        else:
            raise Exception(f"Failed to create learner: {response_data}")

    async def enroll_learners(self, source: str, source_id: str, lms_learner_id: str):
        url = f"{self.BASE_URL}/"
        params = {}
        if source == "staging":
            url += "import_learner_enrollments/"
            params.update({"bulk_upload_id": source_id})
            learner_key = "lms_learner_id"
        else:
            url += "lms_learner_enrollments/"
            params.update({"middleware_id": source_id})
            learner_key = "lms_user_id"

        if lms_learner_id:
            params.update({learner_key: lms_learner_id})

        async with httpx.AsyncClient() as client:
            response = await client.post(url, params=params)
            response.raise_for_status()
            response_data = response.json()

        if response_data.get("out_status") != "SUCCESS":
            raise Exception(f"Failed to enroll learner: {response_data}")

        return response.json().get("enrollment_results")
