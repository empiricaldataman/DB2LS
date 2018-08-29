-- Listing 2.2 Top 10 longest-running queries on server
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TOP 10	qs.total_elapsed_time AS [Total Time]
     , qs.execution_count AS [Execution count]
     , SUBSTRING (qt.[text],(qs.statement_start_offset/2) + 1,
        ((CASE WHEN qs.statement_end_offset = -1
	             THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
               ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1) AS [Individual Query]
     , qt.[text] AS [Parent Query]
     , DB_NAME(qt.dbid) AS DatabaseName
     , qp.query_plan
  FROM sys.dm_exec_query_stats qs
 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
 CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
 ORDER BY [Total Time] DESC;