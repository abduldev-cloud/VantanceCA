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
            print(json.dumps({"error": "No learners found."}))
            return
            
        l_id = learner['learner_id']
        
        # Check tasks for this learner
        cursor.execute("""
            SELECT tt.task_id, tt.task_title, lt.learner_task_id
            FROM BINARY_SUCCESS_TEACHER_TASKS tt
            JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id
            WHERE lt.learner_id = %s
        """, (l_id,))
        tasks = cursor.fetchall()
        
        # Check totals
        cursor.execute("SELECT COUNT(*) as count FROM BINARY_SUCCESS_TEACHER_TASKS")
        total_tt = cursor.fetchone()['count']
        
        cursor.execute("SELECT COUNT(*) as count FROM BINARY_SUCCESS_LEARNER_TASKS")
        total_lt = cursor.fetchone()['count']

        print(json.dumps({
            "learner_id": l_id,
            "tasks_found": tasks,
            "total_teacher_tasks": total_tt,
            "total_learner_tasks": total_lt
        }, indent=2, default=str))

    except Exception as e:
        print(json.dumps({"error": str(e)}))
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    check_task_assignments()
