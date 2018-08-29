-- Listing 11.8 Memory used by objects in the current database

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT OBJECT_NAME(p.[object_id]) AS [TableName]
     , (COUNT(*) * 8) / 1024 AS [Buffer size(MB)]
     , ISNULL(i.name, '-- HEAP --') AS ObjectName
     , COUNT(*) AS NumberOf8KPages
  FROM sys.allocation_units a
 INNER JOIN sys.dm_os_buffer_descriptors b ON a.allocation_unit_id = b.allocation_unit_id
 INNER JOIN sys.partitions p ON a.container_id = p.hobt_id
 INNER JOIN sys.indexes i ON p.index_id = i.index_id
   AND p.[object_id] = i.[object_id]
 WHERE b.database_id = DB_ID()
   AND p.[object_id] > 100
 GROUP BY p.[object_id], i.name