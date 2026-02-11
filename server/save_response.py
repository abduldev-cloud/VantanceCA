import requests
import json

response = requests.get(
    "http://localhost:8000/db/teacher/get_class_summary/",
    params={"teacher_id": "teacher-001", "class_status": "Active"}
)

with open("teacher_response.json", "w") as f:
    json.dump(response.json(), f, indent=2, default=str)

print("Response saved to teacher_response.json")
print(f"Status: {response.status_code}")
