USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseFileStats Collect', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON

DECLARE @file_type CHAR(1)
      , @database_name VARCHAR(128)
      , @include_mnts bit
      , @sql_string nvarchar(4000)

SELECT @file_type = ''a''
     , @include_mnts = 1


CREATE TABLE #log_statistics (
       [database_name] VARCHAR(200),
       [log_size_mb] NUMERIC(18,2),
       [log_used_pct] NUMERIC(18,2),
       [log_status] INT)

CREATE TABLE #file_list	(
       [database_name] VARCHAR(200),
       [filegroup_name] VARCHAR(200) NULL,
       [file_id] INT,
       [file_name] VARCHAR(200),
       [volume_mount_point] VARCHAR(200),
       [file_path] VARCHAR(200),
       [file_size] INT,
       [max_size] BIGINT,
       [growth_size] INT,
       [growth_type] INT,
       [file_type] INT,
       [drive] CHAR(1),
       [used_size] INT NULL,
       [disk_size] INT NULL,
       [free_space] INT NULL)

CREATE TABLE #file_statistics (
       [file_id] INT,
       [filegroup_id] INT,
       [total_extents] INT,
       [used_extents] INT,
       [database_name] VARCHAR(200),
       [file_path] VARCHAR(200))

INSERT #log_statistics EXEC(''DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS'')

   DECLARE database_cursor CURSOR 
       FOR SELECT [name] FROM master.sys.databases WITH (NOLOCK) WHERE state_desc = ''ONLINE'' ORDER BY [name]
  
  OPEN database_cursor
 FETCH NEXT
  FROM database_cursor INTO @database_name

   WHILE @@FETCH_STATUS = 0
         BEGIN
         SET @sql_string = ''USE ['' + @database_name +'']''
         SET @sql_string = @sql_string + '' TRUNCATE TABLE #file_statistics''
         SET @sql_string = @sql_string + '' INSERT #file_statistics EXEC(''''DBCC SHOWFILESTATS WITH NO_INFOMSGS'''')''
         EXEC sp_executesql @sql_string
         SET @sql_string = ''INSERT #file_list''
         SET @sql_string = @sql_string + '' SELECT database_name='''''' + DB_NAME(DB_ID(@database_name)) + '''''', fg.name, df.file_id, df.name, s.volume_mount_point, df.physical_name, df.size, df.max_size, df.growth, df.is_percent_growth, df.type, drive=UPPER(LEFT(df.physical_name,1)), fs.used_extents, CONVERT(INT,ROUND(s.total_bytes /1024.0/1024/1024,0)), CONVERT(INT,ROUND(s.available_bytes/1024.0/1024/1024,0))''
         SET @sql_string = @sql_string + '' FROM ['' + @database_name + ''].sys.database_files df WITH (NOLOCK)''
         SET @sql_string = @sql_string + '' LEFT OUTER JOIN ['' + @database_name + ''].sys.filegroups fg WITH (NOLOCK) ON df.data_space_id = fg.data_space_id''
         SET @sql_string = @sql_string + '' LEFT OUTER JOIN #file_statistics fs WITH (NOLOCK) ON df.file_id = fs.file_id''
         SET @sql_string = @sql_string + '' CROSS APPLY sys.dm_os_volume_stats(DB_ID('''''' + @database_name + ''''''), df.file_id) s''
         EXEC sp_executesql @sql_string
         FETCH NEXT FROM database_cursor INTO @database_name
	END
	CLOSE database_cursor
	DEALLOCATE database_cursor

UPDATE fl
   SET used_size = ls.log_size_mb * ls.log_used_pct / 100 * 1024 / 64
  FROM #file_list fl
  JOIN #log_statistics ls ON fl.[database_name] = ls.[database_name]
 WHERE fl.file_type = 1

INSERT INTO DBA.dbo.DatabaseFileStats
SELECT GETDATE() [date]
     , @@SERVERNAME [instance_name]
     , [database_name] [database_name]
     , file_name [file_name]
     , volume_mount_point [mount_point]
     , file_path [file_path]
     , file_size * 8 / 1024 [size]
     , ISNULL(used_size,0) * 64 / 1024 [used]
     , (file_size * 8 / 1024) - (ISNULL(used_size,0) * 64 / 1024) [free]
     , ISNULL(used_size,0) * 64 / 1024 * 100 / (file_size * 8 / 1024 + 1) [pct]
     , CASE WHEN growth_size = 0 THEN '''' WHEN growth_type = 1 THEN growth_size ELSE growth_size * 8 / 1024 END [growth]
     , CASE max_size WHEN 0 THEN '''' WHEN -1 THEN '''' WHEN 268435456 THEN '''' ELSE max_size * 8 / 1024 END [max]
     , disk_size [drive_size]
     , free_space [drive_free]
  FROM #file_list
 ORDER BY [database_name], file_type, [filegroup_name], [file_id] 
', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DatabaseFileStats Collect 10pm', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190415, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DatabaseFileStats Collect 8am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190415, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=235959

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


