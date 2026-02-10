-- ============================================================================
-- Binary Success Platform - Sample Seed Data
-- Realistic test data for local development
-- ============================================================================

SET @now = NOW();

-- ============================================================================
-- 1. LOOKUP/REFERENCE DATA
-- ============================================================================

-- Roles
INSERT INTO BINARY_SUCCESS_ROLES (role_id, role_name, role_description) VALUES
('role-001', 'PLATFORM_ADMIN', 'Platform Administrator with full access'),
('role-002', 'INSTITUTE_ADMIN', 'School/Institute Administrator'),
('role-003', 'TEACHER', 'Teacher/Instructor'),
('role-004', 'LEARNER', 'Student/Learner');

-- Statuses
INSERT INTO BINARY_SUCCESS_STATUSES (status_id, status_code, status_name, status_description) VALUES
('status-001', 'ACTIVE', 'Active', 'Entity is active and operational'),
('status-002', 'INACTIVE', 'Inactive', 'Entity is inactive'),
('status-003', 'PENDING', 'Pending', 'Entity is pending approval'),
('status-004', 'SUSPENDED', 'Suspended', 'Entity is temporarily suspended');

-- Grade Levels
INSERT INTO BINARY_SUCCESS_GRADE_LEVELS (grade_level_id, grade_name, grade_order) VALUES
('grade-001', 'Grade 6', 6),
('grade-002', 'Grade 7', 7),
('grade-003', 'Grade 8', 8),
('grade-004', 'Grade 9', 9),
('grade-005', 'Grade 10', 10),
('grade-006', 'Grade 11', 11),
('grade-007', 'Grade 12', 12);

-- Task Types
INSERT INTO BINARY_SUCCESS_TASK_TYPES (task_type_id, task_type, task_type_description) VALUES
('tasktype-001', 'ASSIGNMENT', 'Regular assignment'),
('tasktype-002', 'FINGERPRINT', 'Writing fingerprint analysis'),
('tasktype-003', 'QUIZ', 'Quiz or test'),
('tasktype-004', 'ESSAY', 'Essay writing'),
('tasktype-005', 'PROJECT', 'Project work');

-- Task Statuses
INSERT INTO BINARY_SUCCESS_TASK_STATUSES (status_id, status, status_description) VALUES
('taskstatus-001', 'ASSIGNED', 'Task assigned to student'),
('taskstatus-002', 'IN_PROGRESS', 'Student is working on task'),
('taskstatus-003', 'SUBMITTED', 'Task submitted by student'),
('taskstatus-004', 'GRADED', 'Task graded by teacher'),
('taskstatus-005', 'RETURNED', 'Task returned to student');

-- ============================================================================
-- 2. INSTITUTES (SCHOOLS)
-- ============================================================================

INSERT INTO BINARY_SUCCESS_PLATFORM_INSTITUTES (
    institute_id, institute_name, institute_code, institute_email, 
    institute_phone, institute_city, institute_state, institute_country,
    institute_status_id, is_demo
) VALUES
('inst-001', 'Springfield High School', 'SHS001', 'admin@springfield.edu', 
 '+1-555-0101', 'Springfield', 'Illinois', 'USA', 'status-001', 'N'),
 
('inst-002', 'Riverside Academy', 'RVA002', 'info@riverside.edu', 
 '+1-555-0102', 'Riverside', 'California', 'USA', 'status-001', 'N'),
 
('inst-003', 'Demo School', 'DEMO003', 'demo@example.com', 
 '+1-555-0103', 'Demo City', 'Demo State', 'USA', 'status-001', 'Y');

-- ============================================================================
-- 3. PLATFORM USERS
-- ============================================================================

-- Platform Admins (2)
INSERT INTO BINARY_SUCCESS_PLATFORM_USERS (
    user_id, keycloak_id, email, username, first_name, last_name,
    role_id, institute_id, status_id
) VALUES
('user-001', 'kc-admin-001', 'admin@binarysuccess.com', 'admin1', 'Alice', 'Admin',
 'role-001', NULL, 'status-001'),
