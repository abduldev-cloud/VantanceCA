import mysql.connector
from app.core.config import settings

def create_table():
    try:
        conn = mysql.connector.connect(
            host=settings.MYSQL_HOST,
            port=settings.MYSQL_PORT,
            database=settings.MYSQL_DATABASE,
            user=settings.MYSQL_USER,
            password=settings.MYSQL_PASSWORD
        )
        cursor = conn.cursor()
        
        sql = """
        CREATE TABLE IF NOT EXISTS BINARY_SUCCESS_STUDY_MATERIALS (
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
        """
        cursor.execute(sql)
        conn.commit()
        print("✅ Table BINARY_SUCCESS_STUDY_MATERIALS created successfully")
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"❌ Error creating table: {e}")

if __name__ == "__main__":
    create_table()
