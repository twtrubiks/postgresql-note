# Postgresql Avoid SQL injection

## 說明

安裝 psycopg2

```cmd
pip3 install psycopg2==2.9.3
```

文件可參考 [https://www.psycopg.org/docs/sql.html#module-psycopg2.sql](https://www.psycopg.org/docs/sql.html#module-psycopg2.sql)

### SQL injection

先來看 sql injection 例子, [example_sql_injection.py](example_sql_injection.py)

```cmd
python3 example_sql_injection.py
```

可以發現我們透過 sql injection, 可以撈出全部的資料,

甚至可以刪掉 table :exclamation::exclamation:

### 如何避免 SQL injection

修正後, 請看 [example_avoid_sql_injection.py](example_avoid_sql_injection.py)

你會發現透過 sql injection 所執行的攻擊 sql 都被阻擋掉了:smile:

### 更好的處理方式 - SQL string composition

現在我們知道如何避免 sql injection, 那假設現在我們有一個 function,

要動態的傳入 table 變數, [example_demo.py](example_demo.py)

當你執行 `conut_rows_error("res_users")` 你會發生以下錯誤,

```txt
psycopg2.errors.SyntaxError: syntax error at or near "'res_users'"
LINE 1: SELECT count(*) FROM 'res_users'
```

這時候就要使用另一個方法, 執行 `conut_rows_fix("res_users")`

如果更複雜一點的, 執行 `conut_rows_as("res_users")`

### 搭配 pytest - SQL string composition

請參考 [avoid_sql_injection_test.py](avoid_sql_injection_test.py)

```cmd
python3 avoid_sql_injection_test.py -v -s
```

## 執行環境

* Python 3.8.12