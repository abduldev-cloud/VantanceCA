from fastapi import APIRouter, HTTPException, Body, Request
from .schemas import CreateClassesSchema
from .services import ClassesService

router = APIRouter(prefix="/classes", tags=["Classes"])
classes_service = ClassesService()

@router.post("/")
async def create_classes(schema: CreateClassesSchema = Body(...)):
    try:
        return await classes_service.create_classes(schema)
    except HTTPException as e:
        raise e