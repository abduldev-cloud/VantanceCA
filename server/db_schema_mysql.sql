-- ============================================================================
-- Binary Success Platform - MySQL Database Schema
-- Converted from Oracle Production Schema
-- ============================================================================

-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS BINARY_SUCCESS_AI_USAGE_STATS;
DROP TABLE IF EXISTS BINARY_SUCCESS_WRITING_FINGERPRINTS;
DROP TABLE IF EXISTS BINARY_SUCCESS_SUBMISSIONS;
DROP TABLE IF EXISTS BINARY_SUCCESS_LEARNER_TASKS;
DROP TABLE IF EXISTS BINARY_SUCCESS_TEACHER_TASKS;
DROP TABLE IF EXISTS BINARY_SUCCESS_ENROLLMENTS;
DROP TABLE IF EXISTS BINARY_SUCCESS_CLASSES;
DROP TABLE IF EXISTS BINARY_SUCCESS_LEARNERS;
DROP TABLE IF EXISTS BINARY_SUCCESS_TEACHERS;
DROP TABLE IF EXISTS BINARY_SUCCESS_PLATFORM_USERS;
DROP TABLE IF EXISTS BINARY_SUCCESS_PLATFORM_INSTITUTES;
DROP TABLE IF EXISTS BINARY_SUCCESS_TASK_STATUSES;
DROP TABLE IF EXISTS BINARY_SUCCESS_TASK_TYPES;
DROP TABLE IF EXISTS BINARY_SUCCESS_GRADE_LEVELS;
DROP TABLE IF EXISTS BINARY_SUCCESS_STATUSES;
DROP TABLE IF EXISTS BINARY_SUCCESS_ROLES;

-- ============================================================================
-- LOOKUP/REFERENCE TABLES
-- ============================================================================

