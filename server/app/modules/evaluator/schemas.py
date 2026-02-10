from pydantic import BaseModel, Field
from typing import List

class RubricCriterion(BaseModel):
    title: str
    description: str

class AssignmentValidationSchema(BaseModel):
    teacher_question: str = Field(..., example="Describe your idea of a perfect day.")
    student_submission: str = Field(..., example="My perfect day starts with...")
    student_fingerprint: str = Field(..., example="fingerprint123")
    rubric: List[RubricCriterion]
    thesis: List[RubricCriterion]