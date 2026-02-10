import mysql.connector

try:
    conn = mysql.connector.connect(
        user='root',
        password='1234',
        host='localhost',
        database='ca_exam'
    )
    cursor = conn.cursor(dictionary=True)
    
    email = 'ah303130@gmail.com'
    
    # Get user ID
    cursor.execute("SELECT id FROM mock_users WHERE email = %s", (email,))
    user = cursor.fetchone()
    
    if user:
        user_id = user['id']
        print(f"User found: {email} (ID: {user_id})")
        
        # Check entity details
        cursor.execute("SELECT * FROM user_entity_details WHERE keycloak_id = %s", (user_id,))
        details = cursor.fetchone()
        
        if details:
            print("✅ Entity details found:")
            print(details)
        else:
            print("❌ Entity details NOT found. Running create_user_tables.py might be needed.")
            
            # Insert details if missing
            print("Attempting to insert default entity details...")
            
            # Generate IDs for the user
            db_user_id = f"USER_{user_id[:8]}"
            role_entity_id = f"ENTITY_{user_id[:8]}"
            institute_id = f"INST_{user_id[:8]}"
            
            cursor.execute("""
                INSERT INTO user_entity_details 
                (keycloak_id, user_id, role_entity_id, institute_id, 
                    is_demo_school, role_display_name, crm_contact_id, crm_account_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                user_id,
                db_user_id,
                role_entity_id,
                institute_id,
                'false',
                'Teacher',  # Role display name
                f"CRM_CONTACT_{user_id[:8]}",
                f"CRM_ACCOUNT_{user_id[:8]}"
            ))
            conn.commit()
            print("✅ Created entity details for teacher.")
            
    else:
        print(f"User not found: {email}")

except Exception as e:
    print(f"Error: {e}")
finally:
    if 'cursor' in locals(): cursor.close()
    if 'conn' in locals(): conn.close()