('user-002', 'kc-admin-002', 'superadmin@binarysuccess.com', 'admin2', 'Bob', 'SuperAdmin',
 'role-001', NULL, 'status-001');

-- Institute Admins (3)
INSERT INTO BINARY_SUCCESS_PLATFORM_USERS (
    user_id, keycloak_id, email, username, first_name, last_name,
    role_id, institute_id, status_id
) VALUES
('user-003', 'kc-inst-001', 'principal@springfield.edu', 'principal1', 'Carol', 'Principal',
 'role-002', 'inst-001', 'status-001'),
('user-004', 'kc-inst-002', 'admin@riverside.edu', 'admin_rv', 'David', 'Director',
 'role-002', 'inst-002', 'status-001'),
('user-005', 'kc-inst-003', 'demo@example.com', 'demo_admin', 'Demo', 'Admin',
 'role-002', 'inst-003', 'status-001');

-- Teachers (5)
INSERT INTO BINARY_SUCCESS_PLATFORM_USERS (
    user_id, keycloak_id, email, username, first_name, last_name,
    role_id, institute_id, status_id
) VALUES
('user-006', 'kc-teacher-001', 'ah303130@gmail.com', 'teacher1', 'Emma', 'Thompson',
 'role-003', 'inst-001', 'status-001'),
('user-007', 'kc-teacher-002', 'frank.miller@springfield.edu', 'teacher2', 'Frank', 'Miller',
 'role-003', 'inst-001', 'status-001'),
('user-008', 'kc-teacher-003', 'grace.lee@riverside.edu', 'teacher3', 'Grace', 'Lee',
 'role-003', 'inst-002', 'status-001'),
('user-009', 'kc-teacher-004', 'henry.wilson@riverside.edu', 'teacher4', 'Henry', 'Wilson',
 'role-003', 'inst-002', 'status-001'),
('user-010', 'kc-teacher-005', 'demo.teacher@example.com', 'demo_teacher', 'Demo', 'Teacher',
 'role-003', 'inst-003', 'status-001');

-- Students (10)
INSERT INTO BINARY_SUCCESS_PLATFORM_USERS (
    user_id, keycloak_id, email, username, first_name, last_name,
    role_id, institute_id, status_id
) VALUES
('user-011', 'kc-student-001', 'student1@springfield.edu', 'student1', 'Ivy', 'Johnson',
 'role-004', 'inst-001', 'status-001'),
('user-012', 'kc-student-002', 'student2@springfield.edu', 'student2', 'Jack', 'Brown',
 'role-004', 'inst-001', 'status-001'),
('user-013', 'kc-student-003', 'student3@springfield.edu', 'student3', 'Kate', 'Davis',
 'role-004', 'inst-001', 'status-001'),
('user-014', 'kc-student-004', 'student4@springfield.edu', 'student4', 'Liam', 'Martinez',
 'role-004', 'inst-001', 'status-001'),
('user-015', 'kc-student-005', 'student5@riverside.edu', 'student5', 'Mia', 'Garcia',
 'role-004', 'inst-002', 'status-001'),
('user-016', 'kc-student-006', 'student6@riverside.edu', 'student6', 'Noah', 'Rodriguez',
 'role-004', 'inst-002', 'status-001'),
('user-017', 'kc-student-007', 'student7@riverside.edu', 'student7', 'Olivia', 'Hernandez',
 'role-004', 'inst-002', 'status-001'),
('user-018', 'kc-student-008', 'student8@riverside.edu', 'student8', 'Peter', 'Lopez',
 'role-004', 'inst-002', 'status-001'),
('user-019', 'kc-student-009', 'demo.student1@example.com', 'demo_student1', 'Demo', 'Student1',
 'role-004', 'inst-003', 'status-001'),
('user-020', 'kc-student-010', 'demo.student2@example.com', 'demo_student2', 'Demo', 'Student2',
 'role-004', 'inst-003', 'status-001');

-- ============================================================================
-- 4. TEACHERS & LEARNERS
-- ============================================================================

