from pydantic import BaseModel
from typing import List, Optional

class FAQItem(BaseModel):
    recordID: str
    question: str
    answer: str
    category: str
    subcategory: str

class FAQResponse(BaseModel):
    faqs: List[FAQItem]

class FAQFilter(BaseModel):
    user_type: Optional[str] = None