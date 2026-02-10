from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime, timedelta
import json
# from app.common.auth.dependencies import require_admin, get_current_user
from app.core.logger import logger
from app.common.crud_base import CRUDBase
from typing import Dict, List, Any
from app.modules.analytics.schemas import (
    PlatformAdminUserCountsResponse,
    PlatformAdminUserCountsData,
    UserCountsByRole,
    RoleInfo,
    SupportTicketsResponse
)

router = APIRouter(prefix="/analytics", tags=["Analytics"])

# Initialize CRUD base for database operations
crud_base = CRUDBase()


@router.post("/platform-admin/support-tickets")
async def get_platform_admin_support_tickets():
    """
    Lightweight support tickets endpoint for Platform Admin.

    Returns a small list of recent tickets. This is a placeholder
    implementation so the dashboard can render without 404s. Replace with
    integration to your support system when ready.
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


# @router.post("/platform-admin/support-tickets", response_model=SupportTicketsResponse)
# async def get_platform_admin_support_tickets(
#     current_user: dict = Depends(get_current_user)
# ):
#     """
#     Platform Admin Support Tickets Endpoint.
    
#     Returns support tickets data for platform admin.
    
#     Returns:
#         - Support tickets data (3 sample tickets)
#         - User context information
#         - Request metadata and timestamps
#     """
#     request_start_time = datetime.now()
#     user_id = current_user.get("user_id", "unknown")
#     user_email = current_user.get("email", "unknown")
#     user_roles = current_user.get("roles", [])

#     logger.info(f"🚀 Platform admin support tickets request - User: {user_email} ({user_id}), Roles: {user_roles}")

#     try:
#         # Hardcoded support tickets data for immediate response
#         hardcoded_support_tickets = {
#             "filter": {
#                 "moduleID": "450287529901977603",
#                 "namespaceID": "450287529841684483",
#                 "query": "",
#                 "deleted": 0,
#                 "sort": "ID",
#                 "limit": 1000
#             },
#             "set": [
#                 {
#                     "recordID": "454304402652557315",
#                     "moduleID": "450287529901977603",
#                     "revision": 3,
#                     "values": [
#                         {"name": "SolutionName", "value": "Update"},
#                         {"name": "Description", "value": "<p>I need to change my assignment due date</p>"},
#                         {"name": "Priority", "value": "High"},
#                         {"name": "CaseNumber", "value": "7"},
#                         {"name": "SolutionNote", "value": "<p>We are working on the update. You can clear cache & check</p>"},
#                         {"name": "SuppliedEmail", "value": "support@school.com"},
#                         {"name": "Subject", "value": "Update Assignment"},
#                         {"name": "SuppliedName", "value": "support@school.com"},
#                         {"name": "Status", "value": "Closed"},
#                         {"name": "OwnerId", "value": "450287652483133443"}
#                     ],
#                     "namespaceID": "450287529841684483",
#                     "ownedBy": "450287652483133443",
#                     "createdAt": "2025-08-01T02:28:45Z",
#                     "createdBy": "450287652483133443",
#                     "updatedAt": "2025-08-01T02:32:45Z",
#                     "updatedBy": "450287652483133443",
#                     "valueErrors": None,
#                     "canManageOwnerOnRecord": True,
#                     "canUpdateRecord": True,
#                     "canReadRecord": True,
#                     "canDeleteRecord": True,
#                     "canUndeleteRecord": True,
#                     "canSearchRevisions": True,
#                     "canGrant": True
#                 },
#                 {
#                     "recordID": "454304402652557316",
#                     "moduleID": "450287529901977603",
#                     "revision": 2,
#                     "values": [
#                         {"name": "SolutionName", "value": "Bug Report"},
#                         {"name": "Description", "value": "<p>The login page is not working properly</p>"},
#                         {"name": "Priority", "value": "Medium"},
#                         {"name": "CaseNumber", "value": "8"},
#                         {"name": "SolutionNote", "value": "<p>Issue has been identified and fix is in progress</p>"},
#                         {"name": "SuppliedEmail", "value": "user@example.com"},
#                         {"name": "Subject", "value": "Login Issue"},
#                         {"name": "SuppliedName", "value": "user@example.com"},
#                         {"name": "Status", "value": "In Progress"},
#                         {"name": "OwnerId", "value": "450287652483133444"}
#                     ],
#                     "namespaceID": "450287529841684483",
#                     "ownedBy": "450287652483133444",
#                     "createdAt": "2025-08-02T10:15:30Z",
#                     "createdBy": "450287652483133444",
#                     "updatedAt": "2025-08-02T14:20:15Z",
#                     "updatedBy": "450287652483133444",
#                     "valueErrors": None,
#                     "canManageOwnerOnRecord": True,
#                     "canUpdateRecord": True,
#                     "canReadRecord": True,
#                     "canDeleteRecord": True,
#                     "canUndeleteRecord": True,
#                     "canSearchRevisions": True,
#                     "canGrant": True
#                 },
#                 {
#                     "recordID": "454304402652557317",
#                     "moduleID": "450287529901977603",
#                     "revision": 1,
#                     "values": [
#                         {"name": "SolutionName", "value": "Feature Request"},
#                         {"name": "Description", "value": "<p>Please add dark mode to the application</p>"},
#                         {"name": "Priority", "value": "Low"},
#                         {"name": "CaseNumber", "value": "9"},
#                         {"name": "SolutionNote", "value": "<p>Feature request has been logged for future consideration</p>"},
#                         {"name": "SuppliedEmail", "value": "student@school.edu"},
#                         {"name": "Subject", "value": "Dark Mode Request"},
#                         {"name": "SuppliedName", "value": "student@school.edu"},
#                         {"name": "Status", "value": "Open"},
#                         {"name": "OwnerId", "value": "450287652483133445"}
#                     ],
#                     "namespaceID": "450287529841684483",
#                     "ownedBy": "450287652483133445",
#                     "createdAt": "2025-08-03T09:45:12Z",
#                     "createdBy": "450287652483133445",
#                     "updatedAt": "2025-08-03T09:45:12Z",
#                     "updatedBy": "450287652483133445",
#                     "valueErrors": None,
#                     "canManageOwnerOnRecord": True,
#                     "canUpdateRecord": True,
#                     "canReadRecord": True,
#                     "canDeleteRecord": True,
#                     "canUndeleteRecord": True,
#                     "canSearchRevisions": True,
#                     "canGrant": True
#                 }
#             ]
#         }

#         request_duration = (datetime.now() - request_start_time).total_seconds()
#         logger.info(f"✅ Hardcoded support tickets returned successfully in {request_duration:.2f}s")
        
#         return {
#             "success": True,
#             "data": hardcoded_support_tickets,
#             "message": "Support tickets retrieved successfully (hardcoded data)",
#             "timestamp": datetime.now().isoformat(),
#             "source": "hardcoded_data",
#             "user_id": user_id,
#             "user_email": user_email
#         }
#     except Exception as e:
#         logger.error(f"❌ Unexpected error: {e}")
#         raise HTTPException(status_code=500, detail=f"Failed to fetch platform admin support tickets: {str(e)}")


