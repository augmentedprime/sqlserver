--Returns rowcounts for all tables in a DB
SELECT
    a.object_id,
    a.name,
    SUM(b.rows) AS rows,
    CAST(ROUND((SUM(d.used_pages) / (128.00*1024.00)), 2) AS NUMERIC(36, 2)) AS used_GB,
    CAST(ROUND((SUM(d.total_pages) / (128.00*1024.00)), 2) AS NUMERIC(36, 2)) AS total_GB
FROM sys.tables           a
JOIN sys.partitions       b ON a.object_id = b.object_id
JOIN sys.indexes          c ON b.object_id = c.object_id AND b.index_id = c.index_id
JOIN sys.allocation_units d ON b.partition_id = d.container_id
WHERE c.index_id < 2
--AND a.name = ''
GROUP BY a.object_id, a.name
ORDER BY a.name
