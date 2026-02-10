import asyncio
from fastapi import HTTPException

from app.common.utils import send_notification
from app.modules.classes.services import ClassesService


class NotificationService:
    def __init__(self):
        self.class_service = ClassesService()

    async def notify_all_learners_in_class(self, class_id: str, teacher_id: str, task_type: str):
        try:
            # Get all active learner user IDs and class name (if active)
            learners_user_id = self.class_service.get_learners_user_id_by_class_teacher(class_id, teacher_id)
            if not learners_user_id:
                raise HTTPException(status_code=404,
                                    detail=f"No learners found for the provided class {class_id} and teacher {teacher_id}.")

            # Send notifications concurrently
            tasks = [
                send_notification({
                    "user_id": learner["user_id"],
                    "title": "You Have a New Task",
                    "message": f"A new {task_type} has been assigned to you for class {learner['class_name']}."
                })
                for learner in learners_user_id
            ]
            await asyncio.gather(*tasks)

            return {
                "message": "Successfully sent notifications to all learners in the class."
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to send notifications: {str(e)}")