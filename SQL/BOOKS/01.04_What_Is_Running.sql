-- Listing 1.4 Identify what SQL is running now
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT er.session_Id AS [Spid]
     , sp.ecid
     , DB_NAME(sp.dbid) AS [Database]
     , sp.nt_username
     , er.[status]
     , er.wait_type
     , SUBSTRING (qt.[text], (er.statement_start_offset/2) + 1,
        ((CASE WHEN er.statement_end_offset = -1
	             THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2
	             ELSE er.statement_end_offset END - er.statement_start_offset)/2) + 1) AS [Individual Query]
     , qt.text AS [Parent Query]
     , sp.program_name
     , sp.Hostname
     , sp.nt_domain
     , er.start_time
 FROM sys.dm_exec_requests er
 INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
 CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
 WHERE er.session_Id > 50
   AND er.session_Id NOT IN (@@SPID)
   AND DB_NAME(sp.dbid) = 'DW_ServicingMart'
   AND sp.nt_username = 'CTMUSER'
 ORDER BY er.session_Id, sp.ecid;
