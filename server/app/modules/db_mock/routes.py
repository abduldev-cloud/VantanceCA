from fastapi import APIRouter, HTTPException, Request, File, UploadFile, Form
import shutil
import os
import csv
import io
import uuid
from pydantic import BaseModel
from app.core.logger import logger
from app.core.database_mysql import get_mysql_connection
from typing import Dict, List, Any, Optional
from datetime import datetime
from app.core.ai_service import ai_service

router = APIRouter(prefix="/db", tags=["Database Mock"])

# ============================================================================
# CLASSES ENDPOINTS
# ============================================================================

@router.get("/classes")
async def get_all_classes(
    institute_id: Optional[str] = None,
    teacher_id: Optional[str] = None,
    grade_level_id: Optional[str] = None
):
    """Get all classes with optional filters"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            query = """
                SELECT 
                    c.class_id,
                    c.class_name,
                    c.class_code,
                    c.term,
                    c.academic_year,
                    i.institute_name,
                    i.institute_id,
                    gl.grade_name,
                    gl.grade_level_id,
                    t.teacher_id,
                    u.first_name AS teacher_first_name,
                    u.last_name AS teacher_last_name,
                    COUNT(DISTINCT e.learner_id) AS student_count,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_TEACHER_TASKS tt WHERE tt.class_id = c.class_id) as assignments_count
                FROM BINARY_SUCCESS_CLASSES c
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON c.institute_id = i.institute_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
                LEFT JOIN BINARY_SUCCESS_TEACHERS t ON c.teacher_id = t.teacher_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                LEFT JOIN BINARY_SUCCESS_ENROLLMENTS e ON c.class_id = e.class_id AND e.status = 'ACTIVE'
            """
            
            conditions = []
            params = []
            
            if institute_id:
                conditions.append("c.institute_id = %s")
                params.append(institute_id)
            if teacher_id:
                conditions.append("c.teacher_id = %s")
                params.append(teacher_id)
            if grade_level_id:
                conditions.append("c.grade_level_id = %s")
                params.append(grade_level_id)
                
            if conditions:
                query += " WHERE " + " AND ".join(conditions)
                
            query += " GROUP BY c.class_id ORDER BY c.class_name"
            
            cursor.execute(query, tuple(params))
            classes = cursor.fetchall()
            return {"success": True, "data": classes, "count": len(classes)}
        finally:
            cursor.close()
            conn.close()
        
    except Exception as e:
        logger.error(f"Error fetching classes: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/teacher/{teacher_id}/stats")
async def get_teacher_stats(teacher_id: str):
    """Get statistics for the teacher dashboard"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # 1. Pending Review (Submissions with status 'SUBMITTED' for teacher's tasks)
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                WHERE tt.teacher_id = %s AND ts.status = 'SUBMITTED'
            """, (teacher_id,))
            pending_review = cursor.fetchone()["count"]
            
            # 2. Graded This Week (Submissions with status 'GRADED' in last 7 days)
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                WHERE tt.teacher_id = %s 
                AND ts.status = 'GRADED' 
                AND lt.graded_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            """, (teacher_id,))
            graded_this_week = cursor.fetchone()["count"]
            
            # 3. Active Students (Students enrolled in teacher's classes)
            cursor.execute("""
                SELECT COUNT(DISTINCT e.learner_id) as count
                FROM BINARY_SUCCESS_ENROLLMENTS e
                JOIN BINARY_SUCCESS_CLASSES c ON e.class_id = c.class_id
                WHERE c.teacher_id = %s AND e.status = 'ACTIVE'
            """, (teacher_id,))
            active_students = cursor.fetchone()["count"]
            
            # 4. Anomalies (High deviation alerts)
            cursor.execute("""
                SELECT 
                    u.first_name, 
                    u.last_name, 
                    lt.deviation_percentage,
                    tt.task_title
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_LEARNERS l ON lt.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                WHERE tt.teacher_id = %s AND lt.deviation_percentage > 15
                ORDER BY lt.submitted_at DESC
                LIMIT 5
            """, (teacher_id,))
            anomalies = cursor.fetchall()
            
            return {
                "success": True,
                "data": {
                    "pending_review": pending_review,
                    "graded_this_week": graded_this_week,
                    "active_students": active_students,
                    "anomalies": anomalies
                }
            }
        finally:
            cursor.close()
            conn.close()
            
    except Exception as e:
        logger.error(f"Error fetching teacher stats for {teacher_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/classes/{class_id}")
async def get_class_by_id(class_id: str):
    """Get class details by ID"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.execute("""
                SELECT 
                    c.*,
                    i.institute_name,
                    gl.grade_name,
                    u.first_name AS teacher_first_name,
                    u.last_name AS teacher_last_name,
                    u.email AS teacher_email
                FROM BINARY_SUCCESS_CLASSES c
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON c.institute_id = i.institute_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
                LEFT JOIN BINARY_SUCCESS_TEACHERS t ON c.teacher_id = t.teacher_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                WHERE c.class_id = %s
            """, (class_id,))
            
            class_data = cursor.fetchone()
            
            if not class_data:
                raise HTTPException(status_code=404, detail="Class not found")
                
            return {"success": True, "data": class_data}
        finally:
            cursor.close()
            conn.close()
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching class {class_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/classes/{class_id}/students")
async def get_class_students(class_id: str):
    """Get all students enrolled in a class"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.execute("""
                SELECT 
                    l.learner_id,
                    l.learner_code,
                    u.user_id,
                    u.first_name,
                    u.last_name,
                    u.email,
                    gl.grade_name,
                    e.enrollment_date,
                    e.status AS enrollment_status
                FROM BINARY_SUCCESS_ENROLLMENTS e
                JOIN BINARY_SUCCESS_LEARNERS l ON e.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON l.grade_level_id = gl.grade_level_id
                WHERE e.class_id = %s
                ORDER BY u.last_name, u.first_name
            """, (class_id,))
            
            students = cursor.fetchall()
            return {"success": True, "data": students, "count": len(students)}
        finally:
            cursor.close()
            conn.close()
        
    except Exception as e:
        logger.error(f"Error fetching students for class {class_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/teacher/{teacher_id}/submissions")
async def get_teacher_submissions(teacher_id: str):
    """Get all submissions for tasks created by a teacher"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            query = """
                SELECT 
                    lt.learner_task_id,
                    lt.task_id,
                    lt.learner_id,
                    u.first_name,
                    u.last_name,
                    tt.task_title,
                    ts.status,
                    lt.submitted_at,
                    lt.score,
                    lt.feedback,
                    lt.submission_text,
                    lt.deviation_percentage,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_WRITING_FINGERPRINTS wf WHERE wf.learner_id = lt.learner_id) as fingerprint_count
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                JOIN BINARY_SUCCESS_LEARNERS l ON lt.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                WHERE tt.teacher_id = %s
                ORDER BY lt.submitted_at DESC
            """
            cursor.execute(query, (teacher_id,))
            submissions = cursor.fetchall()
            return {"success": True, "data": submissions, "count": len(submissions)}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching teacher submissions for {teacher_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/learners")
async def get_learners(
    institute_id: Optional[str] = None,
    exclude_class_id: Optional[str] = None
):
    """Get all learners, optionally filtered by institute and excluding those already in a class"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            query = """
                SELECT 
                    l.learner_id, l.learner_code,
                    u.user_id, u.first_name, u.last_name, u.email,
                    gl.grade_name,
                    i.institute_name
                FROM BINARY_SUCCESS_LEARNERS l
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON l.grade_level_id = gl.grade_level_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON l.institute_id = i.institute_id
            """
            conditions = []
            params = []

            if institute_id:
                conditions.append("l.institute_id = %s")
                params.append(institute_id)
            if exclude_class_id:
                conditions.append("""l.learner_id NOT IN (
                    SELECT e.learner_id FROM BINARY_SUCCESS_ENROLLMENTS e 
                    WHERE e.class_id = %s AND e.status = 'ACTIVE'
                )""")
                params.append(exclude_class_id)

            if conditions:
                query += " WHERE " + " AND ".join(conditions)
            query += " ORDER BY u.first_name, u.last_name"

            cursor.execute(query, tuple(params))
            learners = cursor.fetchall()
            return {"success": True, "data": learners, "count": len(learners)}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching learners: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/classes/{class_id}/enroll")
async def enroll_students(class_id: str, request: Request):
    """Enroll one or more students into a class"""
    try:
        import uuid

        data = await request.json()
        learner_ids = data.get("learner_ids", [])

        if not learner_ids:
            raise HTTPException(status_code=400, detail="No learner_ids provided")

        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # Verify class exists
            cursor.execute("SELECT class_id FROM BINARY_SUCCESS_CLASSES WHERE class_id = %s", (class_id,))
            if not cursor.fetchone():
                raise HTTPException(status_code=404, detail="Class not found")

            enrolled = 0
            skipped = 0
            for learner_id in learner_ids:
                # Check if already enrolled
                cursor.execute(
                    "SELECT enrollment_id FROM BINARY_SUCCESS_ENROLLMENTS WHERE learner_id = %s AND class_id = %s AND status = 'ACTIVE'",
                    (learner_id, class_id)
                )
                if cursor.fetchone():
                    skipped += 1
                    continue

                enrollment_id = f"enroll-{uuid.uuid4().hex[:12]}"
                cursor.execute(
                    "INSERT INTO BINARY_SUCCESS_ENROLLMENTS (enrollment_id, learner_id, class_id, status) VALUES (%s, %s, %s, 'ACTIVE')",
                    (enrollment_id, learner_id, class_id)
                )
                enrolled += 1

            conn.commit()
            return {
                "success": True,
                "message": f"Enrolled {enrolled} student(s). {skipped} already enrolled.",
                "enrolled": enrolled,
                "skipped": skipped
            }
        finally:
            cursor.close()
            conn.close()
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error enrolling students in class {class_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/classes/learner/{learner_id}")
async def get_learner_classes(learner_id: str):
    """Get all classes a student is enrolled in"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT 
                    c.class_id, c.class_name, c.class_code, c.term, c.academic_year,
                    i.institute_name, gl.grade_name,
                    u.first_name AS teacher_first_name, u.last_name AS teacher_last_name,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_ENROLLMENTS e2 WHERE e2.class_id = c.class_id AND e2.status = 'ACTIVE') as student_count,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_TEACHER_TASKS tt WHERE tt.class_id = c.class_id) as assignments_count
                FROM BINARY_SUCCESS_CLASSES c
                JOIN BINARY_SUCCESS_ENROLLMENTS e ON c.class_id = e.class_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON c.institute_id = i.institute_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
                LEFT JOIN BINARY_SUCCESS_TEACHERS t ON c.teacher_id = t.teacher_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                WHERE e.learner_id = %s AND e.status = 'ACTIVE'
            """, (learner_id,))
            classes = cursor.fetchall()
            return {"success": True, "data": classes, "count": len(classes)}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching classes for learner {learner_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/grade_levels")
async def get_grade_levels():
    """Get all available grade levels"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT grade_level_id, grade_name, grade_order FROM BINARY_SUCCESS_GRADE_LEVELS ORDER BY grade_order")
            grade_levels = cursor.fetchall()
            return {"success": True, "data": grade_levels}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching grade levels: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/classes/create")
async def create_class(request: Request):
    """Create a new class for a teacher"""
    try:
        import uuid
        
        data = await request.json()
        
        class_name = data.get("class_name")
        teacher_id = data.get("teacher_id")
        grade_level_id = data.get("grade_level_id")
        academic_year = data.get("academic_year")
        term = data.get("term", "Semester 1")
        
        if not all([class_name, teacher_id, grade_level_id]):
            raise HTTPException(status_code=400, detail="Missing required fields: class_name, teacher_id, grade_level_id")
            
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Get institute_id from teacher
            cursor.execute("SELECT institute_id FROM BINARY_SUCCESS_TEACHERS WHERE teacher_id = %s", (teacher_id,))
            teacher_data = cursor.fetchone()
            
            if not teacher_data:
                raise HTTPException(status_code=404, detail="Teacher not found")
                
            institute_id = teacher_data["institute_id"]
            class_id = f"class-{uuid.uuid4().hex[:12]}"
            class_code = f"CL{uuid.uuid4().hex[:6].upper()}"
            
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_CLASSES 
                (class_id, class_name, class_code, institute_id, grade_level_id, teacher_id, term, academic_year, created_at)
                VALUES 
                (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (class_id, class_name, class_code, institute_id, grade_level_id, teacher_id, term, academic_year, datetime.now()))
            
            conn.commit()
            
            return {
                "success": True,
                "message": "Class created successfully",
                "data": {
                    "class_id": class_id,
                    "class_name": class_name,
                    "class_code": class_code
                }
            }
        finally:
            cursor.close()
            conn.close()
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating class: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# ASSIGNMENTS/TASKS ENDPOINTS
# ============================================================================

