/*
-------------------------------------------------------------------------------------------------
        NAME: DB_RecoveryModelChange.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to change the recovery model to simple on all databases in an SQL
              instance. Normally used in lower environments where backups are not necessary.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
--             06.17.2014  SYOUNG        Created on this date
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
USE [master]
GO

SET NOCOUNT ON

DECLARE @dbName nvarchar(128)
      , @SQL nvarchar(4000)

DECLARE C CURSOR
    FOR SELECT [name] FROM master.sys.databases WHERE recovery_model_desc = 'FULL'
   OPEN C
  FETCH NEXT FROM C INTO @dbName
  WHILE @@FETCH_STATUS = 0
        BEGIN
        SELECT @SQL = N'ALTER DATABASE ['+ @dbName +'] SET RECOVERY SIMPLE WITH NO_WAIT'
        EXEC sp_executesql @SQLString = @SQL
        FETCH NEXT FROM C INTO @dbName
    END 
  CLOSE C
DEALLOCATE C
GO