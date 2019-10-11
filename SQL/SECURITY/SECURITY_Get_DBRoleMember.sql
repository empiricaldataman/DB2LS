/*
-------------------------------------------------------------------------------------------------
        NAME: SECURITY_Get_DBRoleMember.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays database user role membership.
-------------------------------------------------------------------------------------------------
     HISTORY:
   TR/PROJ#    DATE        MODIFIED      DESCRIPTION
               09.13.2019  SYOUNG        Initival version.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SELECT CONVERT(varchar(24), GETDATE(), 120) [date_time]
     , @@SERVERNAME [instance_name]
     , DB_NAME() [database_name]
     , R.[name] [database_role]
     , ISNULL(M.[name], 'NO MEMBER') [user_name]
  FROM sys.database_role_members RM  
 RIGHT OUTER JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id  
  LEFT OUTER JOIN sys.database_principals M ON RM.member_principal_id = M.principal_id  
 WHERE 1 = 1
   AND R.[type] = 'R'
 ORDER BY R.[name];  
GO