@router.get("/assignments")
async def get_assignments(
    class_id: Optional[str] = None,
    teacher_id: Optional[str] = None,
    learner_id: Optional[str] = None
):
    """Get assignments with optional filters"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            if learner_id:
                cursor.execute("""
                    SELECT tt.task_id, tt.task_title, tt.task_description, tt.due_date, tt.max_score, tt.created_at,
                        ttype.task_type, c.class_name, c.class_id, lt.learner_task_id, lt.status_id, ts.status,
                        lt.score, lt.submitted_at, lt.graded_at, lt.deviation_percentage, lt.feedback,
                        u.first_name AS teacher_first_name, u.last_name AS teacher_last_name
                    FROM BINARY_SUCCESS_TEACHER_TASKS tt
                    JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                    LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                    LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id AND lt.learner_id = %s
                    LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                    LEFT JOIN BINARY_SUCCESS_TEACHERS t ON tt.teacher_id = t.teacher_id
                    LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                    WHERE EXISTS (SELECT 1 FROM BINARY_SUCCESS_ENROLLMENTS e WHERE e.class_id = tt.class_id AND e.learner_id = %s)
                    ORDER BY tt.due_date DESC
                """, (learner_id, learner_id))
            else:
                query = """SELECT tt.task_id, tt.task_title, tt.task_description, tt.due_date, tt.max_score, tt.created_at,
                    ttype.task_type, c.class_name, c.class_id,
                    COUNT(DISTINCT lt.learner_task_id) AS submission_count,
                    COUNT(DISTINCT CASE WHEN ts.status = 'GRADED' THEN lt.learner_task_id END) AS graded_count,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_ENROLLMENTS e WHERE e.class_id = tt.class_id AND e.status = 'ACTIVE') as student_count
                    FROM BINARY_SUCCESS_TEACHER_TASKS tt
                    JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                    LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                    LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id
                    LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id"""
                conditions = []
                params = []
                if class_id:
                    conditions.append("tt.class_id = %s")
                    params.append(class_id)
                if teacher_id:
                    conditions.append("tt.teacher_id = %s")
                    params.append(teacher_id)
                if conditions:
                    query += " WHERE " + " AND ".join(conditions)
                query += " GROUP BY tt.task_id ORDER BY tt.due_date DESC"
                cursor.execute(query, tuple(params))
            assignments = cursor.fetchall()
            return {"success": True, "data": assignments, "count": len(assignments)}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching assignments: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/assignments/{task_id}")
async def get_assignment_by_id(task_id: str, learner_id: Optional[str] = None):
    """Get assignment details by ID, optionally including learner-specific data"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            if learner_id:
                cursor.execute("""
                    SELECT tt.*, ttype.task_type, c.class_name,
                        u.first_name AS teacher_first_name, u.last_name AS teacher_last_name,
                        lt.learner_task_id, lt.status_id AS learner_status_id, 
                        lt.score, lt.submitted_at, lt.submission_text,
                        ts.status AS learner_status
                    FROM BINARY_SUCCESS_TEACHER_TASKS tt
                    JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                    LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                    LEFT JOIN BINARY_SUCCESS_TEACHERS t ON tt.teacher_id = t.teacher_id
                    LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                    LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id AND lt.learner_id = %s
                    LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                    WHERE tt.task_id = %s
                """, (learner_id, task_id))
            else:
                cursor.execute("""
                    SELECT tt.*, ttype.task_type, c.class_name,
                        u.first_name AS teacher_first_name, u.last_name AS teacher_last_name
                    FROM BINARY_SUCCESS_TEACHER_TASKS tt
                    JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                    LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                    LEFT JOIN BINARY_SUCCESS_TEACHERS t ON tt.teacher_id = t.teacher_id
                    LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                    WHERE tt.task_id = %s
                """, (task_id,))
            assignment = cursor.fetchone()
            if not assignment:
                raise HTTPException(status_code=404, detail="Assignment not found")
            
            # If learner_id was provided but no learner_task_id was found,
            # we check if the student is actually enrolled in this class.
            # If they are, we'll auto-assign it (useful for late enrollments).
            if learner_id and not assignment.get('learner_task_id'):
                # Check enrollment
                cursor.execute("""
                    SELECT enrollment_id FROM BINARY_SUCCESS_ENROLLMENTS 
                    WHERE learner_id = %s AND class_id = %s AND status = 'ACTIVE'
                """, (learner_id, assignment['class_id']))
                enrollment = cursor.fetchone()
                
                if enrollment:
                    logger.info(f"Auto-assigning task {task_id} to student {learner_id}")
                    # Get ASSIGNED status_id
                    cursor.execute("SELECT status_id FROM BINARY_SUCCESS_TASK_STATUSES WHERE status = 'ASSIGNED'")
                    status_row = cursor.fetchone()
                    status_id = status_row['status_id'] if status_row else "taskstatus-001"
                    
                    # Create the record
                    new_learner_task_id = f"ltask-{uuid.uuid4().hex[:12]}"
                    cursor.execute("""
                        INSERT INTO BINARY_SUCCESS_LEARNER_TASKS (learner_task_id, task_id, learner_id, status_id, assigned_at)
                        VALUES (%s, %s, %s, %s, %s)
                    """, (new_learner_task_id, task_id, learner_id, status_id, datetime.now()))
                    conn.commit()
                    
                    # Re-fetch the full joined record
                    cursor.execute("""
                        SELECT tt.*, ttype.task_type, c.class_name,
                            u.first_name AS teacher_first_name, u.last_name AS teacher_last_name,
                            lt.learner_task_id, lt.status_id AS learner_status_id, 
                            lt.score, lt.submitted_at, lt.submission_text,
                            ts.status AS learner_status
                        FROM BINARY_SUCCESS_TEACHER_TASKS tt
                        JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                        LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                        LEFT JOIN BINARY_SUCCESS_TEACHERS t ON tt.teacher_id = t.teacher_id
                        LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                        LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id AND lt.learner_id = %s
                        LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                        WHERE tt.task_id = %s
                    """, (learner_id, task_id))
                    assignment = cursor.fetchone()

            return {"success": True, "data": assignment}
        finally:
            cursor.close()
            conn.close()
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching assignment {task_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/assignments/{task_id}/submissions")
async def get_assignment_submissions(task_id: str):
    """Get all submissions for an assignment"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT lt.*, ts.status, l.learner_code, u.first_name, u.last_name, u.email,
                       tt.task_title
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                JOIN BINARY_SUCCESS_LEARNERS l ON lt.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                WHERE lt.task_id = %s
                ORDER BY lt.submitted_at DESC
            """, (task_id,))
            submissions = cursor.fetchall()
            return {"success": True, "data": submissions, "count": len(submissions)}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching submissions for task {task_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/assignments/create")
async def create_assignment(request: Request):
    """Create a new assignment/test for a class"""
    try:
        import uuid
        from datetime import datetime, timedelta
        
        data = await request.json()
        
        # Required fields
        task_title = data.get("task_title")
        task_description = data.get("task_description", "")
        task_type_id = data.get("task_type_id", "tasktype-003")  # Default to QUIZ
        teacher_id = data.get("teacher_id")
        class_id = data.get("class_id")
        due_date = data.get("due_date")
        max_score = data.get("max_score", 100.0)
        
        if not all([task_title, teacher_id, class_id]):
            raise HTTPException(status_code=400, detail="Missing required fields: task_title, teacher_id, class_id")
        
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Get institute_id from class
            cursor.execute("SELECT institute_id FROM BINARY_SUCCESS_CLASSES WHERE class_id = %s", (class_id,))
            class_data = cursor.fetchone()
            
            if not class_data:
                raise HTTPException(status_code=404, detail="Class not found")
            
            institute_id = class_data["institute_id"]
            
            # Generate task_id
            task_id = f"task-{uuid.uuid4().hex[:12]}"
            
            # Parse due_date or set default (7 days from now)
            if due_date:
                due_date_obj = datetime.fromisoformat(due_date.replace('Z', '+00:00'))
            else:
                due_date_obj = datetime.now() + timedelta(days=7)
            
            # Insert teacher task
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_TEACHER_TASKS 
                (task_id, task_title, task_description, task_type_id, teacher_id, 
                 class_id, institute_id, due_date, max_score, created_at)
                VALUES 
                (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (task_id, task_title, task_description, task_type_id, teacher_id,
                  class_id, institute_id, due_date_obj, max_score, datetime.now()))
            
            # Auto-assign to all enrolled students
            cursor.execute("""
                SELECT learner_id FROM BINARY_SUCCESS_ENROLLMENTS 
                WHERE class_id = %s AND status = 'ACTIVE'
            """, (class_id,))
            enrolled_students = cursor.fetchall()
            
            # Get ASSIGNED status_id
            cursor.execute("SELECT status_id FROM BINARY_SUCCESS_TASK_STATUSES WHERE status = 'ASSIGNED'")
            status_data = cursor.fetchone()
            status_id = status_data["status_id"] if status_data else "taskstatus-001"
            
            # Create learner tasks for each enrolled student
            for student in enrolled_students:
                learner_task_id = f"ltask-{uuid.uuid4().hex[:12]}"
                cursor.execute("""
                    INSERT INTO BINARY_SUCCESS_LEARNER_TASKS
                    (learner_task_id, task_id, learner_id, status_id, assigned_at)
                    VALUES
                    (%s, %s, %s, %s, %s)
                """, (learner_task_id, task_id, student["learner_id"], status_id, datetime.now()))
            
            conn.commit()
            logger.info(f"✅ Created assignment {task_id} for {len(enrolled_students)} students")
            
            return {
                "success": True,
                "message": f"Assignment created and assigned to {len(enrolled_students)} students",
                "data": {
                    "task_id": task_id,
                    "task_title": task_title,
                    "class_id": class_id,
                    "students_assigned": len(enrolled_students),
                    "due_date": due_date_obj.isoformat()
                }
            }
        
        finally:
            cursor.close()
            conn.close()
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating assignment: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# USER/ENTITY ENDPOINTS
# ============================================================================

@router.get("/users/get_user_entity_details/{keycloak_id}")
async def get_user_entity_details(keycloak_id: str):
    """Get user entity details by Keycloak ID"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.execute("""
                SELECT 
                    u.user_id,
                    u.keycloak_id,
                    u.email,
                    u.username,
                    u.first_name,
                    u.last_name,
                    r.role_name,
                    r.role_id,
                    i.institute_id,
                    i.institute_name,
                    i.is_demo,
                    i.primary_color,
                    i.logo_url,
                    s.status_code,
                    t.teacher_id,
                    t.teacher_code,
                    l.learner_id,
                    l.learner_code,
                    gl.grade_name
                FROM BINARY_SUCCESS_PLATFORM_USERS u
                LEFT JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON u.institute_id = i.institute_id
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON u.status_id = s.status_id
                LEFT JOIN BINARY_SUCCESS_TEACHERS t ON u.user_id = t.user_id
                LEFT JOIN BINARY_SUCCESS_LEARNERS l ON u.user_id = l.user_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON l.grade_level_id = gl.grade_level_id
                WHERE u.keycloak_id = %s
            """, (keycloak_id,))
            
            user = cursor.fetchone()
            
            if not user:
                raise HTTPException(status_code=404, detail="User not found")
                
            return {"success": True, "data": user}
        
        finally:
            cursor.close()
            conn.close()
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching user entity details for {keycloak_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# INSTITUTES ENDPOINTS
# ============================================================================

@router.get("/institutes")
async def get_all_institutes():
    """Get all institutes/schools"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.execute("""
                SELECT 
                    i.*,
                    s.status_code,
                    s.status_name,
                    COUNT(DISTINCT u.user_id) AS user_count
                FROM BINARY_SUCCESS_PLATFORM_INSTITUTES i
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON i.institute_status_id = s.status_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON i.institute_id = u.institute_id
                GROUP BY i.institute_id
                ORDER BY i.institute_name
            """)
            
            institutes = cursor.fetchall()
            return {"success": True, "data": institutes, "count": len(institutes)}
        finally:
            cursor.close()
            conn.close()
        
    except Exception as e:
        logger.error(f"Error fetching institutes: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/institutes/{institute_id}")
async def get_institute_by_id(institute_id: str):
    """Get institute details by ID"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.execute("""
                SELECT 
                    i.*,
                    s.status_code,
                    s.status_name
                FROM BINARY_SUCCESS_PLATFORM_INSTITUTES i
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON i.institute_status_id = s.status_id
                WHERE i.institute_id = %s
            """, (institute_id,))
            
            institute = cursor.fetchone()
            
            if not institute:
                raise HTTPException(status_code=404, detail="Institute not found")
                
            return {"success": True, "data": institute}
        finally:
            cursor.close()
            conn.close()
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching institute {institute_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# PLATFORM ADMIN ENDPOINTS
# ============================================================================

@router.get("/platform_admin/stats/")
async def get_platform_admin_stats():
    """Get overall platform statistics for the admin dashboard"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # 1. Active Students
            cursor.execute("""
                SELECT COUNT(*) as count 
                FROM BINARY_SUCCESS_PLATFORM_USERS u
                JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id
                JOIN BINARY_SUCCESS_STATUSES s ON u.status_id = s.status_id
                WHERE r.role_name = 'LEARNER' AND s.status_code = 'ACTIVE'
            """)
            active_students = cursor.fetchone()["count"]
            
            # 2. Total Schools
            cursor.execute("SELECT COUNT(*) as count FROM BINARY_SUCCESS_PLATFORM_INSTITUTES")
            total_schools = cursor.fetchone()["count"]
            
            # 3. AI Usage data (Anomalies)
            cursor.execute("""
                SELECT 
                    u.first_name, 
                    u.last_name, 
                    i.institute_name,
                    lt.deviation_percentage,
                    tt.task_title
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_LEARNERS l ON lt.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON u.institute_id = i.institute_id
                WHERE lt.deviation_percentage > 15
                ORDER BY lt.submitted_at DESC
                LIMIT 5
            """)
            anomalies = cursor.fetchall()
            
            return {
                "success": True,
                "data": {
                    "active_students": active_students,
                    "total_schools": total_schools,
                    "system_uptime": "99.9%",
                    "anomalies": anomalies
                }
            }
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/platform_admin/analytics")
async def get_platform_admin_analytics():
    """Get analytics data for platform admin"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # Calculate average deviation score
            cursor.execute("SELECT AVG(deviation_percentage) as avg_dev, COUNT(*) as total_fingerprints FROM BINARY_SUCCESS_LEARNER_TASKS WHERE deviation_percentage IS NOT NULL")
            fingerprint_stats = cursor.fetchone()
            avg_dev = round(fingerprint_stats['avg_dev'] or 0, 1)
            total_fp = fingerprint_stats['total_fingerprints'] or 0

            # Calculate total API quotas used
            cursor.execute("SELECT SUM(tokens_used) as total_tokens FROM BINARY_SUCCESS_API_QUOTAS")
            token_stats = cursor.fetchone()
            total_tokens = token_stats['total_tokens'] or 0

            kpis = [
                { "title": 'Writing Fingerprint', "sub": 'Average Deviation', "value": f'{avg_dev}%', "trend": 'up' },
                { "title": 'Writing Fingerprint', "sub": 'Total Scans', "value": str(total_fp), "trend": 'up' },
                { "title": 'AI Prompt Used', "sub": 'Total Tokens', "value": str(total_tokens), "trend": 'up' },
                { "title": 'AI Prompt Used', "sub": 'Average Per School', "value": str(round(total_tokens / max(1, fingerprint_stats['total_fingerprints']))), "trend": 'down' }
            ]

            chartData = [
                { "name": 'Jan', "value": 30 },
                { "name": 'Feb', "value": 45 },
                { "name": 'Mar', "value": 60 },
                { "name": 'Apr', "value": 25 },
                { "name": 'May', "value": 80 },
                { "name": 'Jun', "value": 50 },
                { "name": 'Jul', "value": 65 },
                { "name": 'Aug', "value": 35 },
                { "name": 'Sep', "value": 75 },
                { "name": 'Oct', "value": 90 },
                { "name": 'Nov', "value": 55 },
                { "name": 'Dec', "value": 70 }
            ]

            return {
                "success": True,
                "kpis": kpis,
                "chartData": chartData
            }
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching platform admin stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/platform_admin/get_all_institute_summary/")
async def get_all_institute_summary(
    institute_status: Optional[str] = None,
    page_number: int = 1,
    page_size: int = 10
):
    """Get all institutes with pagination and status filtering - FAST & ACCURATE"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # 1. Fetch basic info for the requested page (Very Fast)
            query = """
                SELECT 
                    i.institute_id,
                    i.institute_name,
                    i.institute_code,
                    i.is_demo,
                    i.primary_color,
                    i.logo_url,
                    i.created_at,
                    s.status_code,
                    s.status_name
                FROM BINARY_SUCCESS_PLATFORM_INSTITUTES i
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON i.institute_status_id = s.status_id
            """
            
            params = []
            if institute_status:
                query += " WHERE s.status_code = %s"
                params.append(institute_status)
            
            query += " ORDER BY i.created_at DESC"
            offset = (page_number - 1) * page_size
            query += " LIMIT %s OFFSET %s"
            params.extend([page_size, offset])
            
            cursor.execute(query, tuple(params))
            institutes = cursor.fetchall()
            
            if institutes:
                # 2. Extract IDs to fetch counts in one go for ONLY these schools (Efficient)
                inst_ids = [inst['institute_id'] for inst in institutes]
                id_placeholder = ', '.join(['%s'] * len(inst_ids))
                
                # Fetch student/teacher counts
                counts_query = f"""
                    SELECT 
                        institute_id,
                        COUNT(CASE WHEN role_id = 'role-004' THEN 1 END) as student_count,
                        COUNT(CASE WHEN role_id = 'role-003' THEN 1 END) as teacher_count
                    FROM BINARY_SUCCESS_PLATFORM_USERS
                    WHERE institute_id IN ({id_placeholder})
                    GROUP BY institute_id
                """
                cursor.execute(counts_query, tuple(inst_ids))
                user_counts = {row['institute_id']: row for row in cursor.fetchall()}
                
                # Fetch class counts
                class_query = f"""
                    SELECT institute_id, COUNT(*) as class_count
                    FROM BINARY_SUCCESS_CLASSES
                    WHERE institute_id IN ({id_placeholder})
                    GROUP BY institute_id
                """
                cursor.execute(class_query, tuple(inst_ids))
                class_counts = {row['institute_id']: row for row in cursor.fetchall()}
                
                # 3. Merge counts into institute data
                for idx, institute in enumerate(institutes, 1):
                    iid = institute['institute_id']
                    uc = user_counts.get(iid, {})
                    cc = class_counts.get(iid, {})
                    
                    institute['total_users'] = uc.get('student_count', 0) + uc.get('teacher_count', 0)
                    institute['total_teachers'] = uc.get('teacher_count', 0)
                    institute['total_students'] = uc.get('student_count', 0)
                    institute['total_learners'] = uc.get('student_count', 0)
                    institute['total_classes'] = cc.get('class_count', 0)
                    institute['assignment_count'] = 0 # Placeholder for now as it's a separate complex table
                    institute['fingerprint_submitted_count'] = 0
                    institute['rn'] = offset + idx
                    institute['users'] = []
                    institute['classes'] = []
                    institute['teachers'] = []
                    institute['students'] = []
            
            # 4. Get summary counts for the tabs
            summary_query = """
                SELECT 
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_PLATFORM_INSTITUTES i 
                     LEFT JOIN BINARY_SUCCESS_STATUSES s ON i.institute_status_id = s.status_id 
                     WHERE s.status_code = 'ACTIVE') as active_count,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_PLATFORM_INSTITUTES i 
                     LEFT JOIN BINARY_SUCCESS_STATUSES s ON i.institute_status_id = s.status_id 
                     WHERE s.status_code = 'ARCHIVED') as archived_count,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_PLATFORM_USERS) as total_users_count
            """
            cursor.execute(summary_query)
            summary_result = cursor.fetchone()
            
            return {
                "summary_counts": [{
                    "active_institutes": summary_result['active_count'],
                    "archived_institutes": summary_result['archived_count'],
                    "total_users": summary_result['total_users_count']
                }],
                "institute_details": institutes,
                "out_status": "SUCCESS"
            }
        
        finally:
            cursor.close()
            conn.close()
    
    except Exception as e:
        logger.error(f"Error fetching institutes: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/platform_admin/bulk_import_schools/")
async def bulk_import_schools(file: UploadFile = File(...)):
    """Bulk import schools and automatically assign an Institute Admin for each."""
    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="Only CSV files are allowed.")
    
    try:
        contents = await file.read()
        try:
            decoded_text = contents.decode("utf-8")
        except UnicodeDecodeError:
            decoded_text = contents.decode("utf-8-sig") # Fallback for BOM
            
        csv_reader = csv.DictReader(io.StringIO(decoded_text))
        required_cols = ['institute_name', 'institute_code', 'admin_email', 'admin_first_name', 'admin_last_name']
        missing_cols = [col for col in required_cols if col not in csv_reader.fieldnames]
        
        if missing_cols:
            raise HTTPException(status_code=400, detail=f"Missing required columns: {', '.join(missing_cols)}")
        
        conn = get_mysql_connection()
        cursor = conn.cursor()
        
        success_count = 0
        errors = []
        
        try:
            for i, row in enumerate(csv_reader, start=1):
                i_name = row.get('institute_name', '').strip()
                i_code = row.get('institute_code', '').strip()
                a_email = row.get('admin_email', '').strip()
                a_fname = row.get('admin_first_name', '').strip()
                a_lname = row.get('admin_last_name', '').strip()
                
                if not all([i_name, i_code, a_email, a_fname, a_lname]):
                    errors.append(f"Row {i}: Missing required data.")
                    continue
                
                # Check if school code exists
                cursor.execute("SELECT institute_id FROM BINARY_SUCCESS_PLATFORM_INSTITUTES WHERE institute_code = %s", (i_code,))
                if cursor.fetchone():
                    errors.append(f"Row {i}: Institute code '{i_code}' already exists.")
                    continue
                    
                # Check if admin email exists
                cursor.execute("SELECT user_id FROM BINARY_SUCCESS_PLATFORM_USERS WHERE email = %s", (a_email,))
                if cursor.fetchone():
                    errors.append(f"Row {i}: Email '{a_email}' already exists.")
                    continue
                
                # Create institute
                new_inst_id = f"inst-{uuid.uuid4().hex[:8]}"
                cursor.execute("""
                    INSERT INTO BINARY_SUCCESS_PLATFORM_INSTITUTES (
                        institute_id, institute_name, institute_code, institute_email, 
                        institute_city, institute_state, institute_status_id, is_demo
                    ) VALUES (%s, %s, %s, %s, %s, %s, 'status-001', %s)
                """, (
                    new_inst_id, i_name, i_code, a_email, 
                    row.get('city', ''), row.get('state', ''),
                    row.get('is_demo', 'N').upper()
                ))
                
                # Create user
                new_user_id = f"user-{uuid.uuid4().hex[:8]}"
                kc_id = f"kc-inst-{uuid.uuid4().hex[:8]}"
                cursor.execute("""
                    INSERT INTO BINARY_SUCCESS_PLATFORM_USERS (
                        user_id, keycloak_id, email, username, first_name, last_name,
                        role_id, institute_id, status_id
                    ) VALUES (%s, %s, %s, %s, %s, %s, 'role-002', %s, 'status-001')
                """, (
                    new_user_id, kc_id, a_email, a_email.split('@')[0], a_fname, a_lname, new_inst_id
                ))
                
                success_count += 1
                
            conn.commit()
            
        except Exception as inner_e:
            conn.rollback()
            raise inner_e
            
        finally:
            cursor.close()
            conn.close()
            
        return {
            "out_status": "SUCCESS",
            "message": f"Successfully imported {success_count} schools.",
            "errors": errors,
            "success_count": success_count
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Bulk import error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/platform_admin/institute/{institute_id}/branding")
async def update_institute_branding(
    institute_id: str,
    primary_color: str = Form(...),
    logo: Optional[UploadFile] = File(None)
):
    """Update primary color and logo for a school."""
    logo_path = None
    try:
        if logo and logo.filename:
            # Save logo
            upload_dir = os.path.join(os.path.dirname(__file__), "..", "..", "uploads", "logos")
            os.makedirs(upload_dir, exist_ok=True)
            
            ext = os.path.splitext(logo.filename)[1]
            unique_name = f"{institute_id}{ext}"
            file_path = os.path.join(upload_dir, unique_name)
            
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(logo.file, buffer)
                
            logo_path = f"/uploads/logos/{unique_name}"
            
        conn = get_mysql_connection()
        cursor = conn.cursor()
        
        if logo_path:
            cursor.execute("UPDATE BINARY_SUCCESS_PLATFORM_INSTITUTES SET primary_color = %s, logo_url = %s WHERE institute_id = %s", (primary_color, logo_path, institute_id))
        else:
            cursor.execute("UPDATE BINARY_SUCCESS_PLATFORM_INSTITUTES SET primary_color = %s WHERE institute_id = %s", (primary_color, institute_id))
            
        conn.commit()
        return {"out_status": "SUCCESS", "message": "Branding updated successfully!"}
    except Exception as e:
        logger.error(f"Update branding error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if 'cursor' in locals():
            cursor.close()
            conn.close()

class AddUserRequest(BaseModel):
    first_name: str
    last_name: str
    email: str
    role_id: str
    institute_id: Optional[str] = None

@router.post("/platform_admin/add_user/")
async def add_platform_user(req: AddUserRequest):
    """Manually add a single user (Teacher, Learner, or Admin)."""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Check if email already exists
            cursor.execute("SELECT user_id FROM BINARY_SUCCESS_PLATFORM_USERS WHERE email = %s", (req.email,))
            if cursor.fetchone():
                raise HTTPException(status_code=400, detail="Email already exists.")
            
            # Create user
            new_user_id = f"user-{uuid.uuid4().hex[:8]}"
            kc_id = f"kc-user-{uuid.uuid4().hex[:8]}"
            username = req.email.split('@')[0]
            
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_PLATFORM_USERS (
                    user_id, keycloak_id, email, username, first_name, last_name,
                    role_id, institute_id, status_id
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'status-001')
            """, (
                new_user_id, kc_id, req.email, username, req.first_name, req.last_name, 
                req.role_id, req.institute_id
            ))
            
            # If TEACHER role ('role-003'), also add to TEACHERS table
            if req.role_id == 'role-003':
                teacher_id = f"teacher-{uuid.uuid4().hex[:8]}"
                cursor.execute("""
                    INSERT INTO BINARY_SUCCESS_TEACHERS (teacher_id, user_id, institute_id, teacher_code)
                    VALUES (%s, %s, %s, %s)
                """, (teacher_id, new_user_id, req.institute_id, f"T-{uuid.uuid4().hex[:4]}"))
                
            # If LEARNER role ('role-004'), also add to LEARNERS table
            if req.role_id == 'role-004':
                learner_id = f"learner-{uuid.uuid4().hex[:8]}"
                cursor.execute("""
                    INSERT INTO BINARY_SUCCESS_LEARNERS (learner_id, user_id, institute_id, learner_code)
                    VALUES (%s, %s, %s, %s)
                """, (learner_id, new_user_id, req.institute_id, f"S-{uuid.uuid4().hex[:4]}"))
            
            conn.commit()
            
            return {
                "out_status": "SUCCESS",
                "message": "User added successfully.",
                "user_id": new_user_id
            }
            
        except HTTPException:
            raise
        except Exception as inner_e:
            conn.rollback()
            raise inner_e
            
        finally:
            cursor.close()
            conn.close()
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error adding user: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/platform_admin/bulk_import_users/")
async def bulk_import_users(
    file: UploadFile = File(...),
    institute_id: Optional[str] = None
):
    """Bulk import users (Students and Teachers) from CSV."""
    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="Only CSV files are allowed.")
    
    try:
        contents = await file.read()
        try:
            decoded_text = contents.decode("utf-8")
        except UnicodeDecodeError:
            decoded_text = contents.decode("utf-8-sig")
            
        csv_reader = csv.DictReader(io.StringIO(decoded_text))
        required_cols = ['first_name', 'last_name', 'email', 'role_id']
        missing_cols = [col for col in required_cols if col not in csv_reader.fieldnames]
        
        if missing_cols:
            raise HTTPException(status_code=400, detail=f"Missing required columns: {', '.join(missing_cols)}")
            
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        success_count = 0
        errors = []
        
        try:
            for i, row in enumerate(csv_reader, start=1):
                fname = row.get('first_name', '').strip()
                lname = row.get('last_name', '').strip()
                email = row.get('email', '').strip()
                role_id = row.get('role_id', '').strip()
                
                # Use query parameter institute_id if available, otherwise read from CSV
                row_inst_id = institute_id if institute_id else row.get('institute_id', '').strip()
                
                if not all([fname, lname, email, role_id]):
                    errors.append(f"Row {i}: Missing required data.")
                    continue
                    
                # Validate the role ID is among allowed ones
                if role_id not in ['role-002', 'role-003', 'role-004']:
                    errors.append(f"Row {i}: Invalid role_id '{role_id}'.")
                    continue
                
                # Check email existence
                cursor.execute("SELECT user_id FROM BINARY_SUCCESS_PLATFORM_USERS WHERE email = %s", (email,))
                if cursor.fetchone():
                    errors.append(f"Row {i}: Email '{email}' already exists.")
                    continue
                
                # Create user
                new_user_id = f"user-{uuid.uuid4().hex[:8]}"
                kc_id = f"kc-user-{uuid.uuid4().hex[:8]}"
                username = email.split('@')[0]
                
                cursor.execute("""
                    INSERT INTO BINARY_SUCCESS_PLATFORM_USERS (
                        user_id, keycloak_id, email, username, first_name, last_name,
                        role_id, institute_id, status_id
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'status-001')
                """, (
                    new_user_id, kc_id, email, username, fname, lname, 
                    role_id, row_inst_id if row_inst_id else None
                ))
                
                if role_id == 'role-003':
                    teacher_id = f"teacher-{uuid.uuid4().hex[:8]}"
                    cursor.execute("""
                        INSERT INTO BINARY_SUCCESS_TEACHERS (teacher_id, user_id, institute_id, teacher_code)
                        VALUES (%s, %s, %s, %s)
                    """, (teacher_id, new_user_id, row_inst_id if row_inst_id else None, f"T-{uuid.uuid4().hex[:4]}"))
                    
                if role_id == 'role-004':
                    learner_id = f"learner-{uuid.uuid4().hex[:8]}"
                    cursor.execute("""
                        INSERT INTO BINARY_SUCCESS_LEARNERS (learner_id, user_id, institute_id, learner_code)
                        VALUES (%s, %s, %s, %s)
                    """, (learner_id, new_user_id, row_inst_id if row_inst_id else None, f"S-{uuid.uuid4().hex[:4]}"))
                    
                success_count += 1
                
            conn.commit()
            
        except Exception as inner_e:
            conn.rollback()
            raise inner_e
            
        finally:
            cursor.close()
            conn.close()
            
        return {
            "out_status": "SUCCESS",
            "message": f"Successfully imported {success_count} users.",
            "errors": errors,
            "success_count": success_count
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Bulk import error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/platform_admin/get_all_platform_users/")
async def get_all_platform_users(
    user_status: Optional[str] = None,
    institute_id: Optional[str] = None,
    page_number: int = 1,
    page_size: int = 10
):
    """Get all platform users with pagination, status and institute filtering"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Build query with optional filters
            query = """
                SELECT 
                    u.user_id,
                    u.username,
                    u.first_name,
                    u.last_name,
                    u.email,
                    u.created_at,
                    s.status_code,
                    s.status_name,
                    r.role_name as role_display_name,
                    i.institute_name as school_name,
                    i.institute_id
                FROM BINARY_SUCCESS_PLATFORM_USERS u
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON u.status_id = s.status_id
                LEFT JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON u.institute_id = i.institute_id
            """
            
            conditions = []
            params = []
            if user_status:
                conditions.append("LOWER(s.status_code) = LOWER(%s)")
                params.append(user_status)
            if institute_id:
                conditions.append("u.institute_id = %s")
                params.append(institute_id)
            
            if conditions:
                query += " WHERE " + " AND ".join(conditions)
            
            query += " ORDER BY u.created_at DESC"
            
            # Add pagination
            offset = (page_number - 1) * page_size
            query += " LIMIT %s OFFSET %s"
            params.extend([page_size, offset])
            
            cursor.execute(query, tuple(params))
            users = cursor.fetchall()
            
            # Get user counts (scoped to institute if provided)
            count_query = """
                SELECT 
                    COUNT(*) as total_users,
                    SUM(CASE WHEN UPPER(s.status_code) = 'ACTIVE' THEN 1 ELSE 0 END) as active_users,
                    SUM(CASE WHEN UPPER(s.status_code) != 'ACTIVE' THEN 1 ELSE 0 END) as archived_users
                FROM BINARY_SUCCESS_PLATFORM_USERS u
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON u.status_id = s.status_id
            """
            count_params = []
            if institute_id:
                count_query += " WHERE u.institute_id = %s"
                count_params.append(institute_id)
            
            cursor.execute(count_query, tuple(count_params))
            counts = cursor.fetchone()
            
            return {
                "out_status": "SUCCESS",
                "user_counts": [{
                    "total_users": counts['total_users'] if counts else 0,
                    "active_users": counts['active_users'] if counts else 0,
                    "archived_users": counts['archived_users'] if counts else 0
                }],
                "user_list": users
            }
        
        finally:
            cursor.close()
            conn.close()
    
    except Exception as e:
        logger.error(f"Error fetching users: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/platform_admin/audit_logs")
async def get_audit_logs(page_number: int = 1, page_size: int = 20):
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            query = "SELECT log_id, user_name, role_name, action_type, description, ip_address, created_at FROM BINARY_SUCCESS_AUDIT_LOGS ORDER BY created_at DESC"
            offset = (page_number - 1) * page_size
            query += " LIMIT %s OFFSET %s"
            cursor.execute(query, (page_size, offset))
            logs = cursor.fetchall()
            
            cursor.execute("SELECT COUNT(*) as total FROM BINARY_SUCCESS_AUDIT_LOGS")
            total = cursor.fetchone()['total']
            
            return {
                "out_status": "SUCCESS",
                "logs": logs,
                "total": total
            }
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching audit logs: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/platform_admin/api_quotas")
async def get_api_quotas():
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # Join with platform institutes to get the name
            query = """
                SELECT 
                    q.quota_id,
                    q.institute_id,
                    q.month_year,
                    q.tokens_used,
                    q.threshold_limit,
                    q.last_updated,
                    i.institute_name,
                    i.is_demo
                FROM BINARY_SUCCESS_API_QUOTAS q
                JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON q.institute_id = i.institute_id
                ORDER BY q.tokens_used DESC
            """
            cursor.execute(query)
            quotas = cursor.fetchall()
            
            # Simple summary stats
            total_tokens = sum(q['tokens_used'] for q in quotas)
            schools_near_limit = sum(1 for q in quotas if q['tokens_used'] >= (q['threshold_limit'] * 0.8))
            
            return {
                "out_status": "SUCCESS",
                "quotas": quotas,
                "summary": {
                    "total_tokens_used": total_tokens,
                    "schools_near_limit": schools_near_limit
                }
            }
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching api quotas: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# TEACHER ENDPOINTS
# ============================================================================

@router.get("/teacher/get_class_summary/")
async def get_teacher_class_summary(
    teacher_id: str,
    class_status: str = "Active"
):
    """Get teacher's class summary with status filtering"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # 1. Get class details for the teacher
            class_query = """
                SELECT 
                    c.class_id,
                    c.class_name,
                    c.class_code,
                    c.institute_id,
                    c.grade_level_id,
                    c.term,
                    c.academic_year,
                    c.teacher_id,
                    gl.grade_name,
                    %s as class_status,
                    '' as description,
                    '' as alfresco_class_id
                FROM BINARY_SUCCESS_CLASSES c
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
                WHERE c.teacher_id = %s
                ORDER BY c.created_at DESC
            """
            
            cursor.execute(class_query, (class_status, teacher_id))
            classes = cursor.fetchall()
            
            # 2. For each class, get student count and active assignments count
            for cls in classes:
                class_id = cls['class_id']
                
                # Convert academic_year from string to int (extract first year)
                if cls.get('academic_year'):
                    try:
                        # Handle formats like "2025-2026" -> 2025
                        year_str = str(cls['academic_year']).split('-')[0]
                        cls['academic_year'] = int(year_str)
                    except (ValueError, IndexError):
                        cls['academic_year'] = None
                
                # Count enrolled students
                cursor.execute("""
                    SELECT COUNT(*) as count 
                    FROM BINARY_SUCCESS_ENROLLMENTS 
                    WHERE class_id = %s AND status = 'ACTIVE'
                """, (class_id,))
                student_count = cursor.fetchone()
                cls['num_students'] = student_count['count'] if student_count else 0
                
                # Count active assignments
                cursor.execute("""
                    SELECT COUNT(*) as count 
                    FROM BINARY_SUCCESS_TEACHER_TASKS tt
                    WHERE tt.class_id = %s
                """, (class_id,))
                assignment_count = cursor.fetchone()
                cls['num_active_assignments'] = assignment_count['count'] if assignment_count else 0
                
                # Count recent fingerprint submissions (placeholder)
                cls['num_last_fingerprint_submitted'] = 0
            
            # 3. Get teacher summary
            teacher_query = """
                SELECT 
                    t.teacher_id,
                    u.first_name,
                    u.last_name,
                    u.email,
                    t.institute_id,
                    '' as salutation,
                    '' as alfresco_user_id,
                    '' as alfresco_site_id
                FROM BINARY_SUCCESS_TEACHERS t
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                WHERE t.teacher_id = %s
            """
            
            cursor.execute(teacher_query, (teacher_id,))
            teacher = cursor.fetchone()
            
            # Calculate total learners across all classes
            cursor.execute("""
                SELECT COUNT(DISTINCT e.learner_id) as total_learners
                FROM BINARY_SUCCESS_CLASSES c
                JOIN BINARY_SUCCESS_ENROLLMENTS e ON c.class_id = e.class_id
                WHERE c.teacher_id = %s AND e.status = 'ACTIVE'
            """, (teacher_id,))
            learner_count = cursor.fetchone()
            
            if teacher:
                teacher['total_learners'] = learner_count['total_learners'] if learner_count else 0
            
            # 4. Get class status counts
            cursor.execute("""
                SELECT COUNT(*) as total_classes
                FROM BINARY_SUCCESS_CLASSES
                WHERE teacher_id = %s
            """, (teacher_id,))
            total_classes = cursor.fetchone()
            
            # Since we don't have a status column, we'll return all as active
            class_status_count = {
                "active_classes": total_classes['total_classes'] if total_classes else 0,
                "archived_classes": 0
            }
            
            # 5. Format response
            return {
                "class_status_count": [class_status_count],
                "teacher_summary": [teacher] if teacher else [],
                "class_details": classes,
                "out_status": "SUCCESS"
            }
            
        finally:
            cursor.close()
            conn.close()
    
    except Exception as e:
        logger.error(f"Error fetching teacher class summary: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/teacher/get_class_tasks_stats_and_learners/")
async def get_class_tasks_stats_and_learners(
    teacher_id: str,
    class_id: str
):
    """Get class details with students list and task statistics"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # 1. Get students enrolled in this class
            students_query = """
                SELECT 
                    l.learner_id,
                    u.first_name,
                    u.last_name,
                    u.email,
                    e.status as learner_status,
                    '' as salutation,
                    'N' as has_fingerprint_submitted
                FROM BINARY_SUCCESS_ENROLLMENTS e
                JOIN BINARY_SUCCESS_LEARNERS l ON e.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                WHERE e.class_id = %s
                ORDER BY u.last_name, u.first_name
            """
            
            cursor.execute(students_query, (class_id,))
            students = cursor.fetchall()
            
            # 2. Get class summary statistics
            # Count total submitted tasks
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                WHERE tt.class_id = %s AND ts.status IN ('SUBMITTED', 'GRADED')
            """, (class_id,))
            submitted_result = cursor.fetchone()
            total_submitted = submitted_result['count'] if submitted_result else 0
            
            # Count pending review tasks
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                WHERE tt.class_id = %s AND ts.status = 'SUBMITTED'
            """, (class_id,))
            pending_result = cursor.fetchone()
            total_pending_review = pending_result['count'] if pending_result else 0
            
            # Average grade - column doesn't exist yet, set to 0
            avg_teacher_grade = 0.0
            
            # 3. Format response
            return {
                "students_list": students,
                "class_summary": [{
                    "total_submitted": total_submitted,
                    "total_pending_review": total_pending_review,
                    "avg_teacher_grade": round(avg_teacher_grade, 2)
                }],
                "out_status": "SUCCESS"
            }
            
        finally:
            cursor.close()
            conn.close()
    
    except Exception as e:
        logger.error(f"Error fetching class details: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/teacher/get_assignment_overview/")
async def get_assignment_overview(
    teacher_id: str,
    task_status: str = "active"
):
    """Get teacher's assignment overview with task counts and summaries"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # 1. Get task counts - since status_id doesn't exist in teacher_tasks, 
            # we'll count all tasks as active for now
            cursor.execute("""
                SELECT 
                    COUNT(*) as total_tasks
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                WHERE c.teacher_id = %s
            """, (teacher_id,))
            
            counts_result = cursor.fetchone()
            total_count = counts_result['total_tasks'] if counts_result else 0
            
            # Since we don't have status tracking, return all as active
            task_counts = {
                "draft_tasks": 0,
                "scheduled_tasks": 0,
                "active_tasks": total_count
            }
            
            # 2. Get task summaries - return all tasks since we can't filter by status
            task_summary_query = """
                SELECT 
                    tt.task_id,
                    tt.task_title,
                    tt.task_description,
                    tt.due_date,
                    c.class_name,
                    gl.grade_name,
                    'ACTIVE' as status,
                    COUNT(DISTINCT e.learner_id) as total_learners,
                    COUNT(DISTINCT CASE WHEN lts.status = 'SUBMITTED' THEN lt.learner_task_id END) as submitted_count
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
                LEFT JOIN BINARY_SUCCESS_ENROLLMENTS e ON c.class_id = e.class_id AND e.status = 'ACTIVE'
                LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id
                LEFT JOIN BINARY_SUCCESS_TASK_STATUSES lts ON lt.status_id = lts.status_id
                WHERE c.teacher_id = %s
                GROUP BY tt.task_id, tt.task_title, tt.task_description, tt.due_date, 
                         c.class_name, gl.grade_name
                ORDER BY tt.due_date DESC
            """
            
            cursor.execute(task_summary_query, (teacher_id,))
            tasks = cursor.fetchall()
            
            # Format task summaries
            task_summaries = []
            for task in tasks:
                task_summaries.append({
                    "task_id": task['task_id'],
                    "task_title": task['task_title'],
                    "submitted_count": task['submitted_count'] or 0,
                    "total_learners": task['total_learners'] or 0,
                    "class_name": task['class_name'] or '',
                    "grade_name": task['grade_name'] or '',
                    "due_date": task['due_date'].strftime('%Y-%m-%d') if task['due_date'] else '',
                    "status": task['status'] or ''
                })
            
            # 3. Format response
            return {
                "task_counts": [task_counts],
                "task_summary": task_summaries,
                "out_status": "SUCCESS"
            }
            
        finally:
            cursor.close()
            conn.close()
    
    except Exception as e:
        logger.error(f"Error fetching assignment overview: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/teacher/get_stats_and_learners_for_task/")
async def get_stats_and_learners_for_task(task_id: str):
    """Get task statistics and per-student details for a specific assignment"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # 1. Get task info
            cursor.execute("""
                SELECT 
                    tt.task_id,
                    tt.task_title,
                    tt.task_description,
                    tt.due_date,
                    tt.max_score,
                    c.class_id,
                    c.class_name
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                WHERE tt.task_id = %s
            """, (task_id,))
            task_info = cursor.fetchone()
            
            if not task_info:
                return {
                    "task_details_and_stats": [],
                    "task_details_per_student": [],
                    "out_status": "SUCCESS"
                }
            
            class_id = task_info['class_id']
            
            # 2. Get all enrolled learners for the class
            cursor.execute("""
                SELECT 
                    l.learner_id,
                    u.user_id,
                    u.first_name,
                    u.last_name,
                    u.email,
                    e.status as learner_status,
                    '' as salutation
                FROM BINARY_SUCCESS_ENROLLMENTS e
                JOIN BINARY_SUCCESS_LEARNERS l ON e.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                WHERE e.class_id = %s
                ORDER BY u.last_name, u.first_name
            """, (class_id,))
            enrolled_learners = cursor.fetchall()
            
            # 3. Get submission data for each learner
            cursor.execute("""
                SELECT 
                    lt.learner_id,
                    lt.status_id,
                    lt.submitted_at,
                    lt.graded_at,
                    ts.status as task_status
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                WHERE lt.task_id = %s
            """, (task_id,))
            submissions = cursor.fetchall()
            
            # Create submission lookup by learner_id
            submission_map = {}
            for sub in submissions:
                submission_map[sub['learner_id']] = sub
            
            # 4. Build per-student details
            task_details_per_student = []
            total_submitted = 0
            total_missing = 0
            
            for idx, learner in enumerate(enrolled_learners, 1):
                learner_id = learner['learner_id']
                submission = submission_map.get(learner_id)
                
                if submission and submission['task_status'] in ('SUBMITTED', 'GRADED'):
                    task_status = submission['task_status']
                    submitted_at = submission['submitted_at'].isoformat() if submission['submitted_at'] else None
                    has_fingerprint = 'Y'
                    total_submitted += 1
                else:
                    task_status = 'PENDING'
                    submitted_at = None
                    has_fingerprint = 'N'
                    total_missing += 1
                
                task_details_per_student.append({
                    "learner_id": learner_id,
                    "user_id": learner.get('user_id', ''),
                    "salutation": learner.get('salutation', ''),
                    "first_name": learner.get('first_name', ''),
                    "last_name": learner.get('last_name', ''),
                    "email": learner.get('email', ''),
                    "learner_status": learner.get('learner_status', 'ACTIVE'),
                    "has_fingerprint_submitted": has_fingerprint,
                    "task_status": task_status,
                    "submitted_at": submitted_at,
                    "submitted_word_count": 0,
                    "grade": None,
                    "total_points": 0,
                    "rn": idx
                })
            
            # 5. Build task stats
            task_details_and_stats = [{
                "task_id": task_info['task_id'],
                "task_title": task_info['task_title'],
                "total_submitted": total_submitted,
                "total_missing": total_missing,
                "avg_teacher_grade": 0
            }]
            
            return {
                "task_details_and_stats": task_details_and_stats,
                "task_details_per_student": task_details_per_student,
                "out_status": "SUCCESS"
            }
            
        finally:
            cursor.close()
            conn.close()
    
    except Exception as e:
        logger.error(f"Error fetching task stats and learners: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/assignments/submit")
async def submit_assignment(request: Request):
    """Submit a learner task"""
    try:
        data = await request.json()
        
        learner_task_id = data.get("learner_task_id")
        content = data.get("content")
        word_count = data.get("word_count", 0)
        
        if not learner_task_id:
            raise HTTPException(status_code=400, detail="Missing learner_task_id")
            
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Check if task exists and get status_id for 'SUBMITTED'
            cursor.execute("SELECT status_id FROM BINARY_SUCCESS_TASK_STATUSES WHERE status = 'SUBMITTED'")
            status_row = cursor.fetchone()
            if not status_row:
                raise HTTPException(status_code=500, detail="Task status 'SUBMITTED' not found in database")
            
            submitted_status_id = status_row['status_id']
            
            # Update learner task with content and status
            cursor.execute("""
                UPDATE BINARY_SUCCESS_LEARNER_TASKS 
                SET status_id = %s, submitted_at = %s, submission_text = %s
                WHERE learner_task_id = %s
            """, (submitted_status_id, datetime.now(), content, learner_task_id))
            
            conn.commit()
            return {"success": True, "message": "Assignment submitted successfully"}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error submitting assignment: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/assignments/save_draft")
async def save_assignment_draft(request: Request):
    """Save an assignment draft without submitting it"""
    try:
        data = await request.json()
        
        learner_task_id = data.get("learner_task_id")
        content = data.get("content")
        
        if not learner_task_id:
            raise HTTPException(status_code=400, detail="Missing learner_task_id")
            
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Check if task is already in progress, if not set it to IN_PROGRESS
            # Get current status
            cursor.execute("SELECT status_id FROM BINARY_SUCCESS_LEARNER_TASKS WHERE learner_task_id = %s", (learner_task_id,))
            user_task = cursor.fetchone()
            
            if not user_task:
                raise HTTPException(status_code=404, detail="Learner task not found")
                
            # Get status IDs
            cursor.execute("SELECT status_id, status FROM BINARY_SUCCESS_TASK_STATUSES WHERE status IN ('ASSIGNED', 'IN_PROGRESS')")
            status_map = {row['status']: row['status_id'] for row in cursor.fetchall()}
            
            status_id = user_task['status_id']
            if status_id == status_map.get('ASSIGNED'):
                status_id = status_map.get('IN_PROGRESS')
                
            # Update learner task with content
            cursor.execute("""
                UPDATE BINARY_SUCCESS_LEARNER_TASKS 
                SET submission_text = %s, status_id = %s
                WHERE learner_task_id = %s
            """, (content, status_id, learner_task_id))
            
            conn.commit()
            return {"success": True, "message": "Draft saved successfully", "status": "IN_PROGRESS"}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error saving draft: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/assignments/grade")
async def submit_grade(request: Request):
    """Submit score and feedback for a learner task"""
    try:
        data = await request.json()
        learner_task_id = data.get("learner_task_id")
        score = data.get("score")
        feedback = data.get("feedback", "")
        
        if not learner_task_id:
            raise HTTPException(status_code=400, detail="Missing learner_task_id")
            
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Get GRADED status_id
            cursor.execute("SELECT status_id FROM BINARY_SUCCESS_TASK_STATUSES WHERE status = 'GRADED'")
            status_row = cursor.fetchone()
            graded_status_id = status_row['status_id'] if status_row else "taskstatus-004"
            
            # Update learner task
            cursor.execute("""
                UPDATE BINARY_SUCCESS_LEARNER_TASKS 
                SET score = %s, feedback = %s, status_id = %s, graded_at = %s
                WHERE learner_task_id = %s
            """, (score, feedback, graded_status_id, datetime.now(), learner_task_id))
            
            conn.commit()
            return {"success": True, "message": "Grade submitted successfully"}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error submitting grade: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/assignments/{learner_task_id}/chat")
async def get_chat_history(learner_task_id: str):
    """Get chat history for a specific learner task"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT message_id, sender, message_content, created_at
                FROM BINARY_SUCCESS_AIC_MESSAGES
                WHERE learner_task_id = %s
                ORDER BY created_at ASC
            """, (learner_task_id,))
            messages = cursor.fetchall()
            return {"success": True, "data": messages}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error loading chat history: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/assignments/{learner_task_id}/chat")
