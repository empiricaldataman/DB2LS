/*
-------------------------------------------------------------------------------------------------
        NAME: SECURITY_AZDB_USER_RIGHTS.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this queries to view permissions at different levels
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
--[ PERMISSION BY DATABASE ROLES
SELECT CONVERT(varchar(24), GETDATE(), 120) [collection_time]
     , @@SERVERNAME [instance_name]
     , DB_NAME() [database_name]
     , R.[name] [database_role]
     , ISNULL(M.[name], 'NO MEMBER') [user_name]
  FROM sys.database_role_members RM  
 RIGHT OUTER JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id  
  LEFT OUTER JOIN sys.database_principals M ON RM.member_principal_id = M.principal_id  
 WHERE 1 = 1
   AND R.[type] = 'R'
   AND M.[name] IS NOT NULL
   --AND R.[name] IN ('dbmanager','loginmanager')  --[ FIND OUT WHO HAS ELEVATED RIGHTS ON AZURE SQL DATABASE
 ORDER BY R.[name];  
GO

--[ PERMISSION BY DATABASE USERS
SELECT GETDATE() [collection_time]
     , UPPER(@@SERVERNAME) [instance_name]
     , DB_NAME() [database_name]
     , pr.[name]
     , pr.[type_desc]
     , pr.authentication_type_desc
     , pe.state_desc
     , pe.[permission_name]
     , OBJECT_NAME(pe.major_id) [object]
  FROM sys.database_principals AS pr  
  LEFT JOIN sys.database_permissions AS pe ON pe.grantee_principal_id = pr.principal_id
 WHERE 1 = 1
   AND pr.[name] NOT IN ('public','guest','dbo','INFORMATION_SCHEMA','##MS_PolicyEventProcessingLogin##','##MS_AgentSigningCertificate##')
   AND COALESCE(pe.state_desc, pe.[permission_name], OBJECT_NAME(pe.major_id)) IS NOT NULL


--[ SQL INSTANCE LOGINS
SELECT [name]
     , [type_desc]
     , is_disabled
     , create_date
  FROM sys.server_principals
 WHERE 1 = 1
   AND is_fixed_role = 0
   AND [name] NOT LIKE '#%'
   AND [name] NOT LIKE 'NT_%'
   AND [name] NOT IN ('sa','public')


SELECT [name]
     , [type_desc]
     , [create_date]
     , [authentication_type_desc]
  FROM sys.database_principals
 WHERE 1 = 1
   AND is_fixed_role = 0
   AND [name] NOT IN ('sa','public','dbo','guest','sys','INFORMATION_SCHEMA')
 ORDER BY [type], [name]