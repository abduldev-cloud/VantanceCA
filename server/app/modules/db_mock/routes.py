from fastapi import APIRouter, HTTPException, Request
from app.core.logger import logger
from app.common.crud_base import CRUDBase
from typing import Dict, List, Any, Optional
from datetime import datetime

router = APIRouter(prefix="/db", tags=["Database Mock"])
crud = CRUDBase()

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
                        lt.score, lt.submitted_at, lt.graded_at, lt.deviation_percentage
                    FROM BINARY_SUCCESS_TEACHER_TASKS tt
                    JOIN BINARY_SUCCESS_TASK_TYPES ttype ON tt.task_type_id = ttype.task_type_id
                    LEFT JOIN BINARY_SUCCESS_CLASSES c ON tt.class_id = c.class_id
                    LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON tt.task_id = lt.task_id AND lt.learner_id = %s
                    LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                    WHERE EXISTS (SELECT 1 FROM BINARY_SUCCESS_ENROLLMENTS e WHERE e.class_id = tt.class_id AND e.learner_id = %s)
                    ORDER BY tt.due_date DESC
                """, (learner_id, learner_id))
            else:
                query = """SELECT tt.task_id, tt.task_title, tt.task_description, tt.due_date, tt.max_score, tt.created_at,
                    ttype.task_type, c.class_name, c.class_id,
                    COUNT(DISTINCT lt.learner_task_id) AS submission_count,
                    COUNT(DISTINCT CASE WHEN ts.status = 'GRADED' THEN lt.learner_task_id END) AS graded_count
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
async def get_assignment_by_id(task_id: str):
    """Get assignment details by ID"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
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
                SELECT lt.*, ts.status, l.learner_code, u.first_name, u.last_name, u.email
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
                JOIN BINARY_SUCCESS_LEARNERS l ON lt.learner_id = l.learner_id
                JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
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


@router.get("/platform_admin/get_all_platform_users/")
async def get_all_platform_users(
    user_status: Optional[str] = None,
    page_number: int = 1,
    page_size: int = 10
):
    """Get all platform users with pagination and status filtering"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Build query with optional status filter
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
                    i.institute_name as school_name
                FROM BINARY_SUCCESS_PLATFORM_USERS u
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON u.status_id = s.status_id
                LEFT JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id
                LEFT JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i ON u.institute_id = i.institute_id
            """
            
            params = []
            if user_status:
                query += " WHERE LOWER(s.status_code) = LOWER(%s)"
                params.append(user_status)
            
            query += " ORDER BY u.created_at DESC"
            
            # Add pagination
            offset = (page_number - 1) * page_size
            query += " LIMIT %s OFFSET %s"
            params.extend([page_size, offset])
            
            cursor.execute(query, tuple(params))
            users = cursor.fetchall()
            
            # Get user counts
            cursor.execute("""
                SELECT 
                    COUNT(*) as total_users,
                    SUM(CASE WHEN UPPER(s.status_code) = 'ACTIVE' THEN 1 ELSE 0 END) as active_users,
                    SUM(CASE WHEN UPPER(s.status_code) != 'ACTIVE' THEN 1 ELSE 0 END) as archived_users
                FROM BINARY_SUCCESS_PLATFORM_USERS u
                LEFT JOIN BINARY_SUCCESS_STATUSES s ON u.status_id = s.status_id
            """)
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
            
            # Update learner task
            cursor.execute("""
                UPDATE BINARY_SUCCESS_LEARNER_TASKS 
                SET status_id = %s, submitted_at = %s
                WHERE learner_task_id = %s
            """, (submitted_status_id, datetime.now(), learner_task_id))
            
            # Here we would normally save the actual content to a separate table or storage
            # For this mock, we'll just log it or assuming it's handled
            
            conn.commit()
            return {"success": True, "message": "Assignment submitted successfully"}
        finally:
            cursor.close()
            conn.close()
    except Exception as e:
        logger.error(f"Error submitting assignment: {e}")
        raise HTTPException(status_code=500, detail=str(e))


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