async def send_chat_message(learner_task_id: str, request: Request):
    """Send a message to AI and get a response"""
    try:
        data = await request.json()
        message = data.get("message")
        
        if not message:
            raise HTTPException(status_code=400, detail="Message is required")
            
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # 1. Fetch Task Context
            cursor.execute("""
                SELECT tt.task_title, tt.task_description 
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id
                WHERE lt.learner_task_id = %s
            """, (learner_task_id,))
            task = cursor.fetchone()
            task_context = f"Task Title: {task['task_title']}\nDescription: {task['task_description']}" if task else "Generic Writing Task"

            # 2. Fetch Chat History (for context)
            cursor.execute("""
                SELECT sender, message_content 
                FROM BINARY_SUCCESS_AIC_MESSAGES 
                WHERE learner_task_id = %s 
                ORDER BY created_at ASC 
                LIMIT 10
            """, (learner_task_id,))
            history = cursor.fetchall()

            # 3. Save student message
            student_msg_id = f"msg-{uuid.uuid4().hex[:12]}"
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_AIC_MESSAGES (message_id, learner_task_id, sender, message_content)
                VALUES (%s, %s, 'STUDENT', %s)
            """, (student_msg_id, learner_task_id, message))
            
            # 4. Get REAL AI Response
            ai_response = await ai_service.get_chat_response(message, context=task_context, history=history)
            
            # 5. Save AI response
            ai_msg_id = f"msg-{uuid.uuid4().hex[:12]}"
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_AIC_MESSAGES (message_id, learner_task_id, sender, message_content)
                VALUES (%s, %s, 'AI', %s)
            """, (ai_msg_id, learner_task_id, ai_response))
            
            conn.commit()
            
            return {
                "success": True, 
                "student_message": {"message_id": student_msg_id, "sender": "STUDENT", "content": message},
                "ai_response": {"message_id": ai_msg_id, "sender": "AI", "content": ai_response}
            }
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error sending chat message: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/assignments/{learner_task_id}/auto-grade")
async def auto_grade_submission(learner_task_id: str):
    """Trigger AI automated grading for a specific submission"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # 1. Fetch Task Context & Student Submission
            cursor.execute("""
                SELECT tt.task_title, tt.task_description, lt.submission_text
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id
                WHERE lt.learner_task_id = %s
            """, (learner_task_id,))
            data = cursor.fetchone()
            
            if not data or not data['submission_text']:
                raise HTTPException(status_code=400, detail="Submission text not found.")
            
            task_context = f"Title: {data['task_title']}\nDescription: {data['task_description']}"
            submission_text = data['submission_text']
            
            # 2. Get AI Grade
            ai_result = await ai_service.get_auto_grade(submission_text, task_context)
            
            return {
                "success": True, 
                "score": ai_result.get("score", 0),
                "feedback": ai_result.get("feedback", "No feedback generated.")
            }
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error in auto-grading: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/teacher/{teacher_id}/calendar-events")
async def get_calendar_events(teacher_id: str, month: Optional[int] = None, year: Optional[int] = None):
    """Get calendar events for a teacher - includes due dates, submissions, grading"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # 1. Assignment due dates
            cursor.execute("""
                SELECT 
                    tt.task_id, tt.task_title, tt.due_date, tt.created_at,
                    c.class_name, c.class_id,
                    ttype.task_type,
                    COUNT(DISTINCT lt.learner_task_id) as submission_count,
                    COUNT(DISTINCT CASE WHEN ts.status = 'GRADED' THEN lt.learner_task_id END) as graded_count,
                    (SELECT COUNT(*) FROM BINARY_SUCCESS_ENROLLMENTS e WHERE e.class_id = tt.class_id AND e.status = 'ACTIVE') as student_count
                FROM BINARY_SUCCESS_TEACHER_TASKS tt
                JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id
                LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                WHERE tt.teacher_id = %s
                GROUP BY tt.task_id
                ORDER BY tt.due_date ASC
            """, (teacher_id,))
            assignments = cursor.fetchall()

            events = []
            for a in assignments:
                # Due date event
                if a['due_date']:
                    events.append({
                        "date": a['due_date'].strftime('%Y-%m-%d') if hasattr(a['due_date'], 'strftime') else str(a['due_date'])[:10],
                        "type": "deadline",
                        "title": a['task_title'],
                        "class_name": a['class_name'] or 'N/A',
                        "task_id": a['task_id'],
                        "task_type": a['task_type'],
                        "submission_count": a['submission_count'],
                        "student_count": a['student_count'],
                        "graded_count": a['graded_count'],
                        "color": "#EF4444"
                    })
                # Created date event
                if a['created_at']:
                    events.append({
                        "date": a['created_at'].strftime('%Y-%m-%d') if hasattr(a['created_at'], 'strftime') else str(a['created_at'])[:10],
                        "type": "created",
                        "title": f"Created: {a['task_title']}",
                        "class_name": a['class_name'] or 'N/A',
                        "task_id": a['task_id'],
                        "task_type": a['task_type'],
                        "color": "#3B82F6"
                    })

            # 2. Submission events
            cursor.execute("""
                SELECT 
                    lt.submitted_at, lt.graded_at,
                    tt.task_title, tt.task_id,
                    u.first_name, u.last_name,
                    c.class_name
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON lt.task_id = tt.task_id
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                JOIN BINARY_SUCCESS_LEARNERS l ON lt.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
                LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                WHERE tt.teacher_id = %s AND lt.submitted_at IS NOT NULL
                ORDER BY lt.submitted_at DESC
            """, (teacher_id,))
            submissions = cursor.fetchall()

            for s in submissions:
                if s['submitted_at']:
                    events.append({
                        "date": s['submitted_at'].strftime('%Y-%m-%d') if hasattr(s['submitted_at'], 'strftime') else str(s['submitted_at'])[:10],
                        "type": "submission",
                        "title": f"{s['first_name']} {s['last_name']} submitted",
                        "class_name": s['class_name'] or 'N/A',
                        "task_id": s['task_id'],
                        "task_title": s['task_title'],
                        "color": "#F59E0B"
                    })
                if s['graded_at']:
                    events.append({
                        "date": s['graded_at'].strftime('%Y-%m-%d') if hasattr(s['graded_at'], 'strftime') else str(s['graded_at'])[:10],
                        "type": "graded",
                        "title": f"Graded: {s['first_name']} {s['last_name']}",
                        "class_name": s['class_name'] or 'N/A',
                        "task_id": s['task_id'],
                        "task_title": s['task_title'],
                        "color": "#10B981"
                    })

            return {"success": True, "data": events, "count": len(events)}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching calendar events: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# REMINDERS ENDPOINTS
