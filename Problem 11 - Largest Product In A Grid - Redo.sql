
DROP TABLE IF EXISTS #grid
SELECT 
01 AS 'rowNum', 08 AS '1', 02 AS '2', 22 AS '3', 97 AS '4', 38 AS '5', 15 AS '6', 00 AS '7', 40 AS '8', 00 AS '9', 75 AS '10', 04 AS '11', 05 AS '12', 07 AS '13', 78 AS '14', 52 AS '15', 12 AS '16', 50 AS '17', 77 AS '18', 91 AS '19', 08 AS '20'
INTO #grid
UNION SELECT
02, 49, 49, 99, 40, 17, 81, 18, 57, 60, 87, 17, 40, 98, 43, 69, 48, 04, 56 ,62, 00
UNION SELECT
03, 81, 49, 31, 73, 55, 79, 14, 29, 93, 71, 40, 67, 53, 88, 30, 03, 49, 13 ,36, 65
UNION SELECT
04, 52, 70, 95, 23, 04, 60, 11, 42, 69, 24, 68, 56, 01, 32, 56, 71, 37, 02 ,36, 91
UNION SELECT
05, 22, 31, 16, 71, 51, 67, 63, 89, 41, 92, 36, 54, 22, 40, 40, 28, 66, 33 ,13, 80
UNION SELECT
06, 24, 47, 32, 60, 99, 03, 45, 02, 44, 75, 33, 53, 78, 36, 84, 20, 35, 17 ,12, 50
UNION SELECT
07, 32, 98, 81, 28, 64, 23, 67, 10, 26, 38, 40, 67, 59, 54, 70, 66, 18, 38 ,64, 70
UNION SELECT
08, 67, 26, 20, 68, 02, 62, 12, 20, 95, 63, 94, 39, 63, 08, 40, 91, 66, 49 ,94, 21
UNION SELECT
09, 24, 55, 58, 05, 66, 73, 99, 26, 97, 17, 78, 78, 96, 83, 14, 88, 34, 89 ,63, 72
UNION SELECT
10, 21, 36, 23, 09, 75, 00, 76, 44, 20, 45, 35, 14, 00, 61, 33, 97, 34, 31 ,33, 95
UNION SELECT
11, 78, 17, 53, 28, 22, 75, 31, 67, 15, 94, 03, 80, 04, 62, 16, 14, 09, 53 ,56, 92
UNION SELECT
12, 16, 39, 05, 42, 96, 35, 31, 47, 55, 58, 88, 24, 00, 17, 54, 24, 36, 29 ,85, 57
UNION SELECT
13, 86, 56, 00, 48, 35, 71, 89, 07, 05, 44, 44, 37, 44, 60, 21, 58, 51, 54 ,17, 58
UNION SELECT
14, 19, 80, 81, 68, 05, 94, 47, 69, 28, 73, 92, 13, 86, 52, 17, 77, 04, 89 ,55, 40
UNION SELECT
15, 04, 52, 08, 83, 97, 35, 99, 16, 07, 97, 57, 32, 16, 26, 26, 79, 33, 27 ,98, 66
UNION SELECT
16, 88, 36, 68, 87, 57, 62, 20, 72, 03, 46, 33, 67, 46, 55, 12, 32, 63, 93 ,53, 69
UNION SELECT
17, 04, 42, 16, 73, 38, 25, 39, 11, 24, 94, 72, 18, 08, 46, 29, 32, 40, 62 ,76, 36
UNION SELECT
18, 20, 69, 36, 41, 72, 30, 23, 88, 34, 62, 99, 69, 82, 67, 59, 85, 74, 04 ,36, 16
UNION SELECT
19, 20, 73, 35, 29, 78, 31, 90, 01, 74, 31, 49, 71, 48, 86, 81, 16, 23, 57 ,05, 54
UNION SELECT
20, 01, 70, 54, 71, 83, 51, 54, 69, 16, 92, 33, 48, 61, 43, 52, 01, 89, 19 ,67, 48
ORDER BY rownum

--SELECT *
--FROM #grid

DROP TABLE IF EXISTS #table
SELECT CONVERT(int,rowNum) AS rowNum, CONVERT(int,colNum) AS colNum, value
INTO #table
FROM   
   (SELECT rowNum, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20]
   FROM #grid) p  
UNPIVOT  
   (value FOR colNum IN   
      ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20])  
)AS unpvt;  

--SELECT *
--FROM #table
--ORDER BY rowNum,colNum



DECLARE @i int = -17
DECLARE @j int = 1
DECLARE @table TABLE (value int,row int, col int,line varchar(200))
DECLARE @temp int = 0
DECLARE @max int = 0



WHILE @i <= 17
BEGIN
	DELETE FROM @table
	INSERT @table (value)
	SELECT value * 
		LEAD(value,1) OVER(ORDER BY colNum) *
		LEAD(value,2) OVER(ORDER BY colNum) *
		LEAD(value,3) OVER(ORDER BY colNum)
	FROM #table
	WHERE rownum = @i
	UNION
	SELECT value * 
		LEAD(value,1) OVER(ORDER BY rowNum) *
		LEAD(value,2) OVER(ORDER BY rowNum) *
		LEAD(value,3) OVER(ORDER BY rowNum)
	FROM #table
	WHERE colnum = @i
	UNION
	SELECT value * 
		LEAD(value,1) OVER(ORDER BY rowNum) *
		LEAD(value,2) OVER(ORDER BY rowNum) *
		LEAD(value,3) OVER(ORDER BY rowNum)
	FROM #table
	WHERE rowNum - @i + 1 = colNum
	UNION
	SELECT value * 
		LEAD(value,1) OVER(ORDER BY rowNum) *
		LEAD(value,2) OVER(ORDER BY rowNum) *
		LEAD(value,3) OVER(ORDER BY rowNum)
	FROM #table
	WHERE colNum - @i + 1 = 20 - rowNum
	SET @i = @i + 1

END

SELECT * FROM @table
SELECT MAX(value) FROM @table	
