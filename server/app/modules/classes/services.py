from fastapi import HTTPException
from app.core.logger import logger
from app.modules.alfresco.schemas import CreateClassRequest
from app.modules.alfresco.services import AlfrescoService
from app.modules.classes.repository import ClassesRepository
from app.modules.keycloak.services import KeycloakService
from app.modules.classes.schemas import CreateClassesSchema, CreateKeycloakGroupSchema


class ClassesService:
    def __init__(self):
        self.keycloak_service = KeycloakService()
        self.classes_repository = ClassesRepository()
        self.alfresco_service = AlfrescoService()

    async def create_classes(self, schema: CreateClassesSchema):
        class_id = await self.classes_repository.create_classes(schema)
        if not class_id:
            raise HTTPException(status_code=500, detail="Failed to create class in DB")

        try:
            alfresco_result = self.alfresco_service.create_class(
                CreateClassRequest(class_name=schema.class_name)
            )
            if alfresco_result:
                alfresco_class_id = alfresco_result.get("class_id", "")
                # Remove "GROUP_" prefix if it exists, and update into DB
                self.classes_repository.update_alfresco_class_id(
                    class_id, alfresco_class_id.removeprefix("GROUP_")
                )
        except Exception as e:
            logger.error(f"Alfresco creation failed: {e}")
            raise HTTPException(
                status_code=500, detail=f"Failed to create group in Alfresco for class: {schema.class_name}."
            )

        try:
            await self.keycloak_service.create_group(
                CreateKeycloakGroupSchema(
                    institute_id=schema.institute_id,
                    class_id=class_id,
                    class_name=schema.class_name,
                    grade_name=schema.grade_name,
                )
            )
        except HTTPException as e:
            if e.status_code == 409:
                raise HTTPException(
                    status_code=409, detail="Group already exists in Keycloak"
                )
            raise
        except Exception as e:
            logger.error(f"Keycloak creation failed: {e}")
            raise HTTPException(
                status_code=500, detail="Failed to create Keycloak group"
            )

        return {
            "message": "Class successfully created",
            "class_id": class_id,
        }

    # Get user id of all learners enrolled in a class using class_id and teacher_id
    def get_learners_user_id_by_class_teacher(self, class_id: str, teacher_id: str):
        return self.classes_repository.get_learners_user_id_by_class_teacher(class_id, teacher_id)