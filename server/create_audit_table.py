import sys
import os
import uuid

# Add the server directory to python path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def create_table():
    conn = get_mysql_connection()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS BINARY_SUCCESS_AUDIT_LOGS (
            log_id VARCHAR(36) PRIMARY KEY,
            user_id VARCHAR(36),
            user_name VARCHAR(100),
            role_name VARCHAR(50),
            action_type VARCHAR(50) NOT NULL,
            description TEXT NOT NULL,
            ip_address VARCHAR(45),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    """)
    conn.commit()

    # insert some dummy logs if empty
    cursor.execute("SELECT COUNT(*) FROM BINARY_SUCCESS_AUDIT_LOGS")
    if cursor.fetchone()[0] == 0:
        logs = [
            ("Platform Administration", "PLATFORM_ADMIN", "LOGIN", "Platform Admin securely authenticated into the system."),
            ("Platform Administration", "PLATFORM_ADMIN", "BULK_IMPORT_SCHOOLS", "Bulk imported 3 new schools via CSV."),
            ("Platform Administration", "PLATFORM_ADMIN", "BULK_IMPORT_USERS", "Bulk imported users and assigned them to schools."),
            ("Platform Administration", "PLATFORM_ADMIN", "ADD_GRADE_LEVEL", "Dynamically added new Grade Level: Grade 10."),
            ("Institute Administrator", "INSTITUTE_ADMIN", "VIEW_USERS", "Viewed users for Demo Central High."),
            ("Platform Administration", "PLATFORM_ADMIN", "CREATE_TASK_TYPE", "Added new system Task Type: Essay."),
        ]
        
        for uname, role, action, desc in logs:
            cursor.execute(
                "INSERT INTO BINARY_SUCCESS_AUDIT_LOGS (log_id, user_name, role_name, action_type, description, ip_address) VALUES (%s, %s, %s, %s, %s, %s)",
                (f"log-{uuid.uuid4().hex[:8]}", uname, role, action, desc, "192.168.1.100")
            )
        conn.commit()
    
    cursor.close()
    conn.close()
    print("Audit logs table created and seeded successfully.")

if __name__ == '__main__':
    create_table()
