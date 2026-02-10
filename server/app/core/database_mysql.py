# app/core/database_mysql.py
import mysql.connector
from mysql.connector import pooling
from app.core.config import settings
from app.core.logger import logger

# Create MySQL connection pool
try:
    connection_pool = mysql.connector.pooling.MySQLConnectionPool(
        pool_name="binarysuccess_pool",
        pool_size=10,
        pool_reset_session=True,
        host=settings.MYSQL_HOST,
        port=settings.MYSQL_PORT,
        database=settings.MYSQL_DATABASE,
        user=settings.MYSQL_USER,
        password=settings.MYSQL_PASSWORD
    )
    logger.info("✅ MySQL connection pool created successfully")
except Exception as e:
    logger.error(f"❌ Failed to create MySQL connection pool: {e}")
    raise

def get_mysql_connection():
    """Get a connection from the pool"""
    return connection_pool.get_connection()
