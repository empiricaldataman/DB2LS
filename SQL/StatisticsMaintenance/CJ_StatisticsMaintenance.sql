USE [msdb]
GO

/****** Object:  Job [PRD_ALL_C3_01D_LoadStatistics_OLTP]    Script Date: 10/11/2017 1:18:52 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/11/2017 1:18:52 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PRD_ALL_C3_01D_LoadStatistics_OLTP', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Collects statistics metadata for SQL instance/database', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sad', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LoadStatistics - RCHPWCCRPSQL01B\ORIGINATIONS]    Script Date: 10/11/2017 1:18:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LoadStatistics - RCHPWCCRPSQL01B\ORIGINATIONS', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -noprofile Set-Location "D:\SQLScripts"; .\SMO_LoadStatisticsMetadata.ps1 -SQLInstanceSource "RCHPWCCRPSQL01B.PROD.CORPINT.NET\ORIGINATIONS"', 
		@output_file_name=N'D:\SQLJobLogs\PRD_ALL_C3_01D_LoadStatistics_OLTP.out', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LoadStatistics - RCHPWCCRPSQL01A\SERVICING]    Script Date: 10/11/2017 1:18:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LoadStatistics - RCHPWCCRPSQL01A\SERVICING', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -noprofile Set-Location "D:\SQLScripts"; .\SMO_LoadStatisticsMetadata.ps1 -SQLInstanceSource "RCHPWCCRPSQL01A.PROD.CORPINT.NET\SERVICING"', 
		@output_file_name=N'D:\SQLJobLogs\PRD_ALL_C3_01D_LoadStatistics_OLTP.out', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LoadStatistics - RCHPWCCRPSQL01C\WEB]    Script Date: 10/11/2017 1:18:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LoadStatistics - RCHPWCCRPSQL01C\WEB', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -noprofile Set-Location "D:\SQLScripts"; .\SMO_LoadStatisticsMetadata.ps1 -SQLInstanceSource "RCHPWCCRPSQL01C.PROD.CORPINT.NET\WEB"', 
		@output_file_name=N'D:\SQLJobLogs\PRD_ALL_C3_01D_LoadStatistics_OLTP.out', 
		@flags=2
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
		@active_end_time=235959, 
		@schedule_uid=N'4d517ebe-4876-48b7-8f26-c59d11f84c77'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


