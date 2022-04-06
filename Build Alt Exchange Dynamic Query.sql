USE ICES2FE



--Find the maximum possible number of customers/exchanges for any file
DECLARE @maxCustCount int = (
	SELECT MAX(custCount)
	FROM (
		SELECT COUNT(*) AS custCount
		FROM customerFileMapping
		GROUP BY fileName) dt
	)

--This check has to happen before the CTE
DROP TABLE IF EXISTS #Loop

--Generate numbers 1 - maxCustCount
;WITH Loop AS
	(
      SELECT 1 AS i
      UNION ALL
      SELECT  i + 1
      FROM    Loop
      WHERE   i < @maxCustCount
	)
--Store CTE in temp table for ease of troubleshooting, not functionally necessary
SELECT *
INTO #Loop
FROM Loop

--Just some variable declarations, nothing to see here.
DECLARE @NEWLINE AS CHAR(4) =CHAR(10)
DECLARE @sql NVARCHAR(MAX)

 --Build the statement. Godspeed.
SELECT @sql = CONCAT(

--Top of the proc, just some straight text
'
;WITH cte AS (
SELECT DISTINCT exchangeCode, b.[fileName]
FROM client a
INNER JOIN dbo.customerFileMapping b
ON a.client = b.custName
WHERE b.[active] = 1
) 
SELECT fileName,CONCAT('''',',@NEWLINE,

/*
The following generates this pattern: 
ISNULL('|' + [',1,'] + '|',''),
ISNULL('|' + [',2,'] + '|',''),
ISNULL('|' + [',3,'] + '|',''),
....
ISNULL('|' + [',@maxCustCount,'] + '|','')
*/
(SELECT CONCAT('',
	'ISNULL(',
	CASE WHEN i = 1 THEN '''|'' + ' END, --Include '|' before first entry
	'[',i,'] + ''|'','''')',
	CASE WHEN i < @maxCustCount THEN ',' END,@NEWLINE) --Exclude ',' after last entry
FROM #Loop FOR XML PATH('') ),

--More straight text insertion
')
FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY [fileName] ORDER BY exchangeCode) AS rownum,exchangeCode,fileName
FROM cte 
) AS b
PIVOT(
MAX(exchangeCode)
FOR b.rownum IN (',@NEWLINE,

/*
Another pattern: 
[1],[2],[3],...,[@maxCustCount]
*/
(SELECT CONCAT('',
	'[',i,']',
	CASE WHEN i < @maxCustCount THEN ',' END)
FROM #Loop FOR XML PATH ('')),

--Wrap up with closing parentheses and naming the pivot table
')
) AS piv ')

--Print proc for troubleshooting
PRINT @sql


--Temp table to capture results
DROP TABLE IF EXISTS #FileExchanges
CREATE TABLE #FileExchanges(
	filename VARCHAR(200),
	altExchanges VARCHAR(200)
	)

--Fingers crossed
INSERT INTO #FileExchanges
EXECUTE sp_executesql @sql

SELECT *
FROM dbo.#FileExchanges



INSERT INTO AltExchanges (fileName, altExchanges)
SELECT f.filename, f.altExchanges
FROM #FileExchanges f 
LEFT JOIN AltExchanges a
	ON f.filename = a.fileName
WHERE a.filename IS NULL

UPDATE dbo.AltExchanges
SET altExchanges = f.altExchanges
FROM #FileExchanges f 
LEFT JOIN AltExchanges a
	ON f.filename = a.fileName
WHERE f.altExchanges != a.altExchanges