"""
Script to create user_entity_details table and populate with test data
"""
import mysql.connector
import os
from dotenv import load_dotenv
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv('.env.local')

def create_user_tables():
    """Create user_entity_details table in MySQL"""
    
    # Database configuration
    db_config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'port': int(os.getenv('MYSQL_PORT', 3306)),
        'user': os.getenv('MYSQL_USER', 'root'),
        'password': os.getenv('MYSQL_PASSWORD', '1234'),
        'database': os.getenv('MYSQL_DATABASE', 'ca_exam')
    }
    
    try:
        # Connect to MySQL
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        logger.info(f"✅ Connected to MySQL database: {db_config['database']}")
        
        # Create user_entity_details table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS user_entity_details (
                id INT AUTO_INCREMENT PRIMARY KEY,
                keycloak_id VARCHAR(255) UNIQUE NOT NULL,
                user_id VARCHAR(255) NOT NULL,
                role_entity_id VARCHAR(255),
                institute_id VARCHAR(255),
                is_demo_school VARCHAR(10) DEFAULT 'false',
                role_display_name VARCHAR(100),
                crm_contact_id VARCHAR(255),
                crm_account_id VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_keycloak_id (keycloak_id),
                INDEX idx_user_id (user_id)
            )
        """)
        
        logger.info("✅ Created table: user_entity_details")
        
        # Get existing users from mock_users table
        cursor.execute("SELECT id, username, email, first_name, last_name FROM mock_users")
        users = cursor.fetchall()
        
        if users:
            logger.info(f"📋 Found {len(users)} users in mock_users table")
            
            for user in users:
                keycloak_id, username, email, first_name, last_name = user
                
                # Check if user already exists in user_entity_details
                cursor.execute(
                    "SELECT 1 FROM user_entity_details WHERE keycloak_id = %s",
                    (keycloak_id,)
                )
                
                if not cursor.fetchone():
                    # Generate IDs for the user
                    user_id = f"USER_{keycloak_id[:8]}"
                    role_entity_id = f"ENTITY_{keycloak_id[:8]}"
                    institute_id = f"INST_{keycloak_id[:8]}"
                    
                    # Insert user entity details
                    cursor.execute("""
                        INSERT INTO user_entity_details 
                        (keycloak_id, user_id, role_entity_id, institute_id, 
                         is_demo_school, role_display_name, crm_contact_id, crm_account_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    """, (
                        keycloak_id,
                        user_id,
                        role_entity_id,
                        institute_id,
                        'false',
                        'Learner',  # Default role display name
                        f"CRM_CONTACT_{keycloak_id[:8]}",
                        f"CRM_ACCOUNT_{keycloak_id[:8]}"
                    ))
                    
                    logger.info(f"✅ Created entity details for user: {email}")
                else:
                    logger.info(f"⏭️  Entity details already exist for: {email}")
        
        conn.commit()
        logger.info("🎉 User tables setup completed successfully!")
        
    except Exception as e:
        logger.error(f"❌ Error: {e}")
        raise
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    create_user_tables()
