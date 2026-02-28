from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.api.router import router as api_router
from app.core.logger import logger
from app.core.config import settings   # <-- now includes CRM, Alfresco, etc.
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

# Create uploads directory if it doesn't exist
if not os.path.exists("uploads"):
    os.makedirs("uploads")

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🚀 Orchestration API is starting up...")
    logger.info(f"🌍 Environment: {settings.APP_ENV}")
    yield
    logger.error("🛑 Orchestration API is shutting down...")

app = FastAPI(
    title="VantanceCA Orchestration API",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  #! Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all routers
app.include_router(api_router)

# Mount uploads for static files
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
