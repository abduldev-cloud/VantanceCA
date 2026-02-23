import requests
import json

response = requests.get(
    "http://localhost:8000/db/teacher/get_assignment_overview/",
    params={"teacher_id": "teacher-001", "task_status": "active"}
)

print(f"Status: {response.status_code}")
data = response.json()

print(f"\nTask counts: {data.get('task_counts')}")
print(f"Number of tasks: {len(data.get('task_summary', []))}")

if data.get('task_summary'):
    print(f"\nFirst task:")
    print(json.dumps(data['task_summary'][0], indent=2))
