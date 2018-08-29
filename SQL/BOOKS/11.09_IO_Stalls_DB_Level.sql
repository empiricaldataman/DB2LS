
-- Listing 11.9 I/O stalls at the database level

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME(database_id) AS [DatabaseName]
     , SUM(CAST(io_stall / 1000.0 AS DECIMAL(20,2))) AS [IO stall (secs)]
     , SUM(CAST(num_of_bytes_read / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO read (MB)]
     , SUM(CAST(num_of_bytes_written / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO written (MB)]
     , SUM(CAST((num_of_bytes_read + num_of_bytes_written) / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [TotalIO (MB)]
  FROM sys.dm_io_virtual_file_stats(NULL, NULL)
 GROUP BY database_id
 ORDER BY [IO stall (secs)] DESC

SELECT DB_NAME(t1.database_id) [DBName]
     , t1.file_id
     , (t1.io_stall_read_ms/t1.num_of_reads) [IOReads (ms)]
     , (t1.io_stall_write_ms/t1.num_of_writes) [IOWrites (ms)]
     , t1.io_stall
     , t2.io_pending_ms_ticks
     , t2.scheduler_address 
  from sys.dm_io_virtual_file_stats(NULL, NULL) t1
  INNER JOIN sys.dm_io_pending_io_requests as t2 ON t1.file_handle = t2.io_handle
  