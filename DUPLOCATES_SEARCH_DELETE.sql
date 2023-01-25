-- обнаружение и удаление дубликатов ClickHouse

SELECT uniq(a,b,c) FROM test
--OR
SELECT uniq(*) FROM test
--OR
SELECT uniq(*)/count(*) FROM test -- % дублей
--OR
SELECT count(distinct a,b,c)/count(*) FROM test;


OPTIMIZE TABLE test FINAL DEDUPLICATE
-- Deduplicating based on a subset of columns
OPTIMIZE TABLE test FINAL DEDUPLICATE BY a,b;

