from fastapi import APIRouter
from app.core.database import get_oracle_connection

router = APIRouter(prefix="/health", tags=["Health"])

@router.get("/db")
def test_database_connection():
    try:
        connection = get_oracle_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT 1 FROM dual")
        result = cursor.fetchone()
        cursor.close()
        connection.close()
        return {"status": "ok", "message": "Oracle DB connected", "result": result[0]}
    except Exception as e:
        return {"status": "error", "message": "Oracle DB connection failed", "details": str(e)}
