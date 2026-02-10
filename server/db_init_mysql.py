
import mysql.connector
from app.core.config import settings
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def init_db():
    try:
        # Connect to MySQL Server (without specifying DB first to create it if needed)
        conn = mysql.connector.connect(
            host=settings.MYSQL_HOST,
            port=settings.MYSQL_PORT,
            user=settings.MYSQL_USER,
            password=settings.MYSQL_PASSWORD
        )
        cursor = conn.cursor()
        
        # Create Database
        db_name = settings.MYSQL_DATABASE
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
        logger.info(f"✅ Database '{db_name}' check/creation successful")
        
        # Connect to the specific database
        conn.database = db_name
        
        # Create Users Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS mock_users (
            id VARCHAR(36) PRIMARY KEY,
            username VARCHAR(255) UNIQUE NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            first_name VARCHAR(100),
            last_name VARCHAR(100),
            password VARCHAR(255),
            enabled BOOLEAN DEFAULT TRUE,
            created_at BIGINT,
            attributes JSON
        )
        """)
        logger.info("✅ Table 'mock_users' check/creation successful")
        
        # Create User Roles Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS mock_user_roles (
            user_id VARCHAR(36),
            client_id VARCHAR(255),
            role_name VARCHAR(255),
            PRIMARY KEY (user_id, client_id, role_name),
            FOREIGN KEY (user_id) REFERENCES mock_users(id) ON DELETE CASCADE
        )
        """)
        logger.info("✅ Table 'mock_user_roles' check/creation successful")
        
        conn.commit()
        cursor.close()
        conn.close()
        logger.info("🎉 Database initialization completed successfully!")
        
    except Exception as e:
        logger.error(f"❌ Database initialization failed: {e}")

if __name__ == "__main__":
    init_db()
