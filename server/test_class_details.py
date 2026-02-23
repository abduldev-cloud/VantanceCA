import requests
import json

response = requests.get(
    "http://localhost:8000/db/teacher/get_class_tasks_stats_and_learners/",
    params={"teacher_id": "teacher-001", "class_id": "class-001"}
)

print(f"Status: {response.status_code}")
data = response.json()

print(f"\nStudents found: {len(data.get('students_list', []))}")
print(f"Class summary: {data.get('class_summary')}")

if data.get('students_list'):
    print(f"\nFirst student:")
    print(json.dumps(data['students_list'][0], indent=2))
