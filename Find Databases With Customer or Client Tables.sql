



DROP TABLE IF EXISTS #DatabaseNames
CREATE TABLE #DatabaseNames (databaseName NVARCHAR(100), statement NVARCHAR(MAX))

INSERT INTO #DatabaseNames
SELECT name, ''
FROM sys.databases

/*
SELECT * FROM #DatabaseNames
*/



DROP TABLE IF EXISTS #NamesAndStatements
SELECT databaseName, 'INSERT INTO #CustomerDatabases (dbName) SELECT DISTINCT TABLE_CATALOG FROM [' + 
databaseName + 
'].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME IN ( ''Client'', ''Clients'', ''Customers'',''Customer'')' AS statement
INTO #NamesAndStatements
FROM #DatabaseNames

/*
SELECT * FROM #NamesAndStatements
*/



DROP TABLE IF EXISTS #NumberedStatements
SELECT 
	databasename,
	statement, 
	ROW_NUMBER() 
		OVER (ORDER BY statement) AS rowNumber
INTO #NumberedStatements
FROM #NamesAndStatements

/*
SELECT * FROM #NumberedStatements
*/




DECLARE @maxRow int = (SELECT MAX(rownumber) FROM #NumberedStatements)
--set @maxRow = 5
DECLARE @i int = 1
DECLARE @sql NVARCHAR(MAX) = N''
DROP TABLE IF EXISTS #CustomerDatabases CREATE TABLE #CustomerDatabases (dbName NVARCHAR(100))
DECLARE @result NVARCHAR(100) = ''

WHILE @i <= @maxRow
BEGIN
SET @sql = (SELECT statement FROM #NumberedStatements WHERE rowNumber = @i)
EXEC sp_executesql @sql
SET @i = @i + 1
END

SELECT * FROM #CustomerDatabases
