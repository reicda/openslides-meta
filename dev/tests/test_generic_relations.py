from datetime import datetime

import pytest
from tests.base import BaseTestCase  # , db_connection


#@pytest.mark.usefixtures("setup_db_connect")
class GenericRelations(BaseTestCase):
    def test_1(self) -> None:
        print("test1 ohne daten")
        assert 0

    def test_2(self) -> None:
        start = datetime.now()
        with self.db_connection.transaction():
            for i in range(100):
                result = self.curs.execute("insert into themeT (name, accent_500, primary_500, warn_500) VALUES (%s, %s, %s, %s)", (f"name{i}", i, i*10, i*100))
        print(f"test2 100 Sätze per Loop: {datetime.now() - start}")
        assert 0

    def test_3(self) -> None:
        print("test3 ohne daten")
        assert 0

