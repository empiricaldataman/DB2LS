/*
-------------------------------------------------------------------------------------------------
        NAME: DB_OwnershipChange.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to change the database ownership to sa.
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
USE master
GO

SET NOCOUNT ON

DECLARE @dbName nvarchar(128)
      , @SQL nvarchar(4000)
      , @ParamDefinition nvarchar(500)
      , @db nvarchar(128)

DECLARE C CURSOR
    FOR SELECT D.[name]
          FROM master.sys.databases D
          LEFT JOIN master.sys.syslogins L ON D.owner_sid = L.[sid]
         WHERE (L.[name] IS NULL OR L.[name] <> 'sa')
   OPEN C
  FETCH NEXT FROM C INTO @dbName
  WHILE @@FETCH_STATUS = 0
        BEGIN
        SET @db = @dbName
        SELECT @SQL = N'USE ['+ @db +']'+ CHAR(10) +
                       'EXEC dbo.sp_changedbowner @loginame = N''sa'', @map = false'+ CHAR(10)
        SET @ParamDefinition = N'@db nvarchar(128)'

        EXEC sp_executesql @SQL
                         , @ParamDefinition
                         , @db = @dbName
        FETCH NEXT FROM C INTO @dbName
    END 
  CLOSE C
DEALLOCATE C