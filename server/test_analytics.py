"""Test analytics endpoint directly"""
import sys
sys.path.insert(0, 'app')

from modules.analytics.routes import fetch_one_mysql, fetch_all_mysql

try:
    print("Testing fetch_one_mysql...")
    result = fetch_one_mysql("SELECT COUNT(*) as total_users FROM BINARY_SUCCESS_PLATFORM_USERS")
    print(f"✅ fetch_one_mysql works: {result}")
    
    print("\nTesting fetch_all_mysql...")
    results = fetch_all_mysql("SELECT role_id, role_name FROM BINARY_SUCCESS_ROLES LIMIT 3")
    print(f"✅ fetch_all_mysql works: {results}")
    
    print("\n✅ All helper functions work correctly!")
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
