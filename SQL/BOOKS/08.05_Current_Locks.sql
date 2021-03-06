-- Listing 8.5 Observing the current locks
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME(resource_database_id) AS DatabaseName
     , request_session_id
	   , resource_type
     , request_status
     , request_mode
  FROM sys.dm_tran_locks
 WHERE request_session_id != @@spid
 ORDER BY request_session_id;
