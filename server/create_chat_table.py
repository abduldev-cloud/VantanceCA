import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def create_chat_table():
    conn = get_mysql_connection()
    cursor = conn.cursor()
    
    try:
        # Create AI Messages table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS BINARY_SUCCESS_AIC_MESSAGES (
                message_id VARCHAR(36) PRIMARY KEY,
                learner_task_id VARCHAR(36) NOT NULL,
                sender ENUM('STUDENT', 'AI') NOT NULL,
                message_content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (learner_task_id) REFERENCES BINARY_SUCCESS_LEARNER_TASKS(learner_task_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """)
        
        # Add index for faster history retrieval
        cursor.execute("CREATE INDEX idx_chat_task ON BINARY_SUCCESS_AIC_MESSAGES(learner_task_id);")
        
        conn.commit()
        print("Table BINARY_SUCCESS_AIC_MESSAGES created successfully.")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    create_chat_table()
