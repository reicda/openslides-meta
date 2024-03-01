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
        cls,
        curs: Cursor,
        table_name: str,
        data_list: list[dict[str, Any]],
        returning: str = "id",
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
        query = f"INSERT INTO {table_name} ({', '.join(keys)}) VALUES({{}}){' RETURNING ' + returning if returning else ''};"
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
            returning=bool(returning),
        )
        ids = []
        if returning:
            while True:
                ids.append(curs.fetchone()[returning])
                if not curs.nextset():
                    break
        return ids

    @classmethod
    def select_id_wrapper(
        cls,
        curs: Cursor,
        table_name: str,
        id_: int | None = None,
        field_names: list[str] = [],
    ) -> dict[str, Any] | list[dict[str, Any]]:
        """select with single id or all for fields in list or all fields"""
        query = sql.SQL(
            f"SELECT {', '.join(field_names) if field_names else '*'} FROM {table_name}{' where id = %s' if id_ else ''}"
        )
        if id_:
            return curs.execute(query, (id_,)).fetchone()
        else:
            return curs.execute(query).fetchall()
