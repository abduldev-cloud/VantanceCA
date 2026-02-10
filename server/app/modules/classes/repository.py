import httpx
from app.common.crud_base import CRUDBase
from app.common.crud_helper import CRUDHelper
from app.core.config import settings
from app.modules.classes.schemas import CreateClassesSchema

class ClassesRepository:
    def __init__(self):
        self.BASE_URL = settings.ORACLE_DB_URL + "/teacher"
        self.crud = CRUDBase()
        self.crud_helper = CRUDHelper()

    async def create_classes(self, data: CreateClassesSchema) -> str:
        url = f"{self.BASE_URL}/create_class/"
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=data.model_dump())
            response.raise_for_status()
            response_data = response.json()

        if response_data.get("out_status") == "SUCCESS":
            return response_data.get("out_class_id")
        else:
            raise Exception(f"Failed to create class: {response_data}")
        
        
    def updateTeacherIdToClasses(self, teacher_id: str, class_ids: list) -> None:
        return self.crud_helper.update(
            "binary_success_classes",
            data={"teacher_id": teacher_id, "updated_at": "CURRENT_TIMESTAMP"},
            where={"class_id": {"$in": class_ids}}
        )

    #update class status
    def update_class_status_bulk(self, class_ids: list, status: str = "ACTIVE") -> None:
        if not class_ids:
            return

        # Generate placeholders for each class_id
        placeholders = ", ".join([f":id_{i}" for i in range(len(class_ids))])
        params = {f"id_{i}": cid for i, cid in enumerate(class_ids)}
        params["status"] = status.upper()

        query = f"""
            UPDATE binary_success_classes
            SET class_status_id = (
                SELECT status_id FROM binary_success_statuses WHERE UPPER(status_code) = :status
            ), updated_at = CURRENT_TIMESTAMP
            WHERE class_id IN ({placeholders})
        """
        self.crud.execute(query, params)

    def update_alfresco_class_id(self, class_id: str, alfresco_class_id: str) -> None:
        return self.crud_helper.update(
            table="binary_success_classes",
            data={"alfresco_class_id": alfresco_class_id},
            where={"class_id": class_id},
        )
    def update_lms_class_id(self, class_id: str, lms_class_id: str) -> None:
        return self.crud_helper.update(
            table="binary_success_classes",
            data={"lms_class_id": lms_class_id},
            where={"class_id": class_id},
        )
        
    #check if lms class already exits by lms_class_id
    def lms_class_exists(self, lms_class_id: str) -> bool:
        return bool(
            self.crud_helper.select_one(
                table="binary_success_classes",
                where={"lms_class_id": lms_class_id}
            )
        )
    
    #get class by lms_class_ids
    def get_classes_by_lms_ids(self, lms_class_ids: list) -> list:
        return self.crud_helper.select_all(
            table="binary_success_classes",
            where={"lms_class_id": {"$in": lms_class_ids}},
            columns=["class_id", "class_name", "teacher_id", "alfresco_class_id"]
        )
        
    def get_class_by_lms_id(self, lms_class_id: str) -> dict:
        return self.crud_helper.select_one(
            table="binary_success_classes",
            where={"lms_class_id": lms_class_id},
            columns=["class_id", "class_name", "teacher_id", "alfresco_class_id"]
        )

    # Get user id of all learners enrolled in a class using class_id and teacher_id with class name
    # Extract only if the class is active, and include only active users
    def get_learners_user_id_by_class_teacher(self, class_id: str, teacher_id: str) -> list:
        params = {"class_id": class_id, "teacher_id": teacher_id}
        query = f"""
            SELECT m.USER_ID, c.CLASS_NAME
            FROM BINARY_SUCCESS_ENROLLMENTS e
            JOIN BINARY_SUCCESS_STATUSES es ON es.STATUS_ID = e.STATUS_ID AND es.STATUS_CODE = 'ACTIVE'
            JOIN BINARY_SUCCESS_CLASSES c on e.CLASS_ID = c.CLASS_ID
            JOIN BINARY_SUCCESS_STATUSES cs ON cs.STATUS_ID = c.CLASS_STATUS_ID AND cs.STATUS_CODE = 'ACTIVE'
            JOIN BINARY_SUCCESS_USER_ROLE_MAPPING m ON m.ROLE_ENTITY_ID = e.LEARNER_ID
            JOIN BINARY_SUCCESS_PLATFORM_USERS u ON u.USER_ID = m.USER_ID
            JOIN BINARY_SUCCESS_STATUSES us ON us.STATUS_ID = u.STATUS_ID AND us.STATUS_CODE = 'ACTIVE'
            WHERE c.CLASS_ID = :class_id
                AND c.TEACHER_ID = :teacher_id
        """
        return self.crud.fetch_all(query, params)
