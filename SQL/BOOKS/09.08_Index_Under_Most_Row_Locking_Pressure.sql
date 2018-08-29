-- Listing 9.8 Indexes under the most row-locking pressure
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

SELECT TOP 20 x.name AS SchemaName
     , OBJECT_NAME(s.object_id) AS TableName
     , i.name AS IndexName
     , s.row_lock_wait_in_ms
     , s.row_lock_wait_count
  FROM sys.dm_db_index_operational_stats(db_ID(), NULL, NULL, NULL) s
 INNER JOIN sys.objects o ON s.object_id = o.object_id
 INNER JOIN sys.indexes i ON s.index_id = i.index_id
   AND i.object_id = o.object_id
 INNER JOIN sys.schemas x ON x.schema_id = o.schema_id
 WHERE s.row_lock_wait_in_ms > 0
   AND o.is_ms_shipped = 0
 ORDER BY s.row_lock_wait_in_ms DESC;
