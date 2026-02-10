from fastapi import APIRouter, HTTPException, Body, Form

from app.modules.schools.services import SchoolsService


router = APIRouter(prefix="/schools", tags=["Schools"])

schools_service = SchoolsService()

# @router.post("/", )
# async def create_school(client_id: str = Form(...)):
#     try:
#         return await schools_service.create_school(client_id)
#     except HTTPException as e:
#         raise e
    
@router.put("/{institute_id}/bulk_consent")
async def update_bulk_consent(institute_id: str, bulk_consent_given: bool):
    try:
        return await schools_service.update_bulk_consent(institute_id, bulk_consent_given)
    except HTTPException as e:
        raise e