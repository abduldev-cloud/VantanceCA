from fastapi import APIRouter, HTTPException, Query
from app.modules.evaluator.services import AssignmentValidatorService

router = APIRouter(prefix="/llm-validate", tags=["LLM Grading Validation"])
validator_service = AssignmentValidatorService()

@router.post("/")
async def validate_assignment(learner_id: str = Query(...), task_id: str = Query(...)):
    try:
        return await validator_service.validate_assignment(learner_id, task_id)
    except HTTPException as e:
        raise e
