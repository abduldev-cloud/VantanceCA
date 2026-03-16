import google.generativeai as genai
import os
from app.core.config import settings
from app.core.logger import logger

class AIService:
    def __init__(self):
        # Prefer GEMINI_API_KEY, fallback to LLM_API_KEY
        self.api_key = os.getenv("GEMINI_API_KEY") or settings.LLM_API_KEY
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-flash-latest')
        else:
            self.model = None
            logger.warning("AI_SERVICE: No API Key found. AI features will be disabled.")

    async def get_chat_response(self, message: str, context: str = "", history: list = None):
        """
        Get a response from Gemini given a message and optional context/history.
        """
        if not self.model:
            return "I'm sorry, my AI brain is currently disconnected. Please ask your teacher to check the API configuration."

        try:
            # Construct a system prompt
            system_prompt = f"""
            You are a helpful AI Writing Assistant for students preparing for exams.
            Your goal is to provide constructive feedback, clarify instructions, and help with writing style.
            Do NOT write the whole essay for the student. Instead, guide them.
            
            ASSIGNMENT CONTEXT:
            {context}
            
            Be concise and encouraging.
            """
            
            # Format history for Gemini
            chat_history = []
            if history:
                for msg in history:
                    role = "user" if msg['sender'] == 'STUDENT' else "model"
                    chat_history.append({"role": role, "parts": [msg['message_content']]})

            chat = self.model.start_chat(history=chat_history)
            
            # Combine system prompt with the main message for now
            # (Gemini 1.5 prefers this if not using specialized System Instruction)
            full_prompt = f"{system_prompt}\n\nStudent asks: {message}"
            
            response = await chat.send_message_async(full_prompt)
            return response.text
        except Exception as e:
            logger.error(f"AI_SERVICE_ERROR: {e}")
            return "I encountered an error while thinking. Please try again in a moment."

    async def get_auto_grade(self, submission_text: str, task_context: str, rubrics: str = ""):
        """
        AI automated grading.
        Returns a dictionary with 'score' (0-10) and 'feedback'.
        """
        if not self.model:
            return {"score": 0, "feedback": "AI Service disconnected."}

        try:
            prompt = f"""
            You are an expert academic grader. Grade the following student submission based on the assignment context and rubrics.
            
            ASSIGNMENT CONTEXT:
            {task_context}
            
            RUBRICS/CRITERIA:
            {rubrics if rubrics else "General academic writing quality, clarity, and relevance."}
            
            STUDENT SUBMISSION:
            {submission_text}
            
            Goal: Provide a fair score between 0 and 10 and constructive feedback.
            
            Provide your response in EXACT JSON format:
            {{
                "score": <number between 0 and 10>,
                "feedback": "<detailed constructive feedback for the student>"
            }}
            """
            
            logger.info("AI_GRADING: Sending prompt to Gemini")
            response = await self.model.generate_content_async(prompt)
            
            import json
            import re
            text = response.text
            logger.info(f"AI_GRADING_RAW_RESPONSE: {text}")
            
            # Extract JSON from potential markdown code blocks
            match = re.search(r'\{.*\}', text, re.DOTALL)
            if match:
                parsed = json.loads(match.group())
                logger.info(f"AI_GRADING_PARSED: {parsed}")
                return parsed
            
            logger.error("AI_GRADING_PARSE_FAIL: No JSON found in response")
            return {"score": 0, "feedback": "Could not parse AI response output."}
        except Exception as e:
            logger.error(f"AI_GRADING_ERROR: {str(e)}")
            return {"score": 0, "feedback": f"Error during AI grading: {str(e)}"}

ai_service = AIService()
