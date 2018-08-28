USE [master]
GO

IF OBJECT_ID(N'dbo.sp_q','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_q
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_q.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about queries for all active processes
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
CREATE PROCEDURE [dbo].[sp_q]
       @spid INT = NULL

AS

SET NOCOUNT ON

IF @spid IS NOT NULL
BEGIN
	SELECT	date=CONVERT(VARCHAR(10),GETDATE(),101),
		time=CONVERT(VARCHAR(8),GETDATE(),108),
		spid=RIGHT('    '+CONVERT(VARCHAR(4),des.session_id),4),
		status=CONVERT(VARCHAR(12),des.status),
		login_name=CONVERT(VARCHAR(25),des.original_login_name),
		program_name=CONVERT(VARCHAR(20),ISNULL(des.program_name,'')),
		command=CONVERT(VARCHAR(20),ISNULL(der.command,'')),
		database_name=CONVERT(VARCHAR(20),DB_NAME(p.dbid)),
		host_name=CONVERT(VARCHAR(20),ISNULL(des.host_name,'')),
		minutes=DATEDIFF(MINUTE,des.last_request_start_time,GETDATE()),
		hpid=RIGHT('        '+CONVERT(VARCHAR(8),ISNULL(des.host_process_id,0)),8),
		blk=RIGHT('    '+CONVERT(VARCHAR(4),ISNULL(der.blocking_session_id,0)),4),
		wait_sec=RIGHT('        '+CONVERT(VARCHAR(8),p.waittime/1000),8),
--		cpu_ms=RIGHT('          '+CONVERT(VARCHAR(10),des.cpu_time),10),
		cpu_ms=RIGHT('          '+CONVERT(VARCHAR(10),p.cpu),10),
--		reads_kb=RIGHT('            '+CONVERT(VARCHAR(12),des.logical_reads * 8),12),
		reads_kb=RIGHT('            '+CONVERT(VARCHAR(12),p.physical_io * 8),12),
		writes_kb=RIGHT('          '+CONVERT(VARCHAR(10),des.writes * 8),10)
		FROM master.sys.dm_exec_sessions des WITH (NOLOCK)
	LEFT OUTER JOIN master.sys.dm_exec_requests der WITH (NOLOCK) ON des.session_id = der.session_id
	LEFT OUTER JOIN master.sys.sysprocesses p WITH (NOLOCK) ON des.session_id = p.spid
	WHERE des.session_id != @@SPID
	AND des.session_id = @spid
	ORDER BY des.session_id
	
	PRINT ''
	DBCC INPUTBUFFER(@spid) WITH NO_INFOMSGS
END
ELSE
BEGIN
	DECLARE spid_cursor CURSOR FOR 
		SELECT des.session_id
		FROM master.sys.dm_exec_sessions des WITH (NOLOCK)
		JOIN master.sys.dm_exec_requests der WITH (NOLOCK) ON des.session_id = der.session_id
		WHERE des.is_user_process != 0
		AND des.session_id != @@SPID
		ORDER BY des.session_id
	OPEN spid_cursor
	FETCH NEXT FROM spid_cursor INTO @spid
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT	date=CONVERT(VARCHAR(10),GETDATE(),101),
			time=CONVERT(VARCHAR(8),GETDATE(),108),
			spid=RIGHT('    '+CONVERT(VARCHAR(4),des.session_id),4),
			status=CONVERT(VARCHAR(12),des.status),
			login_name=CONVERT(VARCHAR(25),des.original_login_name),
			program_name=CONVERT(VARCHAR(20),ISNULL(des.program_name,'')),
			command=CONVERT(VARCHAR(20),ISNULL(der.command,'')),
			database_name=CONVERT(VARCHAR(20),DB_NAME(p.dbid)),
			host_name=CONVERT(VARCHAR(20),ISNULL(des.host_name,'')),
			minutes=DATEDIFF(MINUTE,des.last_request_start_time,GETDATE()),
			hpid=RIGHT('        '+CONVERT(VARCHAR(8),ISNULL(des.host_process_id,0)),8),
			blk=RIGHT('    '+CONVERT(VARCHAR(4),ISNULL(der.blocking_session_id,0)),4),
			wait_sec=RIGHT('        '+CONVERT(VARCHAR(8),p.waittime/1000),8),
--			cpu_ms=RIGHT('          '+CONVERT(VARCHAR(10),des.cpu_time),10),
			cpu_ms=RIGHT('          '+CONVERT(VARCHAR(10),p.cpu),10),
--			reads_kb=RIGHT('            '+CONVERT(VARCHAR(12),des.logical_reads * 8),12),
			reads_kb=RIGHT('            '+CONVERT(VARCHAR(12),p.physical_io * 8),12),
			writes_kb=RIGHT('          '+CONVERT(VARCHAR(10),des.writes * 8),10)
			FROM master.sys.dm_exec_sessions des WITH (NOLOCK)
		LEFT OUTER JOIN master.sys.dm_exec_requests der WITH (NOLOCK) ON des.session_id = der.session_id
		LEFT OUTER JOIN master.sys.sysprocesses p WITH (NOLOCK) ON des.session_id = p.spid
		WHERE des.session_id = @spid
		AND des.session_id != @@SPID
		ORDER BY des.session_id
	
		PRINT ''
		DBCC INPUTBUFFER(@spid) WITH NO_INFOMSGS
		PRINT ''
		PRINT ''
		FETCH NEXT FROM spid_cursor INTO @spid
	END

	CLOSE spid_cursor
	DEALLOCATE spid_cursor
END
GO
