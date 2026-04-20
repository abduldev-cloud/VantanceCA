-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: ca_exam
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `binary_success_ai_usage_stats`
--

DROP TABLE IF EXISTS `binary_success_ai_usage_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_ai_usage_stats` (
  `usage_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `learner_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `used_count` int DEFAULT '0',
  `prompt_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`usage_id`),
  KEY `idx_ai_usage_task` (`task_id`),
  KEY `idx_ai_usage_learner` (`learner_id`),
  CONSTRAINT `binary_success_ai_usage_stats_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `binary_success_teacher_tasks` (`task_id`),
  CONSTRAINT `binary_success_ai_usage_stats_ibfk_2` FOREIGN KEY (`learner_id`) REFERENCES `binary_success_learners` (`learner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_ai_usage_stats`
--

LOCK TABLES `binary_success_ai_usage_stats` WRITE;
/*!40000 ALTER TABLE `binary_success_ai_usage_stats` DISABLE KEYS */;
INSERT INTO `binary_success_ai_usage_stats` VALUES ('aiusage-001','task-001','learner-001',15,'grammar_check','2026-02-04 04:51:34'),('aiusage-002','task-001','learner-001',8,'paraphrase','2026-02-04 04:51:34'),('aiusage-003','task-001','learner-002',22,'grammar_check','2026-02-04 04:51:34'),('aiusage-004','task-001','learner-002',12,'expand_ideas','2026-02-04 04:51:34'),('aiusage-005','task-002','learner-001',5,'grammar_check','2026-02-04 04:51:34'),('aiusage-006','task-002','learner-002',7,'grammar_check','2026-02-04 04:51:34'),('aiusage-007','task-003','learner-003',3,'grammar_check','2026-02-04 04:51:34'),('aiusage-008','task-003','learner-004',2,'paraphrase','2026-02-04 04:51:34'),('aiusage-009','task-007','learner-005',10,'research_help','2026-02-04 04:51:34'),('aiusage-010','task-007','learner-006',18,'grammar_check','2026-02-04 04:51:34');
/*!40000 ALTER TABLE `binary_success_ai_usage_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_aic_messages`
--

DROP TABLE IF EXISTS `binary_success_aic_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_aic_messages` (
  `message_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `learner_task_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender` enum('STUDENT','AI') COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_chat_task` (`learner_task_id`),
  CONSTRAINT `binary_success_aic_messages_ibfk_1` FOREIGN KEY (`learner_task_id`) REFERENCES `binary_success_learner_tasks` (`learner_task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_aic_messages`
--

LOCK TABLES `binary_success_aic_messages` WRITE;
/*!40000 ALTER TABLE `binary_success_aic_messages` DISABLE KEYS */;
INSERT INTO `binary_success_aic_messages` VALUES ('msg-01956b57e3ea','ltask-cdb92150788c','STUDENT','hello','2026-03-12 05:04:08'),('msg-171edf5c1397','ltask-cdb92150788c','AI','I encountered an error while thinking. Please try again in a moment.','2026-03-12 04:51:09'),('msg-1d1e75e591e3','ltask-cdb92150788c','AI','Hello! IΓÇÖm here to help you prepare for your poetry analysis on Robert Frost. \n\nWhether you need help understanding a specific poem, clarifying the assignment instructions, or refining your writing style, I\'m ready to guide you. \n\nWhich poem are you planning to analyze, or how can I help you get started?','2026-03-12 05:04:11'),('msg-2b74d444a24d','ltask-cdb92150788c','AI','It looks like you\'re working on the **Poetry Analysis** assignment focused on **Robert Frost**.\n\nI\'m not quite sure what you mean by \"**10 one**.\" Could you clarify? For example, are you:\n*   Looking for a list of 10 poems to choose from?\n*   Trying to meet a specific word count or requirement?\n*   Referring to a specific line in a poem?\n\nLet me know how I can help you get started with your analysis! Which Frost poem are you planning to write about?','2026-03-12 05:12:29'),('msg-2fc755eacf88','ltask-cdb92150788c','STUDENT','can you tell me the title of this assignment','2026-03-11 06:22:13'),('msg-4cdf031a6a91','ltask-cdb92150788c','STUDENT','hii','2026-03-12 04:51:09'),('msg-64d7a9de14b2','ltask-cdb92150788c','AI','Hello! IΓÇÖd be happy to help you get started on your **Poetry Analysis of Robert Frost**. \n\nWhile I can\'t write the essay for you, I can guide you through the process step-by-step. To begin, here is a simple way to approach the assignment:\n\n1.  **Choose a Poem:** Do you have a specific Robert Frost poem in mind? Common choices are *\"The Road Not Taken,\"* *\"Stopping by Woods on a Snowy Evening,\"* or *\"Mending Wall.\"*\n2.  **Identify a Theme:** What do you think the poem is about? (e.g., nature, making choices, or human relationships).\n3.  **Look for Literary Devices:** Can you find examples of imagery, metaphors, or specific rhythms Frost uses to convey his message?\n4.  **Draft a Thesis:** Try to write one sentence that explains what the poem means and how Frost uses language to show that meaning.\n\nWhich poem are you planning to analyze? If you tell me which one you\'ve chosen, we can start looking at the main themes together!','2026-03-12 05:08:41'),('msg-7740e025b277','ltask-cdb92150788c','AI','IΓÇÖd be happy to help! Since I donΓÇÖt have your specific classroom list or textbook in front of me, IΓÇÖm not sure which poem is listed as the 10th one.\n\nCould you tell me the **title** of that poem? Once you share it, we can look at its themes and imagery together so you can start your analysis!','2026-03-12 05:12:59'),('msg-777440c8d057','ltask-cdb92150788c','STUDENT','10 one','2026-03-12 05:12:25'),('msg-87e52d4ab91a','ltask-cdb92150788c','STUDENT','hii','2026-03-12 05:01:33'),('msg-93412f1446bf','ltask-cdb92150788c','AI','I encountered an error while thinking. Please try again in a moment.','2026-03-12 05:01:33'),('msg-9615f3515a4a','ltask-cdb92150788c','STUDENT','can you help to write for this assignemnt','2026-03-12 05:08:36'),('msg-a16bfc2aabd1','ltask-cdb92150788c','AI','I encountered an error while thinking. Please try again in a moment.','2026-03-12 05:02:32'),('msg-a1e8da90b355','ltask-cdb92150788c','STUDENT','help me understand the assignment.','2026-03-11 06:21:47'),('msg-a3f8bc1e4efe','ltask-cdb92150788c','STUDENT','hello\\','2026-03-12 05:02:31'),('msg-aae0b5b6aa31','ltask-cdb92150788c','AI','ThatΓÇÖs a great way to start! Selecting the right poem is the first step toward a strong analysis. Here are 10 of Robert FrostΓÇÖs most famous poems for you to consider:\n\n1.  **The Road Not Taken** (Focuses on choices and individuality)\n2.  **Stopping by Woods on a Snowy Evening** (Themes of duty vs. desire)\n3.  **Mending Wall** (Explores boundaries and human relationships)\n4.  **Fire and Ice** (A short look at human passion and destruction)\n5.  **Birches** (Reflects on childhood and escaping reality)\n6.  **Nothing Gold Can Stay** (Deals with the fleeting nature of beauty)\n7.  **After Apple-Picking** (Themes of exhaustion and mortality)\n8.  **Acquainted with the Night** (Explores loneliness and depression)\n9.  **\"Out, OutΓÇö\"** (A tragic look at the fragility of life)\n10. **The Death of the Hired Man** (A narrative poem about mercy and home)\n\nWhich one of these catches your eye? Once you pick one (or two), let me know, and we can start identifying the key themes!','2026-03-12 05:11:43'),('msg-b1eaa9b41b36','ltask-cdb92150788c','STUDENT','then, give me 10 poem ','2026-03-12 05:11:38'),('msg-bb16a3cc0a34','ltask-cdb92150788c','AI','I\'ve received your message: \'help me understand the assignment.\'. As your AI assistant, I recommend focusing on your core argument and ensuring your evidence supports your claims. Would you like more specific advice?','2026-03-11 06:21:47'),('msg-d476811a943d','ltask-cdb92150788c','STUDENT','give me exact answer for this assignment','2026-03-12 05:10:58'),('msg-e7b00fa292d5','ltask-cdb92150788c','AI','In poetry analysis, there isn\'t one single \"exact answer.\" The goal is for you to develop your own interpretation of Robert Frost\'s work and support it with evidence from his poems.\n\nTo get started, I recommend these steps:\n\n1.  **Pick a Poem:** Are you looking at a specific one, like \"The Road Not Taken\" or \"Stopping by Woods on a Snowy Evening\"?\n2.  **Identify a Theme:** What is the poem about on a deeper level? (e.g., nature, making choices, or isolation).\n3.  **Find Literary Devices:** Look for metaphors, imagery, or rhyme schemes that Frost uses to highlight that theme.\n\nIf you share which poem you\'re working on or your initial thoughts, I can help you organize your ideas into a strong analysis! What part of the poem stands out to you most?','2026-03-12 05:11:02'),('msg-e9ae9bf7d0f0','ltask-cdb92150788c','AI','I\'ve received your message: \'can you tell me the title of this assignment\'. As your AI assistant, I recommend focusing on your core argument and ensuring your evidence supports your claims. Would you like more specific advice?','2026-03-11 06:22:13'),('msg-ee96ca4994ca','ltask-001','STUDENT','Hello AI','2026-03-11 06:14:05'),('msg-f8149c085788','ltask-cdb92150788c','STUDENT','the10th one i am refering','2026-03-12 05:12:54'),('msg-fc71b25e874c','ltask-001','AI','I\'ve received your message: \'Hello AI\'. As your AI assistant, I recommend focusing on your core argument and ensuring your evidence supports your claims. Would you like more specific advice?','2026-03-11 06:14:05')';
/*!40000 ALTER TABLE `binary_success_aic_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_api_quotas`
--

DROP TABLE IF EXISTS `binary_success_api_quotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_api_quotas` (
  `quota_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `month_year` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokens_used` int DEFAULT '0',
  `threshold_limit` int DEFAULT '10000',
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`quota_id`),
  UNIQUE KEY `institute_id` (`institute_id`,`month_year`),
  CONSTRAINT `binary_success_api_quotas_ibfk_1` FOREIGN KEY (`institute_id`) REFERENCES `binary_success_platform_institutes` (`institute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_api_quotas`
--

LOCK TABLES `binary_success_api_quotas` WRITE;
/*!40000 ALTER TABLE `binary_success_api_quotas` DISABLE KEYS */;
INSERT INTO `binary_success_api_quotas` VALUES ('qt-0a387333','inst-4b8b2134','2026-02',6137,10000,'2026-02-28 08:07:51'),('qt-15e91bea','inst-002','2026-02',6869,10000,'2026-02-28 08:07:51'),('qt-2b457114','inst-604f8e5f','2026-02',8201,10000,'2026-02-28 08:07:51'),('qt-37d36039','inst-b66f9448','2026-02',3344,10000,'2026-02-28 08:07:51'),('qt-62b91ded','inst-003','2026-02',11738,10000,'2026-02-28 08:07:51'),('qt-d3b99274','inst-001','2026-02',2721,10000,'2026-02-28 08:07:51');
/*!40000 ALTER TABLE `binary_success_api_quotas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_audit_logs`
--

DROP TABLE IF EXISTS `binary_success_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_audit_logs` (
  `log_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_audit_logs`
--

LOCK TABLES `binary_success_audit_logs` WRITE;
/*!40000 ALTER TABLE `binary_success_audit_logs` DISABLE KEYS */;
INSERT INTO `binary_success_audit_logs` VALUES ('log-123a9158',NULL,'Platform Administration','PLATFORM_ADMIN','BULK_IMPORT_USERS','Bulk imported users and assigned them to schools.','192.168.1.100','2026-02-28 06:22:24'),('log-14486c08',NULL,'Platform Administration','PLATFORM_ADMIN','CREATE_TASK_TYPE','Added new system Task Type: Essay.','192.168.1.100','2026-02-28 06:22:24'),('log-5edd038c',NULL,'Institute Administrator','INSTITUTE_ADMIN','VIEW_USERS','Viewed users for Demo Central High.','192.168.1.100','2026-02-28 06:22:24'),('log-712d46d3',NULL,'Platform Administration','PLATFORM_ADMIN','LOGIN','Platform Admin securely authenticated into the system.','192.168.1.100','2026-02-28 06:22:24'),('log-a65ff455',NULL,'Platform Administration','PLATFORM_ADMIN','ADD_GRADE_LEVEL','Dynamically added new Grade Level: Grade 10.','192.168.1.100','2026-02-28 06:22:24'),('log-d9c42d14',NULL,'Platform Administration','PLATFORM_ADMIN','BULK_IMPORT_SCHOOLS','Bulk imported 3 new schools via CSV.','192.168.1.100','2026-02-28 06:22:24');
/*!40000 ALTER TABLE `binary_success_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_classes`
--

DROP TABLE IF EXISTS `binary_success_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_classes` (
  `class_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `class_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `class_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade_level_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `term` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `academic_year` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `teacher_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`class_id`),
  KEY `idx_classes_institute` (`institute_id`),
  KEY `idx_classes_teacher` (`teacher_id`),
  KEY `idx_classes_grade` (`grade_level_id`),
  CONSTRAINT `binary_success_classes_ibfk_1` FOREIGN KEY (`institute_id`) REFERENCES `binary_success_platform_institutes` (`institute_id`),
  CONSTRAINT `binary_success_classes_ibfk_2` FOREIGN KEY (`grade_level_id`) REFERENCES `binary_success_grade_levels` (`grade_level_id`),
  CONSTRAINT `binary_success_classes_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `binary_success_teachers` (`teacher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_classes`
--

LOCK TABLES `binary_success_classes` WRITE;
/*!40000 ALTER TABLE `binary_success_classes` DISABLE KEYS */;
INSERT INTO `binary_success_classes` VALUES ('class-001','English 9A','ENG9A','inst-001','grade-004','Fall','2025-2026','teacher-001','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-002','English 10B','ENG10B','inst-001','grade-005','Fall','2025-2026','teacher-001','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-003','Math 9A','MATH9A','inst-001','grade-004','Fall','2025-2026','teacher-002','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-004','Math 10A','MATH10A','inst-001','grade-005','Fall','2025-2026','teacher-002','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-005','Biology 9A','BIO9A','inst-002','grade-004','Fall','2025-2026','teacher-003','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-006','Biology 10A','BIO10A','inst-002','grade-005','Fall','2025-2026','teacher-003','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-007','History 9A','HIST9A','inst-002','grade-004','Fall','2025-2026','teacher-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-008','History 10A','HIST10A','inst-002','grade-005','Fall','2025-2026','teacher-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-009','Demo Class 1','DEMO1','inst-003','grade-004','Fall','2025-2026','teacher-005','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-010','Demo Class 2','DEMO2','inst-003','grade-004','Fall','2025-2026','teacher-005','2026-02-04 04:51:34','2026-02-04 04:51:34'),('class-d012e8cceca9','Grade 10 English','CL8EB2D4','inst-001','grade-001','Semester 1','2026','teacher-001','2026-02-25 08:48:19','2026-02-25 08:48:19');
/*!40000 ALTER TABLE `binary_success_classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_enrollments`
--

DROP TABLE IF EXISTS `binary_success_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_enrollments` (
  `enrollment_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `learner_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `class_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enrollment_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `unique_enrollment` (`learner_id`,`class_id`),
  KEY `idx_enrollments_learner` (`learner_id`),
  KEY `idx_enrollments_class` (`class_id`),
  CONSTRAINT `binary_success_enrollments_ibfk_1` FOREIGN KEY (`learner_id`) REFERENCES `binary_success_learners` (`learner_id`),
  CONSTRAINT `binary_success_enrollments_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `binary_success_classes` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_enrollments`
--

LOCK TABLES `binary_success_enrollments` WRITE;
/*!40000 ALTER TABLE `binary_success_enrollments` DISABLE KEYS */;
INSERT INTO `binary_success_enrollments` VALUES ('enroll-001','learner-001','class-001','2026-02-04 04:51:34','ACTIVE'),('enroll-002','learner-001','class-003','2026-02-04 04:51:34','ACTIVE'),('enroll-003','learner-002','class-001','2026-02-04 04:51:34','ACTIVE'),('enroll-004','learner-002','class-003','2026-02-04 04:51:34','ACTIVE'),('enroll-005','learner-003','class-002','2026-02-04 04:51:34','ACTIVE'),('enroll-006','learner-003','class-004','2026-02-04 04:51:34','ACTIVE'),('enroll-007','learner-004','class-002','2026-02-04 04:51:34','ACTIVE'),('enroll-008','learner-004','class-004','2026-02-04 04:51:34','ACTIVE'),('enroll-009','learner-005','class-005','2026-02-04 04:51:34','ACTIVE'),('enroll-010','learner-005','class-007','2026-02-04 04:51:34','ACTIVE'),('enroll-011','learner-006','class-005','2026-02-04 04:51:34','ACTIVE'),('enroll-012','learner-006','class-007','2026-02-04 04:51:34','ACTIVE'),('enroll-013','learner-007','class-006','2026-02-04 04:51:34','ACTIVE'),('enroll-014','learner-007','class-008','2026-02-04 04:51:34','ACTIVE'),('enroll-015','learner-008','class-006','2026-02-04 04:51:34','ACTIVE'),('enroll-016','learner-008','class-008','2026-02-04 04:51:34','ACTIVE'),('enroll-017','learner-009','class-009','2026-02-04 04:51:34','ACTIVE'),('enroll-018','learner-010','class-010','2026-02-04 04:51:34','ACTIVE'),('enroll-0490dacfeafb','learner-001','class-d012e8cceca9','2026-02-28 09:13:43','ACTIVE'),('enroll-04c8e7ce9aa8','learner-009','class-002','2026-02-25 08:57:58','ACTIVE'),('enroll-b0d5097f2524','learner-001','class-002','2026-03-10 06:24:12','ACTIVE');
/*!40000 ALTER TABLE `binary_success_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_grade_levels`
--

DROP TABLE IF EXISTS `binary_success_grade_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_grade_levels` (
  `grade_level_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade_order` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`grade_level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_grade_levels`
--

LOCK TABLES `binary_success_grade_levels` WRITE;
/*!40000 ALTER TABLE `binary_success_grade_levels` DISABLE KEYS */;
INSERT INTO `binary_success_grade_levels` VALUES ('grade-001','CA Foundation',1,'2026-02-04 04:51:34'),('grade-002','CA Intermediate - Group I',2,'2026-02-04 04:51:34'),('grade-003','CA Intermediate - Group II',3,'2026-02-04 04:51:34'),('grade-004','CA Final - Group I',4,'2026-02-04 04:51:34'),('grade-005','CA Final - Group II',5,'2026-02-04 04:51:34');
/*!40000 ALTER TABLE `binary_success_grade_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_learner_tasks`
--

DROP TABLE IF EXISTS `binary_success_learner_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_learner_tasks` (
  `learner_task_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `learner_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submission_text` longtext COLLATE utf8mb4_unicode_ci,
  `submission_file_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `score` decimal(10,2) DEFAULT NULL,
  `feedback` text COLLATE utf8mb4_unicode_ci,
  `deviation_percentage` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `submitted_at` timestamp NULL DEFAULT NULL,
  `graded_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`learner_task_id`),
  KEY `idx_learner_tasks_task` (`task_id`),
  KEY `idx_learner_tasks_learner` (`learner_id`),
  KEY `idx_learner_tasks_status` (`status_id`),
  KEY `idx_learner_tasks_assigned` (`assigned_at`),
  CONSTRAINT `binary_success_learner_tasks_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `binary_success_teacher_tasks` (`task_id`),
  CONSTRAINT `binary_success_learner_tasks_ibfk_2` FOREIGN KEY (`learner_id`) REFERENCES `binary_success_learners` (`learner_id`),
  CONSTRAINT `binary_success_learner_tasks_ibfk_3` FOREIGN KEY (`status_id`) REFERENCES `binary_success_task_statuses` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_learner_tasks`
--

LOCK TABLES `binary_success_learner_tasks` WRITE;
/*!40000 ALTER TABLE `binary_success_learner_tasks` DISABLE KEYS */;
INSERT INTO `binary_success_learner_tasks` VALUES ('ltask-001','task-001','learner-001','taskstatus-004','My summer vacation was amazing...',NULL,85.50,NULL,'42.3','2025-12-06 04:51:34','2025-12-13 04:51:34','2025-12-14 04:51:34'),('ltask-002','task-001','learner-002','taskstatus-004','This summer I went to the beach...',NULL,78.00,NULL,'38.7','2025-12-06 04:51:34','2025-12-12 04:51:34','2025-12-14 04:51:34'),('ltask-003','task-002','learner-001','taskstatus-004','Writing sample for analysis...',NULL,90.00,NULL,'45.2','2025-12-11 04:51:34','2025-12-18 04:51:34','2025-12-19 04:51:34'),('ltask-004','task-002','learner-002','taskstatus-004','My writing style is unique...',NULL,88.50,NULL,'52.8','2025-12-11 04:51:34','2025-12-17 04:51:34','2025-12-19 04:51:34'),('ltask-005','task-003','learner-003','taskstatus-003','To Kill a Mockingbird is a powerful novel...',NULL,NULL,NULL,'41.5','2025-12-16 04:51:34','2026-02-02 04:51:34',NULL),('ltask-006','task-003','learner-004','taskstatus-004','The book explores themes of racism...',NULL,92.00,NULL,'47.3','2025-12-16 04:51:34','2025-12-23 04:51:34','2025-12-24 04:51:34'),('ltask-007','task-004','learner-003','taskstatus-002',NULL,NULL,NULL,NULL,NULL,'2025-12-21 04:51:34',NULL,NULL),('ltask-008','task-004','learner-004','taskstatus-004','Robert Frost uses nature imagery...',NULL,4.00,'','39.8','2025-12-21 04:51:34','2026-02-03 04:51:34','2026-04-15 09:10:07'),('ltask-009','task-005','learner-001','taskstatus-004','Quiz answers: 1.x=5, 2.y=3...',NULL,95.00,NULL,NULL,'2025-12-26 04:51:34','2025-12-29 04:51:34','2025-12-30 04:51:34'),('ltask-010','task-005','learner-002','taskstatus-004','Quiz answers: 1.x=5, 2.y=2...',NULL,82.00,NULL,NULL,'2025-12-26 04:51:34','2025-12-28 04:51:34','2025-12-30 04:51:34'),('ltask-011','task-007','learner-005','taskstatus-004','Cell organelles include nucleus, mitochondria...',NULL,87.50,NULL,'44.1','2026-01-05 04:51:34','2026-01-12 04:51:34','2026-01-13 04:51:34'),('ltask-012','task-007','learner-006','taskstatus-003','The nucleus controls cell activities...',NULL,NULL,NULL,'36.9','2026-01-05 04:51:34','2026-02-01 04:51:34',NULL),('ltask-1e9a9887e166','task-f82a6287daba','learner-004','taskstatus-001',NULL,NULL,NULL,NULL,NULL,'2026-03-10 06:23:22',NULL,NULL),('ltask-240a205cdacc','task-003','learner-001','taskstatus-001',NULL,NULL,NULL,NULL,NULL,'2026-03-15 13:29:45',NULL,NULL),('ltask-26ea775625a3','task-f82a6287daba','learner-001','taskstatus-004','<p>https://careers.ibm.com/en_US/careers/JobDetail?jobId=52240https://careers.ibm.com/en_US/careers/JobDetail?jobId=52240https://careers.ibm.com/en_US/careers/JobDetail?jobId=52240https://careers.ibm.com/en_US/careers/JobDetail?jobId=52240https://careers.ibm.com/en_US/careers/JobDetail?jobId=52240https://careers.ibm.com/en_US/careers/JobDetail?jobId=52240</p>',NULL,10.00,'',NULL,'2026-03-10 06:38:46','2026-03-10 08:41:20','2026-03-10 08:50:50'),('ltask-3dd6f4afb9d5','task-f82a6287daba','learner-003','taskstatus-001',NULL,NULL,NULL,NULL,NULL,'2026-03-10 06:23:22',NULL,NULL),('ltask-534a062253b5','task-485a203e1ac6','learner-001','taskstatus-003','',NULL,NULL,NULL,NULL,'2026-02-09 06:16:19','2026-03-03 09:55:15',NULL),('ltask-915c226b6310','task-485a203e1ac6','learner-002','taskstatus-001',NULL,NULL,NULL,NULL,NULL,'2026-02-09 06:16:19',NULL,NULL),('ltask-a6894bf260f2','task-f82a6287daba','learner-009','taskstatus-001',NULL,NULL,NULL,NULL,NULL,'2026-03-10 06:23:22',NULL,NULL),('ltask-cdb92150788c','task-004','learner-001','taskstatus-004','<p>hello world </p>',NULL,1.00,'The submission fails to address the assignment prompt entirely. There is no analysis of Robert Frost\'s poetry, nor does the text follow academic writing standards. It appears to be a placeholder message (\'hello world\') rather than a completed assignment. To receive credit, you must submit a detailed analysis of Frost\'s work as per the instructions.',NULL,'2026-03-11 06:09:39','2026-03-12 06:22:13','2026-03-12 06:27:40');
/*!40000 ALTER TABLE `binary_success_learner_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_learners`
--

DROP TABLE IF EXISTS `binary_success_learners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_learners` (
  `learner_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `learner_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade_level_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`learner_id`),
  KEY `idx_learners_user` (`user_id`),
  KEY `idx_learners_institute` (`institute_id`),
  KEY `idx_learners_grade` (`grade_level_id`),
  CONSTRAINT `binary_success_learners_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `binary_success_platform_users` (`user_id`),
  CONSTRAINT `binary_success_learners_ibfk_2` FOREIGN KEY (`institute_id`) REFERENCES `binary_success_platform_institutes` (`institute_id`),
  CONSTRAINT `binary_success_learners_ibfk_3` FOREIGN KEY (`grade_level_id`) REFERENCES `binary_success_grade_levels` (`grade_level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_learners`
--

LOCK TABLES `binary_success_learners` WRITE;
/*!40000 ALTER TABLE `binary_success_learners` DISABLE KEYS */;
INSERT INTO `binary_success_learners` VALUES ('f0a51246-05f6-42b1-b375-645fa176e5b7','e544bf08-bd65-4975-9bc3-155663868192',NULL,NULL,NULL,'2026-04-20 09:29:11','2026-04-20 09:29:11'),('learner-001','user-011','inst-001','S001','grade-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-002','user-012','inst-001','S002','grade-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-003','user-013','inst-001','S003','grade-005','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-004','user-014','inst-001','S004','grade-005','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-005','user-015','inst-002','S005','grade-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-006','user-016','inst-002','S006','grade-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-007','user-017','inst-002','S007','grade-005','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-008','user-018','inst-002','S008','grade-005','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-009','user-019','inst-003','S009','grade-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-010','user-020','inst-003','S010','grade-004','2026-02-04 04:51:34','2026-02-04 04:51:34'),('learner-a57bed36','user-7950f732','inst-4b8b2134','S-c2d7',NULL,'2026-02-28 06:05:37','2026-02-28 06:05:37'),('learner-c6a7b9fc','user-31ec33f6','inst-4b8b2134','S-79dc',NULL,'2026-02-28 06:05:37','2026-02-28 06:05:37');
/*!40000 ALTER TABLE `binary_success_learners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_platform_institutes`
--

DROP TABLE IF EXISTS `binary_success_platform_institutes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_platform_institutes` (
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `institute_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `institute_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_address` text COLLATE utf8mb4_unicode_ci,
  `institute_city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_zipcode` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_status_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_demo` char(1) COLLATE utf8mb4_unicode_ci DEFAULT 'N',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `primary_color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '#0A8041',
  `logo_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`institute_id`),
  UNIQUE KEY `institute_code` (`institute_code`),
  KEY `institute_status_id` (`institute_status_id`),
  CONSTRAINT `binary_success_platform_institutes_ibfk_1` FOREIGN KEY (`institute_status_id`) REFERENCES `binary_success_statuses` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_platform_institutes`
--

LOCK TABLES `binary_success_platform_institutes` WRITE;
/*!40000 ALTER TABLE `binary_success_platform_institutes` DISABLE KEYS */;
INSERT INTO `binary_success_platform_institutes` VALUES ('inst-001','Springfield High School','SHS001','admin@springfield.edu','+1-555-0101',NULL,'Springfield','Illinois','USA',NULL,'status-001','N','2026-02-04 04:51:34','2026-02-04 04:51:34','#0A8041',NULL),('inst-002','Riverside Academy','RVA002','info@riverside.edu','+1-555-0102',NULL,'Riverside','California','USA',NULL,'status-001','N','2026-02-04 04:51:34','2026-02-04 04:51:34','#0A8041',NULL),('inst-003','Demo School','DEMO003','demo@example.com','+1-555-0103',NULL,'Demo City','Demo State','USA',NULL,'status-001','Y','2026-02-04 04:51:34','2026-02-04 04:51:34','#0A8041',NULL),('inst-4b8b2134','Demo Central High','DCH003','demo_admin_cx@example.com',NULL,NULL,'Austin','TX',NULL,NULL,'status-001','Y','2026-02-28 05:28:56','2026-02-28 05:28:56','#0A8041',NULL),('inst-604f8e5f','Harvard University','HARV001','admin@harvard.edu',NULL,NULL,'Cambridge','MA',NULL,NULL,'status-001','N','2026-02-28 05:28:56','2026-02-28 05:28:56','#0A8041',NULL),('inst-b66f9448','Stanford Academy','STAN002','admin@stanford.edu',NULL,NULL,'Stanford','CA',NULL,NULL,'status-001','N','2026-02-28 05:28:56','2026-02-28 05:28:56','#0A8041',NULL);
/*!40000 ALTER TABLE `binary_success_platform_institutes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_platform_users`
--

DROP TABLE IF EXISTS `binary_success_platform_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_platform_users` (
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keycloak_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT '1',
  `role_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `keycloak_id` (`keycloak_id`),
  KEY `status_id` (`status_id`),
  KEY `idx_users_email` (`email`),
  KEY `idx_users_keycloak` (`keycloak_id`),
  KEY `idx_users_institute` (`institute_id`),
  KEY `idx_users_role` (`role_id`),
  CONSTRAINT `binary_success_platform_users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `binary_success_roles` (`role_id`),
  CONSTRAINT `binary_success_platform_users_ibfk_2` FOREIGN KEY (`institute_id`) REFERENCES `binary_success_platform_institutes` (`institute_id`),
  CONSTRAINT `binary_success_platform_users_ibfk_3` FOREIGN KEY (`status_id`) REFERENCES `binary_success_statuses` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_platform_users`
--

LOCK TABLES `binary_success_platform_users` WRITE;
/*!40000 ALTER TABLE `binary_success_platform_users` DISABLE KEYS */;
INSERT INTO `binary_success_platform_users` VALUES ('admin-user-id','admin-user-id','admin@gmail.com','admin','System','Admin','admin123',1,'role-001',NULL,'status-001',NULL,'2026-02-27 05:00:17','2026-02-27 05:00:17',NULL),('e544bf08-bd65-4975-9bc3-155663868192','e544bf08-bd65-4975-9bc3-155663868192','someonesonebjbj@gmail.com','abdul123','Abdul','Hameed','12345678',1,'role-004',NULL,NULL,NULL,'2026-04-20 09:29:11','2026-04-20 09:29:11',NULL),('user-001','user-001','admin@binarysuccess.com','admin1','Alice','Admin','admin123',1,'role-001',NULL,'status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-002','user-002','superadmin@binarysuccess.com','admin2','Bob','SuperAdmin','admin123',1,'role-001',NULL,'status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-003','user-003','principal@springfield.edu','principal1','Carol','Principal','admin123',1,'role-002','inst-001','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-004','user-004','admin@riverside.edu','admin_rv','David','Director','admin123',1,'role-002','inst-002','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-005','user-005','demo@example.com','demo_admin','Demo','Admin','admin123',1,'role-002','inst-003','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-006','user-006','ah303130@gmail.com','teacher1','Emma','Thompson','teacher123',1,'role-003','inst-001','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-007','user-007','frank.miller@springfield.edu','teacher2','Frank','Miller','teacher123',1,'role-003','inst-001','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-008','user-008','grace.lee@riverside.edu','teacher3','Grace','Lee','teacher123',1,'role-003','inst-002','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-009','user-009','henry.wilson@riverside.edu','teacher4','Henry','Wilson','teacher123',1,'role-003','inst-002','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-010','user-010','demo.teacher@example.com','demo_teacher','Demo','Teacher','teacher123',1,'role-003','inst-003','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-011','user-011','ah909475@gmail.com','student1','Ivy','Johnson','student123',1,'role-004','inst-001','status-001',NULL,'2026-02-04 04:51:34','2026-02-18 04:00:25',NULL),('user-012','user-012','student2@springfield.edu','student2','Jack','Brown','student123',1,'role-004','inst-001','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-013','user-013','student3@springfield.edu','student3','Kate','Davis','student123',1,'role-004','inst-001','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-014','user-014','student4@springfield.edu','student4','Liam','Martinez','student123',1,'role-004','inst-001','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-015','user-015','student5@riverside.edu','student5','Mia','Garcia','student123',1,'role-004','inst-002','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-016','user-016','student6@riverside.edu','student6','Noah','Rodriguez','student123',1,'role-004','inst-002','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-017','user-017','student7@riverside.edu','student7','Olivia','Hernandez','student123',1,'role-004','inst-002','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-018','user-018','student8@riverside.edu','student8','Peter','Lopez','student123',1,'role-004','inst-002','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-019','user-019','demo.student1@example.com','demo_student1','Demo','Student1','student123',1,'role-004','inst-003','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-020','user-020','demo.student2@example.com','demo_student2','Demo','Student2','student123',1,'role-004','inst-003','status-001',NULL,'2026-02-04 04:51:34','2026-02-09 06:09:54',NULL),('user-31ec33f6','kc-user-241bcf45','learner500@example.com','learner500','Demo','Learner500',NULL,1,'role-004','inst-4b8b2134','status-001',NULL,'2026-02-28 06:05:37','2026-02-28 06:05:37',NULL),('user-42c55b71','kc-inst-021adb0a','demo_admin_cx@example.com','demo_admin_cx','Demo','Admin',NULL,1,'role-002','inst-4b8b2134','status-001',NULL,'2026-02-28 05:28:56','2026-02-28 05:28:56',NULL),('user-5131de57','kc-inst-80706f15','admin@harvard.edu','admin','John','Harvard',NULL,1,'role-002','inst-604f8e5f','status-001',NULL,'2026-02-28 05:28:56','2026-02-28 05:28:56',NULL),('user-7950f732','kc-user-cb59ba36','sarah.s@springfield.edu','sarah.s','Sarah','Student',NULL,1,'role-004','inst-4b8b2134','status-001',NULL,'2026-02-28 06:05:37','2026-02-28 06:05:37',NULL),('user-9a6d622d','kc-user-4d6e44f9','mike.t@springfield.edu','mike.t','Mike','Teacher',NULL,1,'role-003','inst-4b8b2134','status-001',NULL,'2026-02-28 06:05:37','2026-02-28 06:05:37',NULL),('user-bf77c7b1','kc-inst-5602f5c7','admin@stanford.edu','admin','Leland','Stanford',NULL,1,'role-002','inst-b66f9448','status-001',NULL,'2026-02-28 05:28:56','2026-02-28 05:28:56',NULL);
/*!40000 ALTER TABLE `binary_success_platform_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_reminders`
--

DROP TABLE IF EXISTS `binary_success_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_reminders` (
  `reminder_id` varchar(36) NOT NULL,
  `teacher_id` varchar(36) NOT NULL,
  `reminder_date` date NOT NULL,
  `reminder_title` varchar(255) NOT NULL,
  `reminder_description` text,
  `reminder_type` enum('personal','class','deadline') DEFAULT 'personal',
  `color` varchar(20) DEFAULT '#6366F1',
  `is_completed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reminder_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_reminders`
--

LOCK TABLES `binary_success_reminders` WRITE;
/*!40000 ALTER TABLE `binary_success_reminders` DISABLE KEYS */;
INSERT INTO `binary_success_reminders` VALUES ('rem-c9e68e12cacc','teacher-001','2026-03-25','Review essays','Check Grade 11-A essays','class','#EF4444',0,'2026-03-25 06:04:45'),('rem-ef6df666651a','teacher-001','2026-03-06','hello','','personal','#6366F1',0,'2026-03-25 06:05:33');
/*!40000 ALTER TABLE `binary_success_reminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_roles`
--

DROP TABLE IF EXISTS `binary_success_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_roles` (
  `role_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_roles`
--

LOCK TABLES `binary_success_roles` WRITE;
/*!40000 ALTER TABLE `binary_success_roles` DISABLE KEYS */;
INSERT INTO `binary_success_roles` VALUES ('role-001','PLATFORM_ADMIN','Platform Administrator with full access','2026-02-04 04:51:34','2026-02-04 04:51:34'),('role-002','INSTITUTE_ADMIN','School/Institute Administrator','2026-02-04 04:51:34','2026-02-04 04:51:34'),('role-003','TEACHER','Teacher/Instructor','2026-02-04 04:51:34','2026-02-04 04:51:34'),('role-004','LEARNER','Student/Learner','2026-02-04 04:51:34','2026-02-04 04:51:34');
/*!40000 ALTER TABLE `binary_success_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_statuses`
--

DROP TABLE IF EXISTS `binary_success_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_statuses` (
  `status_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `status_code` (`status_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_statuses`
--

LOCK TABLES `binary_success_statuses` WRITE;
/*!40000 ALTER TABLE `binary_success_statuses` DISABLE KEYS */;
INSERT INTO `binary_success_statuses` VALUES ('status-001','ACTIVE','Active','Entity is active and operational','2026-02-04 04:51:34'),('status-002','INACTIVE','Inactive','Entity is inactive','2026-02-04 04:51:34'),('status-003','PENDING','Pending','Entity is pending approval','2026-02-04 04:51:34'),('status-004','SUSPENDED','Suspended','Entity is temporarily suspended','2026-02-04 04:51:34');
/*!40000 ALTER TABLE `binary_success_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_study_materials`
--

DROP TABLE IF EXISTS `binary_success_study_materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_study_materials` (
  `material_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `material_type` enum('PDF','VIDEO','DOCUMENT','LINK') COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `external_link` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `teacher_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade_level_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`material_id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `institute_id` (`institute_id`),
  KEY `grade_level_id` (`grade_level_id`),
  CONSTRAINT `binary_success_study_materials_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `binary_success_teachers` (`teacher_id`),
  CONSTRAINT `binary_success_study_materials_ibfk_2` FOREIGN KEY (`institute_id`) REFERENCES `binary_success_platform_institutes` (`institute_id`),
  CONSTRAINT `binary_success_study_materials_ibfk_3` FOREIGN KEY (`grade_level_id`) REFERENCES `binary_success_grade_levels` (`grade_level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_study_materials`
--

LOCK TABLES `binary_success_study_materials` WRITE;
/*!40000 ALTER TABLE `binary_success_study_materials` DISABLE KEYS */;
INSERT INTO `binary_success_study_materials` VALUES ('mat-5e252fa4f38b','Introduction to Taxation','this document is the study material for taxation','PDF','/uploads/98b248b13a654af8b629e4fddd78fe19.pdf','','teacher-001','inst-001','grade-001','2026-02-27 04:17:04','2026-02-27 04:17:04'),('mat-64f53dffc416','hello','hello\n','PDF','hllo','','teacher-001','inst-001','grade-002','2026-02-26 17:42:24','2026-02-26 17:42:24'),('mat-7104c2cb1fed','intro','hello hello','PDF','https://example.com/mock-pdf.pdf','helloworld.com','teacher-001','inst-001','grade-001','2026-02-26 17:36:52','2026-02-26 17:36:52'),('mat-aadd4a589e70','MEANING AND SCOPE OF ACCOUNTING','below is the accounting basic details.','PDF','/uploads/8bd19729142b4598b8fd07e5ff3fac1e.pdf','','teacher-001','inst-001','grade-002','2026-02-27 04:49:30','2026-02-27 04:49:30');
/*!40000 ALTER TABLE `binary_success_study_materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_task_statuses`
--

DROP TABLE IF EXISTS `binary_success_task_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_task_statuses` (
  `status_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_task_statuses`
--

LOCK TABLES `binary_success_task_statuses` WRITE;
/*!40000 ALTER TABLE `binary_success_task_statuses` DISABLE KEYS */;
INSERT INTO `binary_success_task_statuses` VALUES ('taskstatus-001','ASSIGNED','Task assigned to student','2026-02-04 04:51:34'),('taskstatus-002','IN_PROGRESS','Student is working on task','2026-02-04 04:51:34'),('taskstatus-003','SUBMITTED','Task submitted by student','2026-02-04 04:51:34'),('taskstatus-004','GRADED','Task graded by teacher','2026-02-04 04:51:34'),('taskstatus-005','RETURNED','Task returned to student','2026-02-04 04:51:34');
/*!40000 ALTER TABLE `binary_success_task_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_task_types`
--

DROP TABLE IF EXISTS `binary_success_task_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_task_types` (
  `task_type_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_type_id`),
  UNIQUE KEY `task_type` (`task_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_task_types`
--

LOCK TABLES `binary_success_task_types` WRITE;
/*!40000 ALTER TABLE `binary_success_task_types` DISABLE KEYS */;
INSERT INTO `binary_success_task_types` VALUES ('tasktype-001','ASSIGNMENT','Regular assignment','2026-02-04 04:51:34'),('tasktype-002','FINGERPRINT','Writing fingerprint analysis','2026-02-04 04:51:34'),('tasktype-003','QUIZ','Quiz or test','2026-02-04 04:51:34'),('tasktype-004','ESSAY','Essay writing','2026-02-04 04:51:34'),('tasktype-005','PROJECT','Project work','2026-02-04 04:51:34');
/*!40000 ALTER TABLE `binary_success_task_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_teacher_tasks`
--

DROP TABLE IF EXISTS `binary_success_teacher_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_teacher_tasks` (
  `task_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_description` text COLLATE utf8mb4_unicode_ci,
  `task_type_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `teacher_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `class_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `due_date` timestamp NULL DEFAULT NULL,
  `max_score` decimal(10,2) DEFAULT '100.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`),
  KEY `idx_teacher_tasks_teacher` (`teacher_id`),
  KEY `idx_teacher_tasks_class` (`class_id`),
  KEY `idx_teacher_tasks_institute` (`institute_id`),
  KEY `idx_teacher_tasks_type` (`task_type_id`),
  CONSTRAINT `binary_success_teacher_tasks_ibfk_1` FOREIGN KEY (`task_type_id`) REFERENCES `binary_success_task_types` (`task_type_id`),
  CONSTRAINT `binary_success_teacher_tasks_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `binary_success_teachers` (`teacher_id`),
  CONSTRAINT `binary_success_teacher_tasks_ibfk_3` FOREIGN KEY (`class_id`) REFERENCES `binary_success_classes` (`class_id`),
  CONSTRAINT `binary_success_teacher_tasks_ibfk_4` FOREIGN KEY (`institute_id`) REFERENCES `binary_success_platform_institutes` (`institute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_teacher_tasks`
--

LOCK TABLES `binary_success_teacher_tasks` WRITE;
/*!40000 ALTER TABLE `binary_success_teacher_tasks` DISABLE KEYS */;
INSERT INTO `binary_success_teacher_tasks` VALUES ('task-001','Essay: My Summer Vacation','Write a 500-word essay about your summer vacation','tasktype-004','teacher-001','class-001','inst-001','2026-02-11 04:51:34',100.00,'2025-12-06 04:51:34','2026-02-04 04:51:34'),('task-002','Writing Fingerprint Analysis','Initial writing sample for fingerprint analysis','tasktype-002','teacher-001','class-001','inst-001','2026-02-18 04:51:34',100.00,'2025-12-11 04:51:34','2026-02-04 04:51:34'),('task-003','Book Report: To Kill a Mockingbird','Write a comprehensive book report','tasktype-001','teacher-001','class-002','inst-001','2026-02-25 04:51:34',100.00,'2025-12-16 04:51:34','2026-02-04 04:51:34'),('task-004','Poetry Analysis','Analyze Robert Frost poems','tasktype-001','teacher-001','class-002','inst-001','2026-03-04 04:51:34',100.00,'2025-12-21 04:51:34','2026-02-04 04:51:34'),('task-005','Algebra Quiz 1','Solve linear equations','tasktype-003','teacher-002','class-003','inst-001','2026-02-07 04:51:34',100.00,'2025-12-26 04:51:34','2026-02-04 04:51:34'),('task-006','Geometry Project','Create geometric shapes project','tasktype-005','teacher-002','class-004','inst-001','2026-03-06 04:51:34',100.00,'2025-12-31 04:51:34','2026-02-04 04:51:34'),('task-007','Cell Structure Assignment','Describe cell organelles and their functions','tasktype-001','teacher-003','class-005','inst-002','2026-02-14 04:51:34',100.00,'2026-01-05 04:51:34','2026-02-04 04:51:34'),('task-008','Photosynthesis Essay','Explain the process of photosynthesis','tasktype-004','teacher-003','class-006','inst-002','2026-02-19 04:51:34',100.00,'2026-01-10 04:51:34','2026-02-04 04:51:34'),('task-009','World War II Research','Research and present on WWII events','tasktype-005','teacher-004','class-007','inst-002','2026-02-24 04:51:34',100.00,'2026-01-15 04:51:34','2026-02-04 04:51:34'),('task-010','Ancient Civilizations Quiz','Quiz on ancient civilizations','tasktype-003','teacher-004','class-008','inst-002','2026-02-09 04:51:34',100.00,'2026-01-20 04:51:34','2026-02-04 04:51:34'),('task-485a203e1ac6','Mock CA Exam - Financial Accounting','Complete this practice exam covering chapters 1-5 of Financial Accounting. You have 2 hours to complete all questions.','tasktype-003','teacher-001','class-001','inst-001','2026-02-12 06:16:17',100.00,'2026-02-09 06:16:19','2026-02-09 06:16:19'),('task-f82a6287daba','Hello World','hello world','tasktype-003','teacher-001','class-002','inst-001','2025-04-11 15:54:00',100.00,'2026-03-10 06:23:22','2026-03-10 06:23:21');
/*!40000 ALTER TABLE `binary_success_teacher_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_teachers`
--

DROP TABLE IF EXISTS `binary_success_teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_teachers` (
  `teacher_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `institute_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `teacher_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specialization` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `qualifications` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `primary_skills` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experience_years` int DEFAULT '0',
  `verification_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  PRIMARY KEY (`teacher_id`),
  KEY `idx_teachers_user` (`user_id`),
  KEY `idx_teachers_institute` (`institute_id`),
  CONSTRAINT `binary_success_teachers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `binary_success_platform_users` (`user_id`),
  CONSTRAINT `binary_success_teachers_ibfk_2` FOREIGN KEY (`institute_id`) REFERENCES `binary_success_platform_institutes` (`institute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_teachers`
--

LOCK TABLES `binary_success_teachers` WRITE;
/*!40000 ALTER TABLE `binary_success_teachers` DISABLE KEYS */;
INSERT INTO `binary_success_teachers` VALUES ('teacher-001','user-006','inst-001','T001','English','Literature','2026-02-04 04:51:34','2026-02-04 04:51:34',NULL,NULL,0,'PENDING'),('teacher-002','user-007','inst-001','T002','Mathematics','Algebra','2026-02-04 04:51:34','2026-02-04 04:51:34',NULL,NULL,0,'PENDING'),('teacher-003','user-008','inst-002','T003','Science','Biology','2026-02-04 04:51:34','2026-02-04 04:51:34',NULL,NULL,0,'PENDING'),('teacher-004','user-009','inst-002','T004','History','World History','2026-02-04 04:51:34','2026-02-04 04:51:34',NULL,NULL,0,'PENDING'),('teacher-005','user-010','inst-003','T005','English','Writing','2026-02-04 04:51:34','2026-02-04 04:51:34',NULL,NULL,0,'PENDING'),('teacher-8bbfcb87','user-9a6d622d','inst-4b8b2134','T-5b09',NULL,NULL,'2026-02-28 06:05:37','2026-02-28 06:05:37',NULL,NULL,0,'PENDING');
/*!40000 ALTER TABLE `binary_success_teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `binary_success_writing_fingerprints`
--

DROP TABLE IF EXISTS `binary_success_writing_fingerprints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `binary_success_writing_fingerprints` (
  `fingerprint_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `learner_task_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `learner_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deviation_percentage` decimal(5,2) DEFAULT NULL,
  `analysis_data` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`fingerprint_id`),
  KEY `learner_task_id` (`learner_task_id`),
  KEY `learner_id` (`learner_id`),
  CONSTRAINT `binary_success_writing_fingerprints_ibfk_1` FOREIGN KEY (`learner_task_id`) REFERENCES `binary_success_learner_tasks` (`learner_task_id`),
  CONSTRAINT `binary_success_writing_fingerprints_ibfk_2` FOREIGN KEY (`learner_id`) REFERENCES `binary_success_learners` (`learner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_success_writing_fingerprints`
--

LOCK TABLES `binary_success_writing_fingerprints` WRITE;
/*!40000 ALTER TABLE `binary_success_writing_fingerprints` DISABLE KEYS */;
INSERT INTO `binary_success_writing_fingerprints` VALUES ('fp-001','ltask-001','learner-001',42.30,'{\"sentence_complexity\": 0.72, \"vocabulary_richness\": 0.65}','2026-02-04 04:51:34'),('fp-002','ltask-002','learner-002',38.70,'{\"sentence_complexity\": 0.68, \"vocabulary_richness\": 0.58}','2026-02-04 04:51:34'),('fp-003','ltask-003','learner-001',45.20,'{\"sentence_complexity\": 0.75, \"vocabulary_richness\": 0.7}','2026-02-04 04:51:34'),('fp-004','ltask-004','learner-002',52.80,'{\"sentence_complexity\": 0.82, \"vocabulary_richness\": 0.78}','2026-02-04 04:51:34'),('fp-005','ltask-005','learner-003',41.50,'{\"sentence_complexity\": 0.71, \"vocabulary_richness\": 0.64}','2026-02-04 04:51:34'),('fp-006','ltask-006','learner-004',47.30,'{\"sentence_complexity\": 0.76, \"vocabulary_richness\": 0.73}','2026-02-04 04:51:34'),('fp-007','ltask-011','learner-005',44.10,'{\"sentence_complexity\": 0.74, \"vocabulary_richness\": 0.68}','2026-02-04 04:51:34'),('fp-008','ltask-012','learner-006',36.90,'{\"sentence_complexity\": 0.65, \"vocabulary_richness\": 0.55}','2026-02-04 04:51:34');
/*!40000 ALTER TABLE `binary_success_writing_fingerprints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mock_user_roles`
--

DROP TABLE IF EXISTS `mock_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mock_user_roles` (
  `user_id` varchar(36) NOT NULL,
  `client_id` varchar(255) NOT NULL,
  `role_name` varchar(255) NOT NULL,
  PRIMARY KEY (`user_id`,`client_id`,`role_name`),
  CONSTRAINT `mock_user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `mock_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mock_user_roles`
--

LOCK TABLES `mock_user_roles` WRITE;
/*!40000 ALTER TABLE `mock_user_roles` DISABLE KEYS */;
INSERT INTO `mock_user_roles` VALUES ('61d04c47-9dd6-44f2-a040-8c789eff0084','local-client-id','learner'),('a7a04856-875f-40cd-872c-2b34d684ffdf','local-client-id','teacher');
/*!40000 ALTER TABLE `mock_user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mock_users`
--

DROP TABLE IF EXISTS `mock_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mock_users` (
  `id` varchar(36) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT '1',
  `created_at` bigint DEFAULT NULL,
  `attributes` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mock_users`
--

LOCK TABLES `mock_users` WRITE;
/*!40000 ALTER TABLE `mock_users` DISABLE KEYS */;
INSERT INTO `mock_users` VALUES ('26dfb413-0576-11f1-979b-4981acda40b0','admin1','admin@gmail.com','Alice','Admin','admin123',1,20260209104404,NULL),('26e0a92c-0576-11f1-979b-4981acda40b0','admin2','superadmin@binarysuccess.com','Bob','SuperAdmin','admin123',1,20260209104404,NULL),('26e0b03f-0576-11f1-979b-4981acda40b0','principal1','principal@springfield.edu','Carol','Principal','admin123',1,20260209104404,NULL),('26e0b1d3-0576-11f1-979b-4981acda40b0','admin_rv','admin@riverside.edu','David','Director','admin123',1,20260209104404,NULL),('26e0b2ec-0576-11f1-979b-4981acda40b0','demo_admin','demo@example.com','Demo','Admin','admin123',1,20260209104404,NULL),('61d04c47-9dd6-44f2-a040-8c789eff0084','ah909475@gmail.com','ah909475@gmail.com','Abdul','Hameed','Hameed_17022005',1,1769846776298,'{\"phone_number\": [\"+11234567890\"]}'),('a7a04856-875f-40cd-872c-2b34d684ffdf','ah303130@gmail.com','ah303130@gmail.com','Abdul','Hameed','Hameed_17022005',1,1770015450586,'{\"phone_number\": [\"+10987654321\"]}');
/*!40000 ALTER TABLE `mock_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `token_id` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `keycloak_user_id` varchar(100) DEFAULT NULL,
  `token` varchar(255) NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`token_id`),
  UNIQUE KEY `token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_entity_details`
--

DROP TABLE IF EXISTS `user_entity_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_entity_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `keycloak_id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `role_entity_id` varchar(255) DEFAULT NULL,
  `institute_id` varchar(255) DEFAULT NULL,
  `is_demo_school` varchar(10) DEFAULT 'false',
  `role_display_name` varchar(100) DEFAULT NULL,
  `crm_contact_id` varchar(255) DEFAULT NULL,
  `crm_account_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `keycloak_id` (`keycloak_id`),
  KEY `idx_keycloak_id` (`keycloak_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_entity_details`
--

LOCK TABLES `user_entity_details` WRITE;
/*!40000 ALTER TABLE `user_entity_details` DISABLE KEYS */;
INSERT INTO `user_entity_details` VALUES (1,'61d04c47-9dd6-44f2-a040-8c789eff0084','USER_61d04c47','ENTITY_61d04c47','INST_61d04c47','false','Learner','CRM_CONTACT_61d04c47','CRM_ACCOUNT_61d04c47','2026-01-31 08:41:20','2026-01-31 08:41:20'),(2,'a7a04856-875f-40cd-872c-2b34d684ffdf','USER_a7a04856','ENTITY_a7a04856','INST_a7a04856','false','Teacher','CRM_CONTACT_a7a04856','CRM_ACCOUNT_a7a04856','2026-02-02 08:55:48','2026-02-02 08:55:48');
/*!40000 ALTER TABLE `user_entity_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_class_enrollments`
--

DROP TABLE IF EXISTS `vw_class_enrollments`;
/*!50001 DROP VIEW IF EXISTS `vw_class_enrollments`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_class_enrollments` AS SELECT 
 1 AS `enrollment_id`,
 1 AS `class_id`,
 1 AS `class_name`,
 1 AS `class_code`,
 1 AS `learner_id`,
 1 AS `user_id`,
 1 AS `first_name`,
 1 AS `last_name`,
 1 AS `email`,
 1 AS `grade_name`,
 1 AS `enrollment_date`,
 1 AS `status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_user_details`
--

DROP TABLE IF EXISTS `vw_user_details`;
/*!50001 DROP VIEW IF EXISTS `vw_user_details`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_user_details` AS SELECT 
 1 AS `user_id`,
 1 AS `keycloak_id`,
 1 AS `email`,
 1 AS `username`,
 1 AS `first_name`,
 1 AS `last_name`,
 1 AS `role_name`,
 1 AS `institute_name`,
 1 AS `institute_id`,
 1 AS `status_code`,
 1 AS `created_at`,
 1 AS `last_login`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_class_enrollments`
--

/*!50001 DROP VIEW IF EXISTS `vw_class_enrollments`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_class_enrollments` AS select `e`.`enrollment_id` AS `enrollment_id`,`e`.`class_id` AS `class_id`,`c`.`class_name` AS `class_name`,`c`.`class_code` AS `class_code`,`l`.`learner_id` AS `learner_id`,`u`.`user_id` AS `user_id`,`u`.`first_name` AS `first_name`,`u`.`last_name` AS `last_name`,`u`.`email` AS `email`,`gl`.`grade_name` AS `grade_name`,`e`.`enrollment_date` AS `enrollment_date`,`e`.`status` AS `status` from ((((`binary_success_enrollments` `e` join `binary_success_classes` `c` on((`e`.`class_id` = `c`.`class_id`))) join `binary_success_learners` `l` on((`e`.`learner_id` = `l`.`learner_id`))) join `binary_success_platform_users` `u` on((`l`.`user_id` = `u`.`user_id`))) left join `binary_success_grade_levels` `gl` on((`l`.`grade_level_id` = `gl`.`grade_level_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_user_details`
--

/*!50001 DROP VIEW IF EXISTS `vw_user_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_user_details` AS select `u`.`user_id` AS `user_id`,`u`.`keycloak_id` AS `keycloak_id`,`u`.`email` AS `email`,`u`.`username` AS `username`,`u`.`first_name` AS `first_name`,`u`.`last_name` AS `last_name`,`r`.`role_name` AS `role_name`,`i`.`institute_name` AS `institute_name`,`i`.`institute_id` AS `institute_id`,`s`.`status_code` AS `status_code`,`u`.`created_at` AS `created_at`,`u`.`last_login` AS `last_login` from (((`binary_success_platform_users` `u` left join `binary_success_roles` `r` on((`u`.`role_id` = `r`.`role_id`))) left join `binary_success_platform_institutes` `i` on((`u`.`institute_id` = `i`.`institute_id`))) left join `binary_success_statuses` `s` on((`u`.`status_id` = `s`.`status_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-20 16:20:03
