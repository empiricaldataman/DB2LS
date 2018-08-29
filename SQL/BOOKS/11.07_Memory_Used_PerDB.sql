
-- Listing 11.7 Memory used per database

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

SELECT ISNULL(DB_NAME(database_id), 'ResourceDb') AS DatabaseName
     , CAST(COUNT(row_count) * 8.0 / (1024.0) AS DECIMAL(28,2)) AS [Size (MB)]
  FROM sys.dm_os_buffer_descriptors
 GROUP BY database_id
 ORDER BY DatabaseName

