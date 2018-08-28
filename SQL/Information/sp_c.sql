USE [master]
GO

SET NOCOUNT ON

IF OBJECT_ID(N'dbo.sp_c','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_c
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_c.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about 
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    08.16.2018  SYoung        Re-format T-SQL code
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [dbo].[sp_c]
       @login_name VARCHAR(25) = NULL 

AS

IF @login_name IS NOT NULL
   BEGIN
   SELECT CONVERT(VARCHAR(10),GETDATE(),101) [date]
        , CONVERT(VARCHAR(8),GETDATE(),108) [time]
        , CONVERT(VARCHAR(25),des.original_login_name) [login_name]
        , CONVERT(VARCHAR(80),ISNULL(des.program_name,'')) [program_name]
        , CONVERT(VARCHAR(20),DB_NAME(p.dbid)) [database_name]
        , CONVERT(VARCHAR(20),ISNULL(des.host_name,'')) [host_name]
        , count(*) [connections]
     FROM master.sys.dm_exec_sessions des WITH (NOLOCK)
     LEFT OUTER JOIN master.sys.sysprocesses p WITH (NOLOCK) ON des.session_id = p.spid
    WHERE des.original_login_name = @login_name
    GROUP BY CONVERT(VARCHAR(25),des.original_login_name), CONVERT(VARCHAR(80),ISNULL(des.program_name,'')), CONVERT(VARCHAR(20),DB_NAME(p.dbid)), CONVERT(VARCHAR(20),ISNULL(des.host_name,''))
    ORDER BY connections, CONVERT(VARCHAR(25),des.original_login_name), CONVERT(VARCHAR(80),ISNULL(des.program_name,'')), CONVERT(VARCHAR(20),DB_NAME(p.dbid)), CONVERT(VARCHAR(20),ISNULL(des.host_name,''))
END
ELSE
   BEGIN
   SELECT CONVERT(VARCHAR(10),GETDATE(),101) [date]
        , CONVERT(VARCHAR(8),GETDATE(),108) [time]
        , CONVERT(VARCHAR(25),des.original_login_name) [login_name]
        , CONVERT(VARCHAR(80),ISNULL(des.program_name,'')) [program_name]
        , CONVERT(VARCHAR(20),DB_NAME(p.dbid)) [database_name]
        , CONVERT(VARCHAR(20),ISNULL(des.host_name,'')) [host_name]
        , count(*) [connections]
     FROM master.sys.dm_exec_sessions des WITH (NOLOCK)
     LEFT OUTER JOIN master.sys.sysprocesses p WITH (NOLOCK) ON des.session_id = p.spid
    GROUP BY CONVERT(VARCHAR(25),des.original_login_name), CONVERT(VARCHAR(80),ISNULL(des.program_name,'')), CONVERT(VARCHAR(20),DB_NAME(p.dbid)), CONVERT(VARCHAR(20),ISNULL(des.host_name,''))
    ORDER BY connections, CONVERT(VARCHAR(25),des.original_login_name), CONVERT(VARCHAR(80),ISNULL(des.program_name,'')), CONVERT(VARCHAR(20),DB_NAME(p.dbid)), CONVERT(VARCHAR(20),ISNULL(des.host_name,''))
END
GO