@router.get("/platform-admin/user-counts", response_model=PlatformAdminUserCountsResponse)
async def get_platform_admin_user_counts():
    """
    Platform Admin User Counts Endpoint.
    
    Returns user counts by role from local database including:
    - Total schools count
    - Total users count  
    - Total students count
    - All counts by role (PLATFORM_ADMIN, INSTITUTE_ADMIN, LEARNER, TEACHER)
    
    Returns:
        - User counts by role from local database
        - School and user statistics
        - Request metadata and timestamps
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 Platform admin user counts request - No authentication required")

    try:
        # Get role counts from BINARY_SUCCESS_PLATFORM_USERS
        role_counts_query = """
            SELECT 
                r.role_name,
                COUNT(pu.user_id) as user_count
            FROM BINARY_SUCCESS_PLATFORM_USERS pu
            JOIN BINARY_SUCCESS_ROLES r ON pu.role_id = r.role_id
            GROUP BY r.role_name, r.role_id
            ORDER BY r.role_name
        """
        
        role_counts = crud_base.fetch_all(role_counts_query)
        
        # Get total users count
        total_users_query = "SELECT COUNT(*) as total_users FROM BINARY_SUCCESS_PLATFORM_USERS"
        total_users_result = crud_base.fetch_one(total_users_query)
        total_users = total_users_result.get('total_users', 0) if total_users_result else 0
        
        # Get total schools/institutes count
        total_schools_query = "SELECT COUNT(*) as total_schools FROM BINARY_SUCCESS_PLATFORM_INSTITUTES"
        total_schools_result = crud_base.fetch_one(total_schools_query)
        total_schools = total_schools_result.get('total_schools', 0) if total_schools_result else 0
        
        # Get total students/learners count
        total_students_query = "SELECT COUNT(*) as total_students FROM BINARY_SUCCESS_LEARNERS"
        total_students_result = crud_base.fetch_one(total_students_query)
        total_students = total_students_result.get('total_students', 0) if total_students_result else 0
        
        # Get total teachers count
        total_teachers_query = "SELECT COUNT(*) as total_teachers FROM BINARY_SUCCESS_TEACHERS"
        total_teachers_result = crud_base.fetch_one(total_teachers_query)
        total_teachers = total_teachers_result.get('total_teachers', 0) if total_teachers_result else 0
        
        # Get all roles from BINARY_SUCCESS_ROLES for reference
        roles_query = "SELECT role_id, role_name, role_description FROM BINARY_SUCCESS_ROLES ORDER BY role_name"
        all_roles = crud_base.fetch_all(roles_query)
        
        # Format role counts into a structured response
        role_breakdown = {}
        for role_count in role_counts:
            role_name = role_count.get('role_name', 'Unknown')
            user_count = role_count.get('user_count', 0)
            role_breakdown[role_name] = user_count
        
        # Ensure all expected roles are present (even if count is 0)
        expected_roles = ['PLATFORM_ADMIN', 'INSTITUTE_ADMIN', 'LEARNER', 'TEACHER']
        for role in expected_roles:
            if role not in role_breakdown:
                role_breakdown[role] = 0

        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Platform admin user counts retrieved successfully in {request_duration:.2f}s")
        
        return {
            "success": True,
            "data": {
                "total_schools": total_schools,
                "total_users": total_users,
                "total_students": total_students,
                "total_teachers": total_teachers,
                "user_counts_by_role": role_breakdown,
                "all_roles": all_roles
            },
            "message": "Platform admin user counts retrieved successfully from local database",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "user_id": "anonymous",
            "user_email": "anonymous@example.com",
            "request_duration_seconds": round(request_duration, 2)
        }
        
    except Exception as e:
        logger.error(f"❌ Error fetching platform admin user counts: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch platform admin user counts: {str(e)}")


@router.get("/platform-dashboard")
async def get_platform_dashboard(time_range_days: int = 30):
    """
    Platform Dashboard Endpoint.
    
    Returns platform-wide analytics data including:
    - Total schools with active/inactive breakdown
    - Total users with active/inactive breakdown
    - Active students in last 24 hours with grade breakdown
    
    Parameters:
        time_range_days: Number of days to look back (default: 30)
    
    Returns:
        - Platform dashboard statistics
        - Request metadata and timestamps
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 Platform dashboard request - time_range_days: {time_range_days}")

    try:
        # Get total schools count with active/inactive breakdown
        schools_query = """
            SELECT 
                COUNT(*) as total_schools,
                SUM(CASE WHEN st.STATUS_CODE = 'ACTIVE' THEN 1 ELSE 0 END) as active_schools,
                SUM(CASE WHEN st.STATUS_CODE = 'INACTIVE' THEN 1 ELSE 0 END) as inactive_schools
            FROM BINARY_SUCCESS_PLATFORM_INSTITUTES pi
            JOIN BINARY_SUCCESS_STATUSES st on pi.INSTITUTE_STATUS_ID = st.STATUS_ID
        """
        schools_result = crud_base.fetch_one(schools_query)
        
        # Get total users count with active/inactive breakdown
        users_query = """
            SELECT 
                COUNT(*) as total_users,
                SUM(CASE WHEN st.STATUS_CODE = 'ACTIVE' THEN 1 ELSE 0 END) as active_users,
                SUM(CASE WHEN st.STATUS_CODE = 'INACTIVE' THEN 1 ELSE 0 END) as inactive_users
            FROM BINARY_SUCCESS_PLATFORM_USERS pu
            JOIN BINARY_SUCCESS_STATUSES st on pu.STATUS_ID = st.STATUS_ID
        """
        users_result = crud_base.fetch_one(users_query)
        
        # Get active students with grade breakdown (using enrollments as proxy for activity)
        active_students_query = """
            SELECT 
                COUNT(DISTINCT l.learner_id) as total_active_students,
                gl.grade_name,
                COUNT(DISTINCT l.learner_id) as student_count
            FROM BINARY_SUCCESS_LEARNERS l
            JOIN BINARY_SUCCESS_ENROLLMENTS e ON l.learner_id = e.learner_id
            JOIN BINARY_SUCCESS_CLASSES c ON e.class_id = c.class_id
            JOIN BINARY_SUCCESS_GRADE_LEVELS gl ON c.grade_level_id = gl.grade_level_id
            GROUP BY gl.grade_name
            ORDER BY gl.grade_name
        """
        active_students_result = crud_base.fetch_all(active_students_query)
        
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

        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Platform dashboard data retrieved successfully in {request_duration:.2f}s")
        
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
            "source": "local_database",
            "time_range_days": time_range_days,
            "request_duration_seconds": round(request_duration, 2)
        }
        
    except Exception as e:
        logger.error(f"❌ Error fetching platform dashboard data: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch platform dashboard data: {str(e)}")


@router.get("/ai-usage-analytics")
async def get_ai_usage_analytics(
    user_email: str | None = None,
    user_role: str = "PLATFORM_ADMIN",
    days_back: int = 30,
    bucket: str = "month",          # "month" | "week" | "day"
    periods: int = 12,              # how many buckets to return
    class_id: str | None = None,    # filter by CLASS_ID
    grade_level_id: str | None = None,  # filter by GRADE_LEVEL_ID
    term: str | None = None,        # filter by TERM
    academic_year: str | None = None    # filter by ACADEMIC_YEAR
):
    """
    AI Usage Analytics (Role-Based) + Writing Fingerprints Trend.

    Adds `writing_fingerprint_trend`: average deviation per time bucket
    (only FINGERPRINT tasks), zero-filled for missing buckets.
    
    Filters supported:
        - CLASS_ID
        - GRADE_LEVEL_ID
        - TERM
        - ACADEMIC_YEAR
    """

    request_start_time = datetime.now()
    logger.info(
        f"🚀 AI usage analytics - email={user_email}, role={user_role}, "
        f"days_back={days_back}, bucket={bucket}, periods={periods}, "
        f"class_id={class_id}, grade_level_id={grade_level_id}, term={term}, year={academic_year}"
    )

    try:
        # ---------- Helpers ----------
        def build_class_filter_cte() -> tuple[str, str, dict]:
            """Builds CTE + filter SQL fragments for class-level filters."""
            filters = []
            params: dict[str, object] = {}
            if grade_level_id:
                filters.append("c.grade_level_id = :grade_level_id")
                params["grade_level_id"] = grade_level_id
            if term:
                filters.append("c.term = :term")
                params["term"] = term
            if academic_year:
                filters.append("c.academic_year = :academic_year")
                params["academic_year"] = academic_year

            class_cte = ""
            join_clause = ""

            if filters:
                class_cte = f"""
                , cls AS (
                    SELECT DISTINCT c.class_id
                    FROM BINARY_SUCCESS_CLASSES c
                    WHERE {" AND ".join(filters)}
                )
                """
                join_clause = "AND tt.class_id IN (SELECT class_id FROM cls)"

            # Handle direct class_id filter separately (not inside CTE)
            if class_id:
                join_clause += " AND tt.class_id = :class_id"
                params["class_id"] = class_id

            return class_cte, join_clause, params

        
        def get_trend_sql(scope: str) -> tuple[str, dict]:
            """Returns (sql, params) for the time-series avg deviation + submission count."""

            # date bucketing
            if bucket.lower() == "month":
                gen_cte = """
                months AS (
                    SELECT ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -(LEVEL-1)) AS bucket_start
                    FROM dual CONNECT BY LEVEL <= :periods
                )
                """
                trunc_expr = "TRUNC(lt.assigned_at, 'MM')"
                label_expr = "TO_CHAR(m.bucket_start, 'MON')"
                range_pred = "lt.assigned_at >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -( :periods - 1 ))"
            elif bucket.lower() == "week":
                gen_cte = """
                weeks AS (
                    SELECT TRUNC(SYSDATE, 'IW') - 7*(LEVEL-1) AS bucket_start
                    FROM dual CONNECT BY LEVEL <= :periods
                )
                """
                trunc_expr = "TRUNC(lt.assigned_at, 'IW')"
                label_expr = "TO_CHAR(m.bucket_start, 'DD MON')"
                range_pred = "lt.assigned_at >= (TRUNC(SYSDATE, 'IW') - 7*( :periods - 1 ))"
            else:  # day
                gen_cte = """
                days AS (
                    SELECT TRUNC(SYSDATE) - (LEVEL-1) AS bucket_start
                    FROM dual CONNECT BY LEVEL <= :periods
                )
                """
                trunc_expr = "TRUNC(lt.assigned_at)"
                label_expr = "TO_CHAR(m.bucket_start, 'DD MON')"
                range_pred = "lt.assigned_at >= (TRUNC(SYSDATE) - :periods + 1)"

            # role filter
            scope_filter = "1=1"
            params: dict[str, object] = {"periods": periods, "task_type": 'FINGERPRINT'}
            if scope == "institute":
                scope_filter = "tt.institute_id = :scope_id"
                params["scope_id"] = scope_info["scope_id"]
            elif scope == "teacher":
                scope_filter = "tt.teacher_id = :scope_id"
                params["scope_id"] = scope_info["scope_id"]

            # class filters
            class_cte, join_clause, class_params = build_class_filter_cte()
            params.update(class_params)

            gen_name = "months" if "months" in gen_cte else ("weeks" if "weeks" in gen_cte else "days")

            sql = f"""
            WITH params AS (SELECT :periods periods FROM dual)
            , {gen_cte}
            {class_cte}
            , fp_rows AS (
                SELECT {trunc_expr} AS bucket_start,
                    CAST(lt.deviation_percentage AS NUMBER) AS deviation_percentage,
                    ts.status
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                join BINARY_SUCCESS_TASK_TYPES ty on tt.task_type_id = ty.TASK_TYPE_ID 
                join BINARY_SUCCESS_TASK_STATUSES ts on ts.status_id = lt.status_id 
                {"JOIN BINARY_SUCCESS_CLASSES c ON c.class_id = tt.class_id" if grade_level_id or term or academic_year else ""}
                WHERE ty.TASK_TYPE = :task_type
                AND {scope_filter}
                {join_clause}
                AND {range_pred}
            )
            , agg AS (
                SELECT bucket_start,
                    ROUND(AVG(CASE 
                                WHEN deviation_percentage IS NOT NULL
                                    AND REGEXP_LIKE(deviation_percentage, '^[+-]?([0-9]*[.])?[0-9]+$')
                                    AND CAST(deviation_percentage AS NUMBER) > 30
                                THEN deviation_percentage
                                END), 2) AS avg_deviation,
                    COUNT(CASE 
                                WHEN status IN ('SUBMITTED','GRADED')
                                THEN 1 END) AS total_submission
                FROM fp_rows
                GROUP BY bucket_start
            )
            SELECT
                {label_expr}     AS label,
                NVL(a.avg_deviation, 0)   AS avg_deviation,
                NVL(a.total_submission,0) AS total_submission,
                m.bucket_start   AS start_ts
            FROM {gen_name} m
            LEFT JOIN agg a ON a.bucket_start = m.bucket_start
            ORDER BY m.bucket_start
            """
            return sql, params

        def get_previous_period_kpis(scope: str, current_days_back: int) -> dict:
            """
            Get KPIs for the previous period (same length as current period) for comparison.
            Returns a dictionary with the same structure as the main KPI query.
            """

            assignment_row = crud_base.fetch_one(
                "SELECT task_type_id from BINARY_SUCCESS_TASK_TYPES where UPPER(TASK_TYPE)=UPPER(:task_type)",
                {"task_type": 'ASSIGNMENT'}
            )
            if not assignment_row:
                raise HTTPException(status_code=404, detail=f"Assignment Task Type ID not found.")
            assignment_task_type_id = assignment_row["task_type_id"]

            previous_days_back = current_days_back * 2  # Previous period: from 2*days_back to days_back ago
            
            if scope == "platform":
                query = """
                    WITH fingerprint_tasks AS (
                        SELECT CAST(lt.deviation_percentage AS NUMBER) AS deviation_percentage
                        FROM BINARY_SUCCESS_LEARNER_TASKS lt
                        JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                        WHERE tt.task_type_id = :assignment_task_type_id
                        AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :previous_days_back
                        AND lt.assigned_at < SYSTIMESTAMP - INTERVAL '1' DAY * :current_days_back
                        AND lt.deviation_percentage IS NOT NULL
                        AND REGEXP_LIKE(lt.deviation_percentage, '^[+-]?([0-9]*[.])?[0-9]+$')
                    ),
                    fp AS (
                        SELECT NVL(ROUND(AVG(deviation_percentage), 2), 0) AS writing_fingerprint_avg_deviation,
                            NVL(COUNT(*), 0) AS writing_fingerprint_total
                        FROM fingerprint_tasks
                    ),
                    ai_usage AS (
                        SELECT
                            NVL(SUM(CAST(aus.used_count AS NUMBER)), 0)            AS ai_prompt_used_total,
                            NVL(ROUND(AVG(CAST(aus.used_count AS NUMBER)), 2), 0) AS ai_prompt_used_average
                        FROM BINARY_SUCCESS_AI_USAGE_STATS aus
                        JOIN BINARY_SUCCESS_LEARNER_TASKS lt
                        ON aus.task_id = lt.task_id
                        AND aus.learner_id = lt.learner_id
                        JOIN BINARY_SUCCESS_TEACHER_TASKS tt
                        ON tt.task_id = lt.task_id
                        WHERE tt.task_type_id = :assignment_task_type_id
                        AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :previous_days_back
                        AND lt.assigned_at < SYSTIMESTAMP - INTERVAL '1' DAY * :current_days_back
                        AND aus.used_count IS NOT NULL
                    )
                    SELECT
                        fp.writing_fingerprint_avg_deviation,
                        fp.writing_fingerprint_total,
                        ai.ai_prompt_used_average,
                        ai.ai_prompt_used_total
                    FROM fp
                    CROSS JOIN ai_usage ai
                """
                params = {"previous_days_back": previous_days_back, "current_days_back": current_days_back,
                          "assignment_task_type_id": assignment_task_type_id}
                
            elif scope == "institute":
                query = """
                    WITH fingerprint_rows AS (
                        SELECT CAST(lt.deviation_percentage AS NUMBER) AS deviation_percentage
                        FROM BINARY_SUCCESS_LEARNER_TASKS lt
                        JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                        WHERE tt.task_type_id = :assignment_task_type_id
                        AND tt.institute_id = :institute_id
                        AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :previous_days_back
                        AND lt.assigned_at < SYSTIMESTAMP - INTERVAL '1' DAY * :current_days_back
                        AND lt.deviation_percentage IS NOT NULL
                        AND REGEXP_LIKE(lt.deviation_percentage, '^[+-]?([0-9]*[.])?[0-9]+$')
                    ),
                    fp AS (
                        SELECT NVL(ROUND(AVG(deviation_percentage), 2), 0) AS writing_fingerprint_avg_deviation,
                            NVL(COUNT(*), 0) AS writing_fingerprint_total
                        FROM fingerprint_rows
                    ),
                    ai_usage AS (
                        SELECT NVL(SUM(au.used_count), 0)        AS ai_prompt_used_total,
                            NVL(ROUND(AVG(au.used_count), 2), 0) AS ai_prompt_used_average
                        FROM BINARY_SUCCESS_AI_USAGE_STATS au
                        JOIN BINARY_SUCCESS_LEARNER_TASKS lt
                        ON au.task_id = lt.task_id
                        AND au.learner_id = lt.learner_id
                        JOIN BINARY_SUCCESS_TEACHER_TASKS tt
                        ON tt.task_id = lt.task_id
                        WHERE tt.task_type_id = :assignment_task_type_id
                        AND tt.institute_id = :institute_id
                        AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :previous_days_back
                        AND lt.assigned_at < SYSTIMESTAMP - INTERVAL '1' DAY * :current_days_back
                    )
                    SELECT fp.writing_fingerprint_avg_deviation,
                        fp.writing_fingerprint_total,
                        ai.ai_prompt_used_average,
                        ai.ai_prompt_used_total
                    FROM fp
                    CROSS JOIN ai_usage ai
                """
                params = {
                    "institute_id": scope_info["scope_id"],
                    "previous_days_back": previous_days_back,
                    "current_days_back": current_days_back,
                    "assignment_task_type_id": assignment_task_type_id
                }
                
            else:  # teacher
                query = """
                    WITH fingerprint_rows AS (
                        SELECT CAST(lt.deviation_percentage AS NUMBER) AS deviation_percentage
                        FROM BINARY_SUCCESS_LEARNER_TASKS lt
                        JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                        WHERE tt.task_type_id = :assignment_task_type_id
                        AND tt.teacher_id = :teacher_id
                        AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :previous_days_back
                        AND lt.assigned_at < SYSTIMESTAMP - INTERVAL '1' DAY * :current_days_back
                        AND lt.deviation_percentage IS NOT NULL
                        AND REGEXP_LIKE(lt.deviation_percentage, '^[+-]?([0-9]*[.])?[0-9]+$')
                    ),
                    fp AS (
                        SELECT NVL(ROUND(AVG(deviation_percentage), 2), 0) AS writing_fingerprint_avg_deviation,
                            NVL(COUNT(*), 0) AS writing_fingerprint_total
                        FROM fingerprint_rows
                    ),
                    ai_usage AS (
                        SELECT
                            NVL(SUM(au.used_count), 0)                    AS ai_prompt_used_total,
                            NVL(ROUND(AVG(au.used_count), 2), 0)         AS ai_prompt_used_average
                        FROM BINARY_SUCCESS_AI_USAGE_STATS au
                        JOIN BINARY_SUCCESS_LEARNER_TASKS lt
                        ON au.task_id = lt.task_id
                        AND au.learner_id = lt.learner_id
                        JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                        WHERE tt.task_type_id = :assignment_task_type_id
                        AND tt.teacher_id = :teacher_id
                        AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :previous_days_back
                        AND lt.assigned_at < SYSTIMESTAMP - INTERVAL '1' DAY * :current_days_back
                    )
                    SELECT :teacher_id AS teacher_id,
                        fp.writing_fingerprint_avg_deviation,
                        fp.writing_fingerprint_total,
                        ai.ai_prompt_used_average,
                        ai.ai_prompt_used_total
                    FROM fp
                    CROSS JOIN ai_usage ai
                """
                params = {
                    "teacher_id": scope_info["scope_id"],
                    "previous_days_back": previous_days_back,
                    "current_days_back": current_days_back,
                    "assignment_task_type_id": assignment_task_type_id
                }

            try:
                result = crud_base.fetch_one(query, params)
                return result or {}
            except Exception as e:
                logger.warning(f"Failed to fetch previous period data: {e}")
                return {}

        def calculate_trend(current_value: float, previous_value: float) -> str:
            """Calculate trend: 'up', 'down', or 'stable'"""
            if current_value >= previous_value:
                return "up"
            elif current_value <= previous_value:
                return "down"

        # ---------- Resolve scope (same as your KPIs) ----------
        scope_info = {"scope": "unknown", "scope_id": None}
        result = None

        assignment_row = crud_base.fetch_one(
            "SELECT task_type_id from BINARY_SUCCESS_TASK_TYPES where UPPER(TASK_TYPE)=UPPER(:task_type)",
            {"task_type": 'ASSIGNMENT'}
        )
        if not assignment_row:
            raise HTTPException(status_code=404, detail=f"Assignment Task Type ID not found.")
        assignment_task_type_id = assignment_row["task_type_id"]

        if user_role == "PLATFORM_ADMIN":
            # KPIs (your original platform query)
            platform_query = """
                WITH fingerprint_tasks AS (
                    SELECT CAST(lt.deviation_percentage AS NUMBER) AS deviation_percentage
                    FROM BINARY_SUCCESS_LEARNER_TASKS lt
                    JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                    WHERE tt.task_type_id = :assignment_task_type_id
                    AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :days_back
                    AND lt.deviation_percentage IS NOT NULL
                    AND REGEXP_LIKE(lt.deviation_percentage, '^[+-]?([0-9]*[.])?[0-9]+$')
                ),
                fp AS (
                    SELECT NVL(ROUND(AVG(deviation_percentage), 2), 0) AS writing_fingerprint_avg_deviation,
                        NVL(COUNT(*), 0) AS writing_fingerprint_total
                    FROM fingerprint_tasks
                ),
                ai_usage AS (
                    SELECT
                        NVL(SUM(CAST(aus.used_count AS NUMBER)), 0)            AS ai_prompt_used_total,
                        NVL(ROUND(AVG(CAST(aus.used_count AS NUMBER)), 2), 0) AS ai_prompt_used_average
                    FROM BINARY_SUCCESS_AI_USAGE_STATS aus
                    JOIN BINARY_SUCCESS_LEARNER_TASKS lt
                    ON aus.task_id = lt.task_id
                    AND aus.learner_id = lt.learner_id
                    JOIN BINARY_SUCCESS_TEACHER_TASKS tt
                    ON tt.task_id = lt.task_id
                    WHERE tt.task_type_id = :assignment_task_type_id
                    AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :days_back
                    AND aus.used_count IS NOT NULL
                )
                SELECT
                    fp.writing_fingerprint_avg_deviation,
                    fp.writing_fingerprint_total,
                    ai.ai_prompt_used_average,
                    ai.ai_prompt_used_total
                FROM fp
                CROSS JOIN ai_usage ai
            """
            try:
                result = crud_base.fetch_one(platform_query, {"days_back": days_back,
                                                              "assignment_task_type_id": assignment_task_type_id})
            except Exception as db_err:
                logger.error(f"❌ Platform metrics query failed: {db_err}")
                result = {"avg_grade": 0.0, "avg_assignment_time_hours": 0.0}
            scope_info = {"scope": "platform", "scope_id": "all"}
            trend_sql, trend_params = get_trend_sql("platform")

        elif user_role == "INSTITUTE_ADMIN":
            institute_id_row = crud_base.fetch_one(
                "SELECT institute_id FROM BINARY_SUCCESS_PLATFORM_INSTITUTES WHERE LOWER(admin_email)=LOWER(:email)",
                {"email": user_email}
            )
            if not institute_id_row:
                raise HTTPException(status_code=404, detail=f"Institute not found for admin: {user_email}")
            institute_id = institute_id_row["institute_id"]
            scope_info = {"scope": "institute", "scope_id": institute_id}

            institute_query = """
                WITH fingerprint_rows AS (
                    SELECT CAST(lt.deviation_percentage AS NUMBER) AS deviation_percentage
                    FROM BINARY_SUCCESS_LEARNER_TASKS lt
                    JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                    WHERE tt.task_type_id = :assignment_task_type_id
                    AND tt.institute_id = :institute_id
                    AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :days_back
                    AND lt.deviation_percentage IS NOT NULL
                    AND REGEXP_LIKE(lt.deviation_percentage, '^[+-]?([0-9]*[.])?[0-9]+$')
                ),
                fp AS (
                    SELECT NVL(ROUND(AVG(deviation_percentage), 2), 0) AS writing_fingerprint_avg_deviation,
                        NVL(COUNT(*), 0) AS writing_fingerprint_total
                    FROM fingerprint_rows
                ),
                ai_usage AS (
                    SELECT NVL(SUM(au.used_count), 0)        AS ai_prompt_used_total,
                        NVL(ROUND(AVG(au.used_count), 2), 0) AS ai_prompt_used_average
                    FROM BINARY_SUCCESS_AI_USAGE_STATS au
                    JOIN BINARY_SUCCESS_LEARNER_TASKS lt
                    ON au.task_id = lt.task_id
                    AND au.learner_id = lt.learner_id
                    JOIN BINARY_SUCCESS_TEACHER_TASKS tt
                    ON tt.task_id = lt.task_id
                    WHERE tt.task_type_id = :assignment_task_type_id
                    AND tt.institute_id = :institute_id
                    AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :days_back
                )
                SELECT fp.writing_fingerprint_avg_deviation,
                    fp.writing_fingerprint_total,
                    ai.ai_prompt_used_average,
                    ai.ai_prompt_used_total
                FROM fp
                CROSS JOIN ai_usage ai
            """
            result = crud_base.fetch_one(institute_query, {"institute_id": institute_id, "days_back": days_back,
                                                           "assignment_task_type_id": assignment_task_type_id})
            trend_sql, trend_params = get_trend_sql("institute")

        elif user_role == "TEACHER":
            teacher_row = crud_base.fetch_one(
                "SELECT teacher_id FROM BINARY_SUCCESS_TEACHERS WHERE LOWER(email)=LOWER(:email)",
                {"email": user_email}
            )
            if not teacher_row:
                raise HTTPException(status_code=404, detail=f"Teacher not found: {user_email}")
            teacher_id = teacher_row["teacher_id"]
            scope_info = {"scope": "teacher", "scope_id": teacher_id}

            teacher_query = """
                WITH fingerprint_rows AS (
                    SELECT CAST(lt.deviation_percentage AS NUMBER) AS deviation_percentage
                    FROM BINARY_SUCCESS_LEARNER_TASKS lt
                    JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                    WHERE tt.task_type_id = :assignment_task_type_id
                    AND tt.teacher_id = :teacher_id
                    AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :days_back
                    AND lt.deviation_percentage IS NOT NULL
                    AND REGEXP_LIKE(lt.deviation_percentage, '^[+-]?([0-9]*[.])?[0-9]+$')
                ),
                fp AS (
                    SELECT NVL(ROUND(AVG(deviation_percentage), 2), 0) AS writing_fingerprint_avg_deviation,
                        NVL(COUNT(*), 0) AS writing_fingerprint_total
                    FROM fingerprint_rows
                ),
                ai_usage AS (
                    SELECT
                        NVL(SUM(au.used_count), 0)                    AS ai_prompt_used_total,
                        NVL(ROUND(AVG(au.used_count), 2), 0)         AS ai_prompt_used_average
                    FROM BINARY_SUCCESS_AI_USAGE_STATS au
                    JOIN BINARY_SUCCESS_LEARNER_TASKS lt
                    ON au.task_id = lt.task_id
                    AND au.learner_id = lt.learner_id
                    JOIN BINARY_SUCCESS_TEACHER_TASKS tt ON tt.task_id = lt.task_id
                    WHERE tt.task_type_id = :assignment_task_type_id
                    AND tt.teacher_id = :teacher_id
                    AND lt.assigned_at >= SYSTIMESTAMP - INTERVAL '1' DAY * :days_back
                )
                SELECT :teacher_id AS teacher_id,
                    fp.writing_fingerprint_avg_deviation,
                    fp.writing_fingerprint_total,
                    ai.ai_prompt_used_average,
                    ai.ai_prompt_used_total
                FROM fp
                CROSS JOIN ai_usage ai
            """
            result = crud_base.fetch_one(teacher_query, {"teacher_id": teacher_id, "days_back": days_back,
                                                         "assignment_task_type_id": assignment_task_type_id})
            trend_sql, trend_params = get_trend_sql("teacher")

        else:
            raise HTTPException(status_code=403, detail=f"Unsupported user role: {user_role}")

        # ---------- Fetch trend ----------
        trend_rows = crud_base.fetch_all(trend_sql, trend_params) or []
        writing_fingerprint_trend = [
            {
                "label": r.get("label"),
                "avg_deviation": float(r.get("avg_deviation", 0) or 0),
                "total_submission": int(r.get("total_submission", 0) or 0),
                "start_ts": r.get("start_ts").isoformat() if r.get("start_ts") else None,
            }
            for r in trend_rows
        ]


        # ---------- KPIs (from previous blocks) ----------
        writing_fingerprint_avg_deviation = result.get('writing_fingerprint_avg_deviation', 0.0) if result else 0.0
        writing_fingerprint_total = result.get('writing_fingerprint_total', 0) if result else 0
        ai_prompt_used_average = result.get('ai_prompt_used_average', 0.0) if result else 0.0
        ai_prompt_used_total = result.get('ai_prompt_used_total', 0) if result else 0

        # ---------- Get previous period data for comparison ----------
        previous_period_data = get_previous_period_kpis(scope_info["scope"], days_back)
        
        previous_writing_fingerprint_avg_deviation = previous_period_data.get('writing_fingerprint_avg_deviation', 0.0)
        previous_writing_fingerprint_total = previous_period_data.get('writing_fingerprint_total', 0)
        previous_ai_prompt_used_average = previous_period_data.get('ai_prompt_used_average', 0.0)
        previous_ai_prompt_used_total = previous_period_data.get('ai_prompt_used_total', 0)

        # ---------- Calculate trends ----------
        total_count_trend = calculate_trend(writing_fingerprint_total, previous_writing_fingerprint_total)
        average_deviation_trend = calculate_trend(writing_fingerprint_avg_deviation, previous_writing_fingerprint_avg_deviation)
        average_usage_trend = calculate_trend(ai_prompt_used_average, previous_ai_prompt_used_average)
        total_count_ai_trend = calculate_trend(ai_prompt_used_total, previous_ai_prompt_used_total)

        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ AI usage analytics + trend returned in {request_duration:.2f}s")

        return {
            "success": True,
            "data": {
                "writing_fingerprint_analytics": {
                    "total_count": writing_fingerprint_total,
                    "average_deviation": round(writing_fingerprint_avg_deviation, 2) if writing_fingerprint_avg_deviation else 0.0,
                    "total_count_trend": total_count_trend,
                    "average_deviation_trend": average_deviation_trend,
                    "trend": {
                        "bucket": bucket,
                        "periods": periods,
                        "class_name": class_id,
                        "grade_level_id": grade_level_id,
                        "term": term,
                        "academic_year": academic_year,
                        "series": writing_fingerprint_trend
                    }
                },
                "ai_prompt_usage": {
                    "total_count": ai_prompt_used_total,
                    "average_usage": round(ai_prompt_used_average, 2) if ai_prompt_used_average else 0.0,
                    "average_usage_trend": average_usage_trend,
                    "total_count_ai_trend": total_count_ai_trend
                },
                "scope_info": scope_info,
                "user_context": {
                    "email": user_email or "not_provided",
                    "role": user_role,
                    "days_back": days_back
                },
                "comparison_period": f"Previous {days_back} days"
            },
            "message": f"AI usage analytics + trend retrieved for {user_role}",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2)
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error in analytics endpoint: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch AI usage analytics data: {str(e)}")


