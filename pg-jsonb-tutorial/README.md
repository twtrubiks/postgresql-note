## PostgreSQL json

因為是直接字串保存, 所以保存速度比較快, 但是在解析的時候比較慢,

而且保存時, 會保留全部的字串, 包含空白, key 的順序,

以及重複 key 的欄位.

```sql
SELECT '{"a":1,   "b":3, "c":4, "c":5}'::json;
```

官方文件 [JSON 型別](https://docs.postgresql.tw/the-sql-language/data-types/json-types)

## PostgreSQL jsonb

轉換成 binary 後才保存, 所以保存速度比較慢, 但解析的時候比較快,

而且保存時, 不保留空白, 不保留 key 的順序, 不保留重複 key 的欄位,

更重要的是 jsonb 支援 index, 效率更好.

```sql
SELECT '{"a":1,   "b":3, "c":4, "c":5}'::jsonb;
```

還原測試資料,

[demo_data/json_tutorial_dump.sql](https://github.com/twtrubiks/postgresql-note/blob/main/demo_data/json_tutorial_dump.sql)

```cmd
psql -U username -d dbname < demo_data/json_tutorial_dump.sql
```

範例,

```sql

-- `->` returns a JSON object field by key.
-- 顯示 key 'a' 的 value  ->  jsonb format
SELECT id, data, data -> 'a' FROM json_tutorial;

-- `->>` produces a JSON object field by text.
-- 顯示 key 'a' 的 value  ->  text format
SELECT id, data, data ->> 'a' FROM json_tutorial;

-- `#>` (specified path) jsonb format
SELECT '{"a": "1","b": "2","c": {"a":10, "b":20}}'::jsonb #> '{c,a}';

-- `#>>` (specified path) text format
SELECT '{"a": "1","b": "2","c": {"a":["A","B"], "b":20}}'::jsonb #>> '{c,a,1}';

-- 含包 "a" 的 key
SELECT * FROM json_tutorial where data ? 'a';

-- 包含  {"a":"1"} 的 key/value
SELECT * FROM json_tutorial where data @> '{"a":"1"}';

-- 包含 key "a" or "c" 的資料
SELECT * FROM json_tutorial where data ?| array['a','c'];

-- 包含 key "a" and "b" 的資料
SELECT * FROM json_tutorial where data ?& array['a','b'];

-- 列出所有包含 "c" = "3"
SELECT * FROM json_tutorial where data ->> 'c' = '3';

SELECT jsonb_each('{"a": "1", "b": "1"}'::jsonb);

SELECT jsonb_object_keys('{"a": "1", "b": "1"}'::jsonb);

SELECT jsonb_pretty('{"a": "1", "b": "1"}'::jsonb);

SELECT jsonb_build_object('a', '1', 'b', '2', 'c',row('2', 'd', false));

SELECT jsonb_extract_path('{"a": "1", "b": "3"}', 'b');

SELECT jsonb_extract_path('{"a": "1", "b": "1", "c": [1, 2]}', 'c');

-- jsonb_path_query_array

-- jsonb_object_agg

-- jsonb_set ( target jsonb, path text[], new_value jsonb [, create_if_missing boolean ] ) → jsonb
-- id = 6 -> { "a": 2, "g": 3 }
UPDATE json_tutorial SET data = jsonb_set(data, '{g}', '99', false) WHERE id = 6;
UPDATE json_tutorial SET data = jsonb_set(data, '{s}', '123', false) WHERE id = 6;
UPDATE json_tutorial SET data = jsonb_set(data, '{s}', '123', true) WHERE id = 6;
```

建議可以參考官方文件 [JSON Functions and Operators](https://www.postgresql.org/docs/current/functions-json.html)