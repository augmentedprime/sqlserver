-- 2021-04-07 Chris L.

-- This script removes any data issues that have not posted a new alert since @date. Set this variable to your own date, recommended current date - 1.
-- This is useful for clearing out old issues on the dash that have since resolved.
-- First query stolen from Austin.

-- Run on SCHPSQL9.
USE Ticketing;
DECLARE @date DATE = '{myDate}';

DROP TABLE IF EXISTS #DataIssues
SELECT DISTINCT serverName, dbName, reportDateTime
INTO #DataIssues
FROM Ticket
WHERE reportID = 2
	AND serverName LIKE 'SCHPSQL[0-9]'
	AND resolved = 0
ORDER BY serverName, dbName

DROP TABLE IF EXISTS #remove;
SELECT servername, dbname, MAX(reportdatetime) AS [datetime]
INTO #remove
FROM #DataIssues
GROUP BY serverName, dbName
HAVING MAX(reportDateTime) <= @date
UPDATE t
SET resolved = 1
FROM Ticket t
JOIN #remove r
	ON t.serverName = r.serverName
	AND t.dbName = r.dbName