@router.get("/performance-metrics")
async def get_performance_metrics(
    user_email: str | None = None,
    user_role: str = "PLATFORM_ADMIN", 
    days_back: int = 30
):
    """
    Performance Metrics Endpoint (Role-Based) with Trends.

    Returns performance metrics based on user role:
    - Platform Admin: System-wide data
    - Institute Admin: Institute-specific data  
    - Teacher: Teacher-specific data

    Also includes trends: compares current period with previous period of equal length.
    """
    request_start_time = datetime.now()
    logger.info(
        f"🚀 Performance metrics request - email={user_email}, role={user_role}, days_back={days_back}"
    )

    try:
        def calc_trend(curr: float, prev: float) -> str:
            if curr > prev:
                return "up"
            elif curr < prev:
                return "down"
            return "stable"

        # Initialize default values
        avg_grade = 0.0
        avg_assignment_time_hours = 0.0
        prev_grade = 0.0
        prev_time = 0.0
        scope_info = {"scope": "unknown", "scope_id": None}

        now = datetime.now()
        current_window = {
            "start_time": now - timedelta(days=days_back),
            "end_time": now,
        }
        previous_window = {
            "start_time": now - timedelta(days=days_back * 2),
            "end_time": now - timedelta(days=days_back),
        }

        def run_query(sql: str, params: dict) -> dict:
            try:
                return crud_base.fetch_one(sql, params) or {}
            except Exception as e:
                logger.error(f"❌ Query failed: {e}")
                return {"avg_grade": 0.0, "avg_assignment_time_hours": 0.0}

        if user_role == "PLATFORM_ADMIN":
            logger.info("🔍 Executing platform admin performance metrics query")

            sql = """
                WITH q AS (
                  SELECT lt.ai_grade,
                         (lt.submitted_at - lt.draft_started_at) AS diff_i

                  FROM BINARY_SUCCESS_LEARNER_TASKS lt
                  WHERE lt.submitted_at IS NOT NULL
                    AND lt.draft_started_at IS NOT NULL
                    AND lt.submitted_at >= :start_time
                    AND lt.submitted_at < :end_time
                )
                SELECT NVL(ROUND(AVG(ai_grade), 2), 0) AS avg_grade,
                       NVL(ROUND(AVG(
                            EXTRACT(DAY    FROM diff_i) * 24
                          + EXTRACT(HOUR   FROM diff_i)
                          + EXTRACT(MINUTE FROM diff_i) / 60
                          + EXTRACT(SECOND FROM diff_i) / 3600
                       ), 2), 0) AS avg_assignment_time_hours
                FROM q

            """
            result_current = run_query(sql, current_window)
            result_previous = run_query(sql, previous_window)
            scope_info = {"scope": "platform", "scope_id": "all"}

        elif user_role == "INSTITUTE_ADMIN":
            logger.info("🔍 Executing institute admin performance metrics query")

            institute_lookup_query = """
                SELECT INSTITUTE_ID
                FROM BINARY_SUCCESS_PLATFORM_INSTITUTES
                WHERE LOWER(admin_email) = LOWER(:user_email)
                FETCH FIRST 1 ROWS ONLY
            """
            institute_result = crud_base.fetch_one(institute_lookup_query, {"user_email": user_email})

            if not institute_result:
                logger.warning(f"⚠️ Institute not found for admin email: {user_email}")
                raise HTTPException(status_code=404, detail=f"Institute not found for admin email: {user_email}")

            institute_id = institute_result.get("institute_id")
            logger.info(f"🔍 Found institute ID: {institute_id} for admin: {user_email}")

            sql = """
                WITH q AS (
                  SELECT lt.ai_grade,
                         (lt.submitted_at - lt.draft_started_at) AS diff_i
                  FROM BINARY_SUCCESS_LEARNER_TASKS lt
                  JOIN BINARY_SUCCESS_TEACHER_TASKS tt
                    ON tt.task_id = lt.task_id
                  WHERE tt.institute_id = :institute_id
                    AND lt.submitted_at IS NOT NULL
                    AND lt.draft_started_at IS NOT NULL
                    AND lt.submitted_at >= :start_time
                    AND lt.submitted_at < :end_time
                )
                SELECT NVL(ROUND(AVG(ai_grade), 2), 0) AS avg_grade,
                       NVL(ROUND(AVG(
                            EXTRACT(DAY    FROM diff_i) * 24
                          + EXTRACT(HOUR   FROM diff_i)
                          + EXTRACT(MINUTE FROM diff_i) / 60
                          + EXTRACT(SECOND FROM diff_i) / 3600
                       ), 2), 0) AS avg_assignment_time_hours
                FROM q
            """
            params_current = {**current_window, "institute_id": institute_id}
            params_previous = {**previous_window, "institute_id": institute_id}
            result_current = run_query(sql, params_current)
            result_previous = run_query(sql, params_previous)


            scope_info = {"scope": "institute", "scope_id": institute_id}

        elif user_role == "TEACHER":
            logger.info("🔍 Executing teacher performance metrics query")

            teacher_lookup_query = """
                SELECT TEACHER_ID
                FROM BINARY_SUCCESS_TEACHERS
                WHERE LOWER(email) = LOWER(:user_email)
                FETCH FIRST 1 ROWS ONLY
            """
            teacher_result = crud_base.fetch_one(teacher_lookup_query, {"user_email": user_email})

            if not teacher_result:
                logger.warning(f"⚠️ Teacher not found for email: {user_email}")
                raise HTTPException(status_code=404, detail=f"Teacher not found for email: {user_email}")

            teacher_id = teacher_result.get("teacher_id")
            logger.info(f"🔍 Found teacher ID: {teacher_id} for email: {user_email}")

            sql = """
                WITH q AS (
                  SELECT lt.ai_grade,
                         (lt.submitted_at - lt.draft_started_at) AS diff_i
                  FROM BINARY_SUCCESS_LEARNER_TASKS lt
                  JOIN BINARY_SUCCESS_TEACHER_TASKS tt
                    ON tt.task_id = lt.task_id
                  WHERE tt.teacher_id = :teacher_id
                    AND lt.submitted_at IS NOT NULL
                    AND lt.draft_started_at IS NOT NULL
                    AND lt.submitted_at >= :start_time
                    AND lt.submitted_at < :end_time
                )
                SELECT NVL(ROUND(AVG(ai_grade), 2), 0) AS avg_grade,
                       NVL(ROUND(AVG(
                            EXTRACT(DAY    FROM diff_i) * 24
                          + EXTRACT(HOUR   FROM diff_i)
                          + EXTRACT(MINUTE FROM diff_i) / 60
                          + EXTRACT(SECOND FROM diff_i) / 3600
                       ), 2), 0) AS avg_assignment_time_hours

                FROM q
            """
            params_current = {**current_window, "teacher_id": teacher_id}
            params_previous = {**previous_window, "teacher_id": teacher_id}
            result_current = run_query(sql, params_current)
            result_previous = run_query(sql, params_previous)


            scope_info = {"scope": "teacher", "scope_id": teacher_id}

        else:
            logger.warning(f"⚠️ Unsupported user role: {user_role}")
            raise HTTPException(status_code=403, detail=f"Unsupported user role: {user_role}")

        # Process results
        if result_current:
            avg_grade = result_current.get("avg_grade", 0.0)
            avg_assignment_time_hours = result_current.get("avg_assignment_time_hours", 0.0)
        if result_previous:
            prev_grade = result_previous.get("avg_grade", 0.0)
            prev_time = result_previous.get("avg_assignment_time_hours", 0.0)
        trend_grade = calc_trend(avg_grade, prev_grade)
        trend_time = calc_trend(avg_assignment_time_hours, prev_time)

        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Performance metrics data with trends retrieved successfully in {request_duration:.2f}s")

        return {
            "success": True,
            "data": {
                "performance_metrics": {
                    "avg_grade": round(avg_grade, 2),
                    "avg_grade_trend": trend_grade,
                    "avg_assignment_time_hours": round(avg_assignment_time_hours, 2),
                    "avg_assignment_time_trend": trend_time,
                },
                "scope_info": scope_info,
                "user_context": {
                    "email": user_email or "not_provided",
                    "role": user_role,
                    "days_back": days_back,
                    "comparison_period": f"Previous {days_back} days",
                },
            },
            "message": f"Performance metrics data with trends retrieved successfully for {user_role} from local database",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2),
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error fetching performance metrics data: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch performance metrics data: {str(e)}")


