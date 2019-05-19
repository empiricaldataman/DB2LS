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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'RDX - XE_Monitor_Performance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Captures data from extended event XE_Monitor_Performance and saves it in the DPR database.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check State', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF (SELECT ''TRUE''
      FROM sys.dm_xe_session_targets xet
     INNER JOIN sys.dm_xe_sessions xes ON xes.address = xet.event_session_address
     WHERE 1 = 1
       AND xes.[name] = ''XE_Monitor_Performance''
       AND xet.target_name = ''ring_buffer'') IS NULL
   BEGIN
   ALTER EVENT SESSION [XE_Monitor_Performance] ON SERVER
   STATE = START;
   PRINT N''The extended event session XE_Monitor_Performance was started on ''+ CONVERT(VARCHAR(25), GETDATE(), 100) +''.''
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect Data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON

IF OBJECT_ID(N''tempdb..#T1'',''U'') IS NOT NULL
   DROP TABLE #T1

IF OBJECT_ID(N''tempdb..#XE_Monitor_Performance'',''U'') IS NOT NULL
   DROP TABLE #XE_Monitor_Performance
GO

CREATE TABLE #XE_Monitor_Performance (
	[name] [varchar](128) NULL,
	[timestamp] [datetime] NULL,
	[timestamp (UTC)] [datetimeoffset](7) NULL,
	[cpu_time] [decimal](28, 0) NULL,
	[duration] [decimal](28, 0) NULL,
	[physical_reads] [decimal](28, 0) NULL,
	[logical_reads] [decimal](28, 0) NULL,
	[writes] [decimal](28, 0) NULL,
	[result] [varchar](64) NULL,
	[row_count] [decimal](20, 0) NULL,
	[connection_reset_option] [varchar](128) NULL,
	[object_name] [nvarchar](256) NULL,
	[statement] [nvarchar](max) NULL,
	[data_stream] [varbinary](max) NULL,
	[output_parameters] [varchar](256) NULL,
	[username] [varchar](128) NULL,
	[transaction_sequence] [decimal](20, 0) NULL,
	[transaction_id] [bigint] NULL,
	[session_id] [int] NULL,
	[server_principal_name] [varchar](128) NULL,
	[query_hash] [decimal](20, 0) NULL,
	[database_name] [varchar](128) NULL,
	[client_hostname] [varchar](128) NULL,
	[spills] [decimal](20, 0) NULL,
	[batch_text] [nvarchar](max) NULL,
	[sql_text] [nvarchar](max) NULL)

CREATE CLUSTERED INDEX CIX_#XE_Monitor_Performance ON  #XE_Monitor_Performance ([timestamp], session_id)

SELECT CAST(xet.target_data AS XML) [target_data]
  INTO #T1
  FROM sys.dm_xe_session_targets xet
 INNER JOIN sys.dm_xe_sessions xes ON xes.address = xet.event_session_address
 WHERE 1 = 1
   AND xes.[name] = ''XE_Monitor_Performance''
   AND xet.target_name = ''ring_buffer''

INSERT INTO #XE_Monitor_Performance
SELECT i.event_data.value(''(@name)'',''varchar(128)'') [name]
     , DATEADD(hh,-6,i.event_data.value(''(@timestamp)'',''datetime2'')) [timestamp]
     , i.event_data.value(''(@timestamp)'',''datetime2'') [timestamp (UTC)]
     , i.event_data.value(''(data[@name="cpu_time"]/value)[1]'',''bigint'') [cpu_time]
     , i.event_data.value(''(data[@name="duration"]/value)[1]'',''bigint'') [duration]
     , i.event_data.value(''(data[@name="physical_reads"]/value)[1]'',''bigint'') [physical_reads]
     , i.event_data.value(''(data[@name="logical_reads"]/value)[1]'',''bigint'') [logical_reads]
     , i.event_data.value(''(data[@name="writes"]/value)[1]'',''bigint'') [writes]
     , i.event_data.value(''(data[@name="result"]/value)[1]'',''varchar(32)'') [result]
     , i.event_data.value(''(data[@name="row_count"]/value)[1]'',''bigint'') [row_count]
     , NULL [connection_reset_option] --[varchar](128)
     , i.event_data.value(''(data[@name="object_name"]/value)[1]'',''varchar(128)'') [object_name]
     , i.event_data.value(''(data[@name="statement"]/value)[1]'',''varchar(max)'') [statement]
     , NULL [data_stream] --[varbinary](max)
	   , NULL [output_parameters] --[varchar](256)
     , i.event_data.value(''(action[@name="username"]/value)[1]'',''nvarchar(2000)'') [user_name]
     , NULL [transaction_sequence] --[decimal](20, 0)
	   , NULL [transaction_id] --[bigint]
     , i.event_data.value(''(action[@name="session_id"]/value)[1]'',''int'') [session_id]
	   , NULL [server_principal_name] --[varchar](128)
	   , NULL [query_hash] --[decimal](20, 0)
     , i.event_data.value(''(action[@name="database_name"]/value)[1]'',''nvarchar(128)'') [database_name]
     , i.event_data.value(''(action[@name="client_hostname"]/value)[1]'',''nvarchar(128)'') [client_hostname]
	   , NULL [spills] --[decimal](20, 0)
	   , NULL [batch_text] --[nvarchar](max)
     , i.event_data.value(''(action[@name="sql_text"]/value)[1]'',''varchar(max)'') [sql_text]
  FROM #T1 A
 CROSS APPLY A.[target_data].nodes(''/RingBufferTarget/event'') i(event_data)
 
 INSERT INTO DBA.dbo.XE_Monitor_Performance
 SELECT A.* 
   FROM #XE_Monitor_Performance A 
   LEFT JOIN [DBA].[dbo].[XE_Monitor_Performance] B ON A.[timestamp] = B.timestamp
    AND A.session_id = B.session_id
  WHERE B.[timestamp] IS NULL', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table Maintenance', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON
-- RUNS DAILY AFTER MIDNIGHT BEFORE 1AM
IF ((DATEPART(minute,GETDATE()) < 59) AND DATEPART(hour,GETDATE()) < 1)
   DELETE FROM [DBA].[dbo].[XE_Monitor_Performance]
    WHERE [timestamp] < DATEADD(dd,-60,GETDATE())

PRINT CAST(GETDATE() AS VARCHAR) +'' - ''+ CAST(@@ROWCOUNT AS VARCHAR) +'' records were removed from [DBA].[dbo].[XE_Monitor_Performance].''', 
		@database_name=N'DPR', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'30 Minutes', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20181108, 
		@active_end_date=99991231, 
		@active_start_time=0, 
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

