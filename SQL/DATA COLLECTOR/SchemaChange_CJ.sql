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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'!RDX - Collect Schema Change', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'RDX DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect Schema Change', 
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
/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_Schema_Change.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays any schema changed captured in the default trace.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
--             2016.03.18  SYoung        Created today.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF OBJECT_ID(N''tempdb..#temp_trace'',''U'') IS NOT NULL
   DROP TABLE #temp_trace

BEGIN TRY
DECLARE @enable INT; 
SELECT TOP 1 @enable = CONVERT(INT,value_in_use) FROM SYS.CONFIGURATIONS WHERE name = ''DEFAULT trace ENABLED''  

IF @enable = 1 
   BEGIN 
        DECLARE @d1 DATETIME; 
        DECLARE @diff INT; 
        DECLARE @curr_tracefilename VARCHAR(500);  
        DECLARE @base_tracefilename VARCHAR(500);  
        DECLARE @indx INT ; 
 

        CREATE TABLE #temp_trace (
                obj_name NVARCHAR(256)
              , obj_id INT
              , [database_name] NVARCHAR(256)
              , start_time DATETIME
              , event_class INT
              , event_subclass INT
              , object_type INT
              , server_name NVARCHAR(256)
              , login_name NVARCHAR(256)
              , [user_name] NVARCHAR(256)
              , application_name NVARCHAR(256)
              , ddl_operation NVARCHAR(40));
        
        CREATE CLUSTERED INDEX CIX_#temp_trace_start_time_obj_id_database_name ON #temp_trace ([start_time], [obj_id], [database_name])

        SELECT @curr_tracefilename = [path] FROM SYS.TRACES WHERE is_default = 1 ;  
        SET @curr_tracefilename = REVERSE(@curr_tracefilename) 
        SELECT @indx  = PATINDEX(''%\%'', @curr_tracefilename) 
        SET @curr_tracefilename = REVERSE(@curr_tracefilename) 
        SET @base_tracefilename = LEFT( @curr_tracefilename,LEN(@curr_tracefilename) - @indx) + ''\log.trc''; 
        
        INSERT INTO #temp_trace 
        SELECT ObjectName
             , ObjectID
             , DatabaseName
             , StartTime
             , EventClass
             , EventSubClass
             , ObjectType
             , ServerName
             , LoginName
             , NTUserName
             , ApplicationName
             , ''temp'' 
          FROM ::FN_TRACE_GETTABLE( @base_tracefilename, default )  
         WHERE EventClass in (46,47,164) and EventSubclass = 0
           AND ObjectID IS NOT NULL
           AND DatabaseName <> ''tempdb''
           AND LoginName != ''NT SERVICE\SQLTELEMETRY''; 

        UPDATE #temp_trace SET ddl_operation = ''CREATE'' WHERE event_class = 46;
        UPDATE #temp_trace SET ddl_operation = ''DROP'' WHERE event_class = 47;
        UPDATE #temp_trace SET ddl_operation = ''ALTER'' WHERE event_class = 164; 

        SELECT @d1 = min(start_time) FROM #temp_trace 
        SET @diff= datediff(hh,@d1,getdate())
        SET @diff=@diff/24; 
        
		INSERT INTO RDXDBA.dbo.SchemaChange (
               [difference]
             , [date]
             , [obj_type_desc]
             , [l1]
             , [l2]
             , [obj_name]
             , [obj_id]
             , [database_name]
             , [start_time]
             , [event_class]
             , [event_subclass]
             , [object_type]
             , [server_name]
             , [login_name]
             , [user_name]
             , [application_name]
             , [ddl_operation])
        SELECT @diff AS difference
             , @d1 AS DATE
             , A.object_type AS obj_type_desc 
             , (DENSE_RANK() OVER(ORDER BY A.obj_name, A.object_type ) )%2 AS l1 
             , (DENSE_RANK() OVER(ORDER BY A.obj_name, A.object_type, A.start_time ))%2 AS l2
             , A.obj_name
             , A.obj_id
             , A.[database_name]
             , A.start_time
             , A.event_class
             , A.event_subclass
             , A.object_type
             , A.server_name
             , A.login_name
             , A.[user_name]
             , A.application_name
             , A.ddl_operation
          FROM #temp_trace A
		  LEFT JOIN [RDXDBA].[dbo].[SchemaChange] B ON A.[start_time] = B.[start_time]
		   AND A.[obj_id] = B.[obj_id]
		   AND A.[database_name] = B.[database_name]
         WHERE A.object_type not in (21587) -- don''t bother with auto-statistics AS it generates too much noise
		   AND B.[start_time] IS NULL;
END ELSE 
BEGIN  
        SELECT TOP 0 1 AS [difference]
             , 1 AS [date]
             , 1 AS obj_type_desc
             , 1 AS l1
             , 1 AS l2
             , 1 AS obj_name
             , 1 AS obj_id
             , 1 AS [database_name]
             , 1 AS start_time
             , 1 AS event_class
             , 1 AS event_subclass
             , 1 AS object_type
             , 1 AS server_name
             , 1 AS login_name
             , 1 AS [user_name]
             , 1 AS application_name
             , 1 AS ddl_operation  
END  
END TRY  
BEGIN  CATCH  
SELECT -100 AS difference
     , ERROR_NUMBER() AS DATE
     , ERROR_SEVERITY() AS obj_type_desc
     , 1 AS l1, 1 AS l2
     , ERROR_STATE() AS obj_name
     , 1 AS obj_id
     , ERROR_MESSAGE() AS database_name
     , 1 AS start_time, 1 AS event_class, 1 AS event_subclass, 1 AS object_type, 1 AS server_name, 1 AS login_name, 1 AS user_name, 1 AS application_name, 1 AS ddl_operation  
END CATCH', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 6 hrs', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=6, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181022, 
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
