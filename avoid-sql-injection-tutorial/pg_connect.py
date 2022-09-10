"""
https://www.psycopg.org/docs/sql.html#module-psycopg2.sql
2.9.3
"""

import psycopg2

connection = psycopg2.connect(
    host="localhost",
    database="<your database>",
    user="<your user>",
    password="<your password>",
)
connection.set_session(autocommit=True)
