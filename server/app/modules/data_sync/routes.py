import asyncio
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field
from app.modules.data_sync.services import DataSyncService

router = APIRouter(prefix="/sync", tags=["Data Sync"])


class StartSyncRequest(BaseModel):
    institute_id: str = Field(..., description="Institute ID to run the sync/import for")
    source: str = Field(..., description="Source of data. Use 'staging' for import or 'middleware' for sync")
    source_id: str = Field(..., description="Bulk ID for Import or Middleware ID for sync")


@router.post("/start")
async def start_sync(request: StartSyncRequest):
    try:
        service = DataSyncService(source=request.source)
        asyncio.create_task(service.start_sync(request.institute_id, request.source_id))
        return {"message": f"{service.label} started in background"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/consent-from-admin/{response}")
async def consent_from_admin(response: str, source: str = Query(...), source_id: str = Query(...),):
    try:
        service = DataSyncService(source=source)
        await service.process_email_invite_consent_to_learners(response, source_id)

        return {"message": "Consent response from the school admin has been processed."}
    except HTTPException as e:
        raise e
