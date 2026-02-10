import mysql.connector

try:
    conn = mysql.connector.connect(
        user='root',
        password='1234',
        host='localhost',
        database='ca_exam'
    )
    cursor = conn.cursor(dictionary=True)
    
    query = """
    SELECT u.username, u.email, r.role_name 
    FROM mock_users u 
    JOIN mock_user_roles r ON u.id = r.user_id
    """
    
    cursor.execute(query)
    rows = cursor.fetchall()
    
    print('User Roles:')
    for r in rows:
        print(f"{r['email']} - {r['role_name']}")
        
except Exception as e:
    print(f"Error: {e}")
finally:
    if 'cursor' in locals(): cursor.close()
    if 'conn' in locals(): conn.close()
