-------------- note SQL --------------

-- extract
SELECT extract( year FROM TIMESTAMP '2017-08-11' )::int - 1911 AS days ;
SELECT extract( month FROM TIMESTAMP '2017-08-11' )::int AS month;

-- split_part
SELECT (split_part('2017-08-11', '-', 1)) AS year;
SELECT (split_part('2017-08-11', '-', 3)) AS day;

-- ||
SELECT 'A' || ' ' || 'B' AS result_string;
SELECT 'A' || NULL AS result_string; -- NULL

-- CONCAT
SELECT CONCAT('A', ' ', 'B') AS result_string;
-- ignores the NULL arguments.
SELECT CONCAT('A', NULL, 'B') AS result_string;

-- mod
SELECT MOD(10, 10);
SELECT MOD(1, 10);
SELECT MOD(12, 10);

-- round
SELECT round(10::numeric, 3);

-- interval
SELECT now(), now() - INTERVAL '3 days' AS "3 days ago";
SELECT now(), now() - INTERVAL '10 days 10 minutes' AS "10 days 10 minutes ago";

-- generate_series(start, stop, step interval)
SELECT * FROM generate_series(2,4);
SELECT * FROM generate_series(5,1,-2);

SELECT current_date + s AS dates
FROM generate_series(0,14,7) AS s;

SELECT *
FROM generate_series('2022-08-01 00:00'::timestamp,'2022-08-04 12:00', '6 hours');

SELECT date
FROM generate_series('2022-8-01'::date, '2022-8-10'::date, '1 day'::interval) as date;

SELECT 'test' || MOD(i, 10) AS name,
       Md5(i :: text),
       '2022-08-01 00:00:00' :: timestamptz +
	   ( MOD(i, 10) || ' day' ) :: interval +
	   ( MOD(i, 3600) || ' sec' ) :: interval AS time
FROM   generate_series(1, 10) AS i;


-- ARRAY
SELECT ARRAY['a', 'b', 'c'];
SELECT (ARRAY[1, 2, 6])[3];

-- array_to_string
SELECT array_to_string(ARRAY['A', 'B', 'C'], ',');

-- expand an array to a set of rows.
SELECT unnest(ARRAY['A', 'B', 'C', 'D']);

-- array_agg
SELECT array_agg(i::date)
FROM generate_series('2022-12-01'::date, '2022-12-03'::date, '1 day'::interval) as i ;

-- with ordinality
SELECT x.val, x.id
FROM unnest(array['A', 'B', 'C', 'D'])
with ordinality as x(id, val);

-- REGEXP_SPLIT_TO_ARRAY
SELECT REGEXP_SPLIT_TO_ARRAY('01 02 03', '\s+');
-- {01,02,03}

-- UNNEST + REGEXP_SPLIT_TO_ARRAY
SELECT UNNEST(REGEXP_SPLIT_TO_ARRAY('01 02 03', '\s+'));

-- REGEXP_REPLACE
SELECT REGEXP_REPLACE('你好 test 我是誰aaa', '[A-Za-z]+','');
-- 你好  我是誰aaa

-- REGEXP_REPLACE
SELECT REGEXP_REPLACE('你好 test 我是誰aaa', '[A-Za-z]+','','g');
-- 你好  我是誰

-- SUBSTRING
SELECT SUBSTRING('0123456789' from 4 for 5);
-- 34567

-- DELETE
DELETE FROM table_name
WHERE column_name operator value;

-- UPDATE
UPDATE table_name
SET column1=value1, column2=value2
WHERE some_column=some_value;

-- LEFT JOIN
SELECT table_column1, table_column2
FROM table_name1
LEFT JOIN table_name2
ON table_name1.column_name=table_name2.column_name;

-- COALESCE
-- psql -U username -d dbname < demo_data/coalesce_tutorial_dump.sql
SELECT id,
       COALESCE(test1, test2, test3, 10) AS new_data
FROM   coalesce_tutorial
ORDER BY id ASC;

-- TO_CHAR
-- psql -U username -d dbname < demo_data/coalesce_tutorial_dump.sql
SELECT id,
       date,
       TO_CHAR(date, 'HH24:MI:SS') AS custom_date
FROM   coalesce_tutorial;

-- GROUP BY
SELECT column_name(s), aggregate_function(column_name)
FROM table_name
WHERE column_name operator value
GROUP BY column_name1, column_name2;

-- GROUP BY + HAVING
-- psql -U username -d dbname < demo_data/group_by_having_tutorial_dump.sql
SELECT user_id,
       Sum(amount)
FROM   group_by_having_tutorial
GROUP  BY user_id
HAVING Sum(amount) > 40;

-- PostgreSQL WITH
-- psql -U username -d dbname < demo_data/group_by_having_tutorial_dump.sql
WITH tmp
     AS (SELECT user_id,
                Sum(amount)
         FROM   group_by_having_tutorial
         GROUP  BY user_id)
SELECT *
FROM   tmp;

-- DISTINCT
-- psql -U username -d dbname < demo_data/distinct_tutorial_dump.sql
SELECT * FROM distinct_tutorial order by id;

SELECT DISTINCT amount FROM distinct_tutorial;

-- 會依照 兩個 fields 來看
SELECT DISTINCT amount, user_id FROM distinct_tutorial;

-- 只會撈出 group by amount 的第一次出現項目 (多餘的不會顯示), 並且個別分組依照 id 排序 desc
SELECT DISTINCT on (amount) * FROM distinct_tutorial order by amount, id desc;

-- 只會撈出 group by amount 的第一次出現項目 (多餘的不會顯示), 並且個別分組依照 id 排序 asc
SELECT DISTINCT on (amount) * FROM distinct_tutorial order by amount, id asc;

-- 找出重複的 amount 個別數量
SELECT amount, COUNT(*) FROM distinct_tutorial
GROUP BY amount HAVING COUNT(*) > 1

-- 刪除重複的 amount rows.
-- 透過 DELETE FROM ... USING ...
-- Syntax: DELETE FROM table_name row1 USING table_name row2 WHERE condition;
DELETE FROM
    distinct_tutorial a
        USING distinct_tutorial b
WHERE
    a.id < b.id AND a.amount = b.amount;

-- a sequential integer to each row
SELECT id, amount, user_id, ROW_NUMBER() OVER (ORDER BY id)
FROM distinct_tutorial where amount=100 order by id asc;

-- a sequential integer to each group row
SELECT id, amount, user_id, ROW_NUMBER() OVER (PARTITION BY amount)
FROM distinct_tutorial;

-- 搭配 ROW_NUMBER 刪除重複的 row
DELETE
FROM distinct_tutorial
WHERE id in
       (SELECT id
           FROM
              (SELECT id,
                      ROW_NUMBER() OVER (PARTITION BY amount) AS row_num
                  FROM distinct_tutorial) t
           WHERE t.row_num > 1 );

-- MAX
-- psql -U username -d dbname < demo_data/group_by_having_tutorial_dump.sql
SELECT user_id,
       amount,
       id
FROM   group_by_having_tutorial
WHERE  amount = (SELECT MAX(amount)
                 FROM   group_by_having_tutorial);

-- Subquery
-- psql -U username -d dbname < demo_data/group_by_having_tutorial_dump.sql
SELECT *
FROM   group_by_having_tutorial
WHERE  id IN (SELECT id
              FROM   group_by_having_tutorial
              WHERE  user_id = 2);

-- UNION (removes all duplicate rows)
-- psql -U username -d dbname < demo_data/group_by_having_tutorial_dump.sql
SELECT *
FROM   group_by_having_tutorial
WHERE  user_id = 2
UNION
SELECT *
FROM   group_by_having_tutorial
WHERE  user_id = 2;

-- UNION ALL (contain duplicate rows)
-- psql -U username -d dbname < demo_data/group_by_having_tutorial_dump.sql
SELECT *
FROM   group_by_having_tutorial
WHERE  user_id = 2
UNION ALL
SELECT *
FROM   group_by_having_tutorial
WHERE  user_id = 2;

-- CASE
-- psql -U username -d dbname < demo_data/group_by_having_tutorial_dump.sql
SELECT id,
       user_id,
       CASE
         WHEN user_id = 1 THEN '使用者一'
         WHEN user_id = 2 THEN '使用者二'
         ELSE '其他使用者'
       END AS user_name,
       amount
FROM   group_by_having_tutorial;

-- CREATE VIEW
-- psql -U username -d dbname < demo_data/coalesce_tutorial_dump.sql
CREATE OR replace VIEW coalesce_view
AS
  (SELECT id,
          Coalesce(test1, test2, test3, 10) AS new_data
   FROM   coalesce_tutorial
   ORDER  BY id ASC);

-- INSERT INTO
INSERT INTO TABLE_NAME (column1, column2)
VALUES (value1, value2);

-- RESTART IDENTITY -> reset all sequence
-- CONTINUE IDENTITY -> default
TRUNCATE table_name RESTART IDENTITY CASCADE;


-- SELF JOIN SELF
-- psql -U username -d dbname < demo_data/test_employee_dump.sql

-- 找出全部有主管的人, 並且列出全部主管名稱
SELECT
	emp.id, emp.name, emp.manager_id, manager.name
FROM test_employee emp
INNER JOIN test_employee manager ON emp.manager_id = manager.id;

-- 列出全部的細節 (包含沒有主管的)
SELECT
	emp.id, emp.name, emp.manager_id, manager.name
FROM test_employee emp
LEFT JOIN test_employee manager ON emp.manager_id = manager.id;

-- CROSS JOIN
-- 讓每個員工互相配對(但不包含自己)
SELECT
	emp1.id, emp1.name, emp2.id, emp2.name
FROM test_employee emp1
CROSS JOIN test_employee emp2
WHERE emp1.id != emp2.id;

-- 列出全部的階層(職位小到大)
SELECT
	emp.id, emp.name, manager.id, manager.name AS manager_name
FROM test_employee emp
LEFT JOIN test_employee manager ON emp.manager_id <= manager.id
ORDER BY emp.id ASC, manager.id ASC;

