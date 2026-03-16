import sys
import os
import json

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def debug_learner_task(task_id, learner_id):
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Check if task exists
        cursor.execute("SELECT * FROM BINARY_SUCCESS_TEACHER_TASKS WHERE task_id = %s", (task_id,))
        task = cursor.fetchone()
        if not task:
            print(f"Task {task_id} not found in TEACHER_TASKS")
            return

        # Check if learner is enrolled in the class for this task
        cursor.execute("""
            SELECT * FROM BINARY_SUCCESS_ENROLLMENTS 
            WHERE learner_id = %s AND class_id = %s
        """, (learner_id, task['class_id']))
        enrollment = cursor.fetchone()
        
        # Check if learner_task entry exists
        cursor.execute("""
            SELECT * FROM BINARY_SUCCESS_LEARNER_TASKS 
            WHERE task_id = %s AND learner_id = %s
        """, (task_id, learner_id))
        lt = cursor.fetchone()

        result = {
            "task_exists": True,
            "class_id": task['class_id'],
            "is_enrolled": enrollment is not None,
            "learner_task_exists": lt is not None,
            "learner_task": lt
        }
        print(json.dumps(result, indent=2, default=str))

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    # Need to know which task and learner the user is trying.
    # From dump earlier: task-485a203e1ac6 and learner-001
    print("Checking task-485a203e1ac6 for learner-001:")
    debug_learner_task("task-485a203e1ac6", "learner-001")
    
    # Let's also check for any loose ends
    print("\nTasks for learner-001 that might be missing entries:")
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT tt.task_id, tt.task_title
        FROM BINARY_SUCCESS_TEACHER_TASKS tt
        JOIN BINARY_SUCCESS_ENROLLMENTS e ON tt.class_id = e.class_id
        LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id AND lt.learner_id = e.learner_id
        WHERE e.learner_id = 'learner-001' AND lt.learner_task_id IS NULL
    """)
    missing = cursor.fetchall()
    print(json.dumps(missing, indent=2))
    cursor.close()
    conn.close()
