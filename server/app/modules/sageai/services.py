"""
Mock SageAI Service
Provides AI chat assistance without external LLM dependency
"""

from app.core.logger import logger
from app.common.crud_base import CRUDBase
from app.modules.sageai.schemas import SaveAIPromptRequest, AIUsageResponse
from datetime import datetime
import random

crud = CRUDBase()


class AIUsageService:
    """Track AI usage statistics"""
    
    def get_usage_count(self, learner_id: str, task_id: str) -> AIUsageResponse:
        """Get AI usage count for a learner's task"""
        try:
            query = """
                SELECT 
                    IFNULL(SUM(used_count), 0) as total_used
                FROM BINARY_SUCCESS_AI_USAGE_STATS
                WHERE learner_id = :learner_id AND task_id = :task_id
            """
            
            result = crud.fetch_one(query, {
                "learner_id": learner_id,
                "task_id": task_id
            })
            
            used_count = int(result.get('total_used', 0)) if result else 0
            
            return AIUsageResponse(
                success=True,
                used_count=used_count,
                message=f"AI usage count retrieved: {used_count}"
            )
            
        except Exception as e:
            logger.error(f"Error getting AI usage: {e}")
            return AIUsageResponse(
                success=False,
                used_count=0,
                message=f"Failed to get usage count: {str(e)}"
            )


class AIService:
    """Mock AI chat and writing assistance service"""
    
    def __init__(self):
        self.crud = CRUDBase()
        
        # Mock AI responses for different prompt types
        self.response_templates = {
            "grammar_check": [
                "I've reviewed your text. Here are some suggestions:\n- Consider using more varied sentence structures\n- Check subject-verb agreement in paragraph 2\n- Great use of transition words!",
                "Your grammar looks good overall! A few minor suggestions:\n- Watch out for comma splices\n- Consider breaking up that long sentence in the third paragraph",
                "Nice work! Just a couple of things:\n- 'Their' should be 'there' in line 3\n- Consider adding a comma after the introductory phrase"
            ],
            "paraphrase": [
                "Here's a rephrased version:\n\nInstead of: '{original}'\nTry: 'The evidence suggests that this approach yields better results when applied consistently.'",
                "You could rephrase this as:\n\n'{original}' → 'Research indicates that systematic implementation of this method produces superior outcomes.'",
                "Consider this alternative phrasing:\n\nOriginal: '{original}'\nRevised: 'Studies demonstrate the effectiveness of this technique when used regularly.'"
            ],
            "expand_ideas": [
                "Great start! Here are some ways to expand this idea:\n- Add specific examples from the text\n- Explain the significance of this point\n- Connect it to your thesis statement\n- Consider counterarguments",
                "To develop this further, you could:\n- Provide evidence or quotes\n- Explain the 'why' behind this point\n- Draw connections to other themes\n- Add your own analysis",
                "This is a good foundation. Try:\n- Including more detail about the context\n- Explaining the implications\n- Adding supporting evidence\n- Relating it to broader themes"
            ],
            "research_help": [
                "For this topic, consider exploring:\n- Primary sources from the time period\n- Recent scholarly articles\n- Different perspectives on the issue\n- Historical context and background",
                "Good research areas to investigate:\n- Key figures and their contributions\n- Timeline of major events\n- Different interpretations by historians\n- Primary documents and artifacts",
                "To strengthen your research:\n- Look for peer-reviewed sources\n- Consider multiple viewpoints\n- Check the credibility of sources\n- Take detailed notes with citations"
            ],
            "general": [
                "That's an interesting question! Let me help you think through this...",
                "Good thinking! Here's my perspective on that...",
                "I can help with that. Let's break it down..."
            ]
        }
    
    def save_prompt_and_response(self, data: SaveAIPromptRequest):
        """
        Save AI interaction and return mock response
        """
        try:
            logger.info(f"💬 AI Chat - learner: {data.learner_id}, task: {data.task_id}")
            
            # Determine prompt type from the message
            prompt_type = self._classify_prompt(data.prompt)
            
            # Generate mock AI response
            ai_response = self._generate_response(prompt_type, data.prompt)
            
            # Update or create AI usage stats
            self._update_usage_stats(data.learner_id, data.task_id, prompt_type)
            
            # Save the interaction (optional - could store chat history)
            logger.info(f"✅ AI response generated for {prompt_type}")
            
            return {
                "success": True,
                "message": "AI interaction saved successfully",
                "data": {
                    "prompt": data.prompt,
                    "response": ai_response,
                    "prompt_type": prompt_type,
                    "timestamp": datetime.now().isoformat()
                }
            }
            
        except Exception as e:
            logger.error(f"❌ Error in AI service: {e}")
            return {
                "success": False,
                "message": f"Failed to process AI request: {str(e)}",
                "data": None
            }
    
    def _classify_prompt(self, prompt: str) -> str:
        """Classify the type of AI assistance requested"""
        prompt_lower = prompt.lower()
        
        if any(word in prompt_lower for word in ['grammar', 'spelling', 'punctuation', 'correct']):
            return 'grammar_check'
        elif any(word in prompt_lower for word in ['rephrase', 'rewrite', 'paraphrase', 'say differently']):
            return 'paraphrase'
        elif any(word in prompt_lower for word in ['expand', 'elaborate', 'more detail', 'develop']):
            return 'expand_ideas'
        elif any(word in prompt_lower for word in ['research', 'find', 'sources', 'information']):
            return 'research_help'
        else:
            return 'general'
    
    def _generate_response(self, prompt_type: str, original_prompt: str) -> str:
        """Generate a mock AI response based on prompt type"""
        templates = self.response_templates.get(prompt_type, self.response_templates['general'])
        response = random.choice(templates)
        
        # Replace placeholder if present
        if '{original}' in response:
            # Extract a snippet from the original prompt
            snippet = original_prompt[:100] + "..." if len(original_prompt) > 100 else original_prompt
            response = response.replace('{original}', snippet)
        
        return response
    
    def _update_usage_stats(self, learner_id: str, task_id: str, prompt_type: str):
        """Update AI usage statistics in database"""
        try:
            # Check if record exists
            check_query = """
                SELECT usage_id, used_count 
                FROM BINARY_SUCCESS_AI_USAGE_STATS
                WHERE learner_id = :learner_id 
                AND task_id = :task_id 
                AND prompt_type = :prompt_type
            """
            
            existing = crud.fetch_one(check_query, {
                "learner_id": learner_id,
                "task_id": task_id,
                "prompt_type": prompt_type
            })
            
            if existing:
                # Update existing record
                update_query = """
                    UPDATE BINARY_SUCCESS_AI_USAGE_STATS
                    SET used_count = used_count + 1
                    WHERE usage_id = :usage_id
                """
                crud.execute(update_query, {"usage_id": existing['usage_id']})
            else:
                # Insert new record
                import uuid
                insert_query = """
                    INSERT INTO BINARY_SUCCESS_AI_USAGE_STATS
                    (usage_id, task_id, learner_id, used_count, prompt_type, created_at)
                    VALUES (:usage_id, :task_id, :learner_id, 1, :prompt_type, :created_at)
                """
                crud.execute(insert_query, {
                    "usage_id": f"aiusage-{uuid.uuid4().hex[:12]}",
                    "task_id": task_id,
                    "learner_id": learner_id,
                    "prompt_type": prompt_type,
                    "created_at": datetime.now()
                })
                
        except Exception as e:
            logger.error(f"Failed to update AI usage stats: {e}")
