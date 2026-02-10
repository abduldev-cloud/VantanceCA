import oracledb
from app.core.config import settings


wallet_path = settings.ORACLE_WALLET_PATH
if not wallet_path:
    raise RuntimeError("❌ ORACLE_WALLET_PATH environment variable is not set")

pool = oracledb.create_pool(
    user=settings.ORACLE_USER,
    password=settings.ORACLE_PASSWORD,
    dsn=settings.ORACLE_DSN,  
    config_dir=wallet_path,
    min=2,
    max=10,
    increment=1,
    getmode=oracledb.SPOOL_ATTRVAL_NOWAIT  # optional: avoid blocking when exhausted
)

def get_oracle_connection():
    return pool.acquire()