@router.get("/teacher-class-filters")
async def get_teacher_class_filters(
    teacher_id: str | None = None,
    institute_id: str | None = None,
    class_name: str | None = None,
    grade_id: str | None = None,
    term: str | None = None,
    academic_year: str | None = None,
):
    """
    Return filter data for teacher classes:
    - If teacher_id is provided, return that teacher’s classes, grades, terms, academic years.
    - If institute_id is provided, return all teachers with their classes, grades, terms, academic years.
    - If neither is provided, return all institutes with their teachers, classes, grades, terms, academic years.
    - Filters (class_name, grade_id, term, academic_year) apply in all cases.
    """
    request_start_time = datetime.now()
    logger.info(
        f"🚀 Fetching class filters - teacher_id={teacher_id}, institute_id={institute_id}, "
        f"class_name={class_name}, grade_id={grade_id}, term={term}, academic_year={academic_year}"
    )

    try:
        # Base query
        query = """
            SELECT DISTINCT
                i.INSTITUTE_ID   AS institute_id,
                i.INSTITUTE_NAME AS institute_name,
                t.TEACHER_ID     AS teacher_id,
                (t.FIRST_NAME || ' ' || t.LAST_NAME) AS teacher_name,
                c.CLASS_ID       AS class_id,
                c.CLASS_NAME     AS class_name,
                g.GRADE_LEVEL_ID AS grade_id,
                g.GRADE_NAME     AS grade_name,
                c.TERM           AS term,
                c.ACADEMIC_YEAR  AS academic_year
            FROM BINARY_SUCCESS_CLASSES c
            LEFT JOIN BINARY_SUCCESS_GRADE_LEVELS g 
                ON c.GRADE_LEVEL_ID = g.GRADE_LEVEL_ID
            INNER JOIN BINARY_SUCCESS_TEACHERS t 
                ON c.TEACHER_ID = t.TEACHER_ID
            INNER JOIN BINARY_SUCCESS_PLATFORM_INSTITUTES i
                ON t.INSTITUTE_ID = i.INSTITUTE_ID
            WHERE 1=1
        """

        params = {}

        # Apply filters if passed
        if teacher_id:
            query += " AND c.TEACHER_ID = :teacher_id"
            params["teacher_id"] = teacher_id
        if institute_id:
            query += " AND i.INSTITUTE_ID = :institute_id"
            params["institute_id"] = institute_id
        if class_name:
            query += " AND c.CLASS_NAME = :class_name"
            params["class_name"] = class_name
        if grade_id:
            query += " AND g.GRADE_LEVEL_ID = :grade_id"
            params["grade_id"] = grade_id
        if term:
            query += " AND c.TERM = :term"
            params["term"] = term
        if academic_year:
            query += " AND c.ACADEMIC_YEAR = :academic_year"
            params["academic_year"] = academic_year

        rows = crud_base.fetch_all(query, params)

        if not rows:
            raise HTTPException(status_code=404, detail="No data found for given filters")

        # Group by institute -> teachers
        institute_map = {}
        for r in rows:
            iid = r.get("institute_id")
            tid = r.get("teacher_id")
            if not iid or not tid:
                continue

            if iid not in institute_map:
                institute_map[iid] = {
                    "institute_id": iid,
                    "institute_name": r.get("institute_name"),
                    "teachers": {}
                }

            teacher_map = institute_map[iid]["teachers"]

            if tid not in teacher_map:
                teacher_map[tid] = {
                    "teacher_id": tid,
                    "teacher_name": r.get("teacher_name"),
                    "classes": [],
                    "grades": set(),
                    "terms": set(),
                    "academic_years": set(),
                }

            # Add class with grade in display name
            class_display = (
                f"{r.get('class_name')} ({r.get('grade_name')})"
                if r.get("grade_name") else r.get("class_name")
            )

            teacher_map[tid]["classes"].append({
                "class_id": r.get("class_id"),
                "class_name": class_display,
                "grade_id": r.get("grade_id"),
            })

            if r.get("grade_id"):
                teacher_map[tid]["grades"].add((r.get("grade_id"), r.get("grade_name")))
            if r.get("term"):
                teacher_map[tid]["terms"].add(r.get("term"))
            if r.get("academic_year"):
                teacher_map[tid]["academic_years"].add(r.get("academic_year"))

        # Format final response
        response = []
        for inst in institute_map.values():
            teachers_data = []
            for teacher in inst["teachers"].values():
                teachers_data.append({
                    "teacher_id": teacher["teacher_id"],
                    "teacher_name": teacher["teacher_name"],
                    "classes": teacher["classes"],
                    "grades": [{"grade_id": gid, "grade_name": gname} for gid, gname in teacher["grades"]],
                    "terms": sorted(teacher["terms"]),
                    "academic_years": sorted(teacher["academic_years"]),
                })

            response.append({
                "institute_id": inst["institute_id"],
                "institute_name": inst["institute_name"],
                "teachers": teachers_data
            })

        request_duration = (datetime.now() - request_start_time).total_seconds()
        return {
            "success": True,
            "data": response,
            "message": "Filters retrieved successfully",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2),
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error fetching class filters: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch class filters")


