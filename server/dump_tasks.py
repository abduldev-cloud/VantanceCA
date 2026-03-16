import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def dump_tasks():
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT task_id, task_title FROM BINARY_SUCCESS_TEACHER_TASKS")
        tasks = cursor.fetchall()
        print(f"Total tasks found: {len(tasks)}")
        for t in tasks:
            print(f"ID: '{t['task_id']}', Title: '{t['task_title']}'")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    dump_tasks()
