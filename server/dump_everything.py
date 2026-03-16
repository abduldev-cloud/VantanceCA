import sys
import os
import json

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def dump_everything():
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        print("--- Table: BINARY_SUCCESS_TEACHER_TASKS ---")
        cursor.execute("SELECT task_id, task_title, task_type_id FROM BINARY_SUCCESS_TEACHER_TASKS")
        tt = cursor.fetchall()
        for r in tt:
            print(f"{r['task_id']} | {r['task_type_id']} | {r['task_title']}")
        
        print("\n--- Table: BINARY_SUCCESS_LEARNER_TASKS ---")
        cursor.execute("SELECT learner_task_id, task_id, learner_id, status_id FROM BINARY_SUCCESS_LEARNER_TASKS")
        lt = cursor.fetchall()
        for r in lt:
            print(f"{r['learner_task_id']} | {r['task_id']} | {r['learner_id']} | {r['status_id']}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    dump_everything()
