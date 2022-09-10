import pytest
import psycopg2
from psycopg2 import sql

# pytest avoid_sql_injection_test.py -v -s


@pytest.fixture
def connection():
    connection = psycopg2.connect(
        host="localhost",
        database="<your database>",
        user="<your user>",
        password="<your password>",
    )
    connection.set_session(autocommit=True)
    return connection


class Test_Avoid_SQL_injection:
    def test_case1(self, connection):
        username = "admin"
        query = sql.SQL("SELECT login FROM res_users WHERE login = {username};").format(
            username=sql.Identifier(username)
        )
        result = query.as_string(connection)
        expect = 'SELECT login FROM res_users WHERE login = "admin";'
        assert result == expect

    def test_case1_sql_injection_1(self, connection):
        username = "' or 1='1"
        query = sql.SQL("SELECT login FROM res_users WHERE login = {username};").format(
            username=sql.Identifier(username)
        )
        result = query.as_string(connection)
        expect = "SELECT login FROM res_users WHERE login = \"' or 1='1\";"
        assert result == expect

    def test_case1_sql_injection_2(self, connection):
        username = "'; drop table res_users --"
        query = sql.SQL("SELECT login FROM res_users WHERE login = {username};").format(
            username=sql.Identifier(username)
        )
        result = query.as_string(connection)
        expect = (
            'SELECT login FROM res_users WHERE login = "\'; drop table res_users --";'
        )
        assert result == expect

    def test_case2(self, connection):
        table_name = "res_users"
        query = sql.SQL("SELECT count(*) FROM {table_name};").format(
            table_name=sql.Identifier(table_name)
        )
        result = query.as_string(connection)
        expect = 'SELECT count(*) FROM "res_users";'
        assert result == expect

    def test_case3(self, connection):
        table_name = "res_users"
        query = sql.SQL("SELECT count(*) FROM {table_name} where {pkey} = %s;").format(
            table_name=sql.Identifier(table_name),
            pkey=sql.Identifier("id"),
        )
        result = query.as_string(connection)
        expect = 'SELECT count(*) FROM "res_users" where "id" = %s;'
        assert result == expect

    def test_case4(self, connection):
        table_name = "res_users"
        query = sql.SQL(
            "SELECT count(*) FROM {table_name} as e where {pkey} = %s;"
        ).format(
            table_name=sql.Identifier(table_name),
            pkey=sql.Identifier("e", "id"),
        )
        result = query.as_string(connection)
        expect = 'SELECT count(*) FROM "res_users" as e where "e"."id" = %s;'
        assert result == expect


if __name__ == "__main__":
    pytest.main()
