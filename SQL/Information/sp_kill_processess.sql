USE [master]
GO

IF OBJECT_ID(N'dbo.sp_kill_processes','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_kill_processes
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_kill_processes.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Parameter driven KILL
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
CREATE PROCEDURE [dbo].[sp_kill_processes]
       @database_name VARCHAR(100) = NULL
     , @include_list VARCHAR(2000) = NULL
     , @exclude_list VARCHAR(2000) = NULL
     , @blocking CHAR(1) = NULL

AS

SET NOCOUNT ON

DECLARE	@sql_string VARCHAR(4000)
      , @session_id INT
      , @login_name VARCHAR(100)
      , @db_name VARCHAR(100)
      , @host_name VARCHAR(100)
      , @status VARCHAR(100)
      , @program_name VARCHAR(100)
      , @command VARCHAR(100)
      , @login_time DATETIME
      , @last_batch DATETIME

CREATE TABLE #kill_list	(
       session_id INT
     , login_name VARCHAR(100)
     , db_name VARCHAR(100)
     , host_name VARCHAR(100)
     , status VARCHAR(100)
     , program_name VARCHAR(100)
     , command VARCHAR(100)
     , login_time DATETIME
     , last_batch DATETIME)

IF @database_name IS NOT NULL
   BEGIN
   IF NOT EXISTS (SELECT * FROM master.sys.databases WHERE name = @database_name)
	  BEGIN
      RAISERROR ('The %s database does not exist on this SQL Server instance.', 16, 1, @database_name)
      RETURN -1
   END
END

SET	@sql_string = 'INSERT #kill_list'
SET	@sql_string = @sql_string + ' SELECT DISTINCT des.session_id, login_name=des.original_login_name, db_name=d.name, des.host_name, des.status, des.program_name, command=ISNULL(der.command,''''), des.login_time, last_batch=des.last_request_start_time'
SET	@sql_string = @sql_string + ' FROM master.sys.dm_exec_sessions des WITH (NOLOCK)'
SET	@sql_string = @sql_string + ' LEFT OUTER JOIN master.sys.dm_exec_requests der WITH (NOLOCK) ON des.session_id = der.session_id'
SET	@sql_string = @sql_string + ' LEFT OUTER JOIN master.sys.sysprocesses p WITH (NOLOCK) ON des.session_id = p.spid'
SET	@sql_string = @sql_string + ' LEFT OUTER JOIN master.sys.databases d WITH (NOLOCK) ON p.dbid = d.database_id'
SET	@sql_string = @sql_string + ' WHERE des.is_user_process != 0'
SET	@sql_string = @sql_string + ' AND des.session_id != @@SPID'
IF	@database_name IS NOT NULL SET @sql_string = @sql_string + ' AND d.name = ''' + @database_name + ''''
IF	@include_list IS NOT NULL SET @sql_string = @sql_string + ' AND des.original_login_name IN (' + @include_list + ') '
IF	@exclude_list IS NOT NULL SET @sql_string = @sql_string + ' AND des.original_login_name NOT IN (' + @exclude_list + ') '
IF	@blocking = 'Y' SET @sql_string = @sql_string + ' AND ISNULL(der.blocking_session_id,0) = 0 AND des.session_id IN (SELECT blocking_session_id FROM master.sys.dm_exec_requests WITH (NOLOCK) WHERE blocking_session_id != 0)'

EXEC	(@sql_string)

DECLARE kill_cursor CURSOR
    FOR SELECT session_id, login_name, db_name, host_name, status, program_name, command, login_time, last_batch
   FROM #kill_list

   OPEN kill_cursor
  FETCH NEXT FROM kill_cursor 
   INTO @session_id, @login_name, @db_name, @host_name, @status, @program_name, @command, @login_time, @last_batch

WHILE @@FETCH_STATUS = 0	
      BEGIN
      PRINT 'Killing spid ' + RIGHT('    ' + CONVERT(VARCHAR,@session_id),4) + ':  ' + RTRIM(@login_name) + ', ' + RTRIM(@db_name) + ', ' + RTRIM(@host_name) + ', ' + RTRIM(@status) + ', ' + RTRIM(@program_name) + ', ' + RTRIM(@command) + ', ' + RTRIM(CONVERT(VARCHAR,@login_time,109)) + ', ' + RTRIM(CONVERT(VARCHAR,@last_batch,109))
      SELECT @sql_string = 'kill ' + CONVERT(VARCHAR,@session_id)
      BEGIN TRY
         EXEC (@sql_string)
      END TRY
      BEGIN CATCH
         PRINT 'Could not kill SPID ' +  CAST(@session_id as varchar(5)) + ', ' + RTRIM(@db_name) + ', ' + RTRIM(@host_name) + ', ' + RTRIM(CONVERT(VARCHAR,@login_time,109)) 
      END CATCH
      FETCH NEXT FROM kill_cursor 
      INTO @session_id, @login_name, @db_name, @host_name, @status, @program_name, @command, @login_time, @last_batch
END
CLOSE kill_cursor
DEALLOCATE kill_cursor
GO
