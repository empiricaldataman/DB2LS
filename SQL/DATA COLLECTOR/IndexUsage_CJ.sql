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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Collect Index Usage', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Collect index usage information for SQL instance/database', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Index Usage', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[sp_foreachdb] @command = N''USE ?
INSERT INTO [DBA].[dbo].[IndexUsage] ([collection_time], [instance_name], [database_name], [schema_name], [table_name], [index_name], [index_seek], [index_scan], [index_lookup], [index_update], [last_used], [last_updated], [days_instance_up])
SELECT GETDATE() [collection_time]
     , @@SERVERNAME [instance_name]
     , DB_NAME(A.database_id) [database_name]
     , D.[name] [schema_name]
     , B.[name] [table_name]
     , C.[name] [index_name]
     , A.user_seeks [index_seek]
     , A.user_scans [index_scan]
     , A.user_lookups [index_lookup]
     , A.user_updates [index_update]
     , COALESCE(A.last_user_seek, A.last_user_scan, A.last_user_lookup) [last_used]
     , A.last_user_update [last_updated]
     , DATEDIFF(dd, (SELECT sqlserver_start_time FROM sys.dm_os_sys_info), GETDATE()) [days_instance_up]
  FROM sys.tables B
 INNER JOIN sys.indexes C ON B.[object_id] = C.[object_id]
 INNER JOIN sys.schemas D ON B.[schema_id] = D.[schema_id]
  LEFT JOIN sys.dm_db_index_usage_stats A ON A.[object_id] = B.[object_id]
 WHERE A.database_id = db_id()
   AND A.database_id > 4
   AND C.index_id = A.index_id
   AND A.[user_seeks] + A.[user_scans] + A.[user_lookups] <= A.user_updates
   AND OBJECTPROPERTY(A.[object_id], ''''IsUserTable'''') = 1
   AND A.[user_seeks] + A.[user_scans] + A.[user_lookups] >= 100''', 
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
		@command=N'DELETE DBA.dbo.IndexUsage WHERE collection_time <= GETDATE() - 45', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Load Index Usage Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180819, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
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
