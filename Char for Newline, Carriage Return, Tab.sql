



DECLARE
	@NL varchar(1) = CHAR(10),
	@CR varchar(1) = CHAR(13),
	@tab varchar(1) = CHAR(9),
	@enter varchar(2) = CHAR(13) + CHAR(10), --order important
	@statement VARCHAR(MAX) = ''

SET @statement = 
'Line One (1)' + @NL +
'Line Two (2)' + @CR +
@tab + 'Tab and Line Three (3)' + @enter +
'Line Four (5)'

PRINT @statement


/*
Char(10) – New Line / Line Break
Char(13) – Carriage Return
Char(9) – Tab
*/


