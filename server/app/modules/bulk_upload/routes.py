from fastapi import APIRouter, HTTPException, Query
from app.modules.bulk_upload.services import BulkUploadService

router = APIRouter(prefix="/bulk_upload", tags=["Bulk-upload"])
bulk_upload_service = BulkUploadService()


@router.post("/")
async def upload_data_from_file(institute_id: str = Query(...), institute_admin_user_id: str = Query(...),
                                alfresco_site_id: str = Query(...), file_name: str = Query(...)):
    try:
        return await bulk_upload_service.upload_data_from_file(institute_id, institute_admin_user_id, alfresco_site_id,
                                                               file_name)
    except HTTPException as e:
        raise e
