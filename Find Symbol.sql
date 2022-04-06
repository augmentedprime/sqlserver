--SCHPSQL11/12
USE [MVProdPerm2]
GO 

DECLARE @symbol VARCHAR(200) = '#DCEPG<0>', --Include wildcards in symbol
		@troubleshoot bit = 1 --Set to 1 to show temp tables made at each step
	
DROP TABLE IF EXISTS #symbolDB
SELECT DISTINCT  @symbol AS searchSymbol, dbName
INTO #symbolDB
FROM SYMBOL WITH (NOLOCK)
WHERE symbol LIKE @symbol	
	AND dbName IS NOT NULL

IF (SELECT COUNT(*) FROM #symbolDB) = 0
BEGIN
INSERT INTO #symbolDB (searchSymbol, dbName)
SELECT DISTINCT @symbol, dbName
FROM SYMBOL
WHERE dbName IS NOT NULL
	AND EXCHANGE_CODE IN (
		SELECT DISTINCT EXCHANGE_CODE
		FROM SYMBOL WITH (NOLOCK)
		WHERE symbol LIKE @symbol)
END

IF @troubleshoot = 1 
SELECT * FROM #symbolDB

--Capture dbName and serverName in a temp table.
--Should almost always return 1 so a variable would work, but if you are using wildcards you could get more
DROP TABLE IF EXISTS #dbServerPair
CREATE TABLE #dbServerPair (
	serverName VARCHAR(100),
	dbName VARCHAR(100),
	searchSymbol VARCHAR(100)
)

---------------------------------------------------------------------------------------
--Populate #dbServerPair table with matching server and db
INSERT INTO #dbServerPair (serverName, dbName, searchSymbol)
SELECT 'SCHPSQL3', d.name, s.searchSymbol
FROM SCHPSQL3.master.sys.databases d
JOIN #symbolDB s
	ON d.name LIKE CONCAT('%',s.dbName,'%')
UNION
SELECT 'SCHPSQL4', d.name, s.searchSymbol 
FROM SCHPSQL4.master.sys.databases d
JOIN #symbolDB s
	ON d.name LIKE CONCAT('%',s.dbName,'%')
UNION
SELECT 'SCHPSQL5', d.name, s.searchSymbol 
FROM SCHPSQL5.master.sys.databases d
JOIN #symbolDB s
	ON d.name LIKE CONCAT('%',s.dbName,'%')
UNION
SELECT 'SCHPSQL6', d.name, s.searchSymbol 
FROM SCHPSQL6.master.sys.databases d
JOIN #symbolDB s
	ON d.name LIKE CONCAT('%',s.dbName,'%')
UNION
SELECT 'SCHPSQL9', d.name, s.searchSymbol 
FROM SCHPSQL9.master.sys.databases d
JOIN #symbolDB s
	ON d.name LIKE CONCAT('%',s.dbName,'%')
---------------------------------------------------------------------------------------

IF @troubleshoot = 1 
SELECT '#dbServerPair' AS tempTableName, *
FROM #dbServerPair


--Container for following query
DROP TABLE IF EXISTS #Information_Schema
CREATE TABLE #Information_Schema (
	serverName VARCHAR(100),
	TABLE_CATALOG VARCHAR (100), 
	TABLE_SCHEMA VARCHAR (100),
	TABLE_NAME VARCHAR (100), 
	COLUMN_NAME VARCHAR (100),
	searchSymbol VARCHAR (100)
)

--Create query to grab all tables for the server/dbName pairs
DROP TABLE IF EXISTS #SchemaQueries
SELECT CONCAT(
	N'INSERT INTO #Information_Schema (serverName, TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, searchSymbol)
	SELECT ''',serverName,''' AS serverName, TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, ''',searchSymbol,'''
	FROM ',QUOTENAME(serverName),'.',QUOTENAME(dbName),'.INFORMATION_SCHEMA.COLUMNS
	WHERE COLUMN_NAME LIKE ''%symbol%''') AS query
INTO #SchemaQueries
FROM #dbServerPair 


IF @troubleshoot = 1
SELECT * FROM #SchemaQueries

DECLARE @cursorQuery NVARCHAR(MAX)
DECLARE cursed CURSOR
	FOR SELECT query FROM #SchemaQueries
OPEN cursed
FETCH NEXT FROM cursed INTO @cursorQuery
WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			EXEC sp_executesql @cursorQuery
		END TRY
		BEGIN CATCH
			PRINT CONCAT('Query failed. DataReportDetails table may not exist.  ',@cursorQuery)
		END CATCH
		FETCH NEXT FROM cursed INTO @cursorQuery
	END
CLOSE cursed
DEALLOCATE cursed


IF @troubleshoot = 1 
SELECT '#Information_Schema' AS tempTableName, *
FROM #Information_Schema


--Create queries for individual tables
DROP TABLE IF EXISTS #TableQueries
SELECT CONCAT(
N'IF EXISTS( SELECT(1) FROM ',serverName,'.',TABLE_CATALOG,'.',TABLE_SCHEMA,'.',TABLE_NAME,' WHERE ',COLUMN_NAME,' LIKE ''',searchSymbol,''')
SELECT ''',serverName,''' AS serverName, ''',TABLE_CATALOG,''' AS dbName, ''',TABLE_NAME,''' AS tableName, ''',searchSymbol,''' AS searchSymbol, *
FROM ',serverName,'.',TABLE_CATALOG,'.',TABLE_SCHEMA,'.',TABLE_NAME,'
WHERE ',COLUMN_NAME,' LIKE ''',searchSymbol,'''') AS query
INTO #TableQueries
FROM #Information_Schema

IF @troubleshoot = 1 
SELECT '#TableQueries' AS tempTableName, *
FROM #TableQueries


--Cursor to run queries above. Simply returns output to the grid.
DECLARE cursed CURSOR
	FOR SELECT query FROM #TableQueries
OPEN cursed
FETCH NEXT FROM cursed INTO @cursorQuery
WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			EXEC sp_executesql @cursorQuery
		END TRY
		BEGIN CATCH
			PRINT CONCAT('Query failed. DataReportDetails table may not exist.  ',@cursorQuery)
		END CATCH
		FETCH NEXT FROM cursed INTO @cursorQuery
	END
CLOSE cursed
DEALLOCATE cursed


