-- ========================================
-- Binary Success Platform - Database Schema (MySQL)
-- Auto-generated from Python codebase
-- WARNING: This is a PARTIAL schema - stored procedures/triggers are NOT included
-- ========================================

-- Core lookup tables
CREATE TABLE ca_roles (
    role_id VARCHAR(50) PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL,
    role_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE ca_statuses (
    status_id VARCHAR(50) PRIMARY KEY,
    status_code VARCHAR(50) NOT NULL UNIQUE,
    status_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ca_task_types (
    task_type_id VARCHAR(50) PRIMARY KEY,
    task_type VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Platform Users
CREATE TABLE ca_platform_users (
    user_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) NOT NULL UNIQUE,
    status_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    CONSTRAINT fk_user_status FOREIGN KEY (status_id) REFERENCES ca_statuses(status_id)
);

-- Institutes/Schools
CREATE TABLE ca_platform_institutes (
    institute_id VARCHAR(50) PRIMARY KEY,
    institute_name VARCHAR(255) NOT NULL,
    admin_user_id VARCHAR(50),
    admin_email VARCHAR(255),
    bulk_consent_given CHAR(1) DEFAULT 'N',
    alfresco_site_id VARCHAR(100),
    crm_account_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_institute_admin FOREIGN KEY (admin_user_id) REFERENCES ca_platform_users(user_id)
);

-- User Role Mapping
CREATE TABLE ca_user_role_mapping (
    mapping_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    role_entity_id VARCHAR(50),
    keycloak_user_id VARCHAR(100),
    alfresco_user_id VARCHAR(100),
    lms_entity_id VARCHAR(100),
    crm_contact_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_mapping_user FOREIGN KEY (user_id) REFERENCES ca_platform_users(user_id)
);

-- Teachers
CREATE TABLE ca_teachers (
    teacher_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    institute_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_teacher_institute FOREIGN KEY (institute_id) REFERENCES ca_platform_institutes(institute_id)
);

-- Learners/Students
CREATE TABLE ca_learners (
    learner_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    institute_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_learner_institute FOREIGN KEY (institute_id) REFERENCES ca_platform_institutes(institute_id)
);

-- Classes
CREATE TABLE ca_classes (
    class_id VARCHAR(50) PRIMARY KEY,
    class_name VARCHAR(255) NOT NULL,
    teacher_id VARCHAR(50),
    institute_id VARCHAR(50),
    class_status_id VARCHAR(50),
    alfresco_class_id VARCHAR(100),
    lms_class_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_class_teacher FOREIGN KEY (teacher_id) REFERENCES ca_teachers(teacher_id),
    CONSTRAINT fk_class_institute FOREIGN KEY (institute_id) REFERENCES ca_platform_institutes(institute_id),
    CONSTRAINT fk_class_status FOREIGN KEY (class_status_id) REFERENCES ca_statuses(status_id)
);

-- Enrollments
CREATE TABLE ca_enrollments (
    enrollment_id VARCHAR(50) PRIMARY KEY,
    class_id VARCHAR(50) NOT NULL,
    learner_id VARCHAR(50) NOT NULL,
    status_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_enrollment_class FOREIGN KEY (class_id) REFERENCES ca_classes(class_id),
    CONSTRAINT fk_enrollment_learner FOREIGN KEY (learner_id) REFERENCES ca_learners(learner_id),
    CONSTRAINT fk_enrollment_status FOREIGN KEY (status_id) REFERENCES ca_statuses(status_id)
);

-- User Invitations
CREATE TABLE ca_user_invites (
    invite_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    invite_code VARCHAR(100) NOT NULL UNIQUE,
    keycloak_user_id VARCHAR(100),
    role_id VARCHAR(50),
    used TINYINT(1) DEFAULT 0,
    used_at TIMESTAMP NULL,
    source VARCHAR(50),
    additional_details TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    CONSTRAINT fk_invite_role FOREIGN KEY (role_id) REFERENCES ca_roles(role_id)
);

-- Password Reset Tokens
CREATE TABLE password_reset_tokens (
    token_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    keycloak_user_id VARCHAR(100),
    token VARCHAR(255) NOT NULL UNIQUE,
    used TINYINT(1) DEFAULT 0,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- AI Usage Stats
CREATE TABLE ca_ai_usage_stats (
    ai_usage_id VARCHAR(50) PRIMARY KEY,
    task_id VARCHAR(50),
    learner_id VARCHAR(50),
    used_count INT DEFAULT 0,
    last_used TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_usage_learner FOREIGN KEY (learner_id) REFERENCES ca_learners(learner_id)
);

-- AI Prompts
CREATE TABLE ca_ai_prompts (
    prompt_id VARCHAR(50) PRIMARY KEY,
    ai_usage_id VARCHAR(50) NOT NULL,
    prompt_text TEXT,
    ai_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prompt_usage FOREIGN KEY (ai_usage_id) REFERENCES ca_ai_usage_stats(ai_usage_id)
);

-- Bulk Upload Staging
CREATE TABLE ca_stg_bulk_upload (
    bulk_upload_id VARCHAR(50) PRIMARY KEY,
    institute_id VARCHAR(50),
    uploaded_by VARCHAR(50),
    file_name VARCHAR(500),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bulk_institute FOREIGN KEY (institute_id) REFERENCES ca_platform_institutes(institute_id)
);

-- Integration Logs
CREATE TABLE ca_integration_logs (
    log_id VARCHAR(50) PRIMARY KEY,
    message TEXT,
    bulk_upload_id VARCHAR(50),
    middleware_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_bulk FOREIGN KEY (bulk_upload_id) REFERENCES ca_stg_bulk_upload(bulk_upload_id)
);

-- Middleware Tables (for data sync)
CREATE TABLE ca_middleware_teachers (
    middleware_id VARCHAR(50) PRIMARY KEY,
    teacher_id VARCHAR(50),
    user_id VARCHAR(50),
    ca_id VARCHAR(50),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    process_status VARCHAR(20) DEFAULT 'PENDING',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE ca_middleware_students (
    middleware_id VARCHAR(50) PRIMARY KEY,
    student_id VARCHAR(50),
    user_id VARCHAR(50),
    ca_id VARCHAR(50),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    process_status VARCHAR(20) DEFAULT 'PENDING',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ========================================
-- Seed Data for Basic Operation
-- ========================================

-- Insert default statuses
INSERT INTO ca_statuses (status_id, status_code, status_name) VALUES ('1', 'ACTIVE', 'Active');
INSERT INTO ca_statuses (status_id, status_code, status_name) VALUES ('2', 'INACTIVE', 'Inactive');
INSERT INTO ca_statuses (status_id, status_code, status_name) VALUES ('3', 'PENDING', 'Pending');
INSERT INTO ca_statuses (status_id, status_code, status_name) VALUES ('4', 'ARCHIVED', 'Archived');

-- Insert default roles
INSERT INTO ca_roles (role_id, role_name, role_description) VALUES ('1', 'ADMIN', 'Platform Administrator');
INSERT INTO ca_roles (role_id, role_name, role_description) VALUES ('2', 'TEACHER', 'Teacher/Instructor');
INSERT INTO ca_roles (role_id, role_name, role_description) VALUES ('3', 'STUDENT', 'Student/Learner');
INSERT INTO ca_roles (role_id, role_name, role_description) VALUES ('4', 'SCHOOL_ADMIN', 'School Administrator');

-- Insert default task types
INSERT INTO ca_task_types (task_type_id, task_type, description) VALUES ('1', 'ASSIGNMENT', 'Assignment Task');
INSERT INTO ca_task_types (task_type_id, task_type, description) VALUES ('2', 'QUIZ', 'Quiz Task');
INSERT INTO ca_task_types (task_type_id, task_type, description) VALUES ('3', 'PRACTICE', 'Practice Task');



-- -- ========================================
-- -- Binary Success Platform - Database Schema (MySQL)
-- -- Auto-generated from Python codebase
-- -- WARNING: This is a PARTIAL schema - stored procedures/triggers are NOT included
-- -- ========================================

-- -- Core lookup tables
-- CREATE TABLE binary_success_roles (
--     role_id VARCHAR(50) PRIMARY KEY,
--     role_name VARCHAR(100) NOT NULL,
--     role_description VARCHAR(500),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
-- );

-- CREATE TABLE binary_success_statuses (
--     status_id VARCHAR(50) PRIMARY KEY,
--     status_code VARCHAR(50) NOT NULL UNIQUE,
--     status_name VARCHAR(100),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE TABLE binary_success_task_types (
--     task_type_id VARCHAR(50) PRIMARY KEY,
--     task_type VARCHAR(100) NOT NULL UNIQUE,
--     description VARCHAR(500),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Platform Users
-- CREATE TABLE binary_success_platform_users (
--     user_id VARCHAR(50) PRIMARY KEY,
--     first_name VARCHAR(100),
--     last_name VARCHAR(100),
--     email VARCHAR(255) NOT NULL UNIQUE,
--     status_id VARCHAR(50),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     updated_by VARCHAR(50),
--     CONSTRAINT fk_user_status FOREIGN KEY (status_id) REFERENCES binary_success_statuses(status_id)
-- );

-- -- Institutes/Schools
-- CREATE TABLE binary_success_platform_institutes (
--     institute_id VARCHAR(50) PRIMARY KEY,
--     institute_name VARCHAR(255) NOT NULL,
--     admin_user_id VARCHAR(50),
--     admin_email VARCHAR(255),
--     bulk_consent_given CHAR(1) DEFAULT 'N',
--     alfresco_site_id VARCHAR(100),
--     crm_account_id VARCHAR(100),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     CONSTRAINT fk_institute_admin FOREIGN KEY (admin_user_id) REFERENCES binary_success_platform_users(user_id)
-- );

-- -- User Role Mapping
-- CREATE TABLE binary_success_user_role_mapping (
--     mapping_id VARCHAR(50) PRIMARY KEY,
--     user_id VARCHAR(50) NOT NULL,
--     role_entity_id VARCHAR(50),
--     keycloak_user_id VARCHAR(100),
--     alfresco_user_id VARCHAR(100),
--     lms_entity_id VARCHAR(100),
--     crm_contact_id VARCHAR(100),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     CONSTRAINT fk_mapping_user FOREIGN KEY (user_id) REFERENCES binary_success_platform_users(user_id)
-- );

-- -- Teachers
-- CREATE TABLE binary_success_teachers (
--     teacher_id VARCHAR(50) PRIMARY KEY,
--     email VARCHAR(255) NOT NULL,
--     first_name VARCHAR(100),
--     last_name VARCHAR(100),
--     institute_id VARCHAR(50),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     CONSTRAINT fk_teacher_institute FOREIGN KEY (institute_id) REFERENCES binary_success_platform_institutes(institute_id)
-- );

-- -- Learners/Students
-- CREATE TABLE binary_success_learners (
--     learner_id VARCHAR(50) PRIMARY KEY,
--     email VARCHAR(255) NOT NULL,
--     first_name VARCHAR(100),
--     last_name VARCHAR(100),
--     institute_id VARCHAR(50),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     CONSTRAINT fk_learner_institute FOREIGN KEY (institute_id) REFERENCES binary_success_platform_institutes(institute_id)
-- );

-- -- Classes
-- CREATE TABLE binary_success_classes (
--     class_id VARCHAR(50) PRIMARY KEY,
--     class_name VARCHAR(255) NOT NULL,
--     teacher_id VARCHAR(50),
--     institute_id VARCHAR(50),
--     class_status_id VARCHAR(50),
--     alfresco_class_id VARCHAR(100),
--     lms_class_id VARCHAR(100),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     CONSTRAINT fk_class_teacher FOREIGN KEY (teacher_id) REFERENCES binary_success_teachers(teacher_id),
--     CONSTRAINT fk_class_institute FOREIGN KEY (institute_id) REFERENCES binary_success_platform_institutes(institute_id),
--     CONSTRAINT fk_class_status FOREIGN KEY (class_status_id) REFERENCES binary_success_statuses(status_id)
-- );

-- -- Enrollments
-- CREATE TABLE binary_success_enrollments (
--     enrollment_id VARCHAR(50) PRIMARY KEY,
--     class_id VARCHAR(50) NOT NULL,
--     learner_id VARCHAR(50) NOT NULL,
--     status_id VARCHAR(50),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     CONSTRAINT fk_enrollment_class FOREIGN KEY (class_id) REFERENCES binary_success_classes(class_id),
--     CONSTRAINT fk_enrollment_learner FOREIGN KEY (learner_id) REFERENCES binary_success_learners(learner_id),
--     CONSTRAINT fk_enrollment_status FOREIGN KEY (status_id) REFERENCES binary_success_statuses(status_id)
-- );

-- -- User Invitations
-- CREATE TABLE binary_success_user_invites (
--     invite_id VARCHAR(50) PRIMARY KEY,
--     email VARCHAR(255) NOT NULL,
--     invite_code VARCHAR(100) NOT NULL UNIQUE,
--     keycloak_user_id VARCHAR(100),
--     role_id VARCHAR(50),
--     used TINYINT(1) DEFAULT 0,
--     used_at TIMESTAMP NULL,
--     source VARCHAR(50),
--     additional_details TEXT,
--     expires_at TIMESTAMP NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     created_by VARCHAR(50),
--     CONSTRAINT fk_invite_role FOREIGN KEY (role_id) REFERENCES binary_success_roles(role_id)
-- );

-- -- Password Reset Tokens
-- CREATE TABLE password_reset_tokens (
--     token_id VARCHAR(50) PRIMARY KEY,
--     email VARCHAR(255) NOT NULL,
--     keycloak_user_id VARCHAR(100),
--     token VARCHAR(255) NOT NULL UNIQUE,
--     used TINYINT(1) DEFAULT 0,
--     expires_at TIMESTAMP NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
-- );

-- -- AI Usage Stats
-- CREATE TABLE binary_success_ai_usage_stats (
--     ai_usage_id VARCHAR(50) PRIMARY KEY,
--     task_id VARCHAR(50),
--     learner_id VARCHAR(50),
--     used_count INT DEFAULT 0,
--     last_used TIMESTAMP NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     CONSTRAINT fk_ai_usage_learner FOREIGN KEY (learner_id) REFERENCES binary_success_learners(learner_id)
-- );

-- -- AI Prompts
-- CREATE TABLE binary_success_ai_prompts (
--     prompt_id VARCHAR(50) PRIMARY KEY,
--     ai_usage_id VARCHAR(50) NOT NULL,
--     prompt_text TEXT,
--     ai_response TEXT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     CONSTRAINT fk_prompt_usage FOREIGN KEY (ai_usage_id) REFERENCES binary_success_ai_usage_stats(ai_usage_id)
-- );

-- -- Bulk Upload Staging
-- CREATE TABLE binary_success_stg_bulk_upload (
--     bulk_upload_id VARCHAR(50) PRIMARY KEY,
--     institute_id VARCHAR(50),
--     uploaded_by VARCHAR(50),
--     file_name VARCHAR(500),
--     error_message TEXT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     CONSTRAINT fk_bulk_institute FOREIGN KEY (institute_id) REFERENCES binary_success_platform_institutes(institute_id)
-- );

-- -- Integration Logs
-- CREATE TABLE binary_success_integration_logs (
--     log_id VARCHAR(50) PRIMARY KEY,
--     message TEXT,
--     bulk_upload_id VARCHAR(50),
--     middleware_id VARCHAR(50),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     CONSTRAINT fk_log_bulk FOREIGN KEY (bulk_upload_id) REFERENCES binary_success_stg_bulk_upload(bulk_upload_id)
-- );

-- -- Middleware Tables (for data sync)
-- CREATE TABLE binary_success_middleware_teachers (
--     middleware_id VARCHAR(50) PRIMARY KEY,
--     teacher_id VARCHAR(50),
--     user_id VARCHAR(50),
--     binary_success_id VARCHAR(50),
--     status VARCHAR(20) DEFAULT 'ACTIVE',
--     process_status VARCHAR(20) DEFAULT 'PENDING',
--     error_message TEXT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
-- );

-- CREATE TABLE binary_success_middleware_students (
--     middleware_id VARCHAR(50) PRIMARY KEY,
--     student_id VARCHAR(50),
--     user_id VARCHAR(50),
--     binary_success_id VARCHAR(50),
--     status VARCHAR(20) DEFAULT 'ACTIVE',
--     process_status VARCHAR(20) DEFAULT 'PENDING',
--     error_message TEXT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
-- );

-- -- ========================================
-- -- Seed Data for Basic Operation
-- -- ========================================

-- -- Insert default statuses
-- INSERT INTO binary_success_statuses (status_id, status_code, status_name) VALUES ('1', 'ACTIVE', 'Active');
-- INSERT INTO binary_success_statuses (status_id, status_code, status_name) VALUES ('2', 'INACTIVE', 'Inactive');
-- INSERT INTO binary_success_statuses (status_id, status_code, status_name) VALUES ('3', 'PENDING', 'Pending');
-- INSERT INTO binary_success_statuses (status_id, status_code, status_name) VALUES ('4', 'ARCHIVED', 'Archived');

-- -- Insert default roles
-- INSERT INTO binary_success_roles (role_id, role_name, role_description) VALUES ('1', 'ADMIN', 'Platform Administrator');
-- INSERT INTO binary_success_roles (role_id, role_name, role_description) VALUES ('2', 'TEACHER', 'Teacher/Instructor');
-- INSERT INTO binary_success_roles (role_id, role_name, role_description) VALUES ('3', 'STUDENT', 'Student/Learner');
-- INSERT INTO binary_success_roles (role_id, role_name, role_description) VALUES ('4', 'SCHOOL_ADMIN', 'School Administrator');

-- -- Insert default task types
-- INSERT INTO binary_success_task_types (task_type_id, task_type, description) VALUES ('1', 'ASSIGNMENT', 'Assignment Task');
-- INSERT INTO binary_success_task_types (task_type_id, task_type, description) VALUES ('2', 'QUIZ', 'Quiz Task');
-- INSERT INTO binary_success_task_types (task_type_id, task_type, description) VALUES ('3', 'PRACTICE', 'Practice Task');
