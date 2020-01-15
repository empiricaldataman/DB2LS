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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Collect Performance Counter', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Collect performance counters from SQL instance', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect Performance Counter', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON

INSERT INTO DBA.dbo.PerfCounter ([collection_time], [processes_blocked], [user_connections], [free_list_stalls_sec], [lazy_writes_sec], [page_life_expectancy], [full_scans_sec], [index_searches_sec], [batch_requests_sec], [sql_compilations_sec], [sql_re-compilations_sec], [memory_grants_pending])
SELECT GETDATE() [collection_time]
     , [Processes blocked] [processes_blocked]
     , [User Connections]  [user_connections]
     , [Free list stalls/sec] [free_list_stalls_sec]
     , [Lazy writes/sec] [lazy_writes_sec]
     , [Page life expectancy] [page_life_expectancy]
     , [Full Scans/sec] [full_scans_sec]
     , [Index Searches/sec] [index_searches_sec]
     , [Batch Requests/sec] [batch_requests_sec]
     , [SQL Compilations/sec] [sql_compilations_sec]
     , [SQL Re-Compilations/sec] [sql_re-compilations_sec]
     , [Memory Grants Pending] [memory_grants_pending]
  FROM (SELECT counter_name
             , cntr_value
          FROM sys.dm_os_performance_counters
         WHERE 1 = 1
           AND [instance_name] = ''''
           AND [counter_name] IN (''Processes blocked'',''User Connections'',''Free list stalls/sec'',''Lazy writes/sec'',''Page life expectancy'',''Full Scans/sec'',''Index Searches/sec'',''Batch Requests/sec'',''SQL Compilations/sec'',''SQL Re-Compilations/sec'',''Memory Grants Pending'')) ST
 PIVOT (MAX(cntr_value) FOR counter_name IN ([Processes blocked]
     , [User Connections]
     , [Free list stalls/sec]
     , [Lazy writes/sec]
     , [Page life expectancy]
     , [Full Scans/sec]
     , [Index Searches/sec]
     , [Batch Requests/sec]
     , [SQL Compilations/sec]
     , [SQL Re-Compilations/sec]
     , [Memory Grants Pending])) PT
', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table Maintenance', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE DBA.dbo.PerfCounter WHERE collection_time <= GETDATE() - 45', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Collect Performance Counter 1 Hour', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190504, 
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
