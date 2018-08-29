
-- Listing 11.10 I/O stalls at the file level

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

IF OBJECT_ID(N'tempdb..#IOStallsFileLevel','U') IS NOT NULL
   DROP TABLE #IOStallsFileLevel


SELECT DB_NAME(VFS.database_id) AS [DatabaseName]
     , VFS.file_id
     , SUM(CAST(io_stall / 1000.0 AS DECIMAL(20,2))) AS [IO stall (secs)]
     , SUM(CAST(num_of_bytes_read / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO read (MB)]
     , SUM(CAST(num_of_bytes_written / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO written (MB)]
     , SUM(CAST((num_of_bytes_read + num_of_bytes_written) / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [TotalIO (MB)]
     , mf.physical_name
     , GETDATE() [CapturedOn]
  INTO #IOStallsFileLevel
  FROM sys.dm_io_virtual_file_stats(NULL, NULL) VFS
  LEFT JOIN sys.master_files mf ON VFS.file_id = mf.file_id
   AND VFS.database_id = mf.database_id
 WHERE 1 = 2
 GROUP BY VFS.database_id, VFS.file_id, mf.physical_name
 ORDER BY [IO stall (secs)] DESC
GO

INSERT INTO #IOStallsFileLevel
SELECT DB_NAME(VFS.database_id) AS [DatabaseName]
     , VFS.file_id
     , SUM(CAST(io_stall / 1000.0 AS DECIMAL(20,2))) AS [IO stall (secs)]
     , SUM(CAST(num_of_bytes_read / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO read (MB)]
     , SUM(CAST(num_of_bytes_written / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO written (MB)]
     , SUM(CAST((num_of_bytes_read + num_of_bytes_written) / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [TotalIO (MB)]
     , mf.physical_name
     , GETDATE() [CapturedOn]
  FROM sys.dm_io_virtual_file_stats(NULL, NULL) VFS
  LEFT JOIN sys.master_files mf ON VFS.file_id = mf.file_id
   AND VFS.database_id = mf.database_id
 GROUP BY VFS.database_id, VFS.file_id, mf.physical_name

WAITFOR DELAY '00:05:00'


INSERT INTO #IOStallsFileLevel
SELECT DB_NAME(VFS.database_id) AS [DatabaseName]
     , VFS.file_id
     , SUM(CAST(io_stall / 1000.0 AS DECIMAL(20,2))) AS [IO stall (secs)]
     , SUM(CAST(num_of_bytes_read / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO read (MB)]
     , SUM(CAST(num_of_bytes_written / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [IO written (MB)]
     , SUM(CAST((num_of_bytes_read + num_of_bytes_written) / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [TotalIO (MB)]
     , mf.physical_name
     , GETDATE() [CapturedOn]
  FROM sys.dm_io_virtual_file_stats(NULL, NULL) VFS
  LEFT JOIN sys.master_files mf ON VFS.file_id = mf.file_id
   AND VFS.database_id = mf.database_id
 GROUP BY VFS.database_id, VFS.file_id, mf.physical_name
GO


DECLARE @min datetime

SELECT @min = MIN(CapturedON)
  FROM #IOStallsFileLevel

INSERT INTO DBA_BACKUP..IOStallsFileLevel
SELECT A.DatabaseName
     , A.[file_id]
     , A.[IO stall (secs)] - B.[IO stall (secs)] [IO stall (secs)]
     , A.[IO read (MB)] - B.[IO read (MB)] [IO read (MB)]
     , A.[IO written (MB)] - B.[IO written (MB)] [IO written (MB)]
     , A.[TotalIO (MB)] - B.[TotalIO (MB)] [TotalIO (MB)]
     , A.physical_name
     , A.CapturedOn
  FROM #IOStallsFileLevel A
  LEFT JOIN #IOStallsFileLevel B ON A.DatabaseName = B.DatabaseName
   AND A.[file_id] = B.[file_id]
   AND B.CapturedOn = @min
 WHERE A.CapturedOn > @min
   AND (A.[IO stall (secs)] - B.[IO stall (secs)]) > 25
 ORDER BY [IO stall (secs)] DESC


SELECT * FROM DBA_BACKUP..IOStallsFileLevel WHERE DatabaseName = 'Credit' ORDER BY 3 DESC