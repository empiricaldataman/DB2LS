/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_ServerList.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays a list of SQL servers from the Central Management Sever by using the system
              views in msdb
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000     07.05.2012  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
:CONNECT <server_name, sysname, SQL_Server_Instance>
USE msdb
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON;

WITH CTE1 (ServerApplication, ServerName, ServerDescription, ServerGroupDescription)
  AS (SELECT SG.[name] [ServerGroupName]
           --, S.[name] [ServerName]
           , S.server_name
           , S.[description] ServerDescription
           , SG.[description] ServerGroupDescription
        FROM [dbo].[sysmanagement_shared_registered_servers] S
       INNER JOIN [dbo].[sysmanagement_shared_server_groups] SG ON S.server_group_id = SG.server_group_id
       WHERE SG.[name] LIKE 'APP%')
   , CTE2 (ServerEnvironment, ServerName, ServerDescription, ServerGroupDescription)
  AS (SELECT SG.[name] [ServerGroupName]
           --, S.[name] [ServerName]
           , S.server_name
           , S.[description] ServerDescription
           , SG.[description] ServerGroupDescription
        FROM [dbo].[sysmanagement_shared_registered_servers] S
       INNER JOIN [dbo].[sysmanagement_shared_server_groups] SG ON S.server_group_id = SG.server_group_id
       WHERE SG.[name] LIKE 'ENV%')
   , CTE3 (ServerVersion, ServerName, ServerDescription, ServerGroupDescription)
  AS (SELECT SG.[name] [ServerGroupName]
           --, S.[name] [ServerName]
           , S.server_name
           , S.[description] ServerDescription
           , SG.[description] ServerGroupDescription
        FROM [dbo].[sysmanagement_shared_registered_servers] S
       INNER JOIN [dbo].[sysmanagement_shared_server_groups] SG ON S.server_group_id = SG.server_group_id
       WHERE SG.[name] LIKE 'VER%')
   , CTE4 (ServerName)
  AS (SELECT UPPER(S.server_name)
        FROM [dbo].[sysmanagement_shared_registered_servers] S
       INNER JOIN [dbo].[sysmanagement_shared_server_groups] SG ON S.server_group_id = SG.server_group_id
       GROUP BY S.server_name)
 
 SELECT CTE4.ServerName
      , CTE1.ServerDescription
      , CTE2.ServerEnvironment
      , CTE1.ServerApplication
      , CTE3.ServerVersion
   FROM CTE4
   LEFT JOIN CTE1 ON CTE4.ServerName = CTE1.ServerName
   LEFT JOIN CTE2 ON CTE4.ServerName = CTE2.ServerName
   LEFT JOIN CTE3 ON CTE4.ServerName = CTE3.ServerName
  ORDER BY CTE1.ServerApplication, CTE2.ServerEnvironment;
 GO