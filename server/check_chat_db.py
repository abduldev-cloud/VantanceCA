import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def check_messages():
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM BINARY_SUCCESS_AIC_MESSAGES ORDER BY created_at DESC LIMIT 5")
        messages = cursor.fetchall()
        print("Recent Messages:")
        for msg in messages:
            print(f"- {msg['sender']}: {msg['message_content']} (Task: {msg['learner_task_id']})")
            
        cursor.execute("SELECT COUNT(*) as count FROM BINARY_SUCCESS_AIC_MESSAGES")
        print(f"\nTotal messages: {cursor.fetchone()['count']}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    check_messages()
