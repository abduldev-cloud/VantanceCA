from fastapi import APIRouter
from app.modules.keycloak.services import KeycloakService
from app.modules.users.routes import router as users_router
from app.modules.classes.routes import router as classes_router
from app.modules.schools.routes import router as schools_router
from app.modules.evaluator.routes import router as evaluator_router
from app.modules.health.routes import router as health_router
from app.modules.sageai.routes import router as sageai_routes
from app.modules.killbill.routes import router as killbill_router
from app.modules.alfresco.routes import router as alfresco_router
# from app.common.db_router import db_router  # OLD: Oracle proxy
from app.modules.db_mock.routes import router as db_mock_router  # NEW: MySQL mock
from app.modules.data_sync.routes import router as sync_router
from app.modules.bulk_upload.routes import router as bulk_upload_router
from app.modules.notification.routes import router as notification_router
from app.modules.crm.routes import router as crm_router
from app.modules.analytics.routes import router as analytics_router
from app.modules.ai.routes import router as ai_router
from app.modules.faq.routes import router as faq_router
from app.modules.auth_mock.routes import router as auth_mock_router
from datetime import datetime, timezone

router = APIRouter()

@router.get("/", tags=["Home"])
def home():
    return {"message": "Welcome to Binary Success Orchestration API"}

@router.get("/test", tags=["Test"])
async def test():
    return await KeycloakService().add_user_to_group('80cb6ed5-a1cc-43ec-97f9-20cb86866834','3D016881AF55D071E063DF63000AD4FD')

@router.get("/timestamp", tags=["Utility"])
def get_current_timestamp():
    """Return the current UTC timestamp."""
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "epoch": int(datetime.now(timezone.utc).timestamp())
    }

routers = [
    auth_mock_router,  # Mock auth endpoints for local dev (must be first to override)
    db_mock_router,    # NEW: Mock database endpoints (replaces db_router)
    health_router,
    users_router,
    classes_router,
    schools_router,
    evaluator_router,
    sageai_routes,
    killbill_router,
    alfresco_router,
    # db_router,  # OLD: Removed Oracle proxy
    sync_router,
    bulk_upload_router,
    notification_router,
    crm_router,
    analytics_router,
    ai_router,
    faq_router
]

for r in routers:
    router.include_router(r)
