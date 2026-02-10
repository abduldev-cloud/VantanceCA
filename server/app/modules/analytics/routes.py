"""
Analytics Module - MySQL Compatible Version
Converted from Oracle-specific SQL to MySQL
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
from app.core.logger import logger
from app.core.database_mysql import get_mysql_connection
from typing import Optional
from app.modules.analytics.schemas import (
    PlatformAdminUserCountsResponse,
    SupportTicketsResponse
)

router = APIRouter(prefix="/analytics", tags=["Analytics"])


# Helper functions for MySQL queries
def fetch_one_mysql(query: str, params: tuple = ()):
    """Execute MySQL query and return single row as dict"""
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query, params)
        return cursor.fetchone()
    finally:
        cursor.close()
        conn.close()


def fetch_all_mysql(query: str, params: tuple = ()):
    """Execute MySQL query and return all rows as list of dicts"""
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query, params)
        return cursor.fetchall()
    finally:
        cursor.close()
        conn.close()


# ============================================================================
# PLATFORM ADMIN ENDPOINTS
# ============================================================================

@router.post("/platform-admin/support-tickets")
async def get_platform_admin_support_tickets():
    """
    Platform Admin Support Tickets (Mock Data)
    Returns sample support tickets for dashboard display
    """
    request_start_time = datetime.now()
    try:
        sample_tickets = [
            {
                "ticket_number": "ST-1007",
                "user_name": "Alex Johnson",
                "priority": "High",
                "status": "Open",
                "subject": "Login page not loading",
                "description": "User reports the login page shows a blank screen.",
                "created_at": datetime.now().isoformat(),
            },
            {
                "ticket_number": "ST-1006",
                "user_name": "Priya Singh",
                "priority": "Medium",
                "status": "In Progress",
                "subject": "Assignment export CSV is empty",
                "description": "CSV export returns headers only for class 10A.",
                "created_at": datetime.now().isoformat(),
            },
            {
                "ticket_number": "ST-1005",
                "user_name": "Daniel Wu",
                "priority": "Low",
                "status": "Closed",
                "subject": "Feature request: dark mode",
                "description": "Request to add dark mode across the app.",
                "created_at": datetime.now().isoformat(),
            },
        ]

        duration = (datetime.now() - request_start_time).total_seconds()
        return {
            "success": True,
            "data": {"tickets": sample_tickets},
            "message": "Support tickets retrieved successfully",
            "timestamp": datetime.now().isoformat(),
            "request_duration_seconds": round(duration, 2),
        }
    except Exception as e:
        logger.error(f"❌ Error returning support tickets: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch support tickets")


@router.get("/platform-admin/user-counts", response_model=PlatformAdminUserCountsResponse)
async def get_platform_admin_user_counts():
    """
    Platform Admin User Counts
    Returns user counts by role from MySQL database
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 Platform admin user counts request")

    try:
        # Get role counts
        role_counts_query = """
            SELECT 
                r.role_name,
                COUNT(pu.user_id) as user_count
            FROM BINARY_SUCCESS_PLATFORM_USERS pu
            JOIN BINARY_SUCCESS_ROLES r ON pu.role_id = r.role_id
            GROUP BY r.role_name, r.role_id
            ORDER BY r.role_name
        """
        role_counts = fetch_all_mysql(role_counts_query)
        
        # Get total users
        total_users = fetch_one_mysql("SELECT COUNT(*) as total_users FROM BINARY_SUCCESS_PLATFORM_USERS")
        
        # Get total schools
        total_schools = fetch_one_mysql("SELECT COUNT(*) as total_schools FROM BINARY_SUCCESS_PLATFORM_INSTITUTES")
        
        # Get total students
        total_students = fetch_one_mysql("SELECT COUNT(*) as total_students FROM BINARY_SUCCESS_LEARNERS")
        
        # Get total teachers
        total_teachers = fetch_one_mysql("SELECT COUNT(*) as total_teachers FROM BINARY_SUCCESS_TEACHERS")
        
        # Get all roles
        all_roles = fetch_all_mysql("SELECT role_id, role_name, role_description FROM BINARY_SUCCESS_ROLES ORDER BY role_name")
        
        # Format role breakdown
        role_breakdown = {}
        for role_count in role_counts:
            role_name = role_count.get('role_name', 'Unknown')
            user_count = role_count.get('user_count', 0)
            role_breakdown[role_name] = user_count
        
        # Ensure all expected roles are present
        for role in ['PLATFORM_ADMIN', 'INSTITUTE_ADMIN', 'LEARNER', 'TEACHER']:
            if role not in role_breakdown:
                role_breakdown[role] = 0

        duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Platform admin user counts retrieved in {duration:.2f}s")
        
        return {
            "success": True,
            "data": {
                "total_schools": total_schools.get('total_schools', 0) if total_schools else 0,
                "total_users": total_users.get('total_users', 0) if total_users else 0,
                "total_students": total_students.get('total_students', 0) if total_students else 0,
                "total_teachers": total_teachers.get('total_teachers', 0) if total_teachers else 0,
                "user_counts_by_role": role_breakdown,
                "all_roles": all_roles
            },
            "message": "Platform admin user counts retrieved successfully",
            "timestamp": datetime.now().isoformat(),
            "source": "mysql_database",
            "request_duration_seconds": round(duration, 2)
        }
        
    except Exception as e:
        logger.error(f"❌ Error fetching platform admin user counts: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch user counts: {str(e)}")


@router.get("/platform-dashboard")
async def get_platform_dashboard(time_range_days: int = 30):
    """
    Platform Dashboard Analytics
    Returns platform-wide statistics (MySQL compatible)
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 Platform dashboard request - time_range_days: {time_range_days}")

    try:
        # Get schools with active/inactive breakdown
        schools_query = """
            SELECT 
                COUNT(*) as total_schools,
                SUM(CASE WHEN st.STATUS_CODE = 'ACTIVE' THEN 1 ELSE 0 END) as active_schools,
                SUM(CASE WHEN st.STATUS_CODE = 'INACTIVE' THEN 1 ELSE 0 END) as inactive_schools
            FROM BINARY_SUCCESS_PLATFORM_INSTITUTES pi
            JOIN BINARY_SUCCESS_STATUSES st ON pi.INSTITUTE_STATUS_ID = st.STATUS_ID
        """
        schools_result = fetch_one_mysql(schools_query)
        
        # Get users with active/inactive breakdown
        users_query = """
            SELECT 
                COUNT(*) as total_users,
                SUM(CASE WHEN st.STATUS_CODE = 'ACTIVE' THEN 1 ELSE 0 END) as active_users,
                SUM(CASE WHEN st.STATUS_CODE = 'INACTIVE' THEN 1 ELSE 0 END) as inactive_users
            FROM BINARY_SUCCESS_PLATFORM_USERS pu
            JOIN BINARY_SUCCESS_STATUSES st ON pu.STATUS_ID = st.STATUS_ID
        """
        users_result = fetch_one_mysql(users_query)
        
        # Get active students with grade breakdown
        active_students_query = """
            SELECT 
                gl.grade_name,
                COUNT(DISTINCT l.learner_id) as student_count
            FROM BINARY_SUCCESS_LEARNERS l
            JOIN BINARY_SUCCESS_ENROLLMENTS e ON l.learner_id = e.learner_id
            JOIN BINARY_SUCCESS_CLASSES c ON e.class_id = c.class_id
            JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
            WHERE e.status = 'ACTIVE'
            GROUP BY gl.grade_name
            ORDER BY gl.grade_name
        """
        active_students_result = fetch_all_mysql(active_students_query)
        
        # Process grade breakdown
        grade_breakdown = []
        total_active_students = 0
        
        for student_data in active_students_result:
            grade_name = student_data.get('grade_name', 'Unknown')
            student_count = student_data.get('student_count', 0)
            total_active_students += student_count
            
            grade_breakdown.append({
                'grade_name': grade_name,
                'student_count': student_count
            })

        duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Platform dashboard data retrieved in {duration:.2f}s")
        
        return {
            "total_schools": {
                "total": schools_result.get('total_schools', 0) if schools_result else 0,
                "active": schools_result.get('active_schools', 0) if schools_result else 0,
                "inactive": schools_result.get('inactive_schools', 0) if schools_result else 0
            },
            "total_users": {
                "total": users_result.get('total_users', 0) if users_result else 0,
                "active": users_result.get('active_users', 0) if users_result else 0,
                "inactive": users_result.get('inactive_users', 0) if users_result else 0
            },
            "active_students_24hr": {
                "total_count": total_active_students,
                "grade_wise_breakdown": grade_breakdown
            },
            "message": "Platform dashboard data retrieved successfully",
            "timestamp": datetime.now().isoformat(),
            "source": "mysql_database",
            "time_range_days": time_range_days,
            "request_duration_seconds": round(duration, 2)
        }
        
    except Exception as e:
        logger.error(f"❌ Error fetching platform dashboard data: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch dashboard data: {str(e)}")


# ============================================================================
# AI USAGE ANALYTICS (MySQL Compatible)
# ============================================================================

@router.get("/ai-usage-analytics")
async def get_ai_usage_analytics(
    user_email: Optional[str] = None,
    user_role: str = "PLATFORM_ADMIN",
    days_back: int = 30,
    bucket: str = "month",
    periods: int = 12,
    class_id: Optional[str] = None,
    grade_level_id: Optional[str] = None,
    term: Optional[str] = None,
    academic_year: Optional[str] = None
):
    """
    AI Usage Analytics with Writing Fingerprint Trends (MySQL Compatible)
    Converted from Oracle to MySQL syntax
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 AI usage analytics - role={user_role}, days_back={days_back}")

    try:
        # Get ASSIGNMENT task type ID
        assignment_row = fetch_one_mysql(
            "SELECT task_type_id FROM BINARY_SUCCESS_TASK_TYPES WHERE UPPER(TASK_TYPE) = 'ASSIGNMENT'"
        )
        if not assignment_row:
            raise HTTPException(status_code=404, detail="Assignment task type not found")
        
        assignment_task_type_id = assignment_row["task_type_id"]

        # Simplified KPIs query for MySQL
        kpis_query = """
            SELECT 
                IFNULL(ROUND(AVG(CAST(lt.deviation_percentage AS DECIMAL(10,2))), 2), 0) AS writing_fingerprint_avg_deviation,
                IFNULL(COUNT(DISTINCT lt.learner_task_id), 0) AS writing_fingerprint_total,
                IFNULL(ROUND(AVG(CAST(aus.used_count AS DECIMAL(10,2))), 2), 0) AS ai_prompt_used_average,
                IFNULL(SUM(CAST(aus.used_count AS DECIMAL(10,2))), 0) AS ai_prompt_used_total
            FROM BINARY_SUCCESS_LEARNER_TASKS lt
            JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
            LEFT JOIN BINARY_SUCCESS_AI_USAGE_STATS aus ON aus.task_id = lt.task_id AND aus.learner_id = lt.learner_id
            WHERE tt.task_type_id = :task_type_id
            AND lt.assigned_at >= DATE_SUB(NOW(), INTERVAL :days_back DAY)
            AND lt.deviation_percentage IS NOT NULL
            AND lt.deviation_percentage REGEXP '^[0-9]+\.?[0-9]*$'
        """
        
        params = {
            "task_type_id": assignment_task_type_id,
            "days_back": days_back
        }
        
        kpis = fetch_one_mysql(kpis_query, params)
        
        # Simplified trend data (last 6 months)
        trend_query = """
            SELECT 
                DATE_FORMAT(lt.assigned_at, '%b') AS label,
                IFNULL(ROUND(AVG(CAST(lt.deviation_percentage AS DECIMAL(10,2))), 2), 0) AS avg_deviation,
                COUNT(DISTINCT lt.learner_task_id) AS total_submission
            FROM BINARY_SUCCESS_LEARNER_TASKS lt
            JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
            JOIN BINARY_SUCCESS_TASK_STATUSES ts ON ts.status_id = lt.status_id
            WHERE tt.task_type_id = :task_type_id
            AND lt.assigned_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
            AND ts.status IN ('SUBMITTED', 'GRADED')
            GROUP BY DATE_FORMAT(lt.assigned_at, '%Y-%m')
            ORDER BY DATE_FORMAT(lt.assigned_at, '%Y-%m')
            LIMIT 12
        """
        
        trend_data = fetch_all_mysql(trend_query, params)

        duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ AI usage analytics retrieved in {duration:.2f}s")
        
        return {
            "success": True,
            "data": {
                "kpis": kpis or {},
                "writing_fingerprint_trend": trend_data or [],
                "filters_applied": {
                    "class_id": class_id,
                    "grade_level_id": grade_level_id,
                    "term": term,
                    "academic_year": academic_year
                }
            },
            "message": "AI usage analytics retrieved successfully",
            "timestamp": datetime.now().isoformat(),
            "source": "mysql_database",
            "request_duration_seconds": round(duration, 2)
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error fetching AI usage analytics: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch analytics: {str(e)}")


# ============================================================================
# TEACHER/CLASS ANALYTICS
# ============================================================================

@router.get("/teacher-class-filters")
async def get_teacher_class_filters(teacher_id: Optional[str] = None):
    """Get filter options for teacher dashboard"""
    try:
        query = """
            SELECT DISTINCT
                c.class_id,
                c.class_name,
                c.class_code,
                gl.grade_name,
                c.term,
                c.academic_year
            FROM BINARY_SUCCESS_CLASSES c
            LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
        """
        
        params = {}
        if teacher_id:
            query += " WHERE c.teacher_id = :teacher_id"
            params["teacher_id"] = teacher_id
            
        query += " ORDER BY c.class_name"
        
        classes = fetch_all_mysql(query, params)
        
        return {
            "success": True,
            "data": {
                "classes": classes,
                "count": len(classes)
            }
        }
        
    except Exception as e:
        logger.error(f"Error fetching teacher class filters: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/performance-metrics")
async def get_performance_metrics(
    class_id: Optional[str] = None,
    teacher_id: Optional[str] = None
):
    """Get student performance metrics"""
    try:
        query = """
            SELECT 
                l.learner_id,
                u.first_name,
                u.last_name,
                COUNT(DISTINCT lt.learner_task_id) AS total_assignments,
                COUNT(DISTINCT CASE WHEN ts.status = 'SUBMITTED' THEN lt.learner_task_id END) AS submitted_count,
                COUNT(DISTINCT CASE WHEN ts.status = 'GRADED' THEN lt.learner_task_id END) AS graded_count,
                IFNULL(ROUND(AVG(lt.score), 2), 0) AS average_score,
                IFNULL(ROUND(AVG(CAST(lt.deviation_percentage AS DECIMAL(10,2))), 2), 0) AS avg_deviation
            FROM BINARY_SUCCESS_LEARNERS l
            JOIN BINARY_SUCCESS_PLATFORM_USERS u ON l.user_id = u.user_id
            JOIN BINARY_SUCCESS_ENROLLMENTS e ON l.learner_id = e.learner_id
            JOIN BINARY_SUCCESS_CLASSES c ON e.class_id = c.class_id
            LEFT JOIN BINARY_SUCCESS_LEARNER_TASKS lt ON l.learner_id = lt.learner_id
            LEFT JOIN BINARY_SUCCESS_TASK_STATUSES ts ON lt.status_id = ts.status_id
        """
        
        conditions = []
        params = {}
        
        if class_id:
            conditions.append("c.class_id = :class_id")
            params["class_id"] = class_id
        if teacher_id:
            conditions.append("c.teacher_id = :teacher_id")
            params["teacher_id"] = teacher_id
            
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
            
        query += " GROUP BY l.learner_id ORDER BY u.last_name, u.first_name"
        
        metrics = fetch_all_mysql(query, params)
        
        return {
            "success": True,
            "data": metrics,
            "count": len(metrics)
        }
        
    except Exception as e:
        logger.error(f"Error fetching performance metrics: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/filter-options")
async def get_filter_options():
    """
    Get all filter options for Analytics page dropdowns
    Returns schools, teachers, classes, and grades
    """
    try:
        logger.info("🚀 Fetching filter options for analytics")
        
        # Get all schools
        schools_query = """
            SELECT DISTINCT institute_name as school_name
            FROM BINARY_SUCCESS_PLATFORM_INSTITUTES
            WHERE institute_name IS NOT NULL
            ORDER BY institute_name
        """
        schools = fetch_all_mysql(schools_query)
        
        # Get all teachers
        teachers_query = """
            SELECT DISTINCT 
                CONCAT(u.first_name, ' ', u.last_name) as teacher_name
            FROM BINARY_SUCCESS_PLATFORM_USERS u
            JOIN BINARY_SUCCESS_ROLES r ON u.role_id = r.role_id
            WHERE r.role_name = 'TEACHER'
            AND u.first_name IS NOT NULL
            ORDER BY teacher_name
        """
        teachers = fetch_all_mysql(teachers_query)
        
        # Get all classes
        classes_query = """
            SELECT DISTINCT class_name
            FROM BINARY_SUCCESS_CLASSES
            WHERE class_name IS NOT NULL
            ORDER BY class_name
        """
        classes = fetch_all_mysql(classes_query)
        
        # Get all grades
        grades_query = """
            SELECT DISTINCT grade_name
            FROM BINARY_SUCCESS_GRADE_LEVELS
            WHERE grade_name IS NOT NULL
            ORDER BY grade_name
        """
        grades = fetch_all_mysql(grades_query)
        
        logger.info(f"✅ Filter options retrieved: {len(schools)} schools, {len(teachers)} teachers, {len(classes)} classes, {len(grades)} grades")
        
        return {
            "success": True,
            "data": {
                "schools": schools,
                "teachers": teachers,
                "classes": classes,
                "grades": grades
            }
        }
        
    except Exception as e:
        logger.error(f"❌ Error fetching filter options: {e}")
        raise HTTPException(status_code=500, detail=str(e))

