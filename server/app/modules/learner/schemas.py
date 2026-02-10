from app.modules.users.schemas import CreateUserSchema


class CreateLearnerSchema(CreateUserSchema):
    institute_id: str
    source: str
    source_id: str
    lms_entity_id: str
