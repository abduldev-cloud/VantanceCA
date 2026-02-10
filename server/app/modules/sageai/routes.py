from fastapi import APIRouter, Query
from app.modules.sageai.schemas import SaveAIPromptRequest, AIUsageResponse
from app.modules.sageai.services import AIService, AIUsageService

router = APIRouter(prefix="/sage-ai", tags=["Sage AI"])

ai_service = AIService()
usage_service = AIUsageService()

@router.get("/usage", response_model=AIUsageResponse)
def get_ai_usage(learner_id: str = Query(...), task_id: str = Query(...)):
    return usage_service.get_usage_count(learner_id, task_id)

@router.post("/save-chat")
def save_ai_interaction(data: SaveAIPromptRequest):
    return ai_service.save_prompt_and_response(data)

