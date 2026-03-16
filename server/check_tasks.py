import sys
import os
import json

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def check_task_assignments():
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Get one learner to verify
        cursor.execute("SELECT learner_id, user_id FROM BINARY_SUCCESS_LEARNERS LIMIT 1")
        learner = cursor.fetchone()
        if not learner:
            print("No learners found.")
            return
            
        l_id = learner['learner_id']
        print(f"Checking assignments for Learner ID: {l_id}")
        
        # Check tasks for this learner
        cursor.execute("""
            SELECT tt.task_id, tt.task_title, lt.learner_task_id
            FROM BINARY_SUCCESS_TEACHER_TASKS tt
            JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id
            WHERE lt.learner_id = %s
        """, (l_id,))
        tasks = cursor.fetchall()
        
        if tasks:
            print(f"Found {len(tasks)} tasks.")
            for t in tasks:
                print(f" - Task ID: {t['task_id']}, Title: {t['task_title']}, Learner Task ID: {t['learner_task_id']}")
        else:
            print("No tasks found for this learner.")
            
        # Let's check if the specific table exists and has entries
        cursor.execute("SELECT COUNT(*) as count FROM BINARY_SUCCESS_TEACHER_TASKS")
        print(f"Total Teacher Tasks: {cursor.fetchone()['count']}")
        
        cursor.execute("SELECT COUNT(*) as count FROM BINARY_SUCCESS_LEARNER_TASKS")
        print(f"Total Learner Tasks: {cursor.fetchone()['count']}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    check_task_assignments()
