--Check size and logical name of log file
EXEC GLOBAL.dbadmin.DbFileSpaceUsage @database = 'USDA_NASS_V2'

--Shrink file
DBCC SHRINKFILE (N'USDA_NASS_V2_log' , 2048)

--Take backup to enable further shrinking if necessary 
BACKUP LOG [USDA_NASS_V2] TO  DISK = N'E:\Backup\USDA_NASS_V2_20220216.trn' WITH STATS = 5
