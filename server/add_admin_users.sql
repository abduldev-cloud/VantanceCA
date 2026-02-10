-- Add admin users to mock_users table
-- Password for all: admin123

-- Check if table exists and show current users
SELECT 'Current users:' AS '';
SELECT id, username, email FROM mock_users;

-- Insert admin users (id will auto-increment)
INSERT INTO mock_users (id, username, email, password, first_name, last_name, enabled, created_at)
VALUES 
  (UUID(), 'admin1', 'admin@binarysuccess.com', 'admin123', 'Alice', 'Admin', 1, NOW()),
  (UUID(), 'admin2', 'superadmin@binarysuccess.com', 'admin123', 'Bob', 'SuperAdmin', 1, NOW()),
  (UUID(), 'principal1', 'principal@springfield.edu', 'admin123', 'Carol', 'Principal', 1, NOW()),
  (UUID(), 'admin_rv', 'admin@riverside.edu', 'admin123', 'David', 'Director', 1, NOW()),
  (UUID(), 'demo_admin', 'demo@example.com', 'admin123', 'Demo', 'Admin', 1, NOW())
ON DUPLICATE KEY UPDATE password = 'admin123';

-- Verify insertion
SELECT 'Admin users added:' AS '';
SELECT id, username, email, first_name, last_name FROM mock_users 
WHERE email IN (
  'admin@binarysuccess.com',
  'superadmin@binarysuccess.com', 
  'principal@springfield.edu',
  'admin@riverside.edu',
  'demo@example.com'
);
