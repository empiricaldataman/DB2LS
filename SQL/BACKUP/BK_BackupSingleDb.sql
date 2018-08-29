DECLARE @backuplistTVP AS BackupList;

DECLARE @db TABLE (
	database_id int,
	database_name sysname,	
	recovery_model varchar(12));

INSERT INTO @backuplistTVP (database_id, database_name, recovery_model)
SELECT 8
     , 'Archive'
     , 'SIMPLE'
 
EXEC msdb.dbo.pr_BackupFullorDiff 'D', 'RCHPWCCRPSQL50A\REPORTING01', 0, 999999999, @backuplistTVP