@router.get("/role-classes")
async def get_role_classes(id: str, type: str):
    """
    Role-Based Classes Endpoint (ID-Based).
    Depending on role TYPE and ID, returns: 
    - TEACHER: list of classes
    - INSTITUTE_ADMIN: teacher -> list of classes
    - PLATFORM_ADMIN: institute -> teacher -> list of classes
    """

    request_start_time = datetime.now()
    logger.info(f"🚀 Role-classes request - id={id}, type={type}")

    try:
        if type.upper() == "TEACHER":
            logger.info(f"🔍 Fetching classes for TEACHER_ID={id}")
            query = """
                SELECT c.CLASS_NAME
                FROM BINARY_SUCCESS_CLASSES c
                WHERE c.TEACHER_ID = :teacher_id
                ORDER BY c.CLASS_NAME
            """
            classes = crud_base.fetch_all(query, {"teacher_id": id})
            if not classes:
                raise HTTPException(status_code=404, detail=f"No classes found for teacher_id {id}")

            data = {"classes": [r.get("class_name") for r in classes if r.get("class_name")]}

        elif type.upper() == "INSTITUTE_ADMIN":
            logger.info(f"🔍 Fetching teacher classes for INSTITUTE_ID={id}")
            query = """
                SELECT t.FIRST_NAME || ' ' || t.LAST_NAME AS teacher_name,
                       c.CLASS_NAME
                FROM BINARY_SUCCESS_TEACHERS t
                LEFT JOIN BINARY_SUCCESS_CLASSES c ON c.TEACHER_ID = t.TEACHER_ID
                WHERE t.INSTITUTE_ID = :institute_id
                ORDER BY teacher_name, c.CLASS_NAME
            """
            rows = crud_base.fetch_all(query, {"institute_id": id})
            if not rows:
                raise HTTPException(status_code=404, detail=f"No teachers/classes found for institute_id {id}")

            data = {"classes": [
                {"teacher_name": r.get("teacher_name"), "class_name": r.get("class_name")}
                for r in rows if r.get("teacher_name")
            ]}

        elif type.upper() == "PLATFORM_ADMIN":
            logger.info(f"🔍 Checking if USER_ID={id} is a valid platform admin")
            check_query = """
                SELECT pu.USER_ID
                FROM BINARY_SUCCESS_PLATFORM_USERS pu
                JOIN BINARY_SUCCESS_ROLES r ON pu.ROLE_ID = r.ROLE_ID
                WHERE pu.USER_ID = :user_id
                  AND r.ROLE_NAME = 'PLATFORM_ADMIN'
                FETCH FIRST 1 ROWS ONLY
            """
            check_result = crud_base.fetch_one(check_query, {"user_id": id})
            if not check_result:
                raise HTTPException(status_code=404, detail=f"Platform admin not found for ID {id}")

            logger.info("🔍 Fetching all institutes, teachers, and classes for PLATFORM_ADMIN")
            query = """
                SELECT i.INSTITUTE_NAME,
                       t.FIRST_NAME || ' ' || t.LAST_NAME AS teacher_name,
                       c.CLASS_NAME
                FROM BINARY_SUCCESS_PLATFORM_INSTITUTES i
                JOIN BINARY_SUCCESS_TEACHERS t ON t.INSTITUTE_ID = i.INSTITUTE_ID
                LEFT JOIN BINARY_SUCCESS_CLASSES c ON c.TEACHER_ID = t.TEACHER_ID
                ORDER BY i.INSTITUTE_NAME, teacher_name, c.CLASS_NAME
            """
            rows = crud_base.fetch_all(query)
            if not rows:
                raise HTTPException(status_code=404, detail="No institutes/teachers/classes found")

            data = {"classes": [
                {
                    "institute_name": r.get("institute_name"),
                    "teacher_name": r.get("teacher_name"),
                    "class_name": r.get("class_name")
                }
                for r in rows if r.get("institute_name") and r.get("teacher_name")
            ]}

        else:
            raise HTTPException(status_code=400, detail="Invalid type. Use TEACHER, INSTITUTE_ADMIN, or PLATFORM_ADMIN.")

        request_duration = (datetime.now() - request_start_time).total_seconds()
        return {
            "success": True,
            "data": data,
            "message": f"Role-classes data retrieved successfully for {type.upper()}",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2),
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error fetching role-classes data: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch role-classes data")

@router.get("/get-learners-deviation")
async def get_learners_deviation(
    teacher_id: str,
    row_count: int = 5
):
    """
    Get the latest deviation_percentage values for unique learners of a teacher.
    Returns up to `row_count` unique learners (default: 5).
    """
    try:
        learners_query = f"""
            SELECT learner_name, deviation_percentage, created_date
            FROM (
                SELECT 
                    l.first_name || ' ' || l.last_name AS learner_name,
                    lt.deviation_percentage,
                    lt.assigned_at AS created_date,
                    ROW_NUMBER() OVER (
                        PARTITION BY lt.learner_id
                        ORDER BY lt.assigned_at DESC NULLS LAST
                    ) AS rn
                FROM BINARY_SUCCESS_LEARNER_TASKS lt
                JOIN BINARY_SUCCESS_TEACHER_TASKS tt 
                    ON tt.task_id = lt.task_id
                JOIN BINARY_SUCCESS_LEARNERS l
                    ON l.learner_id = lt.learner_id
                WHERE tt.teacher_id = :teacher_id
                  AND lt.deviation_percentage IS NOT NULL
            )
            WHERE rn = 1
            ORDER BY deviation_percentage DESC
            FETCH FIRST :row_count ROWS ONLY
        """
        params = {"teacher_id": teacher_id, "row_count": row_count}
        rows = crud_base.fetch_all(learners_query, params)

        learners = [
            {
                "learner_name": r.get("learner_name"),
                "deviation_percentage": r.get("deviation_percentage"),
                "created_date": (
                    r.get("created_date").isoformat()
                    if r.get("created_date") else None
                ),
            }
            for r in rows
        ]

        return {
            "success": True,
            "data": {"learners": learners},
            "message": f"Top {row_count} learners retrieved successfully",
            "timestamp": datetime.now().isoformat(),
        }

    except Exception as e:
        logger.error(f"❌ Error fetching learners for teacher {teacher_id}: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch learners")


@router.get("/filter-options")
async def get_all_filter_options():
    """
    Get All Filter Options.

    Returns:
      - teachers: list of {"teacher_name"}
      - classes:  list of {"class_id", "class_name"}
      - schools:  list of {"school_id", "school_name"}
      - grades:   list of {"grade_id", "grade_name"}
    """
    request_start_time = datetime.now()
    logger.info("🚀 Get all filter options request")

    try:
        # Use quoted aliases so dict keys are exactly as written (lowercase)
        teachers_query = """
            SELECT
                FIRST_NAME || ' ' || LAST_NAME AS "teacher_name"
            FROM BINARY_SUCCESS_TEACHERS
            WHERE FIRST_NAME IS NOT NULL
            ORDER BY FIRST_NAME
        """

        classes_query = """
            SELECT
                CLASS_ID   AS "class_id",
                CLASS_NAME AS "class_name"
            FROM BINARY_SUCCESS_CLASSES
            WHERE CLASS_ID IS NOT NULL
              AND CLASS_NAME IS NOT NULL
            ORDER BY CLASS_NAME
        """

        schools_query = """
            SELECT
                INSTITUTE_ID   AS "school_id",
                INSTITUTE_NAME AS "school_name"
            FROM BINARY_SUCCESS_PLATFORM_INSTITUTES
            WHERE INSTITUTE_ID IS NOT NULL
              AND INSTITUTE_NAME IS NOT NULL
            ORDER BY INSTITUTE_NAME
        """

        grades_query = """
            SELECT
                GRADE_LEVEL_ID   AS "grade_id",
                GRADE_NAME AS "grade_name"
            FROM BINARY_SUCCESS_GRADE_LEVELS
            WHERE GRADE_NAME IS NOT NULL
            ORDER BY GRADE_NAME
        """

        logger.info("🔍 Executing filter queries")
        logger.info(f"🔍 Teachers SQL: {teachers_query.strip()}")
        logger.info(f"🔍 Classes  SQL: {classes_query.strip()}")
        logger.info(f"🔍 Schools  SQL: {schools_query.strip()}")
        logger.info(f"🔍 Grades   SQL: {grades_query.strip()}")

        # Execute (sync; same style as ai-usage-overview)
        teachers_rows = crud_base.fetch_all(teachers_query)
        classes_rows  = crud_base.fetch_all(classes_query)
        schools_rows  = crud_base.fetch_all(schools_query)
        grades_rows   = crud_base.fetch_all(grades_query)

        # Build response payloads (keys are exactly as quoted above)
        teachers = [
            {"teacher_name": r["teacher_name"]}
            for r in teachers_rows
            if r.get("teacher_name")
        ]

        classes = [
            {"class_id": r["class_id"], "class_name": r["class_name"]}
            for r in classes_rows
            if r.get("class_id") and r.get("class_name")
        ]

        schools = [
            {"school_id": r["school_id"], "school_name": r["school_name"]}
            for r in schools_rows
            if r.get("school_id") and r.get("school_name")
        ]

        grades = [
            {"grade_id": r["grade_id"], "grade_name": r["grade_name"]}
            for r in grades_rows
            if r.get("grade_name")
        ]

        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Filter options retrieved successfully in {request_duration:.2f}s")
        logger.info(f"📊 Sizes => teachers:{len(teachers)} classes:{len(classes)} schools:{len(schools)} grades:{len(grades)}")

        return {
            "success": True,
            "data": {
                "teachers": teachers,
                "classes": classes,
                "schools": schools,
                "grades": grades,
            },
            "message": "Filter options retrieved successfully from local database",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2),
        }

    except Exception as e:
        logger.error(f"❌ Error fetching filter options: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch filter options: {str(e)}")


@router.get("/classes")
async def get_all_classes():
    """Return all classes for analytics dropdowns."""
    try:
        classes_query = """
            SELECT
                CLASS_ID   AS "class_id",
                CLASS_NAME AS "class_name"
            FROM BINARY_SUCCESS_CLASSES
            WHERE CLASS_ID IS NOT NULL
              AND CLASS_NAME IS NOT NULL
            ORDER BY CLASS_NAME
        """
        rows = crud_base.fetch_all(classes_query)
        classes = [
            {"class_id": r.get("class_id"), "class_name": r.get("class_name")}
            for r in rows
            if r.get("class_id") and r.get("class_name")
        ]
        return {
            "success": True,
            "data": {"classes": classes},
            "message": "Classes retrieved successfully",
            "timestamp": datetime.now().isoformat(),
        }
    except Exception as e:
        logger.error(f"❌ Error fetching classes: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch classes")


@router.get("/teachers")
async def get_all_teachers():
    """Return all teachers for analytics dropdowns."""
    try:
        teachers_query = """
            SELECT
                FIRST_NAME || ' ' || LAST_NAME AS "teacher_name"
            FROM BINARY_SUCCESS_TEACHERS
            WHERE FIRST_NAME IS NOT NULL
            ORDER BY FIRST_NAME
        """
        rows = crud_base.fetch_all(teachers_query)
        teachers = [
            {"teacher_name": r.get("teacher_name")}
            for r in rows
            if r.get("teacher_name")
        ]
        return {
            "success": True,
            "data": {"teachers": teachers},
            "message": "Teachers retrieved successfully",
            "timestamp": datetime.now().isoformat(),
        }
    except Exception as e:
        logger.error(f"❌ Error fetching teachers: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch teachers")


