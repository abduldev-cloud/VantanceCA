from fastapi import HTTPException
from app.common.crud_helper import CRUDHelper
from app.common.utils import send_notification
from app.core.logger import logger
from app.modules.alfresco.schemas import CreateStudentsRequest, StudentCreateInfo, AddStudentsToClassRequest
from app.modules.alfresco.services import AlfrescoService
from app.modules.classes.repository import ClassesRepository
from app.modules.data_sync.repository import DataSyncRepository
from app.modules.keycloak.services import KeycloakService
from app.modules.learner.repository import LearnerRepository
from app.modules.schools.repository import SchoolRepository
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import InviteSource, InviteUserSchema
from app.modules.learner.schemas import CreateLearnerSchema


class LearnerService:
    def __init__(self):
        self.learner_repository = LearnerRepository()
        self.classes_repository = ClassesRepository()
        self.keycloak_service = KeycloakService()
        self.crud_helper = CRUDHelper()
        self.data_sync_repo = DataSyncRepository()
        self.alfresco_service = AlfrescoService()
        self.school_repo = SchoolRepository()
        self.user_repo = UserRepository()

    async def create_learner(
            self,
            schema: CreateLearnerSchema,
            additional_details: InviteUserSchema,
            source: InviteSource
    ) -> str:
        config = {}
        source_config = {}
        try:
            # source → mapping of table names + where keys
            source_config = {
                InviteSource.MIDDLEWARE: {
                    "enrollment_table": "binary_success_middleware_student_enrollments",
                    "update_table": "binary_success_middleware_students",
                    "where_keys_update": {
                        "user_id": additional_details.source_user_id,
                        "middleware_id": additional_details.source_id,
                    },
                    "where_keys_enrollment": {
                        "student_id": additional_details.source_user_id,
                        "middleware_id": additional_details.source_id,
                    },
                },
                InviteSource.STAGING: {
                    "enrollment_table": "binary_success_stg_bulk_learner_enrollments",
                    "update_table": "binary_success_stg_bulk_upload_learners",
                    "where_keys_update": {
                        "learner_id": additional_details.source_user_id,
                        "bulk_upload_id": additional_details.source_id,
                    },
                    "where_keys_enrollment": {
                        "learner_id": additional_details.source_user_id,
                        "bulk_upload_id": additional_details.source_id,
                    },
                },
            }

            if source not in source_config:
                raise HTTPException(status_code=400, detail="Invalid invite source.")
            config = source_config[source]

            institute_details = self.school_repo.get_institute_admin(additional_details.institute_id,
                                                                     with_alfresco_site_id=True)
            if not institute_details:
                raise HTTPException(status_code=404, detail="Institute not found")

            alfresco_site_id = institute_details.get("alfresco_site_id")
            if not alfresco_site_id:
                raise HTTPException(status_code=400, detail="Institute is not linked with Alfresco")

            try:
                # Create Learner in DB with entry in BINARY_SUCCESS_PLATFORM_USERS
                learner_id = await self.learner_repository.create_learner(schema)
                logger.info(f"Learner {learner_id} created.")
                self.data_sync_repo.insert_integration_log(f"Learner {learner_id} created.", source, additional_details.source_id)

                # Create an account in Alfresco for the Learner
                alfresco_user_id = f"{schema.email}{learner_id}"
                alfresco_student = self.alfresco_service.create_students(CreateStudentsRequest(
                    site_id=alfresco_site_id,
                    students=[
                        StudentCreateInfo(
                            user_id=alfresco_user_id,
                            email=schema.email,
                            first_name=schema.first_name,
                            last_name=schema.last_name,
                            password=alfresco_user_id,
                        )
                    ]
                ))
                if not alfresco_student:
                    logger.error(f"Failed to create student in Alfresco: {learner_id}")
                    raise HTTPException(status_code=500, detail="Failed to create student in Alfresco")
                logger.info(f"Successfully created student in Alfresco: {learner_id}")

                # update the Alfresco User Id for the learner in binary_success_user_role_mapping table
                self.user_repo.update_alfresco_id(schema.keycloak_user_id, alfresco_user_id)
                self.data_sync_repo.insert_integration_log(f"Successfully created student in Alfresco: {learner_id}", source,
                                                           additional_details.source_id)

                if source == InviteSource.MANUAL:
                    return learner_id

                self.crud_helper.update(
                    table=config["update_table"],
                    data={"process_status": "SUCCESS",
                          "updated_at": "CURRENT_TIMESTAMP", },
                    where=config["where_keys_update"]
                )
            except Exception as e:
                logger.exception("Failed to create student in Alfresco")
                self.data_sync_repo.insert_integration_log(f"Learner created in BINARY_SUCCESS but failed to create it in "
                                                           f"Alfresco: {str(e)}", source, additional_details.source_id)
                if source != InviteSource.MANUAL:
                    self.crud_helper.update(
                        table=config["update_table"],
                        data={
                            "process_status": "FAILED",
                            "error_message": f"Learner created in BINARY_SUCCESS but failed to create it in Alfresco.",
                            "updated_at": "CURRENT_TIMESTAMP",
                        },
                        where=config["where_keys_update"]
                    )
                raise HTTPException(status_code=500, detail="Failed to create student in Alfresco")

            # Start processing class enrollements for the learner
            enrolled_classes = await self.learner_repository.enroll_learners(source, additional_details.source_id,
                                                                       additional_details.source_user_id)
            if not enrolled_classes:
                logger.info(f"No learner enrollments found for {source}.")
                self.data_sync_repo.insert_integration_log(f"No learner enrollments found for {source}.", source,
                                                           additional_details.source_id)
                return

            enrolled_classes_success = [enrollment for enrollment in enrolled_classes
                                        if enrollment.get("process_status") == "PENDING"]

            lms_class_ids = [str(cls["class_id"]) if isinstance(cls["class_id"], tuple) else cls["class_id"]
                             for cls in enrolled_classes_success]

            key_cloack_error = None
            class_ids = []
            user_id = None
            class_names = []
            if lms_class_ids:
                # Map LMS class IDs → Binary Success class IDs
                class_ids = [str(cls["class_id"]) if isinstance(cls["class_id"], tuple) else cls["class_id"]
                             for cls in enrolled_classes_success]
                class_names = [str(cls["class_name"]) if isinstance(cls["class_name"], tuple) else cls["class_name"]
                               for cls in enrolled_classes_success]
                alfresco_class_ids = [str(cls["alfresco_class_id"]) if isinstance(cls["alfresco_class_id"], tuple)
                                      else cls["alfresco_class_id"] for cls in enrolled_classes_success]

                # Add Student to Class (Group) in Alfresco
                if alfresco_class_ids:
                    for cls in alfresco_class_ids:
                        self.alfresco_service.add_students_to_class(AddStudentsToClassRequest(
                            class_id=cls,
                            students=[alfresco_user_id]
                        ))
                    logger.info(f"Successfully added student {learner_id} in Alfresco groups:" + ", ".join(class_names))

                if class_ids:
                    # Get User ID of the learner
                    user_id = enrolled_classes_success[0].get("user_id")

                    # Add learner to Keycloak groups + update status
                    try:
                        await self.keycloak_service.add_user_to_groups(schema.keycloak_user_id, class_ids)
                    except Exception as e:
                        self.data_sync_repo.insert_integration_log(
                            f"Failed to add class in Keycloack for learner: {learner_id}: {str(e)}", source,
                            additional_details.source_id)
                        key_cloack_error = f"Failed to add class in Keycloack for learner: {learner_id}."

            if not lms_class_ids or not class_ids:
                logger.warning(f"No class enrollments found for learner {learner_id}")

            # Update process status of leanrner to class enrollment
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
                logger.info(f"Notification sent to learner {learner_id} with user id {user_id}.")

                logger.info(f"Successfully completed enrollments for learner {learner_id}.")
                self.data_sync_repo.insert_integration_log(f"Successfully completed enrollments for learner {learner_id}.",
                                                       source, additional_details.source_id)
            return learner_id

        except Exception as e:
            logger.exception("Failed to create learner" + (f" from source {source}" if source else "") + str(e))
            self.data_sync_repo.insert_integration_log(f"Failed to create/enroll learner: {str(e)}", source,
                                                       additional_details.source_id)
            if source != InviteSource.MANUAL:
                self.crud_helper.update(
                    table=config["update_table"],
                    data={
                        "process_status": "FAILED",
                        "error_message": "Failed to create learner.",
                        "updated_at": "CURRENT_TIMESTAMP"
                    },
                    where=config["where_keys_update"],
                )
            raise HTTPException(status_code=500, detail=f"Failed to create learner: {str(e)}")
        finally:
            # Update the Bulk Upload Status in BINARY_SUCCESS_STG_BULK_UPLOAD if source is staging
            if source == InviteSource.STAGING and additional_details:
                self.data_sync_repo.update_bulk_upload_status(additional_details.source_id)
                logger.info("Upload Status in BINARY_SUCCESS_STG_BULK_UPLOAD is updated.")
