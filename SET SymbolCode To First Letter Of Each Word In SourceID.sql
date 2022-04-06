DECLARE @sourceID VARCHAR(MAX) 
DECLARE @abbreve VARCHAR(MAX)

WHILE EXISTS (SELECT * FROM MetaData WHERE symbolCode IS NULL)
BEGIN
	SET @sourceID = (SELECT TOP 1 sourceID FROM metadata WHERE symbolCode IS NULL)
	SET @abbreve = 
		(SELECT UPPER(LEFT(value,1)) 
		FROM string_split(REPLACE(REPLACE(@sourceID,'-',' '),'/',' '),' ')
		FOR XML PATH (''))
	--SELECT @sourceID,@abbreve

	UPDATE MetaData
	SET symbolCode = CONCAT(UPPER(LEFT(metal,1)),'.',@abbreve)
	WHERE sourceID = @sourceID
END
