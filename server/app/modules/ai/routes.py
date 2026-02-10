from fastapi import APIRouter, Depends
from app.modules.ai.schemas import DeviationRequest, DeviationResponse, SeedDataRequest, SeedDataResponse, SageAIChatRequest, SageAIChatResponse
from app.modules.ai.services import DeviationService

router = APIRouter(prefix="/ai", tags=["AI"])
service = DeviationService()
@router.post("/get_student_deviation_analysis", response_model=DeviationResponse)
async def get_student_deviation_analysis(req: DeviationRequest):
    return await service.analyze(req)

@router.post("/seed-data", response_model=SeedDataResponse)
async def seed_data(request: SeedDataRequest):
    
    return await service.process_seed_data(request)

@router.post("/sage-ai-chat", response_model=SageAIChatResponse)
async def sage_ai_chat(payload: SageAIChatRequest):
    return service.process_chat(payload)