from pg_connect import psycopg2, connection


def demo_aviod_sql_injection(username: str) -> bool:
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT login FROM res_users WHERE login = %(username)s;",
            {"username": username},
        )
        # cursor.execute("SELECT login FROM res_users WHERE login = %s;", (username,))
        print(cursor.query.decode("utf-8"))
        result = cursor.fetchall()
    return result if result else False


# print(demo_aviod_sql_injection("admin")) # work

print(demo_aviod_sql_injection("admin' or '1'= '1"))  # avoid sql injection
# -> SELECT login FROM res_users WHERE login = 'admin'' or ''1''= ''1';

print(demo_aviod_sql_injection("' or 1='1"))  # avoid sql injection
# -> SELECT login FROM res_users WHERE login = ''' or 1=''1';

print(demo_aviod_sql_injection("'; drop table res_users --"))  # avoid sql injection
# -> SELECT login FROM res_users WHERE login = '''; drop table res_users --';