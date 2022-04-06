
DECLARE @result int = 0
DECLARE @i int = 1
WHILE @i < 1000
BEGIN
	SET @result = CASE 
					WHEN @i % 3 = 0 THEN @result 
	WHEN @i % 5 = 0 THEN @result + @i ELSE @result END
	SET @i = @i + 1
END

SELECT @result




;WITH RecurseCount AS ( 
	SELECT 1 AS hourly, 2080 AS salary
	UNION ALL 
	SELECT hourly + 1, salary + 2080
	FROM RecurseCount
	WHERE hourly < 100
	)
SELECT hourly, FORMAT(salary,'N0') salaryFormatted
FROM RecurseCount
--WHERE salary BETWEEN 80000 AND 120000
ORDER BY hourly


