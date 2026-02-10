from pydantic import BaseModel
from typing import Optional, Dict, Any

class DeviationRequest(BaseModel):
    student_id: str
    task_id: str
    student_response: str

class DeviationResponse(BaseModel):
    deviationPercentage: int
    Reason: str

class SeedDataRequest(BaseModel):
    taskId: str
    learnerId: str
    teacherId: str


class SeedDataResponse(BaseModel):
    message: str
    sessionId: str
    taskId: str
    learnerId: str
    teacherId: str
    additionalInfo: Optional[Dict] = None

class SageAIChatRequest(BaseModel):
    sessionId: str
    question: str
    studentResponse: Optional[str] = ""


class SageAIChatResponse(BaseModel):
    status: int
    aiResponse: Optional[str]
    miscData: Optional[dict] = None
    infoMsg: Optional[Dict[str, Any]] = None 