/*-----------------------------------------------------------------------------------------------
        NAME: DBA_BK_LastFullBackup.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this template to display information about the last backup for each database.
              You will get NULL values for databases missing from msdb.dbo.backupset
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-----------------------------------------------------------------------------------------------*/
:CONNECT <SQLInstance, sysname, SQLInstance>
USE msdb
GO

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*
[ THIS SCRIPT WILL ONLY RUN ON PRODUCTION BECAUSE THE FUNCTION ON LINE ]
[ 25 WAS CREATED IN PRODUCTION SERVERS ONLY.  FEEL FREE TO SCRIPT OUT  ]
[ THIS UDF AND DEPLOYED TO ANY SERVERS YOU NEED TO GATHER BACKUP INFO  ]
*/

BEGIN
DECLARE @tbl0 TABLE (
        [database_name] varchar(128) PRIMARY KEY,
        backup_finish_date smalldatetime)

DECLARE @backup_type char(1)
SET @backup_type = '<BackupType, sysname, D = Full Backup>' --D = Full Backup; I = Differential; L = Log

--[ GATHERS THE DB NAME AND DATE OF LAST SUCCESSFUL BACKUP ] 
INSERT @tbl0 ([database_name], backup_finish_date)
SELECT database_name,
       MAX(CAST(CONVERT(char(10),backup_finish_date,112) AS SMALLDATETIME)) [backup_finish_date] 
  FROM msdb.dbo.backupset
 WHERE [type] = @backup_type
 GROUP BY database_name
       

--[ DISPLAY GENERAL INFORMATION FOR LAST SUCCESSFUL BACKUP ]       
--[ FOR EACH DATABASE                                      ]
SELECT @@SERVERNAME [ServerName],
       D.[name] [database_name],
       msdb.dbo.fn_CreateTimeString(DATEDIFF(s,A.backup_start_date, A.backup_finish_date)) [BackupDuration],
       STR(CAST(backup_size AS DECIMAL(20,2)) / 1048576 ,10,2) + ' MB' [backup_size],
       C.physical_device_name,
       A.backup_finish_date
  FROM [master].[sys].[databases] D
  LEFT JOIN msdb.dbo.backupset A ON D.[name] = A.[database_name]
  LEFT JOIN @tbl0 B ON A.[database_name] = B.[database_name]
   AND [type] = @backup_type
  LEFT JOIN msdb.dbo.backupMediaFamily C ON A.media_set_id = C.media_set_id
 WHERE (A.backup_finish_date >= B.backup_finish_date
       OR 
        A.backup_finish_date IS NULL)
 ORDER BY D.[name]
END

