-- Fix admin keycloak_id linkage - Manual approach
-- Get the IDs from mock_users and update BINARY_SUCCESS_PLATFORM_USERS one by one

-- Step 1: Show current mock_users IDs
SELECT 'Mock Users IDs:' AS '';
SELECT id, email FROM mock_users WHERE email IN (
  'admin@binarysuccess.com',
  'superadmin@binarysuccess.com',
  'principal@springfield.edu',
  'admin@riverside.edu',
  'demo@example.com'
);

-- Step 2: Update each admin manually
-- Admin 1
UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = '26dfb413-0576-11f1-979b-4981acda40b0'
WHERE email = 'admin@binarysuccess.com';

-- Admin 2  
UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = '26e0a92c-0576-11f1-979b-4981acda40b0'
WHERE email = 'superadmin@binarysuccess.com';

-- Principal
UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = '26e0b1d3-0576-11f1-979b-4981acda40b0'
WHERE email = 'principal@springfield.edu';

-- Riverside Admin
UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = '26e0b5f6-0576-11f1-979b-4981acda40b0'
WHERE email = 'admin@riverside.edu';

-- Demo Admin
UPDATE BINARY_SUCCESS_PLATFORM_USERS 
SET keycloak_id = '26e0b9b7-0576-11f1-979b-4981acda40b0'
WHERE email = 'demo@example.com';

-- Step 3: Verify
SELECT 'Updated Platform Users:' AS '';
SELECT keycloak_id, email, first_name, last_name 
FROM BINARY_SUCCESS_PLATFORM_USERS 
WHERE email IN (
  'admin@binarysuccess.com',
  'superadmin@binarysuccess.com',
  'principal@springfield.edu',
  'admin@riverside.edu',
  'demo@example.com'
);