# ============================================================================

@router.get("/teacher/{teacher_id}/reminders")
async def get_reminders(teacher_id: str):
    """Get all reminders for a teacher"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT reminder_id, teacher_id, reminder_date, reminder_title, 
                       reminder_description, reminder_type, color, is_completed, created_at
                FROM BINARY_SUCCESS_REMINDERS 
                WHERE teacher_id = %s 
                ORDER BY reminder_date ASC
            """, (teacher_id,))
            reminders = cursor.fetchall()
            # Convert date objects to strings
            for r in reminders:
                if r.get('reminder_date'):
                    r['reminder_date'] = r['reminder_date'].strftime('%Y-%m-%d') if hasattr(r['reminder_date'], 'strftime') else str(r['reminder_date'])
                if r.get('created_at'):
                    r['created_at'] = r['created_at'].isoformat() if hasattr(r['created_at'], 'isoformat') else str(r['created_at'])
                if r.get('is_completed') is not None:
                    r['is_completed'] = bool(r['is_completed'])
            return {"success": True, "data": reminders, "count": len(reminders)}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching reminders: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/teacher/{teacher_id}/reminders")
async def create_reminder(teacher_id: str, request: Request):
    """Create a new reminder"""
    try:
        data = await request.json()
        title = data.get("title")
        date = data.get("date")
        description = data.get("description", "")
        reminder_type = data.get("type", "personal")
        color = data.get("color", "#6366F1")

        if not title or not date:
            raise HTTPException(status_code=400, detail="Title and date are required.")

        reminder_id = f"rem-{uuid.uuid4().hex[:12]}"

        conn = get_mysql_connection()
        cursor = conn.cursor()
        try:
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_REMINDERS 
                (reminder_id, teacher_id, reminder_date, reminder_title, reminder_description, reminder_type, color)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (reminder_id, teacher_id, date, title, description, reminder_type, color))
            conn.commit()
            return {
                "success": True, 
                "reminder_id": reminder_id,
                "message": "Reminder created successfully."
            }
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error creating reminder: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/reminders/{reminder_id}")
async def delete_reminder(reminder_id: str):
    """Delete a reminder"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM BINARY_SUCCESS_REMINDERS WHERE reminder_id = %s", (reminder_id,))
            conn.commit()
            return {"success": True, "message": "Reminder deleted."}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error deleting reminder: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/reminders/{reminder_id}/toggle")
async def toggle_reminder(reminder_id: str):
    """Toggle a reminder's completed status"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        try:
            cursor.execute("""
                UPDATE BINARY_SUCCESS_REMINDERS 
                SET is_completed = NOT is_completed 
                WHERE reminder_id = %s
            """, (reminder_id,))
            conn.commit()
            return {"success": True, "message": "Reminder toggled."}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error toggling reminder: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/study-materials")
async def get_study_materials(
    teacher_id: Optional[str] = None,
    grade_level_id: Optional[str] = None,
    institute_id: Optional[str] = None
):
    """Get study materials with optional filters"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            query = """
                SELECT sm.*, u.first_name, u.last_name, gl.grade_name
                FROM BINARY_SUCCESS_STUDY_MATERIALS sm
                LEFT JOIN BINARY_SUCCESS_TEACHERS t ON sm.teacher_id = t.teacher_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_USERS u ON t.user_id = u.user_id
                LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON sm.grade_level_id = gl.grade_level_id
            """
            conditions = []
            params = []
            
            if teacher_id:
                conditions.append("sm.teacher_id = %s")
                params.append(teacher_id)
            if grade_level_id:
                conditions.append("sm.grade_level_id = %s")
                params.append(grade_level_id)
            if institute_id:
                conditions.append("sm.institute_id = %s")
                params.append(institute_id)
                
            if conditions:
                query += " WHERE " + " AND ".join(conditions)
            
            query += " ORDER BY sm.created_at DESC"
            cursor.execute(query, tuple(params))
            materials = cursor.fetchall()
            return {"success": True, "data": materials}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error fetching study materials: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/study-materials/upload")
async def upload_study_material(file: UploadFile = File(...)):
    """Upload a file to the server and return the URL"""
    try:
        import uuid
        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{file_extension}"
        file_path = os.path.join("uploads", unique_filename)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # For simplicity, returning a relative URL that matches the mounted path
        # In a real app, this might be a full URL like http://localhost:8000/uploads/...
        file_url = f"/uploads/{unique_filename}"
        
        return {
            "success": True, 
            "file_url": file_url, 
            "filename": file.filename,
            "original_filename": file.filename
        }
    except Exception as e:
        logger.error(f"Error uploading file: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/study-materials/create")
async def create_study_material(request: Request):
    """Upload/Link new study material"""
    try:
        import uuid
        data = await request.json()
        
        material_id = f"mat-{uuid.uuid4().hex[:12]}"
        title = data.get("title")
        description = data.get("description", "")
        material_type = data.get("material_type") # PDF, VIDEO, etc.
        file_url = data.get("file_url", "")
        external_link = data.get("external_link", "")
        teacher_id = data.get("teacher_id")
        grade_level_id = data.get("grade_level_id")
        
        if not all([title, material_type, teacher_id, grade_level_id]):
            raise HTTPException(status_code=400, detail="Missing required fields")
            
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # Get institute from teacher
            cursor.execute("SELECT institute_id FROM BINARY_SUCCESS_TEACHERS WHERE teacher_id = %s", (teacher_id,))
            teacher_data = cursor.fetchone()
            institute_id = teacher_data["institute_id"] if teacher_data else None
            
            cursor.execute("""
                INSERT INTO BINARY_SUCCESS_STUDY_MATERIALS 
                (material_id, title, description, material_type, file_url, external_link, 
                 teacher_id, institute_id, grade_level_id, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
            """, (material_id, title, description, material_type, file_url, external_link, 
                  teacher_id, institute_id, grade_level_id))
            
            conn.commit()
            return {"success": True, "message": "Study material added successfully", "material_id": material_id}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error creating study material: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# SYSTEM DICTIONARY / GLOBAL SETTINGS
# ============================================================================

class GradeLevelCreate(BaseModel):
    grade_name: str
    grade_order: int

@router.get("/dictionary/grade_levels")
async def get_grade_levels():
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM BINARY_SUCCESS_GRADE_LEVELS ORDER BY grade_order ASC")
        return {"out_status": "SUCCESS", "items": cursor.fetchall()}
    finally:
        cursor.close()
        conn.close()

@router.post("/dictionary/grade_levels")
async def add_grade_level(grade: GradeLevelCreate):
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        grade_id = f"grade-{uuid.uuid4().hex[:8]}"
        cursor.execute(
            "INSERT INTO BINARY_SUCCESS_GRADE_LEVELS (grade_level_id, grade_name, grade_order) VALUES (%s, %s, %s)",
            (grade_id, grade.grade_name, grade.grade_order)
        )
        conn.commit()
        return {"out_status": "SUCCESS", "message": "Grade Level added", "grade_level_id": grade_id}
    finally:
        cursor.close()
        conn.close()

@router.delete("/dictionary/grade_levels/{grade_id}")
async def delete_grade_level(grade_id: str):
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        # Ensure it's not being used in classes table
        cursor.execute("SELECT COUNT(*) FROM BINARY_SUCCESS_CLASSES WHERE grade_level_id = %s", (grade_id,))
        if cursor.fetchone()[0] > 0:
            raise HTTPException(status_code=400, detail="Cannot delete because this Grade is tied to active classes.")
            
        cursor.execute("DELETE FROM BINARY_SUCCESS_GRADE_LEVELS WHERE grade_level_id = %s", (grade_id,))
        conn.commit()
        return {"out_status": "SUCCESS", "message": "Grade level deleted"}
    finally:
        cursor.close()
        conn.close()


class TaskTypeCreate(BaseModel):
    task_type: str
    task_type_description: Optional[str] = None

@router.get("/dictionary/task_types")
async def get_task_types():
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM BINARY_SUCCESS_TASK_TYPES ORDER BY created_at DESC")
        return {"out_status": "SUCCESS", "items": cursor.fetchall()}
    finally:
        cursor.close()
        conn.close()

@router.post("/dictionary/task_types")
async def add_task_type(task_type_data: TaskTypeCreate):
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        
        # Check if exists
        cursor.execute("SELECT * FROM BINARY_SUCCESS_TASK_TYPES WHERE lower(task_type) = lower(%s)", (task_type_data.task_type,))
        if cursor.fetchone():
             raise HTTPException(status_code=400, detail="A task type with this name already exists.")

        task_id = f"tt-{uuid.uuid4().hex[:8]}"
        cursor.execute(
            "INSERT INTO BINARY_SUCCESS_TASK_TYPES (task_type_id, task_type, task_type_description) VALUES (%s, %s, %s)",
            (task_id, task_type_data.task_type, task_type_data.task_type_description or "")
        )
        conn.commit()
        return {"out_status": "SUCCESS", "message": "Task Type added", "task_type_id": task_id}
    except HTTPException:
        raise
    finally:
        cursor.close()
        conn.close()

@router.delete("/dictionary/task_types/{type_id}")
async def delete_task_type(type_id: str):
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM BINARY_SUCCESS_TEACHER_TASKS WHERE task_type_id = %s", (type_id,))
        if cursor.fetchone()[0] > 0:
            raise HTTPException(status_code=400, detail="Cannot delete because this Task Type is currently in use.")

        cursor.execute("DELETE FROM BINARY_SUCCESS_TASK_TYPES WHERE task_type_id = %s", (type_id,))
        conn.commit()
        return {"out_status": "SUCCESS", "message": "Task type deleted."}
    finally:
        cursor.close()
        conn.close()

# ============================================================================
# CATCH-ALL PROXY (for unimplemented endpoints)
# ============================================================================

@router.api_route("/{full_path:path}", methods=["GET", "POST", "PATCH", "DELETE", "PUT"])
async def catch_all_proxy(full_path: str, request: Request):
    """
    Catch-all endpoint for unimplemented /db/* routes
    Returns a helpful error message instead of 404
    """
    logger.warning(f"Unimplemented /db endpoint called: {request.method} /db/{full_path}")
    
    return {
        "success": False,
        "message": f"Endpoint /db/{full_path} not yet implemented in mock router",
        "method": request.method,
        "suggestion": "This endpoint needs to be added to db_mock/routes.py",
        "timestamp": datetime.now().isoformat()
    }
