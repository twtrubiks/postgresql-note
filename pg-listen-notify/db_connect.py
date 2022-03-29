import psycopg2
import psycopg2.extensions

conn = psycopg2.connect(
    dbname="postgres",
    user="demo",
    password="demo",
    port="5432",
    host="localhost"
)

# https://www.psycopg.org/docs/extensions.html#psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT
# 執行指令不需要再執行 commit
conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
