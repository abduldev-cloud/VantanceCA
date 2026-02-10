
import mysql.connector

credentials = [
    ("root", ""),
    ("root", "password"),
    ("root", "root"),
    ("root", "admin"),
    ("root", "123456"),
    ("root", "1234")
]

for user, password in credentials:
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user=user,
            password=password
        )
        print(f"✅ SUCCESS: Connected with {user} / '{password}'")
        conn.close()
        break
    except Exception as e:
        print(f"❌ FAILED: {user} / '{password}' - {e}")
