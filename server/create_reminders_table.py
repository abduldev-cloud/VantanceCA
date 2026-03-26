import mysql.connector
from dotenv import load_dotenv
import os

load_dotenv()

conn = mysql.connector.connect(
    host=os.getenv("MYSQL_HOST", "localhost"),
    port=int(os.getenv("MYSQL_PORT", 3306)),
    database=os.getenv("MYSQL_DATABASE", "ca_exam"),
    user=os.getenv("MYSQL_USER", "root"),
    password=os.getenv("MYSQL_PASSWORD", "1234")
)
cursor = conn.cursor()

cursor.execute("""
    CREATE TABLE IF NOT EXISTS BINARY_SUCCESS_REMINDERS (
        reminder_id VARCHAR(36) PRIMARY KEY,
        teacher_id VARCHAR(36) NOT NULL,
        reminder_date DATE NOT NULL,
        reminder_title VARCHAR(255) NOT NULL,
        reminder_description TEXT,
        reminder_type ENUM('personal', 'class', 'deadline') DEFAULT 'personal',
        color VARCHAR(20) DEFAULT '#6366F1',
        is_completed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
""")
conn.commit()
print("Table BINARY_SUCCESS_REMINDERS created successfully!")
cursor.close()
conn.close()
