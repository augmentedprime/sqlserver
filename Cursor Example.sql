
DROP TABLE IF EXISTS #commands
SELECT CONCAT('UPDATE Stage SET ',COLUMN_NAME,' = NULL WHERE ',COLUMN_NAME,' = ''''') AS command
INTO #commands
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Stage'

DECLARE @command NVARCHAR(MAX)
DECLARE cursed CURSOR FOR SELECT command FROM #commands
OPEN cursed
FETCH NEXT FROM cursed INTO @command
WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC sp_executesql @command
		FETCH NEXT FROM cursed INTO @command
	END
CLOSE cursed DEALLOCATE cursed