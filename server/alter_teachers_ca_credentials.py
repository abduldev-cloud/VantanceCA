import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def alter_teachers_table():
    conn = get_mysql_connection()
    cursor = conn.cursor()

    try:
        # Add qualification column
        cursor.execute("SHOW COLUMNS FROM BINARY_SUCCESS_TEACHERS LIKE 'qualifications'")
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE BINARY_SUCCESS_TEACHERS ADD COLUMN qualifications VARCHAR(255) DEFAULT NULL")
            print("Added qualifications column to teachers table.")

        # Add primary_skills column
        cursor.execute("SHOW COLUMNS FROM BINARY_SUCCESS_TEACHERS LIKE 'primary_skills'")
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE BINARY_SUCCESS_TEACHERS ADD COLUMN primary_skills VARCHAR(255) DEFAULT NULL")
            print("Added primary_skills column to teachers table.")

        # Add experience_years column
        cursor.execute("SHOW COLUMNS FROM BINARY_SUCCESS_TEACHERS LIKE 'experience_years'")
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE BINARY_SUCCESS_TEACHERS ADD COLUMN experience_years INT DEFAULT 0")
            print("Added experience_years column to teachers table.")

        # Add verification_status column
        cursor.execute("SHOW COLUMNS FROM BINARY_SUCCESS_TEACHERS LIKE 'verification_status'")
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE BINARY_SUCCESS_TEACHERS ADD COLUMN verification_status VARCHAR(50) DEFAULT 'PENDING'")
            print("Added verification_status column to teachers table.")

        conn.commit()
        print("Teacher table successfully updated with CA credential columns.")

    except Exception as e:
        print(f"Error altering table: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    alter_teachers_table()
