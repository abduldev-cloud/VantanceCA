import sys
import os

# Add the server directory to python path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.core.database_mysql import get_mysql_connection

def update_table():
    conn = get_mysql_connection()
    cursor = conn.cursor()
    
    try:
        # Check if column exists, if not add it
        cursor.execute("""
            SELECT COUNT(*) 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() 
            AND TABLE_NAME = 'BINARY_SUCCESS_PLATFORM_INSTITUTES' 
            AND COLUMN_NAME = 'primary_color';
        """)
        
        if cursor.fetchone()[0] == 0:
            print("Adding branding columns...")
            cursor.execute("ALTER TABLE BINARY_SUCCESS_PLATFORM_INSTITUTES ADD COLUMN primary_color VARCHAR(20) DEFAULT '#0A8041'")
            cursor.execute("ALTER TABLE BINARY_SUCCESS_PLATFORM_INSTITUTES ADD COLUMN logo_url VARCHAR(500) DEFAULT NULL")
            conn.commit()
            print("Columns added successfully.")
        else:
            print("Columns already exist.")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    update_table()
