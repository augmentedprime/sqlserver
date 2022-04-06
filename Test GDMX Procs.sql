

/*
UPDATE History
SET newGDMXData = 1
*/


--Build the statement to execute usp_getGDMXData with each dataSet from DataSetDetails
DECLARE @SQL NVARCHAR(MAX) = '',
	@NL NVARCHAR(1) = CHAR(10)


SET @SQL = 
(
	SELECT 
	N'EXEC usp_getGDMXData @daysback = 1, @dataSet = ' + dataSet + ', @isCorrection = 0' + @NL
	FROM DataSetDetails
	FOR xml PATH ('')
)

/*
PRINT @SQL
SELECT @SQL
*/

EXEC sp_executesql @SQL
