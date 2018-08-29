/*-------------------------------------------------------------------------------------------------
        NAME: Role_Server.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays the SQL instance server roles' members.
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    03.20.2018  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			  killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
USE master
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

SELECT CAST(GETDATE() AS [date]) [load_date]
     , @@SERVERNAME [instance_name]
     , A.[name] [login_name]
     , A.[type] [login_type]
     , A.is_disabled [disabled]
     , A.create_date
     , A.modify_date
     , COALESCE(A.default_database_name,'') [default_database]
     , CONVERT(CHAR(1),ISNULL(B.is_policy_checked,0)) [login_check_policy]
     , CONVERT(CHAR(1),ISNULL(B.is_expiration_checked,0)) [login_check_expiration]
     , ISNULL(D.[name],'') [server_principal]
  FROM sys.server_principals A
  LEFT JOIN sys.sql_logins B ON A.principal_id = B.principal_id
  LEFT JOIN sys.server_role_members C ON A.principal_id = C.member_principal_id
  LEFT JOIN sys.server_principals D ON C.role_principal_id = D.principal_id
 WHERE A.[type] IN ('G','S','U')
   AND A.[name] IS NOT NULL
GO
