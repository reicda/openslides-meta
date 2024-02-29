from datetime import datetime

import pytest
from tests.base import BaseTestCase  # , db_connection


class GenericRelations(BaseTestCase):
    def test_2(self) -> None:
        start = datetime.now()
        with self.db_connection.transaction():
            with self.db_connection.cursor() as curs:
                for i in range(100):
                    curs.execute("insert into themeT (name, accent_500, primary_500, warn_500) VALUES (%s, %s, %s, %s)", (f"name{i}", i, i*10, i*100))
        print(f"test2 100 Sätze per Loop: {datetime.now() - start}")

