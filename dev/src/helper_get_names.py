from typing import Any

KEYSEPARATOR = "/"


class TableFieldType:
    def __init__(
        self,
        table: str,
        column: str,
        field_def: dict[str, Any] | None,
        ref_column: str = "id",
    ):
        self.table = table
        self.column = column
        self.field_def: dict[str, Any] = field_def or {}
        self.ref_column = ref_column

    @property
    def collectionfield(self) -> str:
        if self.table:
            return f"{self.table}{KEYSEPARATOR}{self.column}"
        else:
            return "-"


class HelperGetNames:
    MAX_LEN = 63

    def max_length(func) -> str:
        def wrapper(*args, **kwargs):
            name = func(*args, **kwargs)
            assert (
                len(name) <= HelperGetNames.MAX_LEN
            ), f"Generated name '{name}' to long in function {func}!"
            return name

        return wrapper

    @staticmethod
    @max_length
    def get_table_name(table_name: str) -> str:
        return table_name + "T"

    @staticmethod
    @max_length
    def get_view_name(table_name: str) -> str:
        if table_name in ("group", "user"):
            return table_name + "_"
        return table_name

    @staticmethod
    @max_length
    def get_nm_table_name(own: TableFieldType, foreign: TableFieldType) -> str:
        """table name n:m-relations intermediate table"""
        if (own_str := f"{own.table}_{own.column}") < (
            foreign_str := f"{foreign.table}_{foreign.column}"
        ):
            return f"nm_{own_str}_{foreign.table}"
        else:
            return f"nm_{foreign_str}_{own.table}"

    @staticmethod
    @max_length
    def get_gm_table_name(table_field: TableFieldType) -> str:
        """table name generic-list:m-relations intermediate table"""
        return f"gm_{table_field.table}_{table_field.column}"
