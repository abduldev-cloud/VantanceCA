import mysql.connector

try:
    conn = mysql.connector.connect(
        user='root',
        password='1234',
        host='localhost',
        database='ca_exam'
    )
    cursor = conn.cursor()
    # Update 'Teacher' to 'teacher'
    cursor.execute("UPDATE mock_user_roles SET role_name = 'teacher' WHERE role_name = 'Teacher'")
    conn.commit()
    print(f'Rows updated: {cursor.rowcount}')
    
    # Verify
    cursor.execute("SELECT * FROM mock_user_roles WHERE role_name = 'teacher'")
    rows = cursor.fetchall()
    print(f"Verified 'teacher' roles: {len(rows)}")

except Exception as e:
    print(f"Error: {e}")
finally:
    if 'cursor' in locals(): cursor.close()
    if 'conn' in locals(): conn.close()
