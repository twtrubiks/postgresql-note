from pg_connect import psycopg2, connection

def conut_rows_error(table_name: str) -> int:
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT count(*) FROM %(table_name)s;", {"table_name": table_name}
        )
        print(cursor.query.decode("utf-8"))
        result = cursor.fetchall()
        return result if result else False


def conut_rows_fix(table_name: str) -> int:
    from psycopg2 import sql

    with connection.cursor() as cursor:
        query = sql.SQL("SELECT count(*) FROM {table_name};").format(
            table_name=sql.Identifier(table_name)
        )

        print(query.as_string(cursor))
        # -> SELECT count(*) FROM "res_users";

        cursor.execute(query)
        result = cursor.fetchall()
        return result if result else False


def conut_rows_as(table_name: str) -> int:
    from psycopg2 import sql

    with connection.cursor() as cursor:
        query = sql.SQL(
            "SELECT count(*) FROM {table_name} as e where {pkey} = %s;"
        ).format(
            table_name=sql.Identifier(table_name),
            pkey=sql.Identifier("e", "id"),
        )
        print(query.as_string(cursor))
        # -> SELECT count(*) FROM "res_users" as e where "e"."id" = %s;

        cursor.execute(query, (1,))
        result = cursor.fetchall()
        return result if result else False

print(conut_rows_error("res_users"))
# print(conut_rows_fix("res_users"))
# print(conut_rows_as("res_users"))
