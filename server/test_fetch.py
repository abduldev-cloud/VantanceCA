import sys
import os
import json

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def test_get_assignment(task_id, learner_id=None):
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        if learner_id:
            cursor.execute("""
                SELECT tt.*, ttype.task_type, c.class_name,
                    u.first_name AS teacher_first_name, u.last_name AS teacher_last_name,
                    lt.learner_task_id, lt.status_id AS learner_status_id, 
                    lt.score, lt.submitted_at, lt.submission_text,
                    ts.status AS learner_status
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                LEFT JOIN BINARY_SUCCESS_TEACHERS t ON tt.teacher_id = t.teacher_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id AND lt.learner_id = %s
                LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                WHERE tt.task_id = %s
            """, (learner_id, task_id))
        else:
            cursor.execute("""
                SELECT tt.*, ttype.task_type, c.class_name,
                    u.first_name AS teacher_first_name, u.last_name AS teacher_last_name
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                LEFT JOIN BINARY_SUCCESS_TEACHERS t ON tt.teacher_id = t.teacher_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                WHERE tt.task_id = %s
            """, (task_id,))
        assignment = cursor.fetchone()
        
        if assignment:
            print(json.dumps({"success": True, "data": assignment}, indent=2, default=str))
        else:
            print(json.dumps({"success": False, "message": "Assignment not found"}))

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    # Try one of the IDs found
    test_get_assignment("task-485a203e1ac6", "learner-001")
    # Try another one
    test_get_assignment("task-001", "learner-001")
