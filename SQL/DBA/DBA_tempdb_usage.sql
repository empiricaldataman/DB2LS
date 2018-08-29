
use TempDB
go

SELECT TOP 10 ROW_NUMBER() OVER(PARTITION BY B.session_id ORDER BY (user_objects_alloc_page_count * 8) / 10245) [row_number]
     , B.session_id [session_id]
     , DB_NAME(A.database_id) [database_name]
     , HOST_NAME [host_name]
     , program_name [application_name]
     , login_name [user_name]
     , [status]
     , msdb.[dbo].[fn_CreateTimeString](cpu_time / 1000) [cpu_time]
     --, msdb.[dbo].[fn_CreateTimeString](total_scheduled_time / 1000) AS [Total Scheduled TIME (in milisec)]
     --, msdb.[dbo].[fn_CreateTimeString](total_elapsed_time / 1000) AS [Elapsed TIME (in milisec)]
     , (memory_usage * 8) [memory_usage_kb)]
     , (user_objects_alloc_page_count * 8) / 1024 [current_session_user_space_mb]
     , (user_objects_dealloc_page_count * 8)  AS [space_deallocated_for_user_objects_kb]
     , (internal_objects_alloc_page_count * 8) / 1024 AS [current_session_internal_space_mb]
     , (internal_objects_dealloc_page_count * 8) AS [space_deallocated_for_internal_objes_kb]
     , CASE is_user_process WHEN 1 THEN 'user session'
                            WHEN 0 THEN 'system session' END AS [session_type]
     , row_count AS [row_count]
  FROM sys.dm_db_session_space_usage A
  INNER join sys.dm_exec_sessions B ON A.session_id = B.session_id
  ORDER BY 10 DESC
