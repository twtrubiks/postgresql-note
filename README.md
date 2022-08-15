# postgresql-note

主要是紀錄一些 Postgresql 的指令📝

( 本篇文章會持續更新:smile: )

先附上 postgresql 的 [docker-compose.yml](docker-compose.yml)

執行,

```cmd
docker-compose up -d
```

先進入 CONTAINER

```cmd
docker exec -it CONTAINER su postgres
```

## 基本操作

`psql` - 連接到 PostgreSQL 的 interactive terminal

```cmd
psql -U username -d dbname
```

`-U` `--username=USERNAME` database user name (default: "postgres")

`-d` `--dbname=DBNAME` database name to connect to (default: "postgres")

如果想要連到遠端的 PostgreSQL

```cmd
psql -h remote_server_ip -p port -U username -d dbname
```

`-h`, `--host=HOSTNAME` database server host or socket directory (default: "localhost")

`-p`, `--port=PORT` database server port (default: "5432")

建立 database

```cmd
createdb dbname -U username -W password
```

`-U` `--username=USERNAME` user name

`-W` `--password` password

匯出 dump.sql

`pg_dump` - dumps a database as a text file or to other formats.

```cmd
pg_dump -U username -d dbname > dump.sql
```

`-U` `--username=NAME` connect as specified database user

`-d` `--dbname=DBNAME` database to dump.

匯出 dump.sql ( 特定 table 的 schema )

```cmd
pg_dump -U username -s -t tablename -d dbname > dump.sql
```

`-t` `--table=PATTERN` dump the specified table(s) only.

`-s` `--schema-only` dump only the schema, no data.

客製化匯出格式

```cmd
pg_dump --no-owner -U username --format=c -d dbname > db.dump
```

也可以寫簡化成下方這樣

```cmd
pg_dump -O -U username -Fc -d dbname > db.dump
```

`-F` `--format=c|d|t|p` output file format (custom, directory, tar, plain text (default))

`-O` `--no-owner` skip restoration of object ownership in plain-text format

還原 dump.sql

```cmd
psql -U username -d dbname < dump.sql
```

`pg_restore` - restore a PostgreSQL database from an archive file created by pg_dump

以下指令為範例, 先建立一個 db, 再用 pg_restore 將 db.dump 還原到 dbname.

```cmd
createdb dbname -U username -W password
pg_restore --no-owner -U username -d dbname db.dump
```

資料庫格式排版

```cmd
\x
```

`\x` [ on | off | auto ]

```text
Sets or toggles expanded table formatting mode. As such it is equivalent to \pset expanded.
```

列出當下資料庫所有的 table

```cmd
\dt
```

描述該 table , 包含 index 以及 FOREIGN KEY.....

```cmd
\d table_name
```

