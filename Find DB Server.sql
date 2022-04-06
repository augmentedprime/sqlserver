
;WITH CTE AS (
	SELECT 'Calrock%' AS dbName --Include wildcards in dbName string
	)
SELECT 'SCHPSQL3', *
FROM SCHPSQL3.master.sys.databases d
JOIN CTE c ON d.name LIKE c.dbName
WHERE name LIKE dbName
UNION
SELECT 'SCHPSQL4', *
FROM SCHPSQL4.master.sys.databases d
JOIN CTE c ON d.name LIKE c.dbName
WHERE name LIKE dbName
UNION
SELECT 'SCHPSQL5', *
FROM SCHPSQL5.master.sys.databases d
JOIN CTE c ON d.name LIKE c.dbName
WHERE name LIKE dbName
UNION
SELECT 'SCHPSQL6', *
FROM SCHPSQL6.master.sys.databases d
JOIN CTE c ON d.name LIKE c.dbName
WHERE name LIKE dbName
UNION
SELECT 'SCHPSQL9', *
FROM SCHPSQL9.master.sys.databases d
JOIN CTE c ON d.name LIKE c.dbName
WHERE name LIKE dbName
