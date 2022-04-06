

/*
UPDATE History
SET newGDMXData = 1
*/


--Build the statement to execute usp_getGDMXData with each dataSet from DataSetDetails
DECLARE @SQL NVARCHAR(MAX) = '',
	@NL NVARCHAR(1) = CHAR(10),
	@dateRange NVARCHAR(100) = '2020-07-01:2020-08-01',
	@dateList NVARCHAR(100) = '2020-07-24,2020-07-25,2020-07-26'

UPDATE History
SET newGDMXData = 1
FROM History h 
JOIN vw_Symbols v 
	ON h.symbolID = v.symbolID
	AND h.periodid = v.periodid 

SELECT COUNT(*) FROM History WHERE newGDMXData = 1

SET @SQL = 
(
	SELECT 
	N'EXEC usp_getGDMXData @daysback = 1, @dataSet = ''' + dataset + ''', @isCorrection = 1' + @NL +
	N'EXEC usp_getGDMXData @daysback = 1 , @dataset = ''' + dataset + ''', @iscorrection = 0' + @NL +
	N'EXEC usp_getGDMXData @daysback = 0, @dataSet = ''' + dataset + ''', @isCorrection = 1' + @NL +
	N'EXEC usp_getGDMXData @daysback = 0 , @dataset = ''' + dataset + ''', @iscorrection = 0' + @NL +
	N'EXEC usp_LogDataSent @dataset = ''' + dataset + '''' + @NL +
	N'EXEC usp_LogGWSWarningSent @dataset = ''' + dataset + '''' + @NL +
	N'SELECT * FROM DataSetDetails WHERE DataSet = ''' + dataset + '''' + @NL + 
	N'EXEC usp_getGDMXMetaData @dataset = ''' + dataset + '''' + @NL +
	N'EXEC usp_getGDMXData_History @dataset = ''' + dataset + ''', @reRunDataRange = ''' + @dateRange + '''' + @NL + 
	N'EXEC usp_getGDMXData_History @dataset = ''' + dataset + ''', @reRunDataRange = ''' + @dateList + '''' + @NL +
	N'EXEC usp_GetDataSetExpectedTime @dataset = ''' + dataset + '''' + @NL +
	N'EXEC usp_DiscontinuedDataReceived @dataset = ''' + dataset + '''' + @NL +
	N'EXEC usp_UpdateGDMXHistory @dataset =  ''' + dataset + ''', @iscorrection = 0' + @NL + @NL
	FROM DataSetDetails
	FOR xml PATH ('')
)

PRINT @SQL

/*
SELECT @SQL
*/

EXEC sp_executesql @SQL

SELECT COUNT(*) 
FROM History h 
JOIN vw_Symbols v 
	ON h.symbolID = v.symbolID
	AND h.periodid = v.periodid 
WHERE newGDMXData = 1
