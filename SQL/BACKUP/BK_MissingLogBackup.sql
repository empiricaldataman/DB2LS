/*-----------------------------------------------------------------------------------------------
        NAME: BK_MissingLogBackup.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about databases in full recovery mode that do not have a
              transaction log backup.
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    07.14.2018  SYoung        Initial creation.
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

BEGIN

DECLARE @backup_type char(1)
SET @backup_type = 'D' --D = Full Backup; I = Differential; L = Log

SELECT @@SERVERNAME [instance_name],
       D.[name] [database_name],
       D.recovery_model,
       D.recovery_model_desc,
       STR(CAST(backup_size AS DECIMAL(20,2)) / 1048576 ,10,2) + ' MB' [backup_size],
       A.backup_finish_date
  FROM [master].[sys].[databases] D
  LEFT JOIN msdb.dbo.backupset A ON D.[name] = A.[database_name]
   AND A.[type] = 'L'
 WHERE 1 = 1
   AND D.recovery_model IN (1,2)
   AND A.[type] IS NULL
   AND D.database_id NOT IN (2,3) 
 ORDER BY D.[name]
END
GO
