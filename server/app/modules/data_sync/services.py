import httpx
from fastapi import HTTPException
import csv
import io

from app.common.utils import send_notification
from app.core.logger import logger
from app.modules.classes.repository import ClassesRepository
from app.modules.classes.schemas import CreateClassesSchema
from app.modules.classes.services import ClassesService
from app.modules.data_sync.repository import DataSyncRepository
from app.modules.keycloak.services import KeycloakService
from app.modules.learner.repository import LearnerRepository
from app.modules.teacher.repository import TeacherRepository
from app.modules.schools.repository import SchoolRepository
from app.modules.schools.services import SchoolsService
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import CreateUserInviteSchema, InvitePersona, InviteUserSchema
from app.modules.users.services import UsersService
from app.modules.alfresco.services import AlfrescoService
from app.modules.alfresco.schemas import AddStudentsToClassRequest
from app.modules.invitation.services import InvitationService

SOURCE_LABEL = {
    "staging": "Import",
    "middleware": "Sync"
}

ENTITY_CONFIG = {
    "staging": {
        "base_table": {
            "table": "binary_success_stg_bulk_upload",
            "id_column": "bulk_upload_id",
        },
        "classes": {
            "table": "binary_success_stg_bulk_upload_classes",
            "id_column": "class_id",
            "composite_id_column": "bulk_upload_id",
            "fields": ["class_name", "term", "grade", "class_id", "bulk_upload_id"],
            "extra_params": lambda row: {
                "term": row["term"],
                "grade_name": row["grade"]
            },
            "additional_filters": ["bulk_upload_id = :bulk_upload_id"]
        },
        "teachers": {
            "table": "binary_success_stg_bulk_upload_teachers",
            "id_column": "teacher_id",
            "composite_id_column": "bulk_upload_id",
            "fields": ["first_name", "last_name", "email", "teacher_id", "bulk_upload_id"],
            "additional_filters": ["bulk_upload_id = :bulk_upload_id"]
        },
        "students": {
            "table": "binary_success_stg_bulk_upload_learners",
            "id_column": "learner_id",
            "composite_id_column": "bulk_upload_id",
            "fields": ["first_name", "last_name", "email", "learner_id", "bulk_upload_id"],
            "additional_filters": ["bulk_upload_id = :bulk_upload_id"]
        },
        "learner_enrollments": {
            "table": "binary_success_stg_bulk_learner_enrollments",
            "id_column": "learner_id",
            "composite_id_column": "bulk_upload_id",
            "fields": ["learner_id", "class_id", "bulk_upload_id", "email"],
            "additional_filters": ["bulk_upload_id = :bulk_upload_id"]
        },
        "teacher_enrollments": {
            "table": "binary_success_stg_bulk_teacher_enrollments",
            "id_column": "teacher_id",
            "composite_id_column": "bulk_upload_id",
            "fields": ["teacher_id", "class_id", "bulk_upload_id", "email"],
            "additional_filters": ["bulk_upload_id = :bulk_upload_id"]
        }
    },
    "middleware": {
        "base_table": {
            "table": "binary_success_integrations",
            "id_column": "id",
        },
        "classes": {
            "table": "binary_success_middleware_classes",
            "id_column": "class_id",
            "composite_id_column": "middleware_id",
            "fields": ["class_name", "term", "class_id", "middleware_id", "status", "binary_success_id", "grade"],
            "extra_params": lambda row: {
                "term": row.get("term"),
                "grade_name": row["grade"]
            },
            "additional_filters": ["middleware_id = :middleware_id"],
            "sp_process_inactive": "LMS_PROCESS_INACTIVE_CLASSES"
        },
        "teachers": {
            "table": "binary_success_middleware_teachers",
            "id_column": "user_id",
            "composite_id_column": "middleware_id",
            "fields": ["first_name", "last_name", "email", "user_id", "middleware_id", "status"],
            "additional_filters": ["middleware_id = :middleware_id"],
            "sp_process_inactive": "LMS_PROCESS_INACTIVE_TEACHERS"
        },
        "students": {
            "table": "binary_success_middleware_students",
            "id_column": "user_id",
            "composite_id_column": "middleware_id",
            "fields": ["first_name", "last_name", "email", "user_id", "middleware_id", "status"],
            "additional_filters": ["middleware_id = :middleware_id"],
            "sp_process_inactive": "LMS_PROCESS_INACTIVE_STUDENTS"
        },
        "learner_enrollments": {
            "table": "binary_success_middleware_student_enrollments",
            "id_column": "student_id",
            "composite_id_column": "middleware_id",
            "fields": ["student_id", "class_id", "middleware_id", "status"],
            "additional_filters": ["middleware_id = :middleware_id"]
        },
        "teacher_enrollments": {
            "table": "binary_success_middleware_teacher_enrollments",
            "id_column": "teacher_id",
            "composite_id_column": "middleware_id",
            "fields": ["teacher_id", "class_id", "middleware_id", "status"],
            "additional_filters": ["middleware_id = :middleware_id"]
        }
    }
}


class DataSyncService:
    def __init__(self, source: str = "staging"):
        if source not in ENTITY_CONFIG:
            raise ValueError(f"Invalid source '{source}'. Must be one of {list(ENTITY_CONFIG.keys())}.")

        self.source = source
        self.label = SOURCE_LABEL[source]
        self.repo = DataSyncRepository()
        self.class_service = ClassesService()
        self.school_service = SchoolsService()
        self.user_service = UsersService()
        self.keycloak_service = KeycloakService()
        self.school_repository = SchoolRepository()
        self.class_repository = ClassesRepository()
        self.user_repository = UserRepository()
        self.learner_repository = LearnerRepository()
        self.teacher_repository = TeacherRepository()
        self.alfresco_service = AlfrescoService()
        self.invitation_service = InvitationService()
        self.source_id = None
        self.select_filter_values = None

    async def start_sync(self, institute_id: str, source_id: str = None):
        try:
            institute_details = self.school_service.get_school_admin_user_id(institute_id, True)
            if not institute_details:
                self.repo.insert_integration_log(f"Failed to {self.label} data. Institute admin not found.",
                                                 self.source,
                                                 self.source_id)
                raise HTTPException(status_code=404, detail="Institute admin not found")

            institute_admin_id = institute_details.get("admin_user_id")
            institute_name = institute_details.get("institute_name")
            self.source_id = source_id

            if self.source == "staging":
                self.select_filter_values = {"bulk_upload_id": self.source_id}
            elif self.source == "middleware" and source_id and source_id != "":
                self.select_filter_values = {"middleware_id": self.source_id}

            await self.safe_run(self.sync_classes, institute_id, institute_admin_id)
            await self.safe_run(self.sync_teachers, institute_id, institute_admin_id, institute_name)
            await self.safe_run(self.sync_students, institute_id, institute_admin_id, institute_name,
                                institute_details.get("admin_email"))
            await self.safe_run(self.sync_teacher_enrollments, institute_admin_id)
            await self.safe_run(self.sync_learner_enrollments, institute_admin_id)

            if self.source == "staging":
                # Check for PENDING items and update BINARY_SUCCESS_STG_BULK_UPLOAD accordingly
                self.update_bulk_upload_status(self.source_id)

        except Exception as outer_e:
            logger.exception(f"❌ {self.label} failed at top-level: {outer_e}")
            raise

    async def safe_run(self, func, *args):
        entity = ""
        try:
            entity = func.__name__.replace("sync_", "").replace("_", " ")
            self.repo.insert_integration_log(f"Processing pulled {entity} data from {self.label}.", self.source,
                                             self.source_id)
            await func(*args)
        except Exception as e:
            logger.exception(f"❌ {func.__name__} failed: {e}")
        finally:
            self.repo.insert_integration_log(f"Finished processing {entity} data.", self.source, self.source_id)

    async def sync_classes(self, institute_id, institute_admin_id):
        config = ENTITY_CONFIG[self.source]["classes"]
        table_name = config["table"]
        id_column = config["id_column"]
        composite_id_column = config["composite_id_column"]
        additional_filters = config.get("additional_filters", None)

        logger.info(f"Starting class {self.label} for {table_name} by admin {institute_admin_id}")

        class_data = self.repo.get_middleware_data(table_name, config["fields"], additional_filters,
                                                   self.select_filter_values)
        if not class_data:
            logger.info(f"No classes found for {self.label}.")
            return

        # Process active classes
        await self._process_active_classes(class_data, table_name, id_column, composite_id_column,
                                           additional_filters, institute_id, institute_admin_id, config)

        # Process inactive classes
        if self.source == "middleware":
            await self._process_inactive_classes(class_data, table_name, composite_id_column, config)

        await send_notification({
            "user_id": institute_admin_id,
            "title": f"{self.label} Completed",
            "message": f"Class {self.label} finished. Check integration logs for any failed items."
        })

        logger.info(f"Class {self.label} completed for institute {institute_id}")

    async def _process_active_classes(self, class_data, table_name, id_column, composite_id_column,
                                      additional_filters, institute_id, institute_admin_id, config):
        active_class_data = class_data if self.source == "staging" else [cls for cls in class_data if
                                                                         cls.get("status") == "ACTIVE"]
        for row in active_class_data:
            try:
                if not row.get("grade"):
                    self.repo.update_process_status(table_name, id_column, row[id_column], "FAILED",
                            error_message=f"Missing Grade. Failed to {self.label} class '{row['class_name']}'.",
                            additional_filters=additional_filters,
                            filter_values={composite_id_column: row[composite_id_column]})
                    continue

                params = {
                    "class_name": row["class_name"],
                    "institute_id": institute_id,
                    "created_by": institute_admin_id
                }
                if "extra_params" in config:
                    params.update(config["extra_params"](row))

                res = await self.class_service.create_classes(CreateClassesSchema(**params))

                if self.source == "middleware":
                    self.repo.update_middleware_binary_success_id(table_name, id_column, res.get("class_id"), row[id_column],
                                                           row[composite_id_column], "SUCCESS")
                elif self.source == "staging":
                    self.repo.update_process_status(table_name, id_column, row[id_column], "SUCCESS",
                                                    error_message=None, additional_filters=additional_filters,
                                                    filter_values={composite_id_column: row[composite_id_column]})
                self.class_repository.update_lms_class_id(res.get("class_id"), row["class_id"])
            except httpx.HTTPStatusError as e:
                if e.response.status_code == 409:
                    error_msg = f"Class '{row['class_name']}' already exists in LMS."
                else:
                    error_msg = f"Failed to create class '{row['class_name']}'."
                self._log_and_fail_in_db(table_name, id_column, composite_id_column, row, error_msg, e, additional_filters)
            except Exception as e:
                self._log_and_fail_in_db(table_name, id_column, composite_id_column, row,
                                         f"Failed to create class {row['class_name']}", e, additional_filters)

    async def _process_inactive_classes(self, class_data, table_name, composite_id_column, config):
        try:
            inactive_class_data = [cls for cls in class_data if cls.get("status") == "INACTIVE"]
            if inactive_class_data:
                # Update class groups in keycloas as archived
                class_ids = [str(cls.get("binary_success_id")) for cls in inactive_class_data if "binary_success_id" in cls]
                await self.keycloak_service.update_groups_status(class_ids, "archived")

                # Update class status to archived in Binary Success
                self.repo.process_inactive_entities(config["sp_process_inactive"], self.source_id)
        except Exception as e:
            logger.exception(f"Failed to process inactive classes: {e}")
            error_msg = f"Failed to process inactive classes: {str(e)}"
            self.repo.insert_integration_log(error_msg[:500], self.source, self.source_id)
            self.repo.update_inactive_status_to_fail(table_name, composite_id_column, self.source_id,
                                                         "Failed to process inactive classes.")

    async def sync_teachers(self, institute_id, institute_admin_id, institute_name):
        config = ENTITY_CONFIG[self.source]["teachers"]
        table_name = config["table"]
        id_column = config["id_column"]
        composite_id_column = config["composite_id_column"]
        additional_filters = config.get("additional_filters", None)

        logger.info(f"Starting teacher {self.label} for {table_name} by admin {institute_admin_id}")
        teacher_data = self.repo.get_middleware_data(table_name, config["fields"],
                                                     additional_filters=additional_filters,
                                                     filter_values=self.select_filter_values)
        if not teacher_data:
            logger.info(f"No teachers found for {self.label}.")
            return

        # Process active teachers
        await self._process_active_teachers(teacher_data, table_name, id_column, composite_id_column,
            additional_filters, institute_id, institute_admin_id, institute_name)

        # Process inactive teachers
        if self.source == "middleware":
            await self._process_inactive_teachers(teacher_data, table_name, id_column, composite_id_column,
                additional_filters, config["sp_process_inactive"])

        await send_notification({
            "user_id": institute_admin_id,
            "title": f"{self.label} Completed",
            "message": f"Teacher {self.label} process completed."
        })
        logger.info(f"Teacher {self.label} completed for institute {institute_id}")

    async def _process_active_teachers(self, teacher_data, table_name, id_column, composite_id_column,
            additional_filters, institute_id, institute_admin_id, institute_name):
        active_teachers = teacher_data if self.source == "staging" else [t for t in teacher_data if
                                                                         t.get("status") == "ACTIVE"]
        for row in active_teachers:
            try:
                # Validate if email is available
                if not row.get("email"):
                    self.repo.update_process_status(table_name, id_column, row[id_column], "FAILED",
                                                    error_message=f"Missing email. Failed to {self.label} teacher {row.get('first_name', '')} {row.get('last_name', '')}.",
                                                    additional_filters=additional_filters,
                                                    filter_values={composite_id_column: row[composite_id_column]})
                    continue

                additional_details = InviteUserSchema(
                    first_name=row.get("first_name"),
                    last_name=row.get("last_name"),
                    school_name=institute_name,
                    institute_id=institute_id,
                    invite_persona=InvitePersona.TEACHER,
                    teacher_name=f"{row.get('first_name', '')} {row.get('last_name', '')}".strip(),
                    source_user_id=row.get(id_column),
                    source_id=row[composite_id_column]
                )

                await self.user_service.invite_user(CreateUserInviteSchema(
                    email=row.get("email"),
                    role=InvitePersona.TEACHER,
                    created_by=institute_admin_id,
                    source=self.source,
                    additional_details=additional_details
                ))

                self.repo.update_process_status(table_name, id_column, row[id_column], "INVITED",
                                                additional_filters=additional_filters,
                                                filter_values={composite_id_column: row[composite_id_column]})

            except Exception as e:
                self._log_and_fail_in_db(table_name, id_column, composite_id_column, row,
                                         f"Failed to {self.label} teacher {row.get('first_name', '')} {row.get('last_name', '')}",
                                         e, additional_filters)

    async def _process_inactive_teachers(self, teacher_data, table_name, id_column, composite_id_column,
            additional_filters, sp_process_inactive):
        try:
            inactive_teachers = [t for t in teacher_data if t.get("status") == "INACTIVE"]
            for row in inactive_teachers:
                # Validate if email is available
                if not row.get("email"):
                    self.repo.update_process_status(table_name, id_column, row[id_column], "FAILED",
                                                    error_message=f"Missing email. Failed to {self.label} teacher {row.get('first_name', '')} {row.get('last_name', '')}.",
                                                    additional_filters=additional_filters,
                                                    filter_values={composite_id_column: row[composite_id_column]})
                    continue

            # Update teacher's enrolled classes to inactive in Key cloak in one go
            enrolled_classes = self.repo.get_teachers_enrolled_classes(self.source_id)
            class_ids = [str(cls.get("class_id")) for cls in enrolled_classes if "class_id" in cls]
            if class_ids:
                await self.keycloak_service.update_groups_status(class_ids, "inactive")

            # Update all inactive teachers to disabled in Key cloak in one go
            teacher_keycloak_ids = self.repo.get_keycloak_user_ids(table_name, self.source_id)
            keycloak_ids = [str(k.get("keycloak_user_id")) for k in teacher_keycloak_ids if "keycloak_user_id" in k]
            if teacher_keycloak_ids:
                await self.keycloak_service.update_user_status(keycloak_ids, status=False)

            # Update teacher and their classes to inactive in Binary Success
            self.repo.process_inactive_entities(sp_process_inactive, self.source_id)
        except Exception as e:
            logger.exception(f"Failed to process inactive teacher records: {e}")
            error_msg = f"Failed to process inactive teacher records.: {str(e)}"
            self.repo.insert_integration_log(error_msg[:500], self.source, self.source_id)
            self.repo.update_inactive_status_to_fail(table_name, composite_id_column, self.source_id, error_msg)

    async def sync_students(self, institute_id, institute_admin_id, institute_name, admin_email):
        config = ENTITY_CONFIG[self.source]["students"]
        table_name = config["table"]
        id_column = config["id_column"]
        composite_id_column = config["composite_id_column"]
        additional_filters = config.get("additional_filters", None)

        logger.info(f"Starting learner {self.label} for {table_name} by admin {institute_admin_id}")

        student_data = self.repo.get_middleware_data(table_name, config["fields"],
                                                     additional_filters=additional_filters,
                                                     filter_values=self.select_filter_values)
        if not student_data:
            logger.info(f"No learner found for {self.label}.")
            return
        
        # Process inactive students
        if self.source == "middleware":
            inactive_students = [s for s in student_data if s.get("status") == "INACTIVE"]
            if inactive_students:
                # Update students to disabled in Key cloak
                student_keycloak_ids = self.repo.get_keycloak_user_ids(table_name, self.source_id)
                keycloak_ids = [str(k.get("keycloak_user_id")) for k in student_keycloak_ids if "keycloak_user_id" in k]
                if keycloak_ids:
                    await self.keycloak_service.update_user_status(keycloak_ids, status=False)

                # Update student status to inactive in Binary Success
                self.repo.process_inactive_entities(config["sp_process_inactive"], self.source_id)

        # Process active students
        active_students = student_data if self.source == "staging" else [s for s in student_data if s.get("status") == "ACTIVE"]
        
        # Check for Bulk consent at school level
        consent_given = self.school_repository.checkBulkConsentApproved(institute_id)
        learner_data = []
        for row in active_students:
            if not consent_given and row["email"]:
                # Get first name, last name and email to save as CSV
                learner_data.append([row["first_name"], row["last_name"], row["email"]])
                continue

            await self._send_invite(
                row, institute_name, institute_id, institute_admin_id,
                table_name, id_column, composite_id_column, additional_filters
            )

        if not consent_given and learner_data and active_students:
            csv_file = io.StringIO()
            writer = csv.writer(csv_file)
            writer.writerow(["First Name", "Last Name", "Email"])  # header
            writer.writerows(learner_data)
            csv_file.seek(0)
            csv_bytes = csv_file.getvalue().encode()

            # Get Admin user name
            user_details = await self.user_repository.get_user_details_by_id(institute_admin_id)
            if not user_details:
                raise HTTPException(status_code=404, detail="Admin user details not found")
            admin_name = user_details["first_name"] + " " + user_details["last_name"]

            # Send email to school admin requesting consent to send email to learners
            await self.invitation_service.send_consent_req_email(admin_email, admin_name, self.source,
                                                                 active_students[0][composite_id_column], csv_bytes)

            self.repo.insert_integration_log(f"Consent request email sent to admin {admin_email} for institute {institute_id}.", self.source, active_students[0][composite_id_column])

            logger.info(f"Consent request email sent to admin {admin_email} for institute {institute_id}.")
            title = "Your consent required"
            message = "Provide concent to send invitation email to learners."
        else:
            title = f"{self.label} Completed"
            message = f"Learner {self.label} finished. Check logs for any failed items."

        await send_notification({
            "user_id": institute_admin_id,
            "title": title,
            "message": message
        })

        logger.info(f"Learner {self.label} completed for institute {institute_id}")

    async def sync_teacher_enrollments(self, institute_admin_id):
        config = ENTITY_CONFIG[self.source]["teacher_enrollments"]
        table_name = config["table"]
        id_column = config["id_column"]
        composite_id_column = config["composite_id_column"]
        additional_filters = config.get("additional_filters", None)

        logger.info(f"Starting teacher enrollments {self.label} for {table_name} by admin {institute_admin_id}")

        enrolled_classes = await self.teacher_repository.enroll_teachers(self.source, self.source_id, None)
        if not enrolled_classes:
            logger.info(f"No teacher enrollments found for {self.label}.")
            return

        # Process ACTIVE teacher enrollments
        active_enrollments = [enr for enr in enrolled_classes if enr.get("process_status") == "PENDING" and enr.get("enrollment_status") == "ACTIVE"]
        await self.process_teacher_enrollments(active_enrollments, action="add", table_name=table_name,
                                            id_column=id_column, composite_id_column=composite_id_column,
                                            additional_filters=additional_filters)

        # Process INACTIVE teacher enrollments
        inactive_enrollments = [enr for enr in enrolled_classes if enr.get("process_status") == "PENDING" and enr.get("enrollment_status") == "INACTIVE"]
        await self.process_teacher_enrollments(inactive_enrollments, action="remove", table_name=table_name,
                                            id_column=id_column, composite_id_column=composite_id_column,
                                            additional_filters=additional_filters)

        # Notify admin
        await send_notification({
            "user_id": institute_admin_id,
            "title": f"{self.label} Enrollment Completed",
            "message": f"Teacher {self.label} Enrollment finished. Check integration logs for any failed items."
        })

    async def process_teacher_enrollments(self, enrolled_classes, action, table_name, id_column, composite_id_column, additional_filters):
        unique_teacher_ids = {row.get(id_column) for row in enrolled_classes if row.get(id_column)}
        for lms_teacher_id in unique_teacher_ids:
            try:
                teacher_rows = [row for row in enrolled_classes if row.get(id_column) == lms_teacher_id]
                keycloak_failed, class_names, user_id, row = await self.process_keycloak_groups(
                    teacher_rows, action, table_name, id_column, composite_id_column, additional_filters)

                await send_notification({
                    "user_id": user_id,
                    "title": f"You have been {'added to' if action=='add' else 'removed from'} classes",
                    "message": f"You have been {'added to' if action=='add' else 'removed from'} classes: " + ", ".join(class_names),
                })

                if not keycloak_failed:
                    self.repo.update_process_status(
                        table_name, id_column, row[id_column], "SUCCESS",
                        additional_filters=additional_filters,
                        filter_values={composite_id_column: row[composite_id_column]}
                    )

            except Exception as e:
                self._log_and_fail_in_db(table_name, id_column, composite_id_column, row,
                                         f"Failed to {self.label} enrollments for teacher: {lms_teacher_id}",
                                         e, additional_filters)
                
    async def sync_learner_enrollments(self, institute_admin_id):
        config = ENTITY_CONFIG[self.source]["learner_enrollments"]
        table_name = config["table"]
        id_column = config["id_column"]
        composite_id_column = config["composite_id_column"]
        additional_filters = config.get("additional_filters", None)

        logger.info(f"Starting learner enrollments {self.label} for {table_name} by admin {institute_admin_id}")

        enrolled_classes = await self.learner_repository.enroll_learners(self.source, self.source_id, None)
        if not enrolled_classes:
            logger.info(f"No learner enrollments found for {self.label}.")
            return

        # Process ACTIVE learner enrollments
        active_enrollments = [enr for enr in enrolled_classes if enr.get("process_status") == "PENDING" and enr.get("enrollment_status") == "ACTIVE"]
        await self.process_learner_enrollments(active_enrollments, action="add", table_name=table_name,
                                            id_column=id_column, composite_id_column=composite_id_column,
                                            additional_filters=additional_filters)

        # Process INACTIVE learner enrollments
        inactive_enrollments = [enr for enr in enrolled_classes if enr.get("process_status") == "PENDING" and enr.get("enrollment_status") == "INACTIVE"]
        await self.process_learner_enrollments(inactive_enrollments, action="remove", table_name=table_name,
                                            id_column=id_column, composite_id_column=composite_id_column,
                                            additional_filters=additional_filters)

        # Notify admin
        await send_notification({
            "user_id": institute_admin_id,
            "title": f"{self.label} Enrollment Completed",
            "message": f"Learner {self.label} Enrollment finished. Check integration logs for any failed items."
        })

    async def process_learner_enrollments(self, enrolled_classes, action, table_name, id_column, composite_id_column, additional_filters):
        unique_learner_ids = {row.get(id_column) for row in enrolled_classes if row.get(id_column)}

        for lms_learner_id in unique_learner_ids:
            try:
                learner_rows = [row for row in enrolled_classes if row.get(id_column) == lms_learner_id]
                # Add learner to each class in Alfresco one by one
                alfresco_success = True
                if action == "add":
                    for lr in learner_rows:
                        alfresco_class_id = lr.get("alfresco_class_id")
                        alfresco_user_id = lr.get("alfresco_user_id")
                        class_name = lr.get("class_name")

                        if alfresco_class_id and alfresco_user_id:
                            try:
                                self.alfresco_service.add_students_to_class(AddStudentsToClassRequest(
                                    class_id=alfresco_class_id,
                                    students=[alfresco_user_id]
                                ))
                                logger.info(f"Successfully added student {lms_learner_id} in Alfresco group: {class_name}")
                            except Exception as e:
                                self._log_and_fail_in_db(table_name, id_column, composite_id_column, lr,
                                                         f"Failed to add student {lms_learner_id} in Alfresco group: {class_name}",
                                                         e, additional_filters)
                                alfresco_success = False
                                break  # move to next learner

                if not alfresco_success:
                    continue 
                
                # Add learner to all classes in Keycloak at once
                keycloak_failed, class_names, user_id, row = await self.process_keycloak_groups(
                learner_rows, action, table_name, id_column, composite_id_column, additional_filters)

                # Send notification
                await send_notification({
                    "user_id": user_id,
                    "title": f"You have been {'added to' if action=='add' else 'removed from'} classes",
                    "message": f"You have been {'added to' if action=='add' else 'removed from'} classes: " + ", ".join(class_names),
                })

                if not keycloak_failed:
                    self.repo.update_process_status(
                        table_name, id_column, lms_learner_id, "SUCCESS",
                        additional_filters=additional_filters,
                        filter_values={composite_id_column: row[composite_id_column]}
                    )
            except Exception as e:
                self._log_and_fail_in_db(table_name, id_column, composite_id_column, row,
                                         f"Failed to {self.label} enrollments for learner '{lms_learner_id}'",
                                         e, additional_filters)

    async def process_email_invite_consent_to_learners(self, response: str, source_id: str):
        if self.source not in SOURCE_LABEL:
            raise HTTPException(status_code=400, detail="Invalid invite source.")

        base_config = ENTITY_CONFIG[self.source]["base_table"]
        institute_details = self.repo.get_institute_details_by_source_id(
            base_config["table"], base_config["id_column"], source_id
        )
        if not institute_details:
            raise HTTPException(status_code=404, detail="Institute not found")

        self.repo.insert_integration_log(f"Processing school admin consent response: {response}.",
                                         self.source, source_id)

        if response == "disagree":
            await self._handle_consent_disagree(institute_details, source_id)
        else:
            await self._handle_consent_agree(institute_details, source_id)

    async def _handle_consent_disagree(self, institute_details, source_id):
        config = ENTITY_CONFIG[self.source]["students"]
        table_name = config["table"]
        composite_id_column = config["composite_id_column"]

        self.repo.update_process_status(
            table_name,
            composite_id_column,
            source_id,
            "CONSENT REJECTED",
            additional_filters=["PROCESS_STATUS = :status_pending"],
            filter_values={"status_pending": "PENDING"}
        )
        label = SOURCE_LABEL[self.source]
        self.repo.insert_integration_log(
            f"{label} - Consent not given to send email to Learners for institute {institute_details['institute_id']}",
            self.source, source_id
        )
        logger.info(
            f"{label} - Consent not given to send email to Learners for institute {institute_details['institute_id']}")

    async def _handle_consent_agree(self, institute_details, source_id):
        config = ENTITY_CONFIG[self.source]["students"]
        table_name = config["table"]
        id_column = config["id_column"]
        composite_id_column = config["composite_id_column"]
        additional_filters = config.get("additional_filters")

        select_filter_values = {}
        if self.source == "staging":
            select_filter_values = {"bulk_upload_id": source_id}
        elif self.source == "middleware":
            select_filter_values = {"middleware_id": source_id}

        student_data = self.repo.get_middleware_data(
            table_name, config["fields"], additional_filters=additional_filters,
            filter_values=select_filter_values
        )

        for row in student_data:
            await self._send_invite(
                row, institute_details["institute_name"], institute_details["institute_id"],
                institute_details["admin_user_id"], table_name, id_column, composite_id_column, additional_filters
            )

        label = SOURCE_LABEL[self.source]
        await send_notification({
            "user_id": institute_details["admin_user_id"],
            "title": f"Learner {label} Completed",
            "message": f"{label} - Invitation sent for Learners. Check integration logs for any failed items."
        })
        self.repo.insert_integration_log(
            f"Finished processing school admin consent response.", self.source, source_id
        )
        logger.info(f"{label} - Invitation sent for Learners for institute {institute_details['institute_id']}")

    async def _send_invite(self, row, institute_name, institute_id, created_by, table_name, id_column,
                           composite_id_column, additional_filters=None):
        try:
            if not row.get("email"):
                self.repo.update_process_status(
                    table_name, id_column, row[id_column], "FAILED",
                    error_message=f"Missing email. Failed to {self.label} learner {row.get('first_name', '')} {row.get('last_name', '')}.",
                    additional_filters=additional_filters,
                    filter_values={composite_id_column: row[composite_id_column]}
                )
                return

            additional_details = InviteUserSchema(
                first_name=row["first_name"],
                last_name=row["last_name"],
                school_name=institute_name,
                institute_id=institute_id,
                invite_persona=InvitePersona.LEARNER,
                source_user_id=row[id_column],
                source_id=row[composite_id_column]
            )

            await self.user_service.invite_user(CreateUserInviteSchema(
                email=row["email"],
                role=InvitePersona.LEARNER,
                created_by=created_by,
                source=self.source,
                additional_details=additional_details
            ), True)

            self.repo.update_process_status(
                table_name, id_column, row[id_column], "INVITED",
                additional_filters=additional_filters,
                filter_values={composite_id_column: row[composite_id_column]}
            )

        except Exception as e:
            self._log_and_fail_in_db(table_name, id_column, composite_id_column, row,
                                     f"Failed to {self.label} learner {row['first_name']} {row['last_name']}",
                                     e, additional_filters)
    
    async def process_keycloak_groups(
        self, enrollment_rows, action: str, table_name: str, id_column: str, composite_id_column: str, additional_filters=None
    ):
        row = enrollment_rows[0]
        user_id = row.get(id_column)
        keycloak_user_id = row.get("keycloak_user_id")
        class_ids = [r["class_id"] for r in enrollment_rows]
        class_names = [r["class_name"] for r in enrollment_rows]

        keycloak_failed = False
        if keycloak_user_id and class_ids:
            try:
                if action == "add":
                    await self.keycloak_service.add_user_to_groups(keycloak_user_id, class_ids)
                else:
                    await self.keycloak_service.remove_user_from_groups(keycloak_user_id, class_ids)
            except Exception as e:
                keycloak_failed = True
                self._log_and_fail_in_db(table_name, id_column, composite_id_column, row,
                                     f"Failed to {action} classes in Keycloak for {user_id}",
                                     e, additional_filters)

        return keycloak_failed, class_names, user_id, row

    def _log_and_fail_in_db(self, table_name, id_column, composite_id_column, row, error_msg, e: Exception = None, additional_filters=None):
        full_error_msg = f"{error_msg}: {e}" if e else error_msg
        logger.exception(full_error_msg)
        self.repo.insert_integration_log(full_error_msg[:500], self.source, row.get(composite_id_column))
        self.repo.update_process_status(
            table_name, id_column, row.get(id_column), "FAILED",
            error_message=error_msg + ".",
            additional_filters=additional_filters,
            filter_values={composite_id_column: row.get(composite_id_column)}
        )

    # Update the Bulk Upload Status in BINARY_SUCCESS_STG_BULK_UPLOAD
    def update_bulk_upload_status(self, bulk_upload_id: str):
        if not bulk_upload_id:
            raise ValueError("bulk_upload_id is required")

        # Call the repository method that executes the stored procedure
        self.repo.update_bulk_upload_status(bulk_upload_id)
