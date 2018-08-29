:CONNECT PO

SET NOCOUNT ON

SELECT GETDATE() [DateTime],
       [owt].[session_id],
       CASE WHEN ISNUMERIC(REPLACE(LEFT([owt].[resource_description],2),':','')) = 1 THEN DB_NAME(REPLACE(LEFT([owt].[resource_description],2),':','')) END [db],
       mf.name [db_file],
       mf.physical_name [physical_name],
       [owt].[exec_context_id],
       [owt].[wait_duration_ms],
       [owt].[wait_type],
       [owt].[blocking_session_id],
       [owt].[resource_description],
       CASE [owt].[wait_type]
           WHEN N'CXPACKET' THEN
               RIGHT ([owt].[resource_description],
               CHARINDEX (N'=', REVERSE ([owt].[resource_description])) - 1)
           ELSE NULL
       END AS [Node ID],
       [es].[program_name],
       [est].text,
       [er].[database_id],
       [eqp].[query_plan],
       [er].[cpu_time]
  FROM sys.dm_os_waiting_tasks [owt]
 INNER JOIN sys.dm_exec_sessions [es] ON [owt].[session_id] = [es].[session_id]
 INNER JOIN sys.dm_exec_requests [er] ON [es].[session_id] = [er].[session_id]
  LEFT JOIN sys.master_files mf ON CASE WHEN ISNUMERIC(REPLACE(LEFT([owt].[resource_description],2),':','')) = 1 THEN REPLACE(LEFT([owt].[resource_description],2),':','') ELSE 1 END = mf.database_id
   AND CASE WHEN ISNUMERIC(REPLACE(SUBSTRING([owt].[resource_description], (CHARINDEX(':',[owt].[resource_description]) + 1),2),':','')) = 1 THEN REPLACE(SUBSTRING([owt].[resource_description], (CHARINDEX(':',[owt].[resource_description]) + 1),2),':','')
            ELSE 1 END = mf.file_id
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE [es].[is_user_process] = 1
ORDER BY [owt].[session_id], [owt].[exec_context_id];
GO

