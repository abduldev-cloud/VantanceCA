from fastapi import APIRouter, Query, HTTPException
from typing import Optional
from . import services, schemas

router = APIRouter(prefix="/faq", tags=["FAQ"])
faq_service = services.FAQService()


@router.get("/get-faqs", response_model=schemas.FAQResponse)
async def get_faqs(
        user_type: Optional[str] = Query(
            None,
            alias="user-type",
            description="Filter FAQs by user type (e.g., 'student', 'teacher')"
        )
):
    """
    Get FAQs filtered by user type.

    - **user-type**: Filter by category (e.g., 'student', 'teacher')
    - Returns all FAQs if no filter is provided
    """
    try:
        faqs = faq_service.get_filtered_faqs(user_type)

        return schemas.FAQResponse(faqs=faqs)

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching FAQs: {str(e)}"
        )