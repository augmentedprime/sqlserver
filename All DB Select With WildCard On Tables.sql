
PRINT CONCAT('Get DBNames','  ', GETDATE())
--Part one, get the dbname and exact name of DataReportDetails table next to each other
DROP TABLE IF EXISTS #dbNames
SELECT 'SCHPSQL3' AS serverName,name AS dbName
INTO #dbNames
FROM SCHPSQL3.master.sys.databases
UNION ALL
SELECT 'SCHPSQL4' AS serverName,name
FROM SCHPSQL4.master.sys.databases
UNION ALL
SELECT 'SCHPSQL5' AS serverName,name
FROM SCHPSQL5.master.sys.databases
UNION ALL
SELECT 'SCHPSQL6' AS serverName,name
FROM SCHPSQL6.master.sys.databases

/*
SELECT * FROM #dbNames
*/

PRINT 'Create Commands for serverName, dbName pairs'
PRINT CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()),':',DATEPART(SECOND,GETDATE()))
--Create sql statements using those server.dbName pairs
DROP TABLE IF EXISTS #commands
SELECT CONCAT(
	'INSERT INTO #tables (servername, dbName, tableName)
	SELECT ''',QUOTENAME(servername),''', ''',QUOTENAME(dbName),''', name
	FROM ',QUOTENAME(servername),'.',QUOTENAME(dbName),'.sys.tables
	WHERE name LIKE ''%DataReportDetails%''') AS command
INTO #commands
FROM #dbNames
WHERE dbname NOT LIKE '%generator%'
	AND dbname NOT IN ('GLOBAL')
	
/*
SELECT * FROM #commands
*/

PRINT 'Temp table to store serverName, dbName, tableName groups'
PRINT CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()),':',DATEPART(SECOND,GETDATE()))
--Create a table to hold the triples of server.dbName.tableName
DROP TABLE IF EXISTS #tables
CREATE TABLE #tables (
	serverName nvarchar(100) NULL,
	dbName nvarchar(100) NULL,
	tableName nvarchar(100) NULL
	)

PRINT 'Cursor to populate table'
PRINT CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()),':',DATEPART(SECOND,GETDATE()))
--Populate the temp table above with 
TRUNCATE TABLE #tables

DECLARE @command NVARCHAR(MAX)
DECLARE cursed CURSOR
	FOR SELECT command FROM #commands
OPEN cursed
FETCH NEXT FROM cursed INTO @command
WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC sp_executesql @command
		FETCH NEXT FROM cursed INTO @command
	END
CLOSE cursed
DEALLOCATE cursed

/*
SELECT * FROM #tables
*/
PRINT 'Create commands to populate data report'
PRINT CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()),':',DATEPART(SECOND,GETDATE()))
DROP TABLE IF EXISTS #commands2
SELECT CONCAT(
	'INSERT INTO #dataReports (serverName, dbName, dataReport, postTime, dataExpected) 
	SELECT ''',serverName,''',''',dbName,''',dataReport,postTime,dataExpected 
	FROM ',serverName,'.',dbName,'.dbo.',tableName,'  ',
	'where dataReport <> ''metadata'''
	) AS command
INTO #commands2
FROM #tables

/*
SELECT * FROM #commands2
*/

PRINT 'Create temp table for Data Report'
PRINT CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()),':',DATEPART(SECOND,GETDATE()))
--Create a table to hold the triples of server.dbName.tableName
DROP TABLE IF EXISTS #dataReports
CREATE TABLE #dataReports (
	serverName nvarchar(100) NULL,
	dbName nvarchar(100) NULL,
	dataReport nvarchar(100) NULL,
	postTime nvarchar(100) NULL,
	dataExpected nvarchar(100) NULL
	)

PRINT 'Cursor to run commands to populate dataReports'
PRINT CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()),':',DATEPART(SECOND,GETDATE()))
--Populate the temp table above with 
TRUNCATE TABLE #dataReports

DECLARE @command2 NVARCHAR(MAX)
DECLARE cursed2 CURSOR
	FOR SELECT command FROM #commands2
OPEN cursed2
FETCH NEXT FROM cursed2 INTO @command2
WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC sp_executesql @command2
		FETCH NEXT FROM cursed2 INTO @command2
	END
CLOSE cursed2
DEALLOCATE cursed2

PRINT 'SSF FROM #dataReports'
PRINT CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()),':',DATEPART(SECOND,GETDATE()))SELECT *
FROM #dataReports WITH (NOLOCK)

