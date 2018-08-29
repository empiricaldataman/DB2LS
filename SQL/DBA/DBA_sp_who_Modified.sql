/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_sp_who_Modified.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: 
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/

SET NOCOUNT ON

DECLARE @login SYSNAME

SET @login = 'DOMAIN\ADAccount'

DECLARE @Who TABLE (
        SPID INT,
        Ecid INT,  
        [Status] VARCHAR(1000) NULL,  
        [Login] SYSNAME NULL,  
        HostName SYSNAME NULL,  
        BlkBy SYSNAME NULL,  
        DBName SYSNAME NULL,  
        Command VARCHAR(1000) NULL,  
        REQUESTID INT) 


INSERT INTO @Who
EXEC sp_who;


SELECT SPID
     , Ecid
     , [Status]
     , [Login]
     , HostName
     , BlkBy
     , DBName
     , Command
     , REQUESTID
  FROM @Who
 WHERE Login = @login
 UNION
SELECT SPID
     , Ecid
     , [Status]
     , [Login]
     , HostName
     , BlkBy
     , DBName
     , Command
     , REQUESTID
  FROM @Who
 WHERE SPID IN (SELECT SPID
                  FROM @Who
                 WHERE Login = @login)
GO

