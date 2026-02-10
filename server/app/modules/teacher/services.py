from fastapi import HTTPException
from app.common.crud_helper import CRUDHelper
from app.common.utils import send_notification
from app.core.logger import logger
from app.modules.alfresco.schemas import TeacherCreateRequest
from app.modules.alfresco.services import AlfrescoService
from app.modules.classes.repository import ClassesRepository
from app.modules.data_sync.repository import DataSyncRepository
from app.modules.keycloak.services import KeycloakService
from app.modules.schools.repository import SchoolRepository
from app.modules.teacher.repository import TeacherRepository
from app.modules.teacher.schemas import CreateTeacherSchema
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import InviteSource, InviteUserSchema


class TeacherService:
    def __init__(self):
        self.teacher_repository = TeacherRepository()
        self.classes_repository = ClassesRepository()
        self.keycloak_service = KeycloakService()
        self.crud_helper = CRUDHelper()
        self.data_sync_repo = DataSyncRepository()
        self.school_repo = SchoolRepository()
        self.alfresco_service = AlfrescoService()
        self.user_repo = UserRepository()

    async def create_teacher(
            self,
            schema: CreateTeacherSchema,
            additional_details: InviteUserSchema,
            source: InviteSource
    ) -> str:
        config = {}
        source_config = {}

        try:
            source_config = {
                InviteSource.MIDDLEWARE: {
                    "enrollment_table": "binary_success_middleware_teacher_enrollments",
                    "update_table": "binary_success_middleware_teachers",
                    "where_keys_update": {
                        "user_id": additional_details.source_user_id,
                        "middleware_id": additional_details.source_id,
                    },
                    "where_keys_enrollment": {
                        "teacher_id": additional_details.source_user_id,
                        "middleware_id": additional_details.source_id,
                    },
                },
                InviteSource.STAGING: {
                    "enrollment_table": "binary_success_stg_bulk_teacher_enrollments",
                    "update_table": "binary_success_stg_bulk_upload_teachers",
                    "where_keys_update": {
                        "teacher_id": additional_details.source_user_id,
                        "bulk_upload_id": additional_details.source_id,
                    },
                    "where_keys_enrollment": {
                        "teacher_id": additional_details.source_user_id,
                        "bulk_upload_id": additional_details.source_id,
                    },
                },
            }

            if source not in source_config:
                raise HTTPException(status_code=400, detail="Invalid invite source.")
            config = source_config[source]

            institute_details = self.school_repo.get_institute_admin(additional_details.institute_id, with_alfresco_site_id=True)
            if not institute_details:
                raise HTTPException(status_code=404, detail="Institute not found")

            alfresco_site_id = institute_details.get("alfresco_site_id")
            if not alfresco_site_id:
                raise HTTPException(status_code=400, detail="Institute is not linked with Alfresco")

            try:
                # Create Teacher in DB with entry in BINARY_SUCCESS_PLATFORM_USERS
                teacher_id = await self.teacher_repository.create_teacher(schema)
                logger.info(f"Teacher {teacher_id} created.")
                self.data_sync_repo.insert_integration_log(f"Teacher {teacher_id} created.", source, additional_details.source_id)

                # Create an account in Alfresco for the Teacher
                alfresco_user_id = f"{schema.email}{teacher_id}"
                alfresco_teacher = self.alfresco_service.create_teacher(TeacherCreateRequest(
                    site_id=alfresco_site_id,
                    username=alfresco_user_id,
                    email=schema.email,
                    first_name=schema.first_name,
                    last_name=schema.last_name,
                    password=alfresco_user_id,
                ))
                if not alfresco_teacher:
                    logger.error(f"Failed to create teacher in Alfresco: {teacher_id}")
                    raise HTTPException(status_code=500, detail="Failed to create teacher in Alfresco")
                logger.info(f"Successfully created teacher account in Alfresco: {teacher_id}")
                self.data_sync_repo.insert_integration_log(f"Successfully created teacher account in Alfresco: {teacher_id}", source,
                                                           additional_details.source_id)

                # update the Alfresco User Id for the teacher in binary_success_user_role_mapping table
                self.user_repo.update_alfresco_id(schema.keycloak_user_id, alfresco_user_id)

                if source == InviteSource.MANUAL:
                    return teacher_id

                self.crud_helper.update(
                    table=config["update_table"],
                    data={"process_status": "SUCCESS",
                          "updated_at": "CURRENT_TIMESTAMP", },
                    where=config["where_keys_update"]
                )
            except Exception as e:
                logger.exception("Failed to create teacher in Alfresco")
                self.data_sync_repo.insert_integration_log(f"Teacher created in BINARY_SUCCESS but failed to create it in "
                                                           f"Alfresco: {str(e)}", source, additional_details.source_id)
                if source != InviteSource.MANUAL:
                    self.crud_helper.update(
                        table=config["update_table"],
                        data={
                            "process_status": "FAILED",
                            "error_message": f"Teacher created in BINARY_SUCCESS but failed to create it in Alfresco: {str(e)}",
                            "updated_at": "CURRENT_TIMESTAMP",
                        },
                        where=config["where_keys_update"]
                    )
                # Failure in teacher creation process, so no enrollment to classes
                raise HTTPException(status_code=500, detail="Failed to create teacher in Alfresco")

            # Start processing class enrollements for the teacher
            enrolled_classes = await self.teacher_repository.enroll_teachers(source, additional_details.source_id,
                                                                             additional_details.source_user_id)
            if not enrolled_classes:
                logger.warning(f"No class enrollments found for teacher {teacher_id}")
                self.data_sync_repo.insert_integration_log(f"No class enrollments found for teacher {teacher_id}", source,
                                                           additional_details.source_id)

            enrolled_classes_success = [enrollment for enrollment in enrolled_classes
                                        if enrollment.get("process_status") == "PENDING"]

            lms_class_ids = [str(cls["class_id"]) if isinstance(cls["class_id"], tuple) else cls["class_id"]
                             for cls in enrolled_classes_success]

            if lms_class_ids:
                # Map LMS class IDs → Binary success class IDs
                class_ids = [str(cls["class_id"]) if isinstance(cls["class_id"], tuple) else cls["class_id"]
                             for cls in enrolled_classes_success]
                class_names = [str(cls["class_name"]) if isinstance(cls["class_name"], tuple) else cls["class_name"]
                             for cls in enrolled_classes_success]

                if class_ids:
                    # Get User ID of the teacher
                    user_id = enrolled_classes_success[0].get("user_id")

                    # Add teacher to Keycloak groups + update status
                    key_cloack_error = None
                    try:
                        await self.keycloak_service.add_user_to_groups(schema.keycloak_user_id, class_ids)
                    except Exception as e:
                        self.data_sync_repo.insert_integration_log(
                            f"Failed to add class in Keycloack for teacher: {teacher_id}: {str(e)}", source,
                            additional_details.source_id)
                        key_cloack_error = f"Failed to add class in Keycloack for teacher: {teacher_id}."

                    # Update process status of teacher to class enrollment
                    self.crud_helper.update(
                        table=config["enrollment_table"],
                        data={"process_status": "SUCCESS" if not key_cloack_error else "FAILED",
                              "error_message": key_cloack_error,
                              "updated_at": "CURRENT_TIMESTAMP"},
                        where=config["where_keys_enrollment"],
                    )
                    if not key_cloack_error and user_id:
                        # Send notification
                        await send_notification({
                            "user_id": user_id,
                            "title": "You have been added to classes",
                            "message": "You have been added to classes: " + ", ".join(class_names),
                        })
                        logger.info(f"Notification sent to teacher {teacher_id} with user id {user_id}.")

                        logger.info(f"Successfully completed enrollments for teacher {teacher_id}.")
                        self.data_sync_repo.insert_integration_log(f"Successfully completed enrollments for teacher {teacher_id}.",
                                                           source, additional_details.source_id)
            return teacher_id

        except Exception as e:
            logger.exception("Failed to create teacher" + (f" from source {source}" if source else "") + str(e))
            self.data_sync_repo.insert_integration_log(f"Failed to create/enroll teacher: {str(e)}", source,
                                                       additional_details.source_id)
            if source != InviteSource.MANUAL and config:
                self.crud_helper.update(
                    table=config["update_table"],
                    data={
                        "process_status": "FAILED",
                        "error_message": f"Failed to create teacher: {str(e)}",
                        "updated_at": "CURRENT_TIMESTAMP"
                    },
                    where=config["where_keys_update"],
                )
            raise HTTPException(status_code=500, detail=f"Failed to create teacher: {str(e)}")
        finally:
            # Update the Bulk Upload Status in BINARY_SUCCESS_STG_BULK_UPLOAD if source is staging
            if source == InviteSource.STAGING and additional_details:
                self.data_sync_repo.update_bulk_upload_status(additional_details.source_id)
                logger.info("Upload Status in BINARY_SUCCESS_STG_BULK_UPLOAD is updated.")
