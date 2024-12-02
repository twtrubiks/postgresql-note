-- to_tsvector 用法, 得到向量
SELECT to_tsvector('english', 'PostgreSQL is a powerful, open-source relational database.');

-- 可搭配 setweight 一起使用
-- setweight(text, weight)
-- weight：這是權重，通常是以下四個字母中的一個：
-- 'A'：最高權重
-- 'B'：較高權重
-- 'C'：較低權重
-- 'D'：最低權重
SELECT setweight(to_tsvector('english', 'PostgreSQL'), 'A');

-- 可以合併向量  "||" 代表 合併向量
SELECT setweight(to_tsvector('english', 'PostgreSQL'), 'A') ||
       setweight(to_tsvector('english', 'system'), 'B');

-- 透過向量完成 全文檢索功能 START ---
-- to_tsvector 用法, 得到向量
SELECT to_tsvector('english', 'PostgreSQL is a powerful, open-source relational database.');

-- 可搭配 setweight 一起使用
-- setweight(text, weight)
-- weight：這是權重，通常是以下四個字母中的一個：
-- 'A'：最高權重
-- 'B'：較高權重
-- 'C'：較低權重
-- 'D'：最低權重
SELECT setweight(to_tsvector('english', 'PostgreSQL'), 'A');

-- 可以合併向量  "||" 代表 合併向量
SELECT setweight(to_tsvector('english', 'PostgreSQL'), 'A') ||
       setweight(to_tsvector('english', 'system'), 'B');

-- 透過向量完成 全文檢索功能 的功能 START
WITH source AS (
    SELECT 1 AS id, to_tsvector('english', 'test') AS name
    UNION ALL
	SELECT 2 AS id, to_tsvector('english', 'test-1 data') AS name
    UNION ALL
    SELECT 3 AS id, to_tsvector('english', 'data-test test') AS name
    UNION ALL
    SELECT 4 AS id, to_tsvector('english', 'apple-test-feature') AS name
    UNION ALL
    SELECT 5 AS id, to_tsvector('english', 'system-test-flow test test') AS name
	UNION ALL
    SELECT 6 AS id, to_tsvector('english', 'systemd-test-demo') AS name
)

SELECT id, name
    FROM source, to_tsquery('english', 'system') query_plain
    WHERE source.name @@ query_plain -- @@ 為全文檢索操作符號, 用來檢查 name 欄位是否與查詢 query_plain 匹配

-- END ---


-- 透過向量完成 全文檢索功能並且排名 START
WITH source AS (
    SELECT 1 AS id, setweight(to_tsvector('english', 'test'), 'B') AS name
    UNION ALL
	SELECT 2 AS id, setweight(to_tsvector('english', 'test-1 data'), 'B') AS name
    UNION ALL
    SELECT 3 AS id, setweight(to_tsvector('english', 'data-test test'), 'B') AS name
    UNION ALL
    SELECT 4 AS id, setweight(to_tsvector('english', 'apple-test-feature'), 'B') AS name
    UNION ALL
    SELECT 5 AS id, setweight(to_tsvector('english', 'system-test-flow test test'), 'B') AS name
	UNION ALL
    SELECT 6 AS id, setweight(to_tsvector('english', 'systemd-test-demo'), 'B') AS name
),
ranking AS (
    SELECT id, name, ts_rank(source.name, query_plain) AS rank
    FROM source, to_tsquery('english', 'test') query_plain
    WHERE source.name @@ query_plain
)

SELECT * FROM ranking ORDER BY rank DESC;

-- SELECT * FROM source;

-- END ---
