# Postgresql LISTEN/NOTIFY

* [Youtube Tutorial - Postgresql 教學 LISTEN/NOTIFY](https://youtu.be/UIVMGMD6HT0)

簡單說, 這就像是你訂閱(LISTEN)了一個頻道, 當這個頻道發佈(NOTIFY)的時候,

你訂閱的頻道就會收到通知.

## 介紹 postgresql 中的 LISTEN/NOTIFY

先啟動 postgresql

直接執行 `docker-compose up -d`

接著進入 postgresql 容器內

```cmd
docker exec -it {container id} su postgres
```

進入 psql

```cmd
psql -U demo -d postgres
```

用兩個 session 來測試,

第一個 session, 監聽 LISTEN 這個 channel

```sql
LISTEN demo;
```

![alt tag](https://i.imgur.com/k21aHEz.png)

第二個 session, 向 demo 這個 channel 發送 (NOTIFY) 通知

```sql
NOTIFY demo, 'hello';
```

![alt tag](https://i.imgur.com/QMeLGkT.png)

之後再回到第一個 session 隨便輸入一個指令,

你就會發現你收到通知了.

# Python 搭配 postgresql 中的 LISTEN/NOTIFY

先安裝 requirements.txt

```cmd
pip3 install -r requirements.txt
```

執行 `python3 listen.py`

```cmd
Waiting for notifications on channel 'test'
Timeout
```

持續監聽 LISTEN `test` 這個 channel.

再開啟另一個 terminal 執行 `python3 notify.py`,

你會發現剛剛前面的 `listen.py` terminal 有接收到訊息

```cmd
Waiting for notifications on channel 'test'
Timeout
Got NOTIFY: 38 test hello 123
Timeout
```

以上整個流程是透過 Asynchronous notifications 完成的,

相關文件可參考 [https://www.psycopg.org/docs/advanced.html#asynchronous-notifications](https://www.psycopg.org/docs/advanced.html#asynchronous-notifications)

## 透過 asyncio 進行改良

前面的範例是透過 [select](https://docs.python.org/3/library/select.html) 這個 library 來完成 asynchronous,

但現在 python3 已經有了 asyncio,

所以我們來改造一下,

```python
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
```

這樣子就成功改造完畢 (使用 `asyncio` 取代 `select`).

## 執行環境

* Python 3.8.12