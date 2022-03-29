import asyncio
from db_connect import conn

curs = conn.cursor()
curs.execute("LISTEN test;")

def handle_notify():
    conn.poll()
    while conn.notifies:
        notify = conn.notifies.pop(0)
        print("Got NOTIFY:", notify.pid, notify.channel, notify.payload)

loop = asyncio.get_event_loop()
loop.add_reader(conn, handle_notify)
loop.run_forever()

print("Waiting for notifications on channel 'test'")