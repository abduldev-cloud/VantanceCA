import requests
import json

# First, get a valid task_id
response = requests.get(
    "http://localhost:8000/db/teacher/get_assignment_overview/",
    params={"teacher_id": "teacher-001", "task_status": "active"}
)
data = response.json()

if data.get('task_summary'):
    task_id = data['task_summary'][0]['task_id']
    task_title = data['task_summary'][0]['task_title']
    print(f"Testing with task: {task_title} ({task_id})")
    print("=" * 60)
    
    # Now test the detail endpoint
    detail_response = requests.get(
        "http://localhost:8000/db/teacher/get_stats_and_learners_for_task/",
        params={"task_id": task_id}
    )
    
    print(f"Status: {detail_response.status_code}")
    detail_data = detail_response.json()
    
    print(f"\nTask Stats: {detail_data.get('task_details_and_stats')}")
    print(f"\nStudents count: {len(detail_data.get('task_details_per_student', []))}")
    
    if detail_data.get('task_details_per_student'):
        print(f"\nFirst student:")
        print(json.dumps(detail_data['task_details_per_student'][0], indent=2, default=str))
else:
    print("No tasks found!")
