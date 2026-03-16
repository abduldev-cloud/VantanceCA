import requests
import json

def test_chat():
    url = "http://localhost:8000/db/assignments/ltask-001/chat" # Using a real ID
    payload = {"message": "Hello AI"}
    
    try:
        print(f"Testing POST {url}...")
        response = requests.post(url, json=payload)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    test_chat()
