-- Listing 11.10 I/O stalls at the file level

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME(VFS.database_id) AS [DatabaseName]
     , VFS.file_id
     , SUM(CAST(io_stall / 1000.0 AS DECIMAL(20,2))) AS [IO stall (secs)]
     , SUM(CAST(num_of_bytes_read / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO read (MB)]
     , SUM(CAST(num_of_bytes_written / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO written (MB)]
     , SUM(CAST((num_of_bytes_read + num_of_bytes_written) / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [TotalIO (MB)]
     , mf.physical_name
  FROM sys.dm_io_virtual_file_stats(NULL, NULL) VFS
  LEFT JOIN sys.master_files mf ON VFS.file_id = mf.file_id
   AND VFS.database_id = mf.database_id
 GROUP BY VFS.database_id, VFS.file_id, mf.physical_name
 ORDER BY [IO stall (secs)] DESC


