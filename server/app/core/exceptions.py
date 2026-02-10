from fastapi import HTTPException

class NotFoundException(HTTPException):
    def __init__(self, detail="Resource not found"):
        super().__init__(status_code=404, detail=detail)
        
class DatabaseException(Exception):
    def __init__(self, message: str, original_exception: Exception):
        self.message = message
        self.original_exception = original_exception
        super().__init__(message)
