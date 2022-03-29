from db_connect import conn

curs = conn.cursor()
curs.execute("NOTIFY test, 'hello 123';")
