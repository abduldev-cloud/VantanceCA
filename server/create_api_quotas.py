import sys
import os

# Add the server directory to python path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def create_table():
    conn = get_mysql_connection()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS BINARY_SUCCESS_API_QUOTAS (
            quota_id VARCHAR(36) PRIMARY KEY,
            institute_id VARCHAR(36) NOT NULL,
            month_year VARCHAR(7) NOT NULL,
            tokens_used INT DEFAULT 0,
            threshold_limit INT DEFAULT 10000,
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY(institute_id, month_year),
            FOREIGN KEY (institute_id) REFERENCES BINARY_SUCCESS_PLATFORM_INSTITUTES(institute_id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    """)
    conn.commit()

    # Seed it with some dummy data for existing institutes
    import uuid
    from datetime import datetime
    cursor.execute("SELECT institute_id FROM BINARY_SUCCESS_PLATFORM_INSTITUTES")
    institutes = cursor.fetchall()
    
    current_month = datetime.now().strftime('%Y-%m')
    import random
    
    for inst in institutes:
        institute_id = inst[0]
        # Check if already exists
        cursor.execute("SELECT quota_id FROM BINARY_SUCCESS_API_QUOTAS WHERE institute_id = %s AND month_year = %s", (institute_id, current_month))
        if cursor.fetchone() is None:
            # Seed random token usage, some near threshold
            usage = random.randint(1000, 12000)
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_API_QUOTAS (quota_id, institute_id, month_year, tokens_used, threshold_limit)
                VALUES (%s, %s, %s, %s, 10000)
            """, (f"qt-{uuid.uuid4().hex[:8]}", institute_id, current_month, usage))
            
    conn.commit()
    cursor.close()
    conn.close()
    print("API Quotas table created and seeded successfully.")

if __name__ == '__main__':
    create_table()
