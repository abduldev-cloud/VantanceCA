from fastapi import APIRouter, Request
import httpx
from app.core.config import settings
from fastapi import HTTPException

db_router = APIRouter(prefix="/db")

async def proxy_to_db(full_path: str, request: Request):
    if full_path.startswith("fiacon/"):
        base_url = settings.ORACLE_DB_FIACON_URL
        endpoint_path = full_path.removeprefix("fiacon/")
    else:
        base_url = settings.ORACLE_DB_URL
        endpoint_path = full_path

    target_url = f"{base_url.rstrip('/')}/{endpoint_path.lstrip('/')}"
    method = request.method
    headers = dict(request.headers)
    headers.pop("origin", None)
    headers.pop("host", None)

    async with httpx.AsyncClient(timeout=httpx.Timeout(60.0)) as client:
        try:
            response = await client.request(
                method=method,
                url=target_url,
                headers=headers,
                params=dict(request.query_params),
                content=await request.body()
            )
        except httpx.ConnectTimeout:
            raise HTTPException(status_code=504, detail="Database service timeout")
        except httpx.RequestError as e:
            raise HTTPException(status_code=502, detail=f"DB proxy error: {str(e)}")

    return response.json()


@db_router.get("/{full_path:path}")
async def proxy_get(full_path: str, request: Request):
    return await proxy_to_db(full_path, request)

@db_router.post("/{full_path:path}")
async def proxy_post(full_path: str, request: Request):
    return await proxy_to_db(full_path, request)

@db_router.patch("/{full_path:path}")
async def proxy_patch(full_path: str, request: Request):
    return await proxy_to_db(full_path, request)

@db_router.delete("/{full_path:path}")
async def proxy_delete(full_path: str, request: Request):
    return await proxy_to_db(full_path, request)

