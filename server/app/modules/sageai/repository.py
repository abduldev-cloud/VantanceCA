from datetime import datetime
from app.common.crud_base import CRUDBase
from app.core.logger import logger
from app.modules.sageai.schemas import SaveAIPromptRequest

class AIRepository:
    def __init__(self):
        self.crud = CRUDBase()

    def save_prompt_and_response(self, data: SaveAIPromptRequest):
        try:
            # Step 1: Check if usage entry exists
            select_query = """
                SELECT AI_USAGE_ID AS ai_usage_id, USED_COUNT FROM ADMIN.BINARY_SUCCESS_AI_USAGE_STATS
                WHERE TASK_ID = :task_id AND LEARNER_ID = :learner_id
                FETCH FIRST 1 ROWS ONLY
            """
            usage_entry = self.crud.fetch_one(select_query, {
                "task_id": data.task_id,
                "learner_id": data.learner_id
            })

            if usage_entry:
                used_count = usage_entry.get("used_count") or 0
                if used_count >= 5:
                    return {"error": "Your limit exceeds", "code": 403}

                ai_usage_id = usage_entry.get("ai_usage_id")
                update_query = """
                    UPDATE ADMIN.BINARY_SUCCESS_AI_USAGE_STATS
                    SET USED_COUNT = USED_COUNT + 1, LAST_USED = :now
                    WHERE AI_USAGE_ID = :ai_usage_id
                """
                self.crud.execute(update_query, {
                    "now": datetime.utcnow(),
                    "ai_usage_id": ai_usage_id
                })
            else:
                # First time usage – create a new usage entry
                insert_usage_query = """
                    INSERT INTO ADMIN.BINARY_SUCCESS_AI_USAGE_STATS (
                        TASK_ID, LEARNER_ID, USED_COUNT, LAST_USED
                    ) VALUES (
                        :task_id, :learner_id, 1, :now
                    )
                """
                self.crud.execute(insert_usage_query, {
                    "task_id": data.task_id,
                    "learner_id": data.learner_id,
                    "now": datetime.utcnow()
                })

                # Re-fetch to get the new AI_USAGE_ID
                usage_entry = self.crud.fetch_one(select_query, {
                    "task_id": data.task_id,
                    "learner_id": data.learner_id
                })
                ai_usage_id = usage_entry.get("ai_usage_id")

                if not ai_usage_id:
                    raise ValueError("Failed to retrieve AI_USAGE_ID after insert")

            # Step 2: Insert prompt and response
            insert_prompt_query = """
                INSERT INTO ADMIN.BINARY_SUCCESS_AI_PROMPTS (
                    AI_USAGE_ID, PROMPT_TEXT, AI_RESPONSE, CREATED_AT
                ) VALUES (
                    :ai_usage_id, :prompt_text, :ai_response, :created_at
                )
            """
            self.crud.execute(insert_prompt_query, {
                "ai_usage_id": ai_usage_id,
                "prompt_text": data.prompt_text,
                "ai_response": data.ai_response,
                "created_at": datetime.utcnow()
            })

            return {"message": "Saved successfully", "ai_usage_id": ai_usage_id}

        except Exception as e:
            logger.error("Failed to save AI prompt/response: %s", str(e))
            raise
    
    def fetch_usage(self, learner_id: str, task_id: str):
        query = """
            SELECT USED_COUNT FROM ADMIN.BINARY_SUCCESS_AI_USAGE_STATS
            WHERE LEARNER_ID = :learner_id AND TASK_ID = :task_id
            FETCH FIRST 1 ROWS ONLY
        """
        result = self.crud.fetch_one(query, {
            "learner_id": learner_id,
            "task_id": task_id
        })
        return result or {"used_count": 0}