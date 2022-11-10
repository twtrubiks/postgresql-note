# Postgresql Lock 以及 Transactions

文件說明 [explicit-locking](https://docs.postgresql.tw/the-sql-language/concurrency-control/explicit-locking)

- 目錄連結

- [Transactions](https://github.com/twtrubiks/postgresql-note/tree/main/pg-lock-tutorial#transactions)

- [FOR UPDATE](https://github.com/twtrubiks/postgresql-note/tree/main/pg-lock-tutorial#for-update)

- [DeadLock](https://github.com/twtrubiks/postgresql-note/tree/main/pg-lock-tutorial#deadlock)

# 說明

Postgresql 提供了以下三種的 lock 分別是

- Table-level Locks -> 表鎖

- Row-level Locks -> 行鎖

- Page-level Locks

然後還有幾個名詞,

Exclusive Locks - 排它鎖(互斥鎖)

如果資料加上排它鎖，則其他的事務不能對它讀取和修改

Share Locks - 共享鎖

如果資料加上共享鎖，則該物件可以被其他事務讀取，但不能修改

更多的 Lock Modes 細節可參考 [Databases-Practical PostgreSQL](https://www.linuxtopia.org/online_books/database_guides/Practical_PostgreSQL_database/PostgreSQL_r27479.htm)

## 測試前請關閉 autocommit

使用 [pgadmin4](https://github.com/twtrubiks/docker-pgadmin4-tutorial#docker-pgadmin4-tutorial) 測試, 測試前要關閉 autocommit,

關閉的地方在,

File -> Preferences -> Query tool -> Options -> Auto commit

![alt tag](https://i.imgur.com/eBc2zch.png)

## Transactions

正式介紹前, 先來了解一下什麼是 Transactions:smile:

Transactions 有幾個指令,

`begin` 開啟 transactions.

`commit` 提交這個 transactions, 資料庫真正被修改.

`rollback` 還原 transactions (未保存到資料庫).

```sql
begin;

-- 查看資料
select * from hr_expense where id = 1;

-- 更新資料
UPDATE hr_expense SET name = 'new_name' WHERE id = 1;

-- 再次查看資料, 有更新, name 為 new_name (未保存到資料庫)
select * from hr_expense where id = 1;

rollback;

-- 再次查看資料, 發現 name 已被還原, 因為前面執行了 rollback
select * from hr_expense where id = 1;

-- 提交這個 transaction, 將資料庫真正修改資料.
commit;
```

## FOR UPDATE

在第一個 session 執行以下 sql,

對 `id=1` 這筆 row 進行了 lock,

```sql
SELECT * FROM res_users where id=1 for update;
```

正常撈出資料.

然後不要 commit,

再到第二個 session 執行以下 sql

```sql
SELECT * FROM res_users where id=1 for update;
```

你會發現你一直在等待且無法跑出結果

( 因為目前該 row 被第一個 session lock, 要一直等待 lock 被釋放 ),

回到第一個 session, 並且 commit.

這樣你的第二個 session 就會正常顯示了,

也請記得在第二個 session 上執行 commit.

### FOR UPDATE NOWAIT

加上 NOWAIT 後, 如果取不到鎖, 不會一直持續等待,

而是會直接跳出錯誤.

在第一個 session 執行以下 sql,

對 `id=1` 這筆 row 進行了 lock,

```sql
SELECT * FROM res_users where id=1 for update NOWAIT;
```

正常撈出資料.

然後不要 commit,

再到第二個 session 執行以下 sql

```sql
SELECT * FROM res_users where id=1 for update NOWAIT;
```

這次你會發現直接拋出一個 55P03 的錯誤.

```cmd
ERROR:  could not obtain lock on row in relation "res_users"
SQL state: 55P03
```

( 因為目前該 row 被第一個 session lock ),

回到第一個 session, 並且 commit.

再回到第二個 session, 並且 commit. (先結束這個 transaction)

之後再重新執行, 就可以正常取得資料了.

### FOR UPDATE SKIP LOCKED

除了等待和跳出錯誤之外, 還有一種是跳過被 lock 的資料.

在第一個 session 執行以下 sql,

對 `id=1` 這筆 row 進行了 lock,

```sql
SELECT * FROM res_users where id=1 for update SKIP LOCKED;
```

正常撈出資料.

然後不要 commit,

再到第二個 session 執行以下 sql

```sql
SELECT * FROM res_users where id=1 for update SKIP LOCKED;
```

這次你會發現不用等待也不會跳出錯誤,

但是沒有撈出任何資料.

( 跳過被 lock 的資料, 因為目前該 row 被第一個 session lock ),

回到第一個 session, 並且 commit.

再回到第二個 session 執行, 就可以正常取得資料了.

## DeadLock

會發生 DeadLock, 主要是因為互相都在等待對方的鎖釋放.

來看一個例子 DeadLock,

一樣請記得關閉 autocommit.

在第一個 session 執行以下 sql,

```sql
UPDATE res_users SET active = 'true' WHERE id = 1;
```

不要 commit.

在第二個 session 執行以下 sql,

```sql
UPDATE res_users SET active = 'true' WHERE id = 2;
```

不要 commit.

在第二個 session 執行以下 sql,

```sql
UPDATE res_users SET active = 'true' WHERE id = 1;
```

這邊你會發現他一直在等待(等待 session 1 釋放 `id=1` 的鎖),

不要管他等待, 直接回到第一個 session 執行以下 sql,

```sql
UPDATE res_users SET active = 'true' WHERE id = 2;
```

發生 deadlock,

( 現在 `id=2` 的鎖還沒有被 session 2 釋放)

session1 和 session2 互相在等待對方釋放鎖.

資料庫的錯誤訊息

```cmd
2022-10-08 07:04:45.254 UTC [3753] ERROR:  deadlock detected
2022-10-08 07:04:45.254 UTC [3753] DETAIL:  Process 3753 waits for ShareLock on transaction 6355056; blocked by process 3755.
```

## Reference

* [Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html)

* [explicit-locking](https://docs.postgresql.tw/the-sql-language/concurrency-control/explicit-locking)

* [Databases-Practical PostgreSQL](https://www.linuxtopia.org/online_books/database_guides/Practical_PostgreSQL_database/PostgreSQL_r27479.htm)