import mysql.connector

conn = mysql.connector.connect(
    user='root',
    password='1234',
    host='localhost',
    database='ca_exam'
)

cursor = conn.cursor(dictionary=True)
cursor.execute('SELECT id, username, email, first_name, last_name, enabled FROM mock_users')
users = cursor.fetchall()

print('Users in ca_exam database:')
for u in users:
    print(f"  - {u['email']} ({u['first_name']} {u['last_name']})")
print(f'\nTotal: {len(users)} user(s)')

cursor.close()
conn.close()
