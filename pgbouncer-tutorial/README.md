# pgbouncer 教學

* [Youtube Tutorial - pgbouncer 教學](https://youtu.be/QWZM5d3pa4Q)

簡易架構圖

![alt tag](https://github.com/twtrubiks/postgresql-note/blob/main/pgbouncer-tutorial/image.png?raw=true)

## 為什麼要使用 pgbouncer

- 提升效能

- 提高連線數, 降低連線成本(建立連線的開銷是很大的)

- 保護資料庫, 提高安全性

## 教學

直接參考 [docker-compose.yml](https://github.com/twtrubiks/postgresql-note/blob/main/pgbouncer-tutorial/docker-compose.yml)

pgbouncer 參數說明 [https://www.pgbouncer.org/config.html](https://www.pgbouncer.org/config.html)

`max_client_conn` 預設為 100

`listen_port` 預設為 6432

`server_idle_timeout` 關閉 idle 連線, 預設為 600 秒

`pool_mode` 有三種模式 `session` `transaction` `statement`

## 透過 pgbench 測試

如果沒有 pgbench 安裝

```cmd
sudo apt install postgresql-contrib
```

沒有 pgbouncer

```cmd
# 先初始化
pgbench --host localhost --port 5432 -U myuser postgres -i

# 接著開始測試
pgbench --host localhost --port 5432 -U myuser -t 20 -c 100 -S -C postgres
```

輸出結果如下

```text
pgbench (14.5 (Ubuntu 14.5-1.pgdg18.04+1), server 13.6 (Debian 13.6-1.pgdg110+1))
starting vacuum...end.
transaction type: <builtin: select only>
scaling factor: 1
query mode: simple
number of clients: 100
number of threads: 1
number of transactions per client: 20
number of transactions actually processed: 2000/2000
latency average = 270.079 ms
average connection time = 2.667 ms
tps = 370.261760 (including reconnection times)
```

有 pgbouncer

```cmd
# 先初始化
pgbench --host localhost --port 6432 -U myuser postgres -i

# 接著開始測試
pgbench --host localhost --port 6432 -U myuser -t 20 -c 100 -S -C postgres
```

輸出結果如下

```text
pgbench (14.5 (Ubuntu 14.5-1.pgdg18.04+1), server 13.6 (Debian 13.6-1.pgdg110+1))
starting vacuum...end.
transaction type: <builtin: select only>
scaling factor: 1
query mode: simple
number of clients: 100
number of threads: 1
number of transactions per client: 20
number of transactions actually processed: 2000/2000
latency average = 56.226 ms
average connection time = 0.536 ms
tps = 1778.539783 (including reconnection times)
```

指令參數說明可使用 `pgbench --help` 查看,

或是參考 [pgbench — 進行 PostgreSQL 效能評估](https://docs.postgresql.tw/reference/client-applications/pgbench),

```text
pgbench [OPTION]... [DBNAME]

-i, --initialize         invokes initialization mode

-c, --client=NUM         number of concurrent database clients (default: 1)
-t, --transactions=NUM   number of transactions each client runs (default: 10)

-S, --select-only        perform SELECT-only transactions
-C, --connect            establish new connection for each transaction
```

從各方面來看, 使用 pgbouncer 好處多多:smile:

(TPS, Transaction Per Second, 愈大當然愈好:smile:)

pgbouncer 也會自動斷開處在 idle 狀態的連線

( pg 預設是不會特別幫你處理這個 )

idle 可簡單理解為 already executed connections/queries.

如果你查看 pgbouncer log, 也會看到類似訊息,

```text
2022-08-15 09:43:48.445 UTC [1] LOG xxxxx: postgres/odoo@172.27.0.2:5432 closing because: server idle timeout (age=600s)
```

但 PostgreSQL 14 有實作類似的功能, 可參考 [idle_session_timeout](https://www.postgresql.org/docs/14/runtime-config-client.html#GUC-IDLE-SESSION-TIMEOUT).

如果你在測試中, 想查看目前連線數, 可使用以下的指令

```sql
SELECT count(*) from pg_stat_activity;
```

參考之前的筆記 [pg_stat_activity](https://github.com/twtrubiks/postgresql-note#pg_stat_activity)

## Reference

* [https://github.com/edoburu/docker-pgbouncer](https://github.com/edoburu/docker-pgbouncer)

* [你當然需要 PgBouncer 啊](https://medium.com/pgsql-tw/you-need-pgbouncer-e62fa329b209)

* [HAProxy as PostgreSQL Connection Pool](https://medium.com/pgsql-tw/%E5%AF%A6%E9%A9%97-haproxy-as-postgresql-connection-pool-812dceb22732)
