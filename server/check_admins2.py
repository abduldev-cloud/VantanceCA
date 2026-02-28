import os
import sys

# Add the server directory to python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.core.database_mysql import get_mysql_connection

def count_admins():
    conn = get_mysql_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Get count by role
        cursor.execute("""
            SELECT r.role_name, COUNT(u.user_id) as admin_count 
            FROM BINARY_SUCCESS_PLATFORM_USERS u 
            JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id 
            WHERE r.role_name LIKE '%ADMIN%' 
            GROUP BY r.role_name
        """)
        counts = cursor.fetchall()
        
        print("=== Admin Counts ===")
        for c in counts:
            print(f"{c['role_name']}: {c['admin_count']}")
            
        print("\n=== Detailed Admin List ===")
        cursor.execute("""
            SELECT u.email, u.first_name, u.last_name, r.role_name, i.institute_name
            FROM BINARY_SUCCESS_PLATFORM_USERS u 
            JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id 
            LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON u.institute_id = i.institute_id
            WHERE r.role_name LIKE '%ADMIN%'
        """)
        users = cursor.fetchall()
        for u in users:
            school = u['institute_name'] or "Global (All Schools)"
            print(f"- {u['first_name']} {u['last_name']} ({u['email']}) | Role: {u['role_name']} | Scope: {school}")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    count_admins()
