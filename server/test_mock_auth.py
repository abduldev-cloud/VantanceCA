# Test script to verify mock auth endpoints
import requests
import json

BASE_URL = "http://localhost:8000"

print("Testing Mock Auth Endpoints...")
print("=" * 50)

# Test 1: Get admin token
print("\n1. Testing GET admin token...")
try:
    response = requests.post(
        f"{BASE_URL}/realms/binarysuccess/protocol/openid-connect/token",
        data={
            "grant_type": "client_credentials",
            "client_id": "binarysuccess",
            "client_secret": "local_dev_secret"
        }
    )
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        print(f"   ✓ Token received: {response.json().get('access_token')[:20]}...")
    else:
        print(f"   ✗ Error: {response.text}")
except Exception as e:
    print(f"   ✗ Exception: {e}")

# Test 2: Create user
print("\n2. Testing CREATE user...")
try:
    response = requests.post(
        f"{BASE_URL}/admin/realms/binarysuccess/users",
        json={
            "username": "test@example.com",
            "email": "test@example.com",
            "enabled": True,
            "firstName": "Test",
            "lastName": "User",
            "credentials": [
                {"type": "password", "value": "password123", "temporary": False}
            ]
        }
    )
    print(f"   Status: {response.status_code}")
    if response.status_code == 201:
        print(f"   ✓ User created successfully")
    else:
        print(f"   ✗ Error: {response.text}")
except Exception as e:
    print(f"   ✗ Exception: {e}")

# Test 3: Get user by email
print("\n3. Testing GET user by email...")
try:
    response = requests.get(
        f"{BASE_URL}/admin/realms/binarysuccess/users",
        params={"email": "test@example.com"}
    )
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        users = response.json()
        if users:
            print(f"   ✓ User found: {users[0].get('email')}")
        else:
            print(f"   ✗ No user found")
    else:
        print(f"   ✗ Error: {response.text}")
except Exception as e:
    print(f"   ✗ Exception: {e}")

print("\n" + "=" * 50)
print("Test complete!")
