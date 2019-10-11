/*
-------------------------------------------------------------------------------------------------
        NAME: SECURITY_DB_USER_RIGHTS.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays database user role membership and explicit rights.
-------------------------------------------------------------------------------------------------
     HISTORY:
   TR/PROJ#    DATE        MODIFIED      DESCRIPTION
               09.19.2018  SYOUNG        Initival version.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
USE [master]
GO

IF OBJECT_ID(N'tempdb..#T1','U') IS NOT NULL
   DROP TABLE #T1
GO

CREATE TABLE #T1 ([database_name] sysname, DatabaseRoleName sysname, DatabaseUserName sysname)

EXEC sp_foreachdb @command = N'USE ?; 
INSERT INTO #T1
SELECT DB_NAME()
     , DP1.name AS DatabaseRoleName
     , isnull (DP2.name, ''No members'') AS DatabaseUserName   
  FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1 ON DRM.role_principal_id = DP1.principal_id  
  LEFT OUTER JOIN sys.database_principals AS DP2 ON DRM.member_principal_id = DP2.principal_id  
 WHERE DP1.type = ''R'''
                , @replace_character = N'?'



IF OBJECT_ID(N'tempdb..#T3','U') IS NOT NULL
   DROP TABLE #T3
GO

CREATE TABLE #T3 ([database_name] sysname, [owner] sysname, [Object] sysname, [Grantee] sysname, [Grantor] sysname, [ProtectType] sysname, [Action] sysname, [Column] sysname)

EXEC sp_foreachdb @command = N'USE ?;
CREATE TABLE #T2 ([owner] sysname, [Object] sysname, [Grantee] sysname, [Grantor] sysname, [ProtectType] sysname, [Action] sysname, [Column] sysname); 
INSERT INTO #T2
exec sp_helprotect @permissionarea = ''o'';
INSERT INTO #T3
SELECT DB_NAME(), [owner], [Object], [Grantee], [Grantor], [ProtectType], [Action], [Column] FROM #T2;
DROP TABLE #T2;'
                , @replace_character = N'?'

SELECT * 
  FROM #T1

SELECT * 
  FROM #T3
 