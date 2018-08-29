SET TRAN ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME(database_id) AS DatabaseName
     , file_id
     , io_stall_read_ms / num_of_reads AS 'Average read time'
     , io_stall_write_ms / num_of_writes AS 'Average write time'
  FROM sys.dm_io_virtual_file_stats(NULL, NULL)
 WHERE num_of_reads > 0 and num_of_writes > 0
 ORDER BY DatabaseName