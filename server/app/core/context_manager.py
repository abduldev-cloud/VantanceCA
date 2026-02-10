from contextlib import contextmanager
from app.core.database import get_oracle_connection
from app.core.logger import logger

@contextmanager
def oracle_session(auto_commit: bool = True):
    conn = None
    cursor = None
    try:
        conn = get_oracle_connection()
        cursor = conn.cursor()
        yield cursor
        if auto_commit:
            conn.commit()
    except Exception as e:
        logger.exception("❌ Oracle session failed")
        if conn:
            conn.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()  
