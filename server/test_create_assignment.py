"""
Test script to create a mock assignment from teacher to learners
Usage: python test_create_assignment.py
"""

import requests
import json
from datetime import datetime, timedelta

# API base URL
BASE_URL = "http://localhost:8000"

def create_assignment():
    """Create a sample quiz assignment"""
    
    # Assignment data
    assignment_data = {
        "task_title": "Mock CA Exam - Financial Accounting",
        "task_description": "Complete this practice exam covering chapters 1-5 of Financial Accounting. You have 2 hours to complete all questions.",
        "task_type_id": "tasktype-003",  # QUIZ
        "teacher_id": "teacher-001",  # Ms. Anderson
        "class_id": "class-001",  # Grade 10A - Springfield
        "due_date": (datetime.now() + timedelta(days=3)).isoformat(),  # Due in 3 days
        "max_score": 100.0
    }
    
    print("📝 Creating assignment...")
    print(f"Title: {assignment_data['task_title']}")
    print(f"Class: {assignment_data['class_id']}")
    print(f"Due: {assignment_data['due_date']}")
    print()
    
    # Make POST request
    response = requests.post(
        f"{BASE_URL}/db/assignments/create",
        json=assignment_data,
        headers={"Content-Type": "application/json"}
    )
    
    if response.status_code == 200:
        result = response.json()
        print("✅ Assignment created successfully!")
        print(json.dumps(result, indent=2))
        print()
        print(f"📊 Task ID: {result['data']['task_id']}")
        print(f"👥 Assigned to: {result['data']['students_assigned']} students")
        print(f"📅 Due date: {result['data']['due_date']}")
    else:
        print(f"❌ Error: {response.status_code}")
        print(response.text)

def list_assignments_for_class(class_id="class-001"):
    """List all assignments for a class"""
    print(f"\n📚 Fetching assignments for class {class_id}...")
    
    response = requests.get(f"{BASE_URL}/db/assignments?class_id={class_id}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Found {result['count']} assignments:")
        for assignment in result['data']:
            print(f"  - {assignment['task_title']} (Due: {assignment.get('due_date', 'N/A')})")
    else:
        print(f"❌ Error: {response.status_code}")

def list_student_assignments(learner_id="learner-001"):
    """List assignments for a specific student"""
    print(f"\n🎓 Fetching assignments for student {learner_id}...")
    
    response = requests.get(f"{BASE_URL}/db/assignments?learner_id={learner_id}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Found {result['count']} assignments:")
        for assignment in result['data']:
            status = assignment.get('status', 'ASSIGNED')
            print(f"  - {assignment['task_title']} - Status: {status}")
    else:
        print(f"❌ Error: {response.status_code}")

if __name__ == "__main__":
    print("=" * 60)
    print("  Mock Assignment Creation Test")
    print("=" * 60)
    print()
    
    # Create assignment
    create_assignment()
    
    # List assignments for the class
    list_assignments_for_class("class-001")
    
    # List assignments for a student
    list_student_assignments("learner-001")
    
    print()
    print("=" * 60)
    print("✅ Test completed!")
    print("=" * 60)
