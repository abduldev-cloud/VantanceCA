import requests
import json

# Test the teacher class summary endpoint
url = "http://localhost:8000/db/teacher/get_class_summary/"
params = {
    "teacher_id": "teacher-001",
    "class_status": "Active"
}

print("Testing API endpoint...")
print(f"URL: {url}")
print(f"Params: {params}\n")

try:
    response = requests.get(url, params=params)
    print(f"Status Code: {response.status_code}\n")
    
    if response.status_code == 200:
        data = response.json()
        
        print("=== RESPONSE STRUCTURE ===")
        print(f"Keys: {list(data.keys())}\n")
        
        print("=== CLASS STATUS COUNT ===")
        print(json.dumps(data.get("class_status_count"), indent=2))
        
        print("\n=== TEACHER SUMMARY ===")
        print(json.dumps(data.get("teacher_summary"), indent=2))
        
        print("\n=== CLASS DETAILS ===")
        class_details = data.get("class_details", [])
        print(f"Number of classes: {len(class_details)}")
        
        if class_details:
            print("\nFirst class:")
            print(json.dumps(class_details[0], indent=2))
            
            print("\nAll class fields:")
            for key in class_details[0].keys():
                print(f"  - {key}: {type(class_details[0][key]).__name__}")
        
        print(f"\n=== OUT STATUS ===")
        print(data.get("out_status"))
        
    else:
        print(f"Error: {response.text}")
        
except Exception as e:
    print(f"Exception: {e}")
