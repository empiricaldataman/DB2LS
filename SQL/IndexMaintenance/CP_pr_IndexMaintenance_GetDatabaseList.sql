USE [msdb]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
-------------------------------------------------------------------------------------------------
        NAME: pr_IndexMaintenance_GetDatabaseList.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Returns the list of databases to collect index fragmentation from
-------------------------------------------------------------------------------------------------
  CHANGE HISTORY:
   DATE        MODIFIED      DESCRIPTION   
-- 02.20.2018  SYOUNG        Create procedure
-- 02.22.2018  SYOUNG        Added @Name and @Clause variables to handle database exclusion/inclusion
                             capability.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[pr_IndexMaintenance_GetDatabaseList]
      @Name VARCHAR(50) = 'DatabasesToExclude'
AS 

SET NOCOUNT ON

DECLARE @TSQL nvarchar(4000)
      , @DBLIST nvarchar(4000)
      , @Clause VARCHAR(8)

IF @Name <> 'DatabasesToExclude' SET @Clause = 'IN' ELSE SET @Clause = 'NOT IN'

SELECT @DBLIST = N''''+ REPLACE([value],',',''',''') ++'''' FROM msdb.dbo.IndexMaintenanceConfig WHERE [name] = ''+ @Name +''

IF OBJECT_ID(N'msdb.dbo.IndexMaintenanceConfig','U') IS NOT NULL 

SELECT @TSQL = N'SELECT [name] [database_name]'+ CHAR(10)+
      'FROM master.sys.databases'+ CHAR(10)+
	  'WHERE state_desc = ''ONLINE'' AND [name] '+ @Clause +' ('+ @DBLIST +') ORDER BY [name]'

EXEC(@TSQL) 
GO
