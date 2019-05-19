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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Collect Statistics', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Collects statistics metadata for SQL instance/database', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
EXEC [dbo].[sp_foreachdb] @command = N''USE ?
INSERT INTO [DBA].[dbo].[Statistics] ([collection_time], [instance_name], [database_name], [schema_name], [table_name], [stat_name], [stat_last_updated], [rows_in_table], [rows_modified], [rows_modified_percent])
SELECT CAST(getdate() AS DATE) [collection_time]
     , @@ServerName [instance_name]
     , DB_NAME() [database_name]
     , sc.name [schema_name]
     , o.name [table_name]
     , [s].[name] [stat_name]
     , [ddsp].[last_updated] [stat_last_updated]
     , [ddsp].[rows] [rows_in_table]
     , [ddsp].[modification_counter] [rows_modified]
     , CAST(100 * [ddsp].[modification_counter] / [ddsp].[rows] AS DECIMAL(18,2)) [rows_modified_percent]
  FROM sys.objects o
  JOIN sys.stats s ON o.object_id = s.object_id
  JOIN sys.schemas sc ON o.schema_id = sc.schema_id
 OUTER APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) ddsp
 WHERE o.type = ''''U''''     --user tables
   AND s.auto_created = 0 --stats creates as part of index creation
   AND ddsp.rows > 1000   --stat having greater than or equal to 1000 rows''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily @ 10:00 AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160211, 
		@active_end_date=99991231, 
		@active_start_time=100000, 
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
