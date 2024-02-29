from typing import Any

from psycopg import Cursor, sql


class DbUtils:
    @classmethod
    def insert_wrapper(cls, curs: Cursor, table_name: str, data: dict[str, Any]) -> int:
        query = f"INSERT INTO {table_name} ({', '.join(data.keys())}) VALUES({{}}) RETURNING id;"
        query = (
            sql.SQL(query)
            .format(
                sql.SQL(", ").join(sql.Placeholder() * len(data.keys())),
            )
            .as_string(curs)
        )
        return curs.execute(query, tuple(data.values())).fetchone()["id"]

    @classmethod
    def insert_many_wrapper(
        cls, curs: Cursor, table_name: str, data_list: list[dict[str, Any]]
    ) -> list[int]:
        ids: list[int] = []
        if not data_list:
            return ids
        # use all keys in same sequence
        keys = set()
        for data in data_list:
            keys.update(data.keys())
        keys = sorted(keys)
        temp_data = {k: None for k in keys}

        dates = [temp_data | data for data in data_list]
        query = (
            f"INSERT INTO {table_name} ({', '.join(keys)}) VALUES({{}}) RETURNING id;"
        )
        query = (
            sql.SQL(query)
            .format(
                sql.SQL(", ").join(sql.Placeholder() * len(keys)),
            )
            .as_string(curs)
        )
        curs.executemany(
            query,
            tuple(tuple(v for _, v in sorted(data.items())) for data in dates),
            returning=True,
        )
        ids = []
        while True:
            ids.append(curs.fetchone()["id"])
            if not curs.nextset():
                break
        return ids
