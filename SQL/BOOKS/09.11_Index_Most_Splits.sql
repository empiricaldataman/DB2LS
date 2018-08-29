-- Listing 9.11 Indexes with the most page splits

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TOP 20 x.name AS SchemaName
     , object_name(s.object_id) AS TableName
     , i.name AS IndexName
     , s.leaf_allocation_count
     , s.nonleaf_allocation_count
  FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) s
 INNER JOIN sys.objects o ON s.object_id = o.object_id
 INNER JOIN sys.indexes i ON s.index_id = i.index_id
   AND i.object_id = o.object_id
 INNER JOIN sys.schemas x ON x.schema_id = o.schema_id
 WHERE s.leaf_allocation_count > 0
   AND o.is_ms_shipped = 0
 ORDER BY s.leaf_allocation_count DESC;
