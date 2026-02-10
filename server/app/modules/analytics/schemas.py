from pydantic import BaseModel
from typing import Dict, List, Any, Optional
from datetime import datetime


class RoleInfo(BaseModel):
    """Schema for role information"""
    role_id: str
    role_name: str
    role_description: Optional[str] = None


class UserCountsByRole(BaseModel):
    """Schema for user counts by role"""
    role_name: str
    user_count: int


class PlatformAdminUserCountsData(BaseModel):
    """Schema for platform admin user counts data"""
    total_schools: int
    total_users: int
    total_students: int
    total_teachers: int
    user_counts_by_role: Dict[str, int]
    all_roles: List[Dict[str, Any]]


class PlatformAdminUserCountsResponse(BaseModel):
    """Schema for platform admin user counts response"""
    success: bool
    data: PlatformAdminUserCountsData
    message: str
    timestamp: str
    source: str
    user_id: str
    user_email: str
    request_duration_seconds: float


class SupportTicketValue(BaseModel):
    """Schema for support ticket value"""
    name: str
    value: str


class SupportTicketRecord(BaseModel):
    """Schema for support ticket record"""
    recordID: str
    moduleID: str
    revision: int
    values: List[SupportTicketValue]
    namespaceID: str
    ownedBy: str
    createdAt: str
    createdBy: str
    updatedAt: str
    updatedBy: str
    valueErrors: Optional[Any] = None
    canManageOwnerOnRecord: bool
    canUpdateRecord: bool
    canReadRecord: bool
    canDeleteRecord: bool
    canUndeleteRecord: bool
    canSearchRevisions: bool
    canGrant: bool


class SupportTicketFilter(BaseModel):
    """Schema for support ticket filter"""
    moduleID: str
    namespaceID: str
    query: str
    deleted: int
    sort: str
    limit: int


class SupportTicketData(BaseModel):
    """Schema for support ticket data"""
    filter: SupportTicketFilter
    set: List[SupportTicketRecord]


class SupportTicketsResponse(BaseModel):
    """Schema for support tickets response"""
    success: bool
    data: SupportTicketData
    message: str
    timestamp: str
    source: str
    user_id: str
    user_email: str

class TeacherLearnersRequest(BaseModel):
    teacher_id: str
    row_count: int = 5