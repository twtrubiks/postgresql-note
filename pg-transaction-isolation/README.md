# 交易隔離 transaction isolation

為了解決資料庫面臨的幾個問題:

`dirty read`(髒讀)

`nonrepeatable read`(無法重複的讀取)

`phantom read`(幻讀)

`serialization anomaly`(序列化異常)

於是有了 Isolation Level.

推薦大家一定要搭配官方手冊 [交易隔離](https://docs.postgresql.tw/the-sql-language/concurrency-control/transaction-isolation) 閱讀,

也可以了解一下 [MVCC](https://docs.postgresql.tw/the-sql-language/concurrency-control) 一致性管理,

它是 Multiversion Concurrency Control 的縮寫.

Isolation Level 大致分為幾個

- Read uncommitted

- Read Committed (預設)

- Repeatable Read

- Serializable

推薦搭配 [交易隔離等級](https://docs.postgresql.tw/the-sql-language/concurrency-control/transaction-isolation#table-13.1.-jiao-yi-ge-li-deng-ji) 閱讀.

如何查看目前的 Isolation Level,

```sql
SHOW TRANSACTION ISOLATION LEVEL;
```

預設的 Isolation Level,

```sql
SHOW default_transaction_isolation;
```

執行以下的範例時, 請記得 [測試前請關閉 autocommit](https://github.com/twtrubiks/postgresql-note/blob/main/pg-lock-tutorial/README.md#%E6%B8%AC%E8%A9%A6%E5%89%8D%E8%AB%8B%E9%97%9C%E9%96%89-autocommit)

## Read uncommitted

transaction 可以讀取尚未 commit 的資料,

所以可能產生 dirty read.

但在 Postgre 中不會發生 dirty read.

原因如下,

```text
In PostgreSQL READ UNCOMMITTED is treated as READ COMMITTED.
```

## Read Committed

PostgreSQL 預設的 Isolation Level.

速度快, 適合不複雜的搜尋, 如果執行較複雜的搜尋, 可能結果會不如預期.

但對大部份的使用已足夠, 也是為什麼它是預設的 Isolation Level.

透過 SQL 來看一下它的行為,

session 1

```sql
BEGIN ISOLATION LEVEL Read Committed;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)
```

session 2

```sql
BEGIN ISOLATION LEVEL Read Committed;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)
```

session 1

```sql
UPDATE hr_expense SET total_amount = total_amount + 1 WHERE id=26;
commit;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          496
(1 row)
```

拿到最新的資料.

session 2

```sql
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          496
(1 row)
```

這邊也成功拿到最新的資料.

### Phantom Read

藉由 Read Committed 這個, 來看一下什麼是 phantom read.

透過 SQL 來看一下它的行為,

session 1

```sql
BEGIN ISOLATION LEVEL Read Committed;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)
```

session 2

```sql
BEGIN ISOLATION LEVEL Read Committed;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)
```

session 1

```sql
UPDATE hr_expense SET total_amount = total_amount + 1 WHERE id=26;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          496
(1 row)
```

session 2

```sql
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)

```

session 1

```sql
commit;
```

session 2

```sql
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          496
(1 row)
```

這裡就是產生了 phantom read:exclamation::exclamation:

## Repeatable Read

Odoo 選擇的 Isolation Level.

有可能看到比較舊的沒更新的資料, 或是產生序列化衝突,

所以要好好的搭配 lock 使用( Odoo 也自己實做了它的 lock).

在 Repeatable Read 中, Postgre 是不會發生 phantom read.

透過 SQL 來看一下它的行為,

session 1

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)
```

session 2

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)
```

session 1

```sql
UPDATE hr_expense SET total_amount = total_amount+1 WHERE id=26;
commit;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          496
(1 row)
```

拿到最新的資料

session 2

```sql
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          495
(1 row)
```

這邊和 Read Committed 不一樣的地方是, 拿到了 **舊** 的資料,

但是卻避免了 phantom read.

那要怎麼樣才能拿到最新的資料呢:question:

很簡單, 結束這個 transaction 再 search 一次即可.

```sql
commit;
select id, total_amount from hr_expense where id=26;

 id | total_amount
----+--------------
 26 |          496
(1 row)
```

### 序列化衝突

使用 Repeatable Read 且同時更新(其他 transaction 尚未結束),

很容易發生序列化衝突

`ERROR:  could not serialize access due to concurrent update`

需注意的是，只有更新的交易可能需要重試; 只有讀取的交易永遠不會發生序列化衝突.

透過 SQL 來看一下它的行為,

session 1

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
UPDATE hr_expense SET total_amount = 494 WHERE id=26;
```

session 2

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
UPDATE hr_expense SET total_amount = 495 WHERE id=26;
```

這時候你會發現 session 2 一直在等待, 不用管他.

回到 session 1

```sql
commit;
```

session 2

```sql
ERROR:  could not serialize access due to concurrent update
```

此時如果 commit, 會直接 rollback.

```sql
commit;
ROLLBACK

select id, total_amount from hr_expense where id=26;
 id | total_amount
----+--------------
 26 |          494
(1 row)

```

成功的只有 session 1.

## Serializable

顧名思義, 就是最嚴格的一個一個來, 如果當下有其他人也要執行,

就是必須要等待.

當然, 選擇這個效能也會比較差一點點.

## Reference

* [交易隔離](https://docs.postgresql.tw/the-sql-language/concurrency-control/transaction-isolation)