from numpy import where
from app.common.crud_base import CRUDBase


class CRUDHelper:
    def __init__(self):
        self.crud = CRUDBase()

    def create(self, table: str, data: dict, auto_commit=True):
        columns = ", ".join(data.keys())
        placeholders = ", ".join([f":{k}" for k in data.keys()])
        query = f"INSERT INTO {table} ({columns}) VALUES ({placeholders})"
        return self.crud.execute(query, data, auto_commit)

    def update(self, table: str, data: dict, where: dict, auto_commit=True):
        set_parts = []
        params = {}

        for k, v in data.items():
            if isinstance(v, str) and v.upper() in ["CURRENT_TIMESTAMP", "SYSDATE"]:
                set_parts.append(f"{k} = {v}") # Oracle function, so no need binding param
            else:
                set_parts.append(f"{k} = :set_{k}")
                params[f"set_{k}"] = v

        where_clauses = []
        for k, v in where.items():
            if isinstance(v, dict) and "$in" in v:
                placeholders = [f":where_{k}_{i}" for i in range(len(v["$in"]))]
                where_clauses.append(f"{k} IN ({', '.join(placeholders)})")
                params.update({f"where_{k}_{i}": val for i, val in enumerate(v["$in"])})
            else:
                where_clauses.append(f"{k} = :where_{k}")
                params[f"where_{k}"] = v

        query = f"UPDATE {table} SET {', '.join(set_parts)} WHERE {' AND '.join(where_clauses)}"
        return self.crud.execute(query, params, auto_commit)

    def delete(self, table: str, where: dict, auto_commit=True):
        where_clause = " AND ".join([f"{k} = :{k}" for k in where.keys()])
        query = f"DELETE FROM {table} WHERE {where_clause}"
        return self.crud.execute(query, where, auto_commit)

    def select_one(self, table: str, where: dict, columns: list = None):
        cols = ", ".join(columns) if columns else "*"
        where_clause = " AND ".join([f"{k} = :{k}" for k in where.keys()])
        query = f"SELECT {cols} FROM {table} WHERE {where_clause}"
        return self.crud.fetch_one(query, where)

    def select_all(self, table: str, where: dict = None, columns: list = None,
                order_by: str = None, limit: int = None, offset: int = None):
        cols = ", ".join(columns) if columns else "*"
        query = f"SELECT {cols} FROM {table}"
        params = {}

        if where:
            clauses = []
            for k, v in where.items():
                if isinstance(v, dict) and "$in" in v:
                    # Flatten any tuples inside the list
                    values = [val[0] if isinstance(val, tuple) else val for val in v["$in"]]
                    placeholders = ", ".join([f":{k}_{i}" for i in range(len(values))])
                    clauses.append(f"{k} IN ({placeholders})")
                    for i, val in enumerate(values):
                        params[f"{k}_{i}"] = val
                else:
                    clauses.append(f"{k} = :{k}")
                    params[k] = v

            query += " WHERE " + " AND ".join(clauses)

        if order_by:
            query += f" ORDER BY {order_by}"
        if limit is not None:
            query += f" OFFSET {offset or 0} ROWS FETCH NEXT {limit} ROWS ONLY"

        return self.crud.fetch_all(query, params)
