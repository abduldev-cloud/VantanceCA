# app/modules/auth_mock/routes.py
"""
Mock authentication endpoints for local development without Keycloak.
These endpoints simulate Keycloak's behavior for testing purposes.
NOW PERSISTED IN MYSQL.
"""

from fastapi import APIRouter, HTTPException, Body, Form
from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any, List
import uuid
import json
from datetime import datetime, timedelta
import secrets
from app.core.database_mysql import get_mysql_connection
import logging

# Configure logger
logger = logging.getLogger(__name__)

router = APIRouter(tags=["Auth Mock (Local Dev)"])

# In-memory storage for tokens (temporary, no need to persist for local dev)
mock_tokens_db: Dict[str, Dict[str, Any]] = {}


class KeycloakUserCreate(BaseModel):
    username: str
    email: EmailStr
    enabled: bool = True
    firstName: str
    lastName: str
    attributes: Optional[Dict[str, List[str]]] = None
    credentials: Optional[List[Dict[str, Any]]] = None


@router.post("/realms/binarysuccess/protocol/openid-connect/token")
async def token_endpoint(
    grant_type: str = Form(...),
    client_id: str = Form(...),
    client_secret: str = Form(None),
    username: str = Form(None),
    password: str = Form(None)
):
    """Mock Keycloak token endpoint - handles both admin token and user login"""
    
    # Admin token request (client_credentials)
    if grant_type == "client_credentials":
        access_token = f"mock_admin_token_{secrets.token_urlsafe(32)}"
        
        return {
            "access_token": access_token,
            "expires_in": 3600,
            "refresh_expires_in": 7200,
            "refresh_token": f"mock_refresh_{secrets.token_urlsafe(32)}",
            "token_type": "Bearer",
            "not-before-policy": 0,
            "session_state": str(uuid.uuid4()),
            "scope": "email profile"
        }
    
    # User login request (password)
    elif grant_type == "password":
        if not username or not password:
            raise HTTPException(status_code=400, detail="Username and password required")
        
        # Check user in BINARY_SUCCESS_PLATFORM_USERS (consolidated table)
        conn = get_mysql_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT user_id, keycloak_id, username, email, password, enabled, 
                       first_name, last_name
                FROM BINARY_SUCCESS_PLATFORM_USERS 
                WHERE username = %s OR email = %s
            """, (username, username))
            user = cursor.fetchone()
            
            if not user:
                raise HTTPException(status_code=401, detail="Invalid credentials")
            
            if user["password"] != password:
                raise HTTPException(status_code=401, detail="Invalid credentials")
            
            if not user["enabled"]:
                raise HTTPException(status_code=401, detail="User is disabled")
            
            # Use user_id as keycloak_id (they're the same now)
            keycloak_id = user["user_id"]
            
            # Generate tokens
            access_token = f"mock_access_token_{secrets.token_urlsafe(32)}"
            refresh_token = f"mock_refresh_token_{secrets.token_urlsafe(32)}"
            
            # Store token in memory
            mock_tokens_db[access_token] = {
                "user_id": keycloak_id,
                "username": user["username"],
                "email": user["email"],
                "expires_at": datetime.now() + timedelta(hours=1)
            }
            
            return {
                "access_token": access_token,
                "expires_in": 3600,
                "refresh_expires_in": 7200,
                "refresh_token": refresh_token,
                "token_type": "Bearer",
                "not-before-policy": 0,
                "session_state": str(uuid.uuid4()),
                "scope": "email profile"
            }
        except Exception as e:
            logger.error(f"Login error: {e}")
            raise HTTPException(status_code=500, detail=str(e))
        finally:
            cursor.close()
            conn.close()
    
    else:
        raise HTTPException(status_code=400, detail=f"Unsupported grant_type: {grant_type}")


@router.post("/admin/realms/binarysuccess/users", status_code=201)
async def create_keycloak_user(user_data: KeycloakUserCreate):
    """Mock Keycloak user creation endpoint (MySQL)"""
    
    conn = get_mysql_connection()
    cursor = conn.cursor()
    
    try:
        # Check if user already exists
        cursor.execute("SELECT 1 FROM mock_users WHERE email = %s", (user_data.email,))
        if cursor.fetchone():
            raise HTTPException(
                status_code=409,
                detail={"errorMessage": "User already exists"}
            )
        
        # Create mock user
        user_id = str(uuid.uuid4())
        password = None
        if user_data.credentials and len(user_data.credentials) > 0:
            password = user_data.credentials[0].get("value")
        
        created_timestamp = int(datetime.now().timestamp() * 1000)
        attributes_json = json.dumps(user_data.attributes or {})
        
        cursor.execute("""
            INSERT INTO mock_users 
            (id, username, email, first_name, last_name, password, enabled, created_at, attributes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            user_id, 
            user_data.username, 
            user_data.email, 
            user_data.firstName, 
            user_data.lastName, 
            password, 
            user_data.enabled, 
            created_timestamp,
            attributes_json
        ))
        
        conn.commit()
        return {}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Create user error: {e}")
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()


@router.get("/admin/realms/binarysuccess/users")
async def get_users(email: Optional[str] = None, username: Optional[str] = None):
    """Mock Keycloak get users endpoint (MySQL)"""
    
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        if email:
            cursor.execute("SELECT * FROM mock_users WHERE email = %s", (email,))
        elif username:
            cursor.execute("SELECT * FROM mock_users WHERE username = %s", (username,))
        else:
            cursor.execute("SELECT * FROM mock_users")
            
        users = cursor.fetchall()
        
        response = []
        for user in users:
            response.append({
                "id": user["id"],
                "username": user["username"],
                "email": user["email"],
                "firstName": user["first_name"],
                "lastName": user["last_name"],
                "enabled": bool(user["enabled"]),
                "createdTimestamp": user["created_at"]
            })
            
        return response
        
    except Exception as e:
        logger.error(f"Get users error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()


@router.get("/admin/realms/binarysuccess/clients/69aa196c-c762-43a4-b198-3d73f46e4317/roles/{role_name}")
async def get_role_details(role_name: str):
    """Mock Keycloak get role details endpoint"""
    
    # Return mock role details
    role_id = str(uuid.uuid4())
    return {
        "id": role_id,
        "name": role_name,
        "description": f"Mock {role_name} role",
        "composite": False,
        "clientRole": True,
        "containerId": "69aa196c-c762-43a4-b198-3d73f46e4317"
    }


@router.post("/admin/realms/binarysuccess/users/{user_id}/role-mappings/clients/{client_id}", status_code=204)
async def update_user_role(user_id: str, client_id: str, roles: List[Dict[str, str]] = Body(...)):
    """Mock Keycloak update user role endpoint (MySQL)"""
    
    conn = get_mysql_connection()
    cursor = conn.cursor()
    
    try:
        # Check if user exists
        cursor.execute("SELECT 1 FROM mock_users WHERE id = %s", (user_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="User not found")
        
        # Insert roles
        for role in roles:
            role_name = role["name"]
            # Use REPLACE to handle duplicates gracefully
            cursor.execute("""
                REPLACE INTO mock_user_roles (user_id, client_id, role_name)
                VALUES (%s, %s, %s)
            """, (user_id, client_id, role_name))
            
        conn.commit()
        return {}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Update role error: {e}")
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()


@router.get("/health")
async def health_check():
    """Health check endpoint"""
    conn = get_mysql_connection()
    cursor = conn.cursor()
    count = 0
    try:
        cursor.execute("SELECT COUNT(*) FROM mock_users")
        count = cursor.fetchone()[0]
    except:
        pass
    finally:
        cursor.close()
        conn.close()
        
    return {
        "status": "healthy",
        "service": "Mock Auth Service (MySQL)",
        "users_count": count
    }


from app.modules.users.schemas import LoginSchema

@router.post("/users/login")
async def mock_login(
    schema: LoginSchema = Body(...)
):
    """Mock login endpoint for local development (MySQL)"""
    import jwt
    from datetime import datetime, timedelta
    
    # Use username from schema (which contains email in Flutter app)
    login_identifier = schema.username
    password = schema.password
    
    if not login_identifier or not password:
        raise HTTPException(status_code=400, detail="Email/username and password required")
    
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute(
            """SELECT user_id, username, email, password, enabled, first_name, last_name, role_id
               FROM BINARY_SUCCESS_PLATFORM_USERS 
               WHERE username = %s OR email = %s""",
            (login_identifier, login_identifier)
        )
        user = cursor.fetchone()
        
        if not user:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        if user["password"] != password:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        if not user["enabled"]:
            raise HTTPException(status_code=401, detail="User is disabled")
        
        # Get user roles from BINARY_SUCCESS_ROLES
        roles = ["learner"]  # Default
        if user.get("role_id"):
            cursor.execute(
                "SELECT role_name FROM BINARY_SUCCESS_ROLES WHERE role_id = %s",
                (user["role_id"],)
            )
            role_row = cursor.fetchone()
            if role_row:
                roles = [role_row["role_name"].lower()]
        
        # Create JWT token with proper claims
        now = datetime.utcnow()
        exp = now + timedelta(hours=1)
        
        token_payload = {
            "exp": int(exp.timestamp()),
            "iat": int(now.timestamp()),
            "sub": user["user_id"],  # Use user_id as keycloak_id
            "email": user["email"],
            "name": f"{user['first_name']} {user['last_name']}",
            "preferred_username": user["username"],
            "realm_access": {
                "roles": roles if roles else ["learner"]  # Default to learner if no roles
            }
        }
        
        # Generate JWT token (using a simple secret for local dev)
        access_token = jwt.encode(token_payload, "local_dev_secret", algorithm="HS256")
        refresh_token = f"mock_refresh_token_{secrets.token_urlsafe(32)}"
        
        # Store token in memory
        mock_tokens_db[access_token] = {
            "user_id": user["user_id"],
            "username": user["username"],
            "email": user["email"],
            "expires_at": exp
        }
        
        return {
            "access_token": access_token,
            "expires_in": 3600,
            "refresh_expires_in": 7200,
            "refresh_token": refresh_token,
            "token_type": "Bearer"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
        cursor.close()
        conn.close()


@router.get("/db/users/get_user_entity_details/{keycloak_id}")
async def get_user_entity_details(keycloak_id: str):
    """Mock endpoint to get user entity details (MySQL)"""
    
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
        
        user_details = cursor.fetchone()
        
        if not user_details:
            return {"items": []}
        
        # Format response to match expected structure
        return {
            "items": [{
                "user_id": user_details["user_id"],
                "role_entity_id": user_details.get("teacher_id") or user_details.get("learner_id"),
                "institute_id": user_details["institute_id"],
                "is_demo_school": user_details.get("is_demo", False),
                "role_display_name": user_details.get("role_name", ""),
                "email": user_details["email"],
                "first_name": user_details["first_name"],
                "last_name": user_details["last_name"]
            }]
        }
        
    except Exception as e:
        logger.error(f"Get user entity details error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()


# ============================================================================
# PLATFORM ADMIN ENDPOINTS
# ============================================================================

@router.get("/admin/platform_admin/get_all_platform_users/")
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