-- Teachers
INSERT INTO BINARY_SUCCESS_TEACHERS (teacher_id, user_id, institute_id, teacher_code, department, specialization) VALUES
('teacher-001', 'user-006', 'inst-001', 'T001', 'English', 'Literature'),
('teacher-002', 'user-007', 'inst-001', 'T002', 'Mathematics', 'Algebra'),
('teacher-003', 'user-008', 'inst-002', 'T003', 'Science', 'Biology'),
('teacher-004', 'user-009', 'inst-002', 'T004', 'History', 'World History'),
('teacher-005', 'user-010', 'inst-003', 'T005', 'English', 'Writing');

-- Learners
INSERT INTO BINARY_SUCCESS_LEARNERS (learner_id, user_id, institute_id, learner_code, grade_level_id) VALUES
('learner-001', 'user-011', 'inst-001', 'S001', 'grade-004'),
('learner-002', 'user-012', 'inst-001', 'S002', 'grade-004'),
('learner-003', 'user-013', 'inst-001', 'S003', 'grade-005'),
('learner-004', 'user-014', 'inst-001', 'S004', 'grade-005'),
('learner-005', 'user-015', 'inst-002', 'S005', 'grade-004'),
('learner-006', 'user-016', 'inst-002', 'S006', 'grade-004'),
('learner-007', 'user-017', 'inst-002', 'S007', 'grade-005'),
('learner-008', 'user-018', 'inst-002', 'S008', 'grade-005'),
('learner-009', 'user-019', 'inst-003', 'S009', 'grade-004'),
('learner-010', 'user-020', 'inst-003', 'S010', 'grade-004');

-- ============================================================================
-- 5. CLASSES
-- ============================================================================

INSERT INTO BINARY_SUCCESS_CLASSES (
    class_id, class_name, class_code, institute_id, grade_level_id, 
    term, academic_year, teacher_id
) VALUES
('class-001', 'English 9A', 'ENG9A', 'inst-001', 'grade-004', 'Fall', '2025-2026', 'teacher-001'),
('class-002', 'English 10B', 'ENG10B', 'inst-001', 'grade-005', 'Fall', '2025-2026', 'teacher-001'),
('class-003', 'Math 9A', 'MATH9A', 'inst-001', 'grade-004', 'Fall', '2025-2026', 'teacher-002'),
('class-004', 'Math 10A', 'MATH10A', 'inst-001', 'grade-005', 'Fall', '2025-2026', 'teacher-002'),
('class-005', 'Biology 9A', 'BIO9A', 'inst-002', 'grade-004', 'Fall', '2025-2026', 'teacher-003'),
('class-006', 'Biology 10A', 'BIO10A', 'inst-002', 'grade-005', 'Fall', '2025-2026', 'teacher-003'),
('class-007', 'History 9A', 'HIST9A', 'inst-002', 'grade-004', 'Fall', '2025-2026', 'teacher-004'),
('class-008', 'History 10A', 'HIST10A', 'inst-002', 'grade-005', 'Fall', '2025-2026', 'teacher-004'),
('class-009', 'Demo Class 1', 'DEMO1', 'inst-003', 'grade-004', 'Fall', '2025-2026', 'teacher-005'),
('class-010', 'Demo Class 2', 'DEMO2', 'inst-003', 'grade-004', 'Fall', '2025-2026', 'teacher-005');

-- ============================================================================
-- 6. ENROLLMENTS
-- ============================================================================

INSERT INTO BINARY_SUCCESS_ENROLLMENTS (enrollment_id, learner_id, class_id, status) VALUES
-- Springfield students
('enroll-001', 'learner-001', 'class-001', 'ACTIVE'),
('enroll-002', 'learner-001', 'class-003', 'ACTIVE'),
('enroll-003', 'learner-002', 'class-001', 'ACTIVE'),
('enroll-004', 'learner-002', 'class-003', 'ACTIVE'),
('enroll-005', 'learner-003', 'class-002', 'ACTIVE'),
('enroll-006', 'learner-003', 'class-004', 'ACTIVE'),
('enroll-007', 'learner-004', 'class-002', 'ACTIVE'),
('enroll-008', 'learner-004', 'class-004', 'ACTIVE'),
-- Riverside students
('enroll-009', 'learner-005', 'class-005', 'ACTIVE'),
('enroll-010', 'learner-005', 'class-007', 'ACTIVE'),
('enroll-011', 'learner-006', 'class-005', 'ACTIVE'),
('enroll-012', 'learner-006', 'class-007', 'ACTIVE'),
('enroll-013', 'learner-007', 'class-006', 'ACTIVE'),
('enroll-014', 'learner-007', 'class-008', 'ACTIVE'),
('enroll-015', 'learner-008', 'class-006', 'ACTIVE'),
('enroll-016', 'learner-008', 'class-008', 'ACTIVE'),
-- Demo students
('enroll-017', 'learner-009', 'class-009', 'ACTIVE'),
('enroll-018', 'learner-010', 'class-010', 'ACTIVE');