![alt tag](https://i.imgur.com/MFpXXSu.png)

列出所有資料庫名稱

```cmd
\l
```

列出所有 schema

```cmd
\dn
```

列出所有的 views

```cmd
List available views
\dv
```

查詢 PostgreSQL 版本

```cmd
SELECT version();
```

可以使用 `\g` 自動執行前一次的 SELECT 指令.

查詢歷史指令

```cmd
\s
```

如果要顯示 sql 執行時間, 可先執行以下指令再執行 SQL.

```cmd
\timing
```

切換資料庫

```cmd
\c dbname
```

## 依照 Schema 建立 table

Schema 如下

```sql
               Table "public.hr_expense"
  Column  |       Type        | Collation | Nullable |                Default
----------+-------------------+-----------+----------+----------------------------------------
 id       | integer           |           | not null | nextval('hr_expense_id_seq'::regclass)
 name     | character varying |           | not null |
 state    | character varying |           |          |
 sheet_id | integer           |           |          |
Indexes:
    "hr_expense_pkey" PRIMARY KEY, btree (id)
    "hr_expense_state_index" btree (state)
Foreign-key constraints:
    "hr_expense_sheet_id_fkey" FOREIGN KEY (sheet_id) REFERENCES hr_expense_sheet(id) ON DELETE SET NULL


               Table "public.hr_expense_sheet"
 Column |       Type        | Collation | Nullable | Default
--------+-------------------+-----------+----------+---------
 id     | integer           |           | not null |
 name   | character varying |           | not null |
Indexes:
    "hr_expense_sheet_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "hr_expense" CONSTRAINT "hr_expense_sheet_id_fkey" FOREIGN KEY (sheet_id) REFERENCES hr_expense_sheet(id) ON DELETE SET NULL
```

依照 Schema 建立 table

```sql
DROP TABLE IF EXISTS public.hr_expense;
DROP TABLE IF EXISTS public.hr_expense_sheet;

create table public.hr_expense_sheet(
   id integer not null PRIMARY KEY,
   name character varying not null
);

create table public.hr_expense(
   id integer not null,
   name character varying not null,
   state character varying,
   sheet_id  integer,
   PRIMARY KEY (id),
   CONSTRAINT hr_expense_sheet_id_fkey
      FOREIGN KEY(sheet_id)
      REFERENCES public.hr_expense_sheet(id)
      ON DELETE SET NULL
);

CREATE INDEX hr_expense_state_index ON public.hr_expense (state);
CREATE SEQUENCE hr_expense_id_seq OWNED BY hr_expense.id;;
ALTER TABLE hr_expense ALTER COLUMN id SET DEFAULT nextval('hr_expense_id_seq');
```

## 參數說明

`max_connection` 說明可參考 [https://postgresqlco.nf/doc/en/param/max_connections/](https://postgresqlco.nf/doc/en/param/max_connections/)

但通常如果調整這個值, 要搭配 `shared_buffers` 一起修改,

因為每個連線數都會消耗 ram. [參考來源](https://stackoverflow.com/questions/30778015/how-to-increase-the-max-connections-in-postgres?answertab=votes#tab-top)

`shared_buffers` 說明可參考 [https://postgresqlco.nf/doc/en/param/shared_buffers/](https://postgresqlco.nf/doc/en/param/shared_buffers/)

`effective_cache_size` 說明可參考 [https://postgresqlco.nf/doc/en/param/effective_cache_size/](https://postgresqlco.nf/doc/en/param/effective_cache_size/)

推薦一個網站 [https://pgtune.leopard.in.ua](https://pgtune.leopard.in.ua)

可以把你的配置需求填入, 它會幫你算出需要設定的參數.

以下指令可以查看 `postgresql.conf` 設定

查看 max_connections 設定,

```cmd
postgres=# show max_connections;
 max_connections
-----------------
 100
(1 row)
```

查看 listen_addresses 設定,

```cmd
postgres=# show listen_addresses;
 listen_addresses
------------------
 *
(1 row)
```

一次查看全部的設定

```cmd
show all;
```

如果要查詢 `postgresql.conf` 的路徑

```cmd
postgres=# SHOW config_file;
                   config_file
-------------------------------------------------
 /var/lib/postgresql/data/pgdata/postgresql.conf
(1 row)
```

## pg_stat_activity

查看有多少 process, 可以想成目前有多少 user 連線

```sql
SELECT * from pg_stat_activity;
```

查看目前 state 為 idle 的資料,

```sql
SELECT * FROM pg_stat_activity WHERE state='idle';
```

state 說明可參考 [https://www.postgresql.org/docs/9.2/monitoring-stats.html#PG-STAT-ACTIVITY-VIEW](https://www.postgresql.org/docs/9.2/monitoring-stats.html#PG-STAT-ACTIVITY-VIEW),

```text
Current overall state of this backend. Possible values are:
active: The backend is executing a query.

idle: The backend is waiting for a new client command.

idle in transaction: The backend is in a transaction, but is not currently executing a query.

idle in transaction (aborted): This state is similar to idle in transaction, except one of the statements in the transaction caused an error.

fastpath function call: The backend is executing a fast-path function.

disabled: This state is reported if track_activities is disabled in this backend.
```

當 `idle` 很多的時候, 不需要太擔心, 除非連線數真著很多, 吃掉你太多的 ram. [參考來源](https://dba.stackexchange.com/questions/202006/what-does-idle-state-denotes-in-a-row-of-pg-stat-activity?answertab=active#tab-top)

## 其他

以下這個指令幫你找出最大 size 的前 20 個 table

```sql
SELECT nspname
       || '.'
       || relname                                    AS "relation",
       Pg_size_pretty(Pg_total_relation_size(C.oid)) AS "total_size"
FROM   pg_class C
       LEFT JOIN pg_namespace N
              ON ( N.oid = C.relnamespace )
WHERE  nspname NOT IN ( 'pg_catalog', 'information_schema' )
       AND C.relkind <> 'i'
       AND nspname !~ '^pg_toast'
ORDER  BY Pg_total_relation_size(C.oid) DESC
LIMIT  20;
```

一些範例以及教學的 SQL 放在 [example.sql](https://github.com/twtrubiks/postgresql-note/blob/main/example.sql) 中.

## 延伸閱讀

* [pg-listen-notify](https://github.com/twtrubiks/postgresql-note/tree/main/pg-listen-notify) - 介紹 postgresql 中的 LISTEN/NOTIFY

* [pg-master-slave](https://github.com/twtrubiks/postgresql-note/tree/main/pg-master-slave) - 介紹 postgresql 中的 master-slave 架構