@router.get("/school-analytics/{institute_id}")
async def get_school_analytics(institute_id: str):
    """
    School Analytics Endpoint.
    
    Returns school-specific analytics data including:
    - Total unique learners enrolled under the institute
    - Total teachers in the institute
    - Assignment submission counts by status (GRADED and SUBMITTED)
    
    Parameters:
        institute_id: Institute ID to get analytics for
    
    Returns:
        - School analytics statistics
        - Request metadata and timestamps
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 School analytics request - institute_id: {institute_id}")

    try:
        # 1. Get total unique learners enrolled under the institute
        students_query = """
            SELECT COUNT(DISTINCT e.LEARNER_ID) AS total_learners
            FROM BINARY_SUCCESS_CLASSES c
            JOIN BINARY_SUCCESS_ENROLLMENTS e
              ON e.CLASS_ID = c.CLASS_ID
            JOIN BINARY_SUCCESS_STATUSES s 
                ON c.CLASS_STATUS_ID = s.STATUS_ID AND UPPER(s.STATUS_CODE) <> 'INACTIVE'
            WHERE c.INSTITUTE_ID = :institute_id
        """
        
        # 2. Get total teachers in the institute
        teachers_query = """
            SELECT COUNT(DISTINCT TEACHER_ID) AS total_teachers
            FROM BINARY_SUCCESS_TEACHERS
            WHERE INSTITUTE_ID = :institute_id
        """
        
        # 3. Get assignment submission counts by status (GRADED and IN_REVIEW)
        assignments_query = """
            SELECT ts.STATUS,
                   COUNT(lt.LEARNER_TASK_ID) AS submission_count
            FROM BINARY_SUCCESS_LEARNER_TASKS lt
            JOIN BINARY_SUCCESS_TEACHER_TASKS tt
              ON lt.TASK_ID = tt.TASK_ID
            JOIN BINARY_SUCCESS_TASK_STATUSES ts
              ON ts.STATUS_ID = lt.STATUS_ID
            JOIN BINARY_SUCCESS_TASK_TYPES ty 
                ON tt.TASK_TYPE_ID = ty.TASK_TYPE_ID
            WHERE tt.INSTITUTE_ID = :institute_id
              AND UPPER(ty.TASK_TYPE) = 'ASSIGNMENT'
              AND ts.STATUS IN ('GRADED', 'SUBMITTED')
            GROUP BY ts.STATUS
            ORDER BY ts.STATUS
        """
        
        logger.info(f"🔍 Executing school analytics queries for institute: {institute_id}")
        
        # Execute queries with parameterized institute_id
        students_result = crud_base.fetch_one(students_query, {"institute_id": institute_id})
        teachers_result = crud_base.fetch_one(teachers_query, {"institute_id": institute_id})
        assignments_result = crud_base.fetch_all(assignments_query, {"institute_id": institute_id})
        
        # Process results
        total_learners = students_result.get('total_learners', 0) if students_result else 0
        total_teachers = teachers_result.get('total_teachers', 0) if teachers_result else 0
        
        # Process assignment status breakdown
        assignment_status_breakdown = {}
        total_assignments = 0
        
        for assignment_data in assignments_result:
            status = assignment_data.get('status', 'Unknown')
            count = assignment_data.get('submission_count', 0)
            assignment_status_breakdown[status] = count
            total_assignments += count
        
        # Ensure both expected statuses are present (even if count is 0)
        expected_statuses = ['GRADED', 'SUBMITTED']
        for status in expected_statuses:
            if status not in assignment_status_breakdown:
                assignment_status_breakdown[status] = 0

        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ School analytics data retrieved successfully in {request_duration:.2f}s")
        
        return {
            "success": True,
            "data": {
                "institute_id": institute_id,
                "total_students": total_learners,
                "total_teachers": total_teachers,
                "assignments": {
                    "total_submissions": total_assignments,
                    "status_breakdown": assignment_status_breakdown
                }
            },
            "message": "School analytics data retrieved successfully from local database",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2)
        }
        
    except Exception as e:
        logger.error(f"❌ Error fetching school analytics data: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch school analytics data: {str(e)}")


@router.get("/institute-by-email/{email}")
async def get_institute_by_email(email: str):
    """
    Get Institute by Email Endpoint.
    
    Returns institute ID for a given admin user email address.
    Looks up the institute where the user is the admin.
    
    Parameters:
        email: Admin user email address to look up
    
    Returns:
        - Institute ID if found
        - 404 if institute not found for the email
        - Request metadata and timestamps
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 Get institute by email request - email: {email}")

    try:
        # Query to get institute ID by admin user email
        institute_query = """
            SELECT i.INSTITUTE_ID
            FROM BINARY_SUCCESS_PLATFORM_INSTITUTES i
            JOIN BINARY_SUCCESS_PLATFORM_USERS u
              ON i.ADMIN_USER_ID = u.USER_ID
            WHERE u.EMAIL = :email
        """
        
        logger.info(f"🔍 Executing institute lookup query for admin email: {email}")
        
        # Execute query with parameterized email
        institute_result = crud_base.fetch_one(institute_query, {"email": email})
        
        if not institute_result:
            logger.warning(f"⚠️ Institute not found for admin email: {email}")
            raise HTTPException(status_code=404, detail=f"Institute not found for admin email: {email}")
        
        institute_id = institute_result.get('institute_id')
        
        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Institute found successfully in {request_duration:.2f}s - Institute ID: {institute_id}")
        
        return {
            "success": True,
            "data": {
                "admin_email": email,
                "institute_id": institute_id
            },
            "message": "Institute found successfully for admin email",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2)
        }
        
    except HTTPException:
        # Re-raise HTTP exceptions (like 404)
        raise
    except Exception as e:
        logger.error(f"❌ Error fetching institute by email: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch institute by email: {str(e)}")


@router.get("/teacher-dashboard/{teacher_email}")
async def get_teacher_dashboard(teacher_email: str):
    """
    Teacher Dashboard Endpoint.
    
    Returns teacher-specific dashboard data including:
    - Assignment counts by status (GRADED and IN_REVIEW)
    - Total students enrolled in teacher's classes
    
    Parameters:
        teacher_email: Teacher email address to get dashboard data for
    
    Returns:
        - Teacher dashboard statistics
        - Request metadata and timestamps
    """
    request_start_time = datetime.now()
    logger.info(f"🚀 Teacher dashboard request - teacher_email: {teacher_email}")

    try:
        # Optimized single query combining all the logic from the provided SQL
        dashboard_query = """
            WITH params AS (
              SELECT t.teacher_id
              FROM BINARY_SUCCESS_TEACHERS t
              WHERE t.EMAIL = :teacher_email
            ),
            t_tasks AS (
              SELECT tt.TASK_ID
              FROM BINARY_SUCCESS_TEACHER_TASKS tt
              JOIN params p ON p.teacher_id = tt.TEACHER_ID
            ),
            status_counts AS (
              SELECT
                COUNT(CASE WHEN ts.STATUS = 'GRADED'    THEN 1 END) AS graded_count,
                COUNT(CASE WHEN ts.STATUS = 'SUBMITTED' THEN 1 END) AS in_review_count
              FROM BINARY_SUCCESS_LEARNER_TASKS lt
              JOIN t_tasks tt            ON tt.TASK_ID   = lt.TASK_ID
              JOIN BINARY_SUCCESS_TASK_STATUSES ts ON ts.STATUS_ID = lt.STATUS_ID
            ),
            student_counts AS (
              SELECT COUNT(DISTINCT l.LEARNER_ID) AS total_students
              FROM BINARY_SUCCESS_LEARNERS l
              JOIN BINARY_SUCCESS_ENROLLMENTS e ON e.LEARNER_ID = l.LEARNER_ID
              JOIN BINARY_SUCCESS_CLASSES c     ON c.CLASS_ID   = e.CLASS_ID
              JOIN BINARY_SUCCESS_TEACHERS t    ON t.TEACHER_ID = c.TEACHER_ID
              JOIN params p              ON p.teacher_id = t.TEACHER_ID
            )
            SELECT
              sc.graded_count,
              sc.in_review_count,
              st.total_students
            FROM status_counts sc
            CROSS JOIN student_counts st
        """
        
        logger.info(f"🔍 Executing teacher dashboard query for email: {teacher_email}")
        
        # Execute query with parameterized teacher_email
        dashboard_result = crud_base.fetch_one(dashboard_query, {"teacher_email": teacher_email})
        
        if not dashboard_result:
            logger.warning(f"⚠️ No data found for teacher email: {teacher_email}")
            # Return zeros if teacher not found or has no data
            dashboard_result = {
                'graded_count': 0,
                'in_review_count': 0,
                'total_students': 0
            }
        
        # Process results
        graded_count = dashboard_result.get('graded_count', 0)
        in_review_count = dashboard_result.get('in_review_count', 0)
        total_students = dashboard_result.get('total_students', 0)
        total_assignments = graded_count + in_review_count

        request_duration = (datetime.now() - request_start_time).total_seconds()
        logger.info(f"✅ Teacher dashboard data retrieved successfully in {request_duration:.2f}s")
        
        return {
            "success": True,
            "data": {
                "teacher_email": teacher_email,
                "assignments": {
                    "graded_count": graded_count,
                    "in_review_count": in_review_count,
                    "total_assignments": total_assignments
                },
                "students": {
                    "total_students": total_students
                }
            },
            "message": "Teacher dashboard data retrieved successfully from local database",
            "timestamp": datetime.now().isoformat(),
            "source": "local_database",
            "request_duration_seconds": round(request_duration, 2)
        }
        
    except Exception as e:
        logger.error(f"❌ Error fetching teacher dashboard data: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch teacher dashboard data: {str(e)}")


@router.get("/school-id-by-email")
async def get_school_id_by_email_legacy(email: str):
    """
    Legacy School ID by Email Endpoint (Compatibility).
    
    This endpoint exists for backward compatibility with Flutter app caching issues.
    It redirects to the new institute-by-email endpoint and transforms the response.
    
    Parameters:
        email: Admin user email address (as query parameter)
    
    Returns:
        - School ID (actually institute ID) in legacy format
        - Compatible with existing Flutter app expectations
    """
    request_start_time = datetime.now()
    logger.info(f"🔄 Legacy school-id-by-email request - email: {email}")

    try:
        # Call our new institute-by-email endpoint internally
        institute_result = await get_institute_by_email(email)
        
        if institute_result and institute_result.get('success'):
            institute_id = institute_result['data']['institute_id']
            logger.info(f"✅ Legacy endpoint returning institute ID: {institute_id}")
            
            # Return in the format expected by the old Flutter app
            return {
                "school_id": institute_id,
                "school_name": "Institute",
                "user_type": "INSTITUTE_ADMIN",
                "success": True
            }
        else:
            logger.warning(f"⚠️ No institute found for email: {email}")
            raise HTTPException(status_code=404, detail=f"No school association found for email: {email}")
            
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logger.error(f"❌ Error in legacy school-id-by-email endpoint: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch school ID: {str(e)}")