-- ============================================================================
-- 7. TEACHER TASKS (ASSIGNMENTS)
-- ============================================================================

-- Assignments from last 3 months
INSERT INTO BINARY_SUCCESS_TEACHER_TASKS (
    task_id, task_title, task_description, task_type_id, teacher_id, 
    class_id, institute_id, due_date, max_score, created_at
) VALUES
-- Teacher 1 (Emma) - English assignments
('task-001', 'Essay: My Summer Vacation', 'Write a 500-word essay about your summer vacation', 
 'tasktype-004', 'teacher-001', 'class-001', 'inst-001', DATE_ADD(@now, INTERVAL 7 DAY), 100, DATE_SUB(@now, INTERVAL 60 DAY)),
('task-002', 'Writing Fingerprint Analysis', 'Initial writing sample for fingerprint analysis', 
 'tasktype-002', 'teacher-001', 'class-001', 'inst-001', DATE_ADD(@now, INTERVAL 14 DAY), 100, DATE_SUB(@now, INTERVAL 55 DAY)),
('task-003', 'Book Report: To Kill a Mockingbird', 'Write a comprehensive book report', 
 'tasktype-001', 'teacher-001', 'class-002', 'inst-001', DATE_ADD(@now, INTERVAL 21 DAY), 100, DATE_SUB(@now, INTERVAL 50 DAY)),
('task-004', 'Poetry Analysis', 'Analyze Robert Frost poems', 
 'tasktype-001', 'teacher-001', 'class-002', 'inst-001', DATE_ADD(@now, INTERVAL 28 DAY), 100, DATE_SUB(@now, INTERVAL 45 DAY)),

-- Teacher 2 (Frank) - Math assignments
('task-005', 'Algebra Quiz 1', 'Solve linear equations', 
 'tasktype-003', 'teacher-002', 'class-003', 'inst-001', DATE_ADD(@now, INTERVAL 3 DAY), 100, DATE_SUB(@now, INTERVAL 40 DAY)),
('task-006', 'Geometry Project', 'Create geometric shapes project', 
 'tasktype-005', 'teacher-002', 'class-004', 'inst-001', DATE_ADD(@now, INTERVAL 30 DAY), 100, DATE_SUB(@now, INTERVAL 35 DAY)),

-- Teacher 3 (Grace) - Biology assignments
('task-007', 'Cell Structure Assignment', 'Describe cell organelles and their functions', 
 'tasktype-001', 'teacher-003', 'class-005', 'inst-002', DATE_ADD(@now, INTERVAL 10 DAY), 100, DATE_SUB(@now, INTERVAL 30 DAY)),
('task-008', 'Photosynthesis Essay', 'Explain the process of photosynthesis', 
 'tasktype-004', 'teacher-003', 'class-006', 'inst-002', DATE_ADD(@now, INTERVAL 15 DAY), 100, DATE_SUB(@now, INTERVAL 25 DAY)),

-- Teacher 4 (Henry) - History assignments
('task-009', 'World War II Research', 'Research and present on WWII events', 
 'tasktype-005', 'teacher-004', 'class-007', 'inst-002', DATE_ADD(@now, INTERVAL 20 DAY), 100, DATE_SUB(@now, INTERVAL 20 DAY)),
('task-010', 'Ancient Civilizations Quiz', 'Quiz on ancient civilizations', 
 'tasktype-003', 'teacher-004', 'class-008', 'inst-002', DATE_ADD(@now, INTERVAL 5 DAY), 100, DATE_SUB(@now, INTERVAL 15 DAY));

