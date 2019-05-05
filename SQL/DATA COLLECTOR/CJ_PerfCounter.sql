USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'Collect Performance Counter')
if (@jobId is NULL)
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Collect Performance Counter', 
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

END

IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
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
--SELECT * FROM  RDXDBA.dbo.PerfCounter
INSERT INTO RDXDBA.dbo.PerfCounter
SELECT GETDATE() [collection_time]
     , [User Connections] [processes_blocked]
     , [Free list stalls/sec] [user_connections]
     , [Lazy writes/sec] [free_list_stalls_sec]
     , [Page life expectancy] [lazy_writes_sec]
     , [Full Scans/sec] [page_life_expectancy]
     , [Index Searches/sec] [full_scans_sec]
     , [Batch Requests/sec] [index_searches_sec]
     , [SQL Compilations/sec] [batch_requests_sec]
     , [SQL Re-Compilations/sec] [sql_compilations_sec]
     , [Memory Grants Pending] [sql_re-compilations_sec]
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

IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 2)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Performance Counter', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE RDXDBA.dbo.PerCounter WHERE collection_date <= GETDATE() - 45', 
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

