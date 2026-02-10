-- Link admin users from mock_users to BINARY_SUCCESS_PLATFORM_USERS
-- This allows the /db/users/get_user_entity_details endpoint to work

-- First, get the keycloak IDs from mock_users
SELECT 'Getting admin keycloak IDs from mock_users...' AS '';
SELECT id AS keycloak_id, username, email FROM mock_users 
WHERE email IN (
  'admin@binarysuccess.com',
  'superadmin@binarysuccess.com',
  'principal@springfield.edu',
  'admin@riverside.edu',
  'demo@example.com'
);

-- Update existing BINARY_SUCCESS_PLATFORM_USERS with correct keycloak_ids
-- Platform Admins
UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = (SELECT id FROM mock_users WHERE email = 'admin@binarysuccess.com')
WHERE email = 'admin@binarysuccess.com';

UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = (SELECT id FROM mock_users WHERE email = 'superadmin@binarysuccess.com')
WHERE email = 'superadmin@binarysuccess.com';

-- School Admins
UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = (SELECT id FROM mock_users WHERE email = 'principal@springfield.edu')
WHERE email = 'principal@springfield.edu';

UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = (SELECT id FROM mock_users WHERE email = 'admin@riverside.edu')
WHERE email = 'admin@riverside.edu';

UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = (SELECT id FROM mock_users WHERE email = 'demo@example.com')
WHERE email = 'demo@example.com';

-- Verify the linkage
SELECT 'Verification - Platform users with keycloak IDs:' AS '';
SELECT user_id, keycloak_id, email, username, first_name, last_name, r.role_name
FROM BINARY_SUCCESS_PLATFORM_USERS u
JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id
WHERE email IN (
  'admin@binarysuccess.com',
  'superadmin@binarysuccess.com',
  'principal@springfield.edu',
  'admin@riverside.edu',
  'demo@example.com'
);