-- Roles Table
CREATE TABLE BINARY_SUCCESS_ROLES (
    role_id VARCHAR(36) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Statuses Table (for users, institutes, etc.)
CREATE TABLE BINARY_SUCCESS_STATUSES (
    status_id VARCHAR(36) PRIMARY KEY,
    status_code VARCHAR(20) NOT NULL UNIQUE,
    status_name VARCHAR(50) NOT NULL,
    status_description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Grade Levels Table
CREATE TABLE BINARY_SUCCESS_GRADE_LEVELS (
    grade_level_id VARCHAR(36) PRIMARY KEY,
    grade_name VARCHAR(50) NOT NULL,
    grade_order INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Task Types Table
CREATE TABLE BINARY_SUCCESS_TASK_TYPES (
    task_type_id VARCHAR(36) PRIMARY KEY,
    task_type VARCHAR(50) NOT NULL UNIQUE,
    task_type_description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Task Statuses Table
CREATE TABLE BINARY_SUCCESS_TASK_STATUSES (
    status_id VARCHAR(36) PRIMARY KEY,
    status VARCHAR(50) NOT NULL UNIQUE,
    status_description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- CORE ENTITY TABLES
-- ============================================================================

-- Platform Institutes (Schools)
CREATE TABLE BINARY_SUCCESS_PLATFORM_INSTITUTES (
    institute_id VARCHAR(36) PRIMARY KEY,
    institute_name VARCHAR(255) NOT NULL,
    institute_code VARCHAR(50) UNIQUE,
    institute_email VARCHAR(255),
    institute_phone VARCHAR(20),
    institute_address TEXT,
    institute_city VARCHAR(100),
    institute_state VARCHAR(100),
    institute_country VARCHAR(100),
    institute_zipcode VARCHAR(20),
    institute_status_id VARCHAR(36),
    is_demo CHAR(1) DEFAULT 'N',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (institute_status_id) REFERENCES BINARY_SUCCESS_STATUSES(status_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Platform Users
CREATE TABLE BINARY_SUCCESS_PLATFORM_USERS (
    user_id VARCHAR(36) PRIMARY KEY,
    keycloak_id VARCHAR(255) UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_id VARCHAR(36),
    institute_id VARCHAR(36),
    status_id VARCHAR(36),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    FOREIGN KEY (role_id) REFERENCES BINARY_SUCCESS_ROLES(role_id),
    FOREIGN KEY (institute_id) REFERENCES BINARY_SUCCESS_PLATFORM_INSTITUTES(institute_id),
    FOREIGN KEY (status_id) REFERENCES BINARY_SUCCESS_STATUSES(status_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Teachers
CREATE TABLE BINARY_SUCCESS_TEACHERS (
    teacher_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    institute_id VARCHAR(36),
    teacher_code VARCHAR(50),
    department VARCHAR(100),
    specialization VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES BINARY_SUCCESS_PLATFORM_USERS(user_id),
    FOREIGN KEY (institute_id) REFERENCES BINARY_SUCCESS_PLATFORM_INSTITUTES(institute_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Learners (Students)
CREATE TABLE BINARY_SUCCESS_LEARNERS (
    learner_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    institute_id VARCHAR(36),
    learner_code VARCHAR(50),
    grade_level_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES BINARY_SUCCESS_PLATFORM_USERS(user_id),
    FOREIGN KEY (institute_id) REFERENCES BINARY_SUCCESS_PLATFORM_INSTITUTES(institute_id),
    FOREIGN KEY (grade_level_id) REFERENCES BINARY_SUCCESS_GRADE_LEVELS(grade_level_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Classes
CREATE TABLE BINARY_SUCCESS_CLASSES (
    class_id VARCHAR(36) PRIMARY KEY,
    class_name VARCHAR(255) NOT NULL,
    class_code VARCHAR(50),
    institute_id VARCHAR(36),
    grade_level_id VARCHAR(36),
    term VARCHAR(50),
    academic_year VARCHAR(20),
    teacher_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (institute_id) REFERENCES BINARY_SUCCESS_PLATFORM_INSTITUTES(institute_id),
    FOREIGN KEY (grade_level_id) REFERENCES BINARY_SUCCESS_GRADE_LEVELS(grade_level_id),
    FOREIGN KEY (teacher_id) REFERENCES BINARY_SUCCESS_TEACHERS(teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Enrollments (Student-Class relationship)
CREATE TABLE BINARY_SUCCESS_ENROLLMENTS (
    enrollment_id VARCHAR(36) PRIMARY KEY,
    learner_id VARCHAR(36) NOT NULL,
    class_id VARCHAR(36) NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    FOREIGN KEY (learner_id) REFERENCES BINARY_SUCCESS_LEARNERS(learner_id),
    FOREIGN KEY (class_id) REFERENCES BINARY_SUCCESS_CLASSES(class_id),
    UNIQUE KEY unique_enrollment (learner_id, class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- ASSIGNMENT/TASK TABLES
-- ============================================================================

-- Teacher Tasks (Assignments created by teachers)
CREATE TABLE BINARY_SUCCESS_TEACHER_TASKS (
    task_id VARCHAR(36) PRIMARY KEY,
    task_title VARCHAR(255) NOT NULL,
    task_description TEXT,
    task_type_id VARCHAR(36),
    teacher_id VARCHAR(36),
    class_id VARCHAR(36),
    institute_id VARCHAR(36),
    due_date TIMESTAMP NULL,
    max_score DECIMAL(10,2) DEFAULT 100.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (task_type_id) REFERENCES BINARY_SUCCESS_TASK_TYPES(task_type_id),
    FOREIGN KEY (teacher_id) REFERENCES BINARY_SUCCESS_TEACHERS(teacher_id),
    FOREIGN KEY (class_id) REFERENCES BINARY_SUCCESS_CLASSES(class_id),
    FOREIGN KEY (institute_id) REFERENCES BINARY_SUCCESS_PLATFORM_INSTITUTES(institute_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Learner Tasks (Student submissions)
CREATE TABLE BINARY_SUCCESS_LEARNER_TASKS (
    learner_task_id VARCHAR(36) PRIMARY KEY,
    task_id VARCHAR(36) NOT NULL,
    learner_id VARCHAR(36) NOT NULL,
    status_id VARCHAR(36),
    submission_text LONGTEXT,
    submission_file_url VARCHAR(500),
    score DECIMAL(10,2),
    feedback TEXT,
    deviation_percentage VARCHAR(10),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP NULL,
    graded_at TIMESTAMP NULL,
    FOREIGN KEY (task_id) REFERENCES BINARY_SUCCESS_TEACHER_TASKS(task_id),
    FOREIGN KEY (learner_id) REFERENCES BINARY_SUCCESS_LEARNERS(learner_id),
    FOREIGN KEY (status_id) REFERENCES BINARY_SUCCESS_TASK_STATUSES(status_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Study Materials
CREATE TABLE BINARY_SUCCESS_STUDY_MATERIALS (
    material_id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    material_type ENUM('PDF', 'VIDEO', 'DOCUMENT', 'LINK') NOT NULL,
    file_url VARCHAR(500),
    external_link VARCHAR(500),
    teacher_id VARCHAR(36),
    institute_id VARCHAR(36),
    grade_level_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES BINARY_SUCCESS_TEACHERS(teacher_id),
    FOREIGN KEY (institute_id) REFERENCES BINARY_SUCCESS_PLATFORM_INSTITUTES(institute_id),
    FOREIGN KEY (grade_level_id) REFERENCES BINARY_SUCCESS_GRADE_LEVELS(grade_level_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- AI/ANALYTICS TABLES
-- ============================================================================

-- AI Usage Statistics
CREATE TABLE BINARY_SUCCESS_AI_USAGE_STATS (
    usage_id VARCHAR(36) PRIMARY KEY,
    task_id VARCHAR(36),
    learner_id VARCHAR(36),
    used_count INT DEFAULT 0,
    prompt_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES BINARY_SUCCESS_TEACHER_TASKS(task_id),
    FOREIGN KEY (learner_id) REFERENCES BINARY_SUCCESS_LEARNERS(learner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Writing Fingerprints
CREATE TABLE BINARY_SUCCESS_WRITING_FINGERPRINTS (
    fingerprint_id VARCHAR(36) PRIMARY KEY,
    learner_task_id VARCHAR(36),
    learner_id VARCHAR(36),
    deviation_percentage DECIMAL(5,2),
    analysis_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (learner_task_id) REFERENCES BINARY_SUCCESS_LEARNER_TASKS(learner_task_id),
    FOREIGN KEY (learner_id) REFERENCES BINARY_SUCCESS_LEARNERS(learner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Platform Users Indexes
CREATE INDEX idx_users_email ON BINARY_SUCCESS_PLATFORM_USERS(email);
CREATE INDEX idx_users_keycloak ON BINARY_SUCCESS_PLATFORM_USERS(keycloak_id);
CREATE INDEX idx_users_institute ON BINARY_SUCCESS_PLATFORM_USERS(institute_id);
CREATE INDEX idx_users_role ON BINARY_SUCCESS_PLATFORM_USERS(role_id);

-- Teachers Indexes
CREATE INDEX idx_teachers_user ON BINARY_SUCCESS_TEACHERS(user_id);
CREATE INDEX idx_teachers_institute ON BINARY_SUCCESS_TEACHERS(institute_id);

-- Learners Indexes
CREATE INDEX idx_learners_user ON BINARY_SUCCESS_LEARNERS(user_id);
CREATE INDEX idx_learners_institute ON BINARY_SUCCESS_LEARNERS(institute_id);
CREATE INDEX idx_learners_grade ON BINARY_SUCCESS_LEARNERS(grade_level_id);

-- Classes Indexes
CREATE INDEX idx_classes_institute ON BINARY_SUCCESS_CLASSES(institute_id);
CREATE INDEX idx_classes_teacher ON BINARY_SUCCESS_CLASSES(teacher_id);
CREATE INDEX idx_classes_grade ON BINARY_SUCCESS_CLASSES(grade_level_id);

-- Enrollments Indexes
CREATE INDEX idx_enrollments_learner ON BINARY_SUCCESS_ENROLLMENTS(learner_id);
CREATE INDEX idx_enrollments_class ON BINARY_SUCCESS_ENROLLMENTS(class_id);

-- Teacher Tasks Indexes
CREATE INDEX idx_teacher_tasks_teacher ON BINARY_SUCCESS_TEACHER_TASKS(teacher_id);
CREATE INDEX idx_teacher_tasks_class ON BINARY_SUCCESS_TEACHER_TASKS(class_id);
CREATE INDEX idx_teacher_tasks_institute ON BINARY_SUCCESS_TEACHER_TASKS(institute_id);
CREATE INDEX idx_teacher_tasks_type ON BINARY_SUCCESS_TEACHER_TASKS(task_type_id);

-- Learner Tasks Indexes
CREATE INDEX idx_learner_tasks_task ON BINARY_SUCCESS_LEARNER_TASKS(task_id);
CREATE INDEX idx_learner_tasks_learner ON BINARY_SUCCESS_LEARNER_TASKS(learner_id);
CREATE INDEX idx_learner_tasks_status ON BINARY_SUCCESS_LEARNER_TASKS(status_id);
CREATE INDEX idx_learner_tasks_assigned ON BINARY_SUCCESS_LEARNER_TASKS(assigned_at);

-- AI Usage Indexes
CREATE INDEX idx_ai_usage_task ON BINARY_SUCCESS_AI_USAGE_STATS(task_id);
CREATE INDEX idx_ai_usage_learner ON BINARY_SUCCESS_AI_USAGE_STATS(learner_id);

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: User Details with Role and Institute
CREATE OR REPLACE VIEW vw_user_details AS
SELECT 
    u.user_id,
    u.keycloak_id,
    u.email,
    u.username,
    u.first_name,
    u.last_name,
    r.role_name,
    i.institute_name,
    i.institute_id,
    s.status_code,
    u.created_at,
    u.last_login
FROM BINARY_SUCCESS_PLATFORM_USERS u
LEFT JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id
LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON u.institute_id = i.institute_id
LEFT JOIN BINARY_SUCCESS_STATUSES s ON u.status_id = s.status_id;

-- View: Class Enrollments with Student Details
CREATE OR REPLACE VIEW vw_class_enrollments AS
SELECT 
    e.enrollment_id,
    e.class_id,
    c.class_name,
    c.class_code,
    l.learner_id,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    gl.grade_name,
    e.enrollment_date,
    e.status
FROM BINARY_SUCCESS_ENROLLMENTS e
JOIN BINARY_SUCCESS_CLASSES c ON e.class_id = c.class_id
JOIN BINARY_SUCCESS_LEARNERS l ON e.learner_id = l.learner_id
JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON l.grade_level_id = gl.grade_level_id;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================
SELECT 'Database schema created successfully!' AS message;
