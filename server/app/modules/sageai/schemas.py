from pydantic import BaseModel, Field

class SaveAIPromptRequest(BaseModel):
    learner_id: str
    task_id: str
    prompt_text: str
    ai_response: str

class AIUsageQuery(BaseModel):
    learner_id: str = Field(..., example="abc123")
    task_id: str = Field(..., example="xyz456")


class AIUsageResponse(BaseModel):
    learner_id: str
    task_id: str
    used_count: int = Field(..., example=3)
    limit_reached: bool = Field(..., example=False)
