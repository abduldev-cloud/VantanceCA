# app/modules/users/routes.py

from fastapi import APIRouter, HTTPException, Body, Form
from .schemas import AcceptInviteGoogleSchema, AcceptInviteSchema, CreateUserInviteSchema, CreateKeycloakUserSchema, \
    LoginSchema, UpdateUserStatusSchema
from .services import UsersService

router = APIRouter(prefix="/users", tags=["Users"])

users_service = UsersService()

@router.post("/", )
async def create_user(schema: CreateKeycloakUserSchema):
    try:
        return await users_service.create_user(schema)
    except HTTPException as e:
        raise e
    
@router.post("/invite-user")
async def invite_user(schema:CreateUserInviteSchema = Body(...)):
    try:
        return await users_service.invite_user(schema)
    except HTTPException as e:
        raise e

@router.get("/invite/{invite_code}")
async def get_invite_by_code(invite_code: str):
    try:
        return await users_service.get_invite_by_code(invite_code)
    except HTTPException as e:
        raise e

#accept invite
@router.post("/accept-invite/{invite_code}")
async def accept_invite(invite_code: str, schema: AcceptInviteSchema = Body(...)):
    try:
        return await users_service.accept_invite(schema, invite_code)
    except HTTPException as e:
        raise e

#accept invite from google login
@router.post("/accept-invite-google/{invite_code}")
async def accept_invite_google(invite_code: str, schema: AcceptInviteGoogleSchema = Body(...)):
    try:
        return await users_service.accept_invite_google(schema, invite_code)
    except HTTPException as e:
        raise e
@router.post("/login",)
async def login_user(schema: LoginSchema = Body(...)):
    try:
        return await users_service.login_user(schema.username, schema.password)
    except HTTPException as e:
        raise e
    
@router.post("/refresh-token")
async def refresh_token(refresh_token: str = Form(...)):
    try:
        return await users_service.refresh_token(refresh_token)
    except HTTPException as e:
        raise e

@router.post("/google-login")
async def google_login(token: str = Form(...)):
    try:
        return await users_service.login_user_with_google(token)
    except HTTPException as e:
        raise e

@router.post("/logout")
async def logout_user(refresh_token: str = Form(...)):
    try:
        return await users_service.logout_user(refresh_token)
    except HTTPException as e:
        raise e
    
@router.post("/impersonate/{username}")
async def impersonate_user(username: str):
    try:
        return await users_service.impersonate_user(username)
    except HTTPException as e:
        raise e
    
@router.post("/change-password")
async def change_password(email: str = Form(...), new_password: str = Form(...)):
    try:
        return await users_service.change_password(email, new_password)
    except HTTPException as e:
        raise e
    
@router.post("/forgot-password")
async def forgot_password(email: str = Form(...)):
    try:
        return await users_service.forgot_password(email)
    except HTTPException as e:
        raise e
    
@router.get("/forgot-password/{token}")
async def get_forgot_password_token(token: str):
    try:
        return await users_service.get_forgot_password_token(token)
    except HTTPException as e:
        raise e
    
#reset password
@router.post("/reset-password")
async def reset_password(token: str = Form(...), new_password: str = Form(...)):
    try:
        return await users_service.reset_password(token, new_password)
    except HTTPException as e:
        raise e

#update user status
@router.post("/update-user-status")
async def update_user_status(schema: UpdateUserStatusSchema = Body(...)):
    try:
        if schema.status.upper() not in ("INACTIVE", "ACTIVE", "ARCHIVED"):
            raise HTTPException(status_code=400, detail="Invalid status")
        await users_service.update_user_status(schema)
        return {"message": "User successfully updated in Keycloak and Binary Success."}
    except HTTPException as e:
        raise e