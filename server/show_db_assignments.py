from app.core.database_mysql import get_mysql_connection
import json

conn = get_mysql_connection()
cursor = conn.cursor(dictionary=True)

# Get all assignments for teacher-001
query = """
SELECT 
    tt.task_id,
    tt.task_title,
    tt.due_date,
    c.class_name,
    tt.created_at
FROM BINARY_SUCCESS_TEACHER_TASKS tt
JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
WHERE c.teacher_id = 'teacher-001'
ORDER BY tt.created_at
"""

cursor.execute(query)
assignments = cursor.fetchall()

print("=" * 60)
print(f"ASSIGNMENTS FROM DATABASE FOR TEACHER-001")
print("=" * 60)
print(f"\nTotal assignments found: {len(assignments)}\n")

for i, assignment in enumerate(assignments, 1):
    print(f"{i}. {assignment['task_title']}")
    print(f"   Class: {assignment['class_name']}")
    print(f"   Due Date: {assignment['due_date']}")
    print(f"   Task ID: {assignment['task_id']}")
    print(f"   Created: {assignment['created_at']}")
    print()

cursor.close()
conn.close()

print("=" * 60)
print("✅ These are REAL database records, not static data!")
print("=" * 60)
