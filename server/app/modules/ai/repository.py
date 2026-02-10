from app.common.crud_base import CRUDBase


class DeviationRepository:
    def __init__(self):
        self.crud = CRUDBase()

    async def get_student_grade_info(self, learner_id: str):
        query = """
        SELECT DISTINCT
            l.first_name, l.last_name, g.grade_name
        FROM binary_success_teacher_tasks t
        JOIN binary_success_learner_tasks lt ON t.task_id = lt.task_id
        JOIN binary_success_learners l ON lt.learner_id = l.learner_id
        JOIN binary_success_classes c ON t.class_id = c.class_id
        JOIN binary_success_grade_levels g ON c.grade_level_id = g.grade_level_id
        WHERE l.learner_id = :learner_id
        """
        return self.crud.fetch_all(query, {"learner_id": learner_id})

    async def get_teacher_details(self, learner_id: str, task_id: str):
        query = """
        SELECT T.PROMPT AS task_prompt
        FROM BINARY_SUCCESS_TEACHER_TASKS T
        JOIN BINARY_SUCCESS_LEARNER_TASKS LT ON LT.TASK_ID = T.TASK_ID
        WHERE LT.LEARNER_ID = :learner_id
        AND T.TASK_ID = :task_id
        """
        rows = self.crud.fetch_all(query, {"learner_id": learner_id, "task_id": task_id})
        print(rows)
        if rows:
            prompt_lob = rows[0]["task_prompt"]   # ✅ use dict key
            return prompt_lob.read() if hasattr(prompt_lob, "read") else str(prompt_lob)
        return ""


    async def save_deviation_result(self, student_id, task_id, deviation_data, session_id):
        query = """
        UPDATE BINARY_SUCCESS_LEARNER_TASKS
        SET DEVIATION_PERCENTAGE = :deviationPercentage,
            DEVIATION_REASON = :Reason,
            LLM_SESSION_ID = :session_id
        WHERE LEARNER_ID = :learner_id
          AND TASK_ID = :task_id
        """
        params = {
            "deviationPercentage": deviation_data.get("deviationPercentage"),
            "Reason": deviation_data.get("Reason"),
            "session_id": session_id,
            "learner_id": student_id,
            "task_id": task_id,
        }
        self.crud.execute(query, params)

    async def get_llm_session_id(self, learner_id, task_id):
        query = """
        SELECT LLM_SESSION_ID 
        FROM BINARY_SUCCESS_LEARNER_TASKS 
        WHERE LEARNER_ID = :learner_id AND TASK_ID = :task_id
        """
        rows = self.crud.fetch_all(query, {"learner_id": learner_id, "task_id": task_id})
        return rows[0][0] if rows else None

    async def clear_llm_session_id(self, learner_id, task_id):
        query = """
        UPDATE BINARY_SUCCESS_LEARNER_TASKS
        SET LLM_SESSION_ID = NULL
        WHERE LEARNER_ID = :learner_id AND TASK_ID = :task_id
        """
        self.crud.execute(query, {"learner_id": learner_id, "task_id": task_id})

    async def update_llm_session(self, learner_id: str, task_id: str, session_id: str):
        query = """
        UPDATE BINARY_SUCCESS_LEARNER_TASKS 
        SET LLM_SESSION_ID = :session_id
        WHERE LEARNER_ID = :learner_id AND TASK_ID = :task_id
        """
        rowcount = self.crud.execute(
            query, {"session_id": session_id, "learner_id": learner_id, "task_id": task_id}
        )
        if rowcount == 0:
            return {"status": 400, "message": "No record updated"}
        return {"status": 200, "message": "Session updated"}

    def get_task_by_session(self, session_id: str):
        query = """
        SELECT LEARNER_ID, TASK_ID
        FROM BINARY_SUCCESS_LEARNER_TASKS
        WHERE LLM_SESSION_ID = :session_id
        """
        rows = self.crud.fetch_all(query, {"session_id": session_id})
        if not rows:
            return None

        # Assuming fetch_all returns a list of tuples
        learner_id, task_id = rows[0]
        return {"LEARNER_ID": learner_id, "TASK_ID": task_id}
