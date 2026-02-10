from app.core.context_manager import oracle_session
from app.core.logger import logger
from app.core.exceptions import DatabaseException

class CRUDBase:
    def fetch_all(self, query: str, params=()):
        try:
            with oracle_session() as cursor:
                cursor.execute(query, params)
                columns = [col[0].lower() for col in cursor.description]
                return [dict(zip(columns, row)) for row in cursor.fetchall()]
        except Exception as e:
            logger.exception(f"❌ fetch_all failed: {query} | params: {params}")
            raise DatabaseException("Database fetch_all failed", e)

    def fetch_one(self, query: str, params=()):
        try:
            with oracle_session() as cursor:
                cursor.execute(query, params)
                row = cursor.fetchone()
                if row:
                    columns = [col[0].lower() for col in cursor.description]
                    return dict(zip(columns, row))
                return None
        except Exception as e:
            logger.exception(f"❌ fetch_one failed: {query} | params: {params}")
            raise DatabaseException("Database fetch_one failed", e)

    def execute(self, query: str, params=(), auto_commit=True):
        try:
            with oracle_session(auto_commit=auto_commit) as cursor:
                cursor.execute(query, params)
                return cursor.rowcount  
        except Exception as e:
            logger.exception(f"❌ execute failed: {query} | params: {params}")
            raise DatabaseException("Database execute failed", e)

    def bulk_insert(self, query: str, param_list: list):
        try:
            with oracle_session() as cursor:
                cursor.executemany(query, param_list)
                return cursor.rowcount
        except Exception as e:
            logger.exception(f"❌ bulk_insert failed: {query} | data count: {len(param_list)}")
            raise DatabaseException("Database bulk_insert failed", e)

    def insert_and_return_id(self, query: str, params: dict, returning_col: str):
        try:
            with oracle_session(auto_commit=True) as cursor:
                out_var = cursor.var(str)  # create the OUT variable
                bind_params = {**params, "out_id": out_var}  # combine input params
                cursor.execute(f"{query} RETURNING {returning_col} INTO :out_id", bind_params)

                value = out_var.getvalue()[0] if out_var.getvalue() else None
                return {returning_col.lower(): value}
        except Exception as e:
            logger.exception(f"❌ insert_and_return_id failed: {query} | params: {params}")
            raise DatabaseException("Database insert_and_return_id failed", e)

    def call_procedure(self, sp_name: str, in_params: dict, out_params: dict = None) -> dict:
        try:
            with oracle_session(auto_commit=True) as cursor:
                # Prepare OUT bind variables
                binds = {**in_params}
                if out_params:
                    for key, typ in out_params.items():
                        binds[key] = cursor.var(typ)

                # Build PL/SQL block dynamically
                in_bind_str = ", ".join(f":{k}" for k in in_params.keys())
                out_bind_str = ", ".join(f":{k}" for k in (out_params or {}).keys())
                all_bind_str = ", ".join(filter(None, [in_bind_str, out_bind_str]))

                plsql = f"BEGIN {sp_name}({all_bind_str}); END;"

                # Execute
                cursor.execute(plsql, binds)

                # Extract OUT values
                result = {k: binds[k].getvalue() for k in (out_params or {}).keys()}
                return result

        except Exception as e:
            logger.exception(f"❌ call_proc failed: {sp_name} | in_params: {in_params}")
            raise DatabaseException(f"Procedure {sp_name} failed", e)
