"""
Mock AI Services
Provides writing fingerprint analysis and AI chat without external LLM
"""

from fastapi import HTTPException
from app.core.logger import logger
from app.common.crud_base import CRUDBase
from app.modules.ai.schemas import (
    DeviationRequest, DeviationResponse,
    SeedDataRequest, SeedDataResponse,
    SageAIChatRequest, SageAIChatResponse
)
from datetime import datetime
import random

crud = CRUDBase()


class DeviationService:
    """Mock service for writing fingerprint deviation analysis"""
    
    async def analyze(self, req: DeviationRequest) -> DeviationResponse:
        """
        Analyze writing deviation between fingerprint and submission
        Returns mock deviation percentage
        """
        try:
            logger.info(f"📊 Analyzing deviation - learner: {req.learner_id}, task: {req.task_id}")
            
            # Get existing deviation if already calculated
            check_query = """
                SELECT deviation_percentage
                FROM BINARY_SUCCESS_LEARNER_TASKS
                WHERE learner_id = :learner_id AND task_id = :task_id
            """
            
            existing = crud.fetch_one(check_query, {
                "learner_id": req.learner_id,
                "task_id": req.task_id
            })
            
            if existing and existing.get('deviation_percentage'):
                deviation = float(existing['deviation_percentage'])
                logger.info(f"✅ Using existing deviation: {deviation}%")
            else:
                # Generate realistic mock deviation (30-60% range)
                deviation = round(random.uniform(30, 60), 2)
                
                # Update the learner task with deviation
                update_query = """
                    UPDATE BINARY_SUCCESS_LEARNER_TASKS
                    SET deviation_percentage = :deviation
                    WHERE learner_id = :learner_id AND task_id = :task_id
                """
                crud.execute(update_query, {
                    "deviation": str(deviation),
                    "learner_id": req.learner_id,
                    "task_id": req.task_id
                })
                
                logger.info(f"✅ Generated new deviation: {deviation}%")
            
            # Determine if deviation is acceptable (< 50% is good)
            is_acceptable = deviation < 50
            
            return DeviationResponse(
                success=True,
                deviation_percentage=deviation,
                is_acceptable=is_acceptable,
                message=f"Deviation analysis complete: {deviation}%",
                analysis_details={
                    "vocabulary_consistency": round(random.uniform(60, 95), 2),
                    "sentence_structure_match": round(random.uniform(65, 90), 2),
                    "writing_style_similarity": round(random.uniform(55, 85), 2),
                    "overall_deviation": deviation
                }
            )
            
        except Exception as e:
            logger.error(f"❌ Error analyzing deviation: {e}")
            raise HTTPException(status_code=500, detail=f"Failed to analyze deviation: {str(e)}")
    
    async def process_seed_data(self, request: SeedDataRequest) -> SeedDataResponse:
        """
        Process seed writing fingerprint data
        Stores initial writing sample for future comparison
        """
        try:
            logger.info(f"🌱 Processing seed data - learner: {request.learner_id}")
            
            # Check if fingerprint already exists
            check_query = """
                SELECT fingerprint_id
                FROM BINARY_SUCCESS_WRITING_FINGERPRINTS
                WHERE learner_id = :learner_id
                LIMIT 1
            """
            
            existing = crud.fetch_one(check_query, {"learner_id": request.learner_id})
            
            if existing:
                return SeedDataResponse(
                    success=True,
                    message="Writing fingerprint already exists",
                    fingerprint_id=existing['fingerprint_id']
                )
            
            # Create new fingerprint
            import uuid
            fingerprint_id = f"fp-{uuid.uuid4().hex[:12]}"
            
            # Analyze the seed text
            analysis_data = {
                "vocabulary_richness": round(random.uniform(0.5, 0.9), 2),
                "avg_sentence_length": random.randint(12, 25),
                "complexity_score": round(random.uniform(0.4, 0.8), 2),
                "common_phrases": ["in my opinion", "I think", "it is important"],
                "writing_level": random.choice(["beginner", "intermediate", "advanced"])
            }
            
            insert_query = """
                INSERT INTO BINARY_SUCCESS_WRITING_FINGERPRINTS
                (fingerprint_id, learner_id, deviation_percentage, analysis_data, created_at)
                VALUES (:fingerprint_id, :learner_id, :deviation, :analysis_data, :created_at)
            """
            
            crud.execute(insert_query, {
                "fingerprint_id": fingerprint_id,
                "learner_id": request.learner_id,
                "deviation": 0.0,  # Baseline
                "analysis_data": str(analysis_data),
                "created_at": datetime.now()
            })
            
            logger.info(f"✅ Seed data processed: {fingerprint_id}")
            
            return SeedDataResponse(
                success=True,
                message="Writing fingerprint created successfully",
                fingerprint_id=fingerprint_id,
                analysis=analysis_data
            )
            
        except Exception as e:
            logger.error(f"❌ Error processing seed data: {e}")
            raise HTTPException(status_code=500, detail=f"Failed to process seed data: {str(e)}")
    
    def process_chat(self, payload: SageAIChatRequest) -> SageAIChatResponse:
        """
        Process AI chat request
        Returns mock AI responses for writing assistance
        """
        try:
            logger.info(f"💬 Processing AI chat - type: {payload.message_type}")
            
            # Generate response based on message type
            responses = {
                "grammar": "I've checked your grammar. Here are some suggestions:\n- Consider using more varied sentence structures\n- Watch for subject-verb agreement\n- Good use of punctuation overall!",
                "paraphrase": "Here's a rephrased version of your text:\n\n" + self._generate_paraphrase(payload.message),
                "expand": "To expand on this idea, consider:\n- Adding specific examples\n- Explaining the significance\n- Connecting to your main argument\n- Providing evidence or quotes",
                "summarize": "Here's a concise summary:\n\n" + self._generate_summary(payload.message),
                "general": "That's a great question! " + self._generate_general_response(payload.message)
            }
            
            response_text = responses.get(payload.message_type, responses["general"])
            
            return SageAIChatResponse(
                success=True,
                response=response_text,
                message_type=payload.message_type,
                timestamp=datetime.now().isoformat()
            )
            
        except Exception as e:
            logger.error(f"❌ Error processing chat: {e}")
            return SageAIChatResponse(
                success=False,
                response="I'm sorry, I encountered an error processing your request.",
                message_type=payload.message_type,
                timestamp=datetime.now().isoformat()
            )
    
    def _generate_paraphrase(self, text: str) -> str:
        """Generate a mock paraphrased version"""
        if len(text) < 50:
            return "The concept can be expressed differently while maintaining the same meaning."
        return "This idea can be articulated in an alternative manner, preserving the core message while varying the expression."
    
    def _generate_summary(self, text: str) -> str:
        """Generate a mock summary"""
        return "The main point emphasizes the importance of clear communication and thoughtful analysis in academic writing."
    
    def _generate_general_response(self, message: str) -> str:
        """Generate a general AI response"""
        responses = [
            "Let me help you think through this. Consider breaking it down into smaller parts.",
            "That's an interesting perspective. Have you thought about how this connects to your main argument?",
            "Good question! Try approaching it from a different angle to see new insights.",
            "I can help with that. Let's explore the key concepts together."
        ]
        return random.choice(responses)
