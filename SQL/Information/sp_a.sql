IF OBJECT_ID(N'dbo.sp_a','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_a
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_a.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays all active processes
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
CREATE PROCEDURE [dbo].[sp_a]
       @login_name VARCHAR(25) = NULL 

AS

IF @login_name IS NOT NULL
   BEGIN
   SELECT CONVERT(VARCHAR(10),GETDATE(),101) [date]
        , CONVERT(VARCHAR(8),GETDATE(),108) [time]
        , RIGHT('    '+CONVERT(VARCHAR(4),des.session_id),4) [spid]
        , CONVERT(VARCHAR(12),des.status) [status]
        , CONVERT(VARCHAR(25),des.original_login_name) [login_name]
        , CONVERT(VARCHAR(20),ISNULL(des.program_name,'')) [program_name]
        , CONVERT(VARCHAR(20),ISNULL(der.command,'')) [command]
        , CONVERT(VARCHAR(20),DB_NAME(p.dbid)) [database_name]
        , CONVERT(VARCHAR(20),ISNULL(des.host_name,'')) [host_name]
        , DATEDIFF(MINUTE,des.last_request_start_time,GETDATE()) [minutes]
        , RIGHT('        '+CONVERT(VARCHAR(8),ISNULL(des.host_process_id,0)),8) [hpid]
        , RIGHT('    '+CONVERT(VARCHAR(4),ISNULL(der.blocking_session_id,0)),4) [blk]
        , RIGHT('        '+CONVERT(VARCHAR(8),p.waittime/1000),8) [wait_sec]
        , RIGHT('          '+CONVERT(VARCHAR(10),p.cpu),10) [cpu_ms]
        , RIGHT('            '+CONVERT(VARCHAR(12),p.physical_io * 8),12) [reads_kb]
        , RIGHT('          '+CONVERT(VARCHAR(10),des.writes * 8),10) [writes_kb]
     FROM master.sys.dm_exec_sessions des WITH (NOLOCK)
     JOIN master.sys.dm_exec_requests der WITH (NOLOCK) ON des.session_id = der.session_id
     LEFT OUTER JOIN master.sys.sysprocesses p WITH (NOLOCK) ON des.session_id = p.spid
    WHERE des.is_user_process != 0
      AND des.session_id != @@SPID
      AND des.original_login_name = @login_name
    ORDER BY des.session_id
END
ELSE
    BEGIN
    SELECT CONVERT(VARCHAR(10),GETDATE(),101) [date]
         , CONVERT(VARCHAR(8),GETDATE(),108) [time]
         , RIGHT('    '+CONVERT(VARCHAR(4),des.session_id),4) [spid]
         , CONVERT(VARCHAR(12),des.status) [status]
         , CONVERT(VARCHAR(25),des.original_login_name) [login_name]
         , CONVERT(VARCHAR(20),ISNULL(des.program_name,'')) [program_name]
         , CONVERT(VARCHAR(20),ISNULL(der.command,'')) [command]
         , CONVERT(VARCHAR(20),DB_NAME(p.dbid)) [database_name]
         , CONVERT(VARCHAR(20),ISNULL(des.host_name,'')) [host_name]
         , DATEDIFF(MINUTE,des.last_request_start_time,GETDATE()) [minutes]
         , RIGHT('        '+CONVERT(VARCHAR(8),ISNULL(des.host_process_id,0)),8) [hpid]
         , RIGHT('    '+CONVERT(VARCHAR(4),ISNULL(der.blocking_session_id,0)),4) [blk]
         , RIGHT('        '+CONVERT(VARCHAR(8),p.waittime/1000),8) [wait_sec]
         , RIGHT('          '+CONVERT(VARCHAR(10),p.cpu),10) [cpu_ms]
         , RIGHT('            '+CONVERT(VARCHAR(12),p.physical_io * 8),12) [reads_kb]
         , RIGHT('          '+CONVERT(VARCHAR(10),des.writes * 8),10) [writes_kb]
      FROM master.sys.dm_exec_sessions des WITH (NOLOCK)
      JOIN master.sys.dm_exec_requests der WITH (NOLOCK) ON des.session_id = der.session_id
      LEFT OUTER JOIN master.sys.sysprocesses p WITH (NOLOCK) ON des.session_id = p.spid
     WHERE des.is_user_process != 0
       AND des.session_id != @@SPID
     ORDER BY des.session_id
END

GO
