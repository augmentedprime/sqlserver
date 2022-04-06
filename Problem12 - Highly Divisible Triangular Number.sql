DECLARE @triangle int = 0
DECLARE @n int = 1
DECLARE @factors TABLE (factor int)
DECLARE @i int = 1

WHILE (SELECT COUNT(*) FROM @factors) < 500
BEGIN
	--Get next triangle number
	SET @triangle = @triangle + @n
	DELETE FROM @factors
	
	--Find Factors
	SET @i = 1
	WHILE @i <= SQRT(@triangle)
	BEGIN
		IF @triangle % @i = 0 INSERT @factors (factor) SELECT @i UNION SELECT @triangle/@i
		SET @i = @i + 1
	END
--	SET @log = CONCAT('Triangle: ',@triangle,CHAR(10),'Nth: ',@n,CHAR(10),'Factors: ',(SELECT CONCAT(factor,',') FROM @factors ORDER BY factor FOR XML PATH('')),CHAR(10),'Count: ',(SELECT COUNT(*) FROM @factors),CHAR(10),'Max Count = ',@maxCount) PRINT @log
	SET @n = @n + 1
END
	
SELECT @triangle, 'a Triangle' AS sort
UNION SELECT @n, 'b N'
UNION SELECT (SELECT COUNT (*) FROM @factors), 'c Count'	
UNION SELECT factor, 'd Factors' FROM @factors ORDER BY sort
	
--	PRINT CONCAT('Nth:             ',@n,CHAR(10),'Triangle Number: ',@triangle,CHAR(10))
