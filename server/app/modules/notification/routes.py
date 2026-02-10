from fastapi import APIRouter, Query
from typing import Literal

from app.modules.notification.services import NotificationService

router = APIRouter(prefix="/notification", tags=["Notification"])
notification_service = NotificationService()


@router.post("/notify_all_learners_in_class")
async def notify_all_learners_in_class(class_id: str = Query(...), teacher_id: str = Query(...),
                                task_type: Literal["Assignment", "Fingerprint"] = Query(...)):
    return await notification_service.notify_all_learners_in_class(class_id, teacher_id, task_type)
