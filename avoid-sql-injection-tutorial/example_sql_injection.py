from pg_connect import psycopg2, connection


def demo_sql_injection(username: str) -> bool:
    with connection.cursor() as cursor:
        cursor.execute("SELECT login FROM res_users WHERE login = '%s';" % username)
        result = cursor.fetchall()
        print(cursor.query.decode("utf-8"))
    return result if result else False


print(demo_sql_injection("admin"))  # work

# print(demo_sql_injection("admin' or '1'= '1")    )      # sql_injection
# -> SELECT login FROM res_users WHERE login = 'admin' or '1'= '1';

# print(demo_sql_injection("' or 1='1")            )      # sql_injection
# -> SELECT login FROM res_users WHERE login = '' or 1='1';

# print(demo_sql_injection("'; drop table res_users --")) # sql_injection
# -> SELECT login FROM res_users WHERE login = ''; drop table res_users --';

# '   代表關閉內容
# ;   代表關閉符號
# --  代表 sql 的註解 (忽略之後的內容)


"""
都會有 sql_injection 問題
cursor.execute("SELET * FROM res_users WHERE login = " + username + ";")
cursor.execute("SELECT * FROM res_users WHERE login = '%s';" % username)
cursor.execute("SELECT * FROM res_users WHERE login = '{}';".format(username))
cursor.execute(f"SELECT * FROM res_users WHERE login = '{username}';")
"""