-- ============================================================================
-- 8. LEARNER TASKS (SUBMISSIONS)
-- ============================================================================

-- Generate submissions with varying statuses and scores
INSERT INTO BINARY_SUCCESS_LEARNER_TASKS (
    learner_task_id, task_id, learner_id, status_id, submission_text, 
    score, deviation_percentage, assigned_at, submitted_at, graded_at
) VALUES
-- Task 1 submissions (Essay)
('ltask-001', 'task-001', 'learner-001', 'taskstatus-004', 'My summer vacation was amazing...', 
 85.5, '42.3', DATE_SUB(@now, INTERVAL 60 DAY), DATE_SUB(@now, INTERVAL 53 DAY), DATE_SUB(@now, INTERVAL 52 DAY)),
('ltask-002', 'task-001', 'learner-002', 'taskstatus-004', 'This summer I went to the beach...', 
 78.0, '38.7', DATE_SUB(@now, INTERVAL 60 DAY), DATE_SUB(@now, INTERVAL 54 DAY), DATE_SUB(@now, INTERVAL 52 DAY)),

-- Task 2 submissions (Fingerprint)
('ltask-003', 'task-002', 'learner-001', 'taskstatus-004', 'Writing sample for analysis...', 
 90.0, '45.2', DATE_SUB(@now, INTERVAL 55 DAY), DATE_SUB(@now, INTERVAL 48 DAY), DATE_SUB(@now, INTERVAL 47 DAY)),
('ltask-004', 'task-002', 'learner-002', 'taskstatus-004', 'My writing style is unique...', 
 88.5, '52.8', DATE_SUB(@now, INTERVAL 55 DAY), DATE_SUB(@now, INTERVAL 49 DAY), DATE_SUB(@now, INTERVAL 47 DAY)),

-- Task 3 submissions (Book Report)
('ltask-005', 'task-003', 'learner-003', 'taskstatus-003', 'To Kill a Mockingbird is a powerful novel...', 
 NULL, '41.5', DATE_SUB(@now, INTERVAL 50 DAY), DATE_SUB(@now, INTERVAL 2 DAY), NULL),
('ltask-006', 'task-003', 'learner-004', 'taskstatus-004', 'The book explores themes of racism...', 
 92.0, '47.3', DATE_SUB(@now, INTERVAL 50 DAY), DATE_SUB(@now, INTERVAL 43 DAY), DATE_SUB(@now, INTERVAL 42 DAY)),

-- Task 4 submissions (Poetry)
('ltask-007', 'task-004', 'learner-003', 'taskstatus-002', NULL, 
 NULL, NULL, DATE_SUB(@now, INTERVAL 45 DAY), NULL, NULL),
('ltask-008', 'task-004', 'learner-004', 'taskstatus-003', 'Robert Frost uses nature imagery...', 
 NULL, '39.8', DATE_SUB(@now, INTERVAL 45 DAY), DATE_SUB(@now, INTERVAL 1 DAY), NULL),

-- Task 5 submissions (Math Quiz)
('ltask-009', 'task-005', 'learner-001', 'taskstatus-004', 'Quiz answers: 1.x=5, 2.y=3...', 
 95.0, NULL, DATE_SUB(@now, INTERVAL 40 DAY), DATE_SUB(@now, INTERVAL 37 DAY), DATE_SUB(@now, INTERVAL 36 DAY)),
('ltask-010', 'task-005', 'learner-002', 'taskstatus-004', 'Quiz answers: 1.x=5, 2.y=2...', 
 82.0, NULL, DATE_SUB(@now, INTERVAL 40 DAY), DATE_SUB(@now, INTERVAL 38 DAY), DATE_SUB(@now, INTERVAL 36 DAY)),

-- Task 7 submissions (Biology)
('ltask-011', 'task-007', 'learner-005', 'taskstatus-004', 'Cell organelles include nucleus, mitochondria...', 
 87.5, '44.1', DATE_SUB(@now, INTERVAL 30 DAY), DATE_SUB(@now, INTERVAL 23 DAY), DATE_SUB(@now, INTERVAL 22 DAY)),
('ltask-012', 'task-007', 'learner-006', 'taskstatus-003', 'The nucleus controls cell activities...', 
 NULL, '36.9', DATE_SUB(@now, INTERVAL 30 DAY), DATE_SUB(@now, INTERVAL 3 DAY), NULL);

-- ============================================================================
-- 9. AI USAGE STATISTICS
-- ============================================================================

INSERT INTO BINARY_SUCCESS_AI_USAGE_STATS (usage_id, task_id, learner_id, used_count, prompt_type) VALUES
-- High AI usage
('aiusage-001', 'task-001', 'learner-001', 15, 'grammar_check'),
('aiusage-002', 'task-001', 'learner-001', 8, 'paraphrase'),
('aiusage-003', 'task-001', 'learner-002', 22, 'grammar_check'),
('aiusage-004', 'task-001', 'learner-002', 12, 'expand_ideas'),

-- Medium AI usage
('aiusage-005', 'task-002', 'learner-001', 5, 'grammar_check'),
('aiusage-006', 'task-002', 'learner-002', 7, 'grammar_check'),

-- Low AI usage
('aiusage-007', 'task-003', 'learner-003', 3, 'grammar_check'),
('aiusage-008', 'task-003', 'learner-004', 2, 'paraphrase'),

-- Biology assignments
('aiusage-009', 'task-007', 'learner-005', 10, 'research_help'),
('aiusage-010', 'task-007', 'learner-006', 18, 'grammar_check');

-- ============================================================================
-- 10. WRITING FINGERPRINTS
-- ============================================================================

INSERT INTO BINARY_SUCCESS_WRITING_FINGERPRINTS (
    fingerprint_id, learner_task_id, learner_id, deviation_percentage, analysis_data
) VALUES
('fp-001', 'ltask-001', 'learner-001', 42.30, '{"vocabulary_richness": 0.65, "sentence_complexity": 0.72}'),
('fp-002', 'ltask-002', 'learner-002', 38.70, '{"vocabulary_richness": 0.58, "sentence_complexity": 0.68}'),
('fp-003', 'ltask-003', 'learner-001', 45.20, '{"vocabulary_richness": 0.70, "sentence_complexity": 0.75}'),
('fp-004', 'ltask-004', 'learner-002', 52.80, '{"vocabulary_richness": 0.78, "sentence_complexity": 0.82}'),
('fp-005', 'ltask-005', 'learner-003', 41.50, '{"vocabulary_richness": 0.64, "sentence_complexity": 0.71}'),
('fp-006', 'ltask-006', 'learner-004', 47.30, '{"vocabulary_richness": 0.73, "sentence_complexity": 0.76}'),
('fp-007', 'ltask-011', 'learner-005', 44.10, '{"vocabulary_richness": 0.68, "sentence_complexity": 0.74}'),
('fp-008', 'ltask-012', 'learner-006', 36.90, '{"vocabulary_richness": 0.55, "sentence_complexity": 0.65}');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

SELECT 'Seed data inserted successfully!' AS message;
SELECT 'Summary:' AS '';
SELECT COUNT(*) AS total_users FROM BINARY_SUCCESS_PLATFORM_USERS;
SELECT COUNT(*) AS total_institutes FROM BINARY_SUCCESS_PLATFORM_INSTITUTES;
SELECT COUNT(*) AS total_teachers FROM BINARY_SUCCESS_TEACHERS;
SELECT COUNT(*) AS total_learners FROM BINARY_SUCCESS_LEARNERS;
SELECT COUNT(*) AS total_classes FROM BINARY_SUCCESS_CLASSES;
SELECT COUNT(*) AS total_enrollments FROM BINARY_SUCCESS_ENROLLMENTS;
SELECT COUNT(*) AS total_assignments FROM BINARY_SUCCESS_TEACHER_TASKS;
SELECT COUNT(*) AS total_submissions FROM BINARY_SUCCESS_LEARNER_TASKS;
SELECT COUNT(*) AS total_ai_usage FROM BINARY_SUCCESS_AI_USAGE_STATS;
