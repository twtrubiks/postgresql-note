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
SELECT DISTINCT column1
FROM table_name
WHERE column_name operator value;

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
