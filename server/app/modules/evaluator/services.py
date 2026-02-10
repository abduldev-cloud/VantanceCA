"""
Mock Assignment Evaluator Service
Provides realistic grading and feedback without external LLM dependency
"""

from fastapi import HTTPException
from app.core.logger import logger
from app.common.crud_base import CRUDBase
from datetime import datetime
import random

crud = CRUDBase()


class AssignmentValidatorService:
    """Mock service for validating and grading assignments"""
    
    async def validate_assignment(self, learner_id: str, task_id: str):
        """
        Validate and grade an assignment submission
        Returns mock grading results with realistic scores and feedback
        """
        try:
            logger.info(f"🎓 Grading assignment - learner: {learner_id}, task: {task_id}")
            
            # Get the learner task submission
            submission_query = """
                SELECT 
                    lt.*,
                    tt.task_title,
                    tt.task_description,
                    tt.max_score,
                    ttype.task_type,
                    u.first_name,
                    u.last_name
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                JOIN BINARY_SUCCESS_LEARNERS l ON lt.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                WHERE lt.learner_id = :learner_id AND lt.task_id = :task_id
            """
            
            submission = crud.fetch_one(submission_query, {
                "learner_id": learner_id,
                "task_id": task_id
            })
            
            if not submission:
                raise HTTPException(status_code=404, detail="Submission not found")
            
            # Check if already graded
            if submission.get('score') is not None:
                logger.info(f"✅ Assignment already graded: {submission.get('score')}")
                return {
                    "success": True,
                    "message": "Assignment already graded",
                    "data": {
                        "score": float(submission.get('score', 0)),
                        "max_score": float(submission.get('max_score', 100)),
                        "feedback": submission.get('feedback', ''),
                        "deviation_percentage": submission.get('deviation_percentage'),
                        "graded_at": submission.get('graded_at')
                    }
                }
            
            # Generate realistic mock grade
            task_type = submission.get('task_type', 'ASSIGNMENT')
            submission_text = submission.get('submission_text', '')
            
            # Calculate mock score based on submission length and type
            score, feedback, deviation = self._generate_mock_grade(
                task_type, 
                submission_text,
                float(submission.get('max_score', 100))
            )
            
            # Get graded status ID
            graded_status = crud.fetch_one(
                "SELECT status_id FROM BINARY_SUCCESS_TASK_STATUSES WHERE status = 'GRADED'"
            )
            graded_status_id = graded_status['status_id'] if graded_status else None
            
            # Update the submission with grade
            update_query = """
                UPDATE BINARY_SUCCESS_LEARNER_TASKS
                SET score = :score,
                    feedback = :feedback,
                    deviation_percentage = :deviation,
                    status_id = :status_id,
                    graded_at = :graded_at
                WHERE learner_task_id = :learner_task_id
            """
            
            crud.execute(update_query, {
                "score": score,
                "feedback": feedback,
                "deviation": str(deviation),
                "status_id": graded_status_id,
                "graded_at": datetime.now(),
                "learner_task_id": submission['learner_task_id']
            })
            
            logger.info(f"✅ Assignment graded successfully: {score}/{submission.get('max_score')}")
            
            return {
                "success": True,
                "message": "Assignment graded successfully",
                "data": {
                    "score": score,
                    "max_score": float(submission.get('max_score', 100)),
                    "feedback": feedback,
                    "deviation_percentage": deviation,
                    "graded_at": datetime.now().isoformat(),
                    "student_name": f"{submission.get('first_name')} {submission.get('last_name')}",
                    "task_title": submission.get('task_title')
                }
            }
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error grading assignment: {e}")
            raise HTTPException(status_code=500, detail=f"Failed to grade assignment: {str(e)}")
    
    def _generate_mock_grade(self, task_type: str, submission_text: str, max_score: float):
        """Generate realistic mock grade based on submission"""
        
        # Base score on submission length
        text_length = len(submission_text) if submission_text else 0
        
        if text_length == 0:
            return 0.0, "No submission provided.", 0.0
        
        # Calculate base score (70-95% range for realistic grading)
        if text_length < 50:
            base_score = random.uniform(60, 75)
            quality = "brief"
        elif text_length < 200:
            base_score = random.uniform(70, 85)
            quality = "adequate"
        elif text_length < 500:
            base_score = random.uniform(80, 92)
            quality = "good"
        else:
            base_score = random.uniform(85, 98)
            quality = "excellent"
        
        score = round((base_score / 100) * max_score, 2)
        
        # Generate feedback based on task type
        if task_type == 'FINGERPRINT':
            deviation = round(random.uniform(35, 55), 2)
            feedback = self._generate_fingerprint_feedback(quality, deviation)
        elif task_type == 'ESSAY':
            deviation = round(random.uniform(30, 50), 2)
            feedback = self._generate_essay_feedback(quality, score, max_score)
        elif task_type == 'QUIZ':
            deviation = 0.0
            feedback = self._generate_quiz_feedback(score, max_score)
        else:
            deviation = round(random.uniform(35, 50), 2)
            feedback = self._generate_general_feedback(quality, score, max_score)
        
        return score, feedback, deviation
    
    def _generate_fingerprint_feedback(self, quality: str, deviation: float):
        """Generate feedback for writing fingerprint analysis"""
        feedback_templates = {
            "excellent": f"Excellent writing sample! Your writing shows strong consistency with a deviation of {deviation}%. Your vocabulary and sentence structure are well-developed.",
            "good": f"Good writing sample. Deviation of {deviation}% indicates consistent writing patterns. Consider varying your sentence structure more.",
            "adequate": f"Adequate writing sample with {deviation}% deviation. Work on developing more complex sentence structures and expanding vocabulary.",
            "brief": f"Brief submission with {deviation}% deviation. Please provide a more substantial writing sample for accurate analysis."
        }
        return feedback_templates.get(quality, "Writing sample received.")
    
    def _generate_essay_feedback(self, quality: str, score: float, max_score: float):
        """Generate feedback for essay assignments"""
        percentage = (score / max_score) * 100
        
        feedback_templates = {
            "excellent": f"Outstanding work! ({percentage:.0f}%) Your essay demonstrates strong analytical skills, clear organization, and effective use of evidence. The introduction engages the reader, and your conclusion effectively synthesizes your arguments.",
            "good": f"Good effort! ({percentage:.0f}%) Your essay shows solid understanding of the topic with clear arguments. Consider strengthening your thesis statement and providing more specific examples to support your points.",
            "adequate": f"Satisfactory work ({percentage:.0f}%). Your essay addresses the prompt but could benefit from deeper analysis. Work on developing stronger topic sentences and smoother transitions between paragraphs.",
            "brief": f"Needs improvement ({percentage:.0f}%). Your essay is too brief and lacks sufficient development. Expand your arguments with more detailed examples and analysis."
        }
        return feedback_templates.get(quality, f"Score: {score}/{max_score}")
    
    def _generate_quiz_feedback(self, score: float, max_score: float):
        """Generate feedback for quiz assignments"""
        percentage = (score / max_score) * 100
        
        if percentage >= 90:
            return f"Excellent work! ({percentage:.0f}%) You demonstrated strong mastery of the material."
        elif percentage >= 80:
            return f"Good job! ({percentage:.0f}%) You showed solid understanding with minor areas for review."
        elif percentage >= 70:
            return f"Satisfactory ({percentage:.0f}%). Review the questions you missed and study those concepts."
        else:
            return f"Needs improvement ({percentage:.0f}%). Please review the material and see me for additional help."
    
    def _generate_general_feedback(self, quality: str, score: float, max_score: float):
        """Generate general feedback for other assignment types"""
        percentage = (score / max_score) * 100
        
        feedback_templates = {
            "excellent": f"Excellent work! ({percentage:.0f}%) You exceeded expectations and demonstrated thorough understanding.",
            "good": f"Good job! ({percentage:.0f}%) Solid work with room for minor improvements.",
            "adequate": f"Satisfactory ({percentage:.0f}%). Meets basic requirements but could be stronger.",
            "brief": f"Needs more development ({percentage:.0f}%). Please expand your response."
        }
        return feedback_templates.get(quality, f"Score: {score}/{max_score}")
