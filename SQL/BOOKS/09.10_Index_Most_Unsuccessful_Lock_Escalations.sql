-- Listing 9.10 Indexes with the most unsuccessful lock escalations
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TOP 20 x.name AS SchemaName
     , OBJECT_NAME (s.object_id) AS TableName
     , i.name AS IndexName
     , s.index_lock_promotion_attempt_count - s.index_lock_promotion_count AS UnsuccessfulIndexLockPromotions
  FROM sys.dm_db_index_operational_stats(db_ID(), NULL, NULL, NULL) s
 INNER JOIN sys.objects o ON s.object_id = o.object_id
 INNER JOIN sys.indexes i ON s.index_id = i.index_id
   AND i.object_id = o.object_id
 INNER JOIN sys.schemas x ON x.schema_id = o.schema_id
 WHERE (s.index_lock_promotion_attempt_count - index_lock_promotion_count)>0
   AND o.is_ms_shipped = 0
 ORDER BY UnsuccessfulIndexLockPromotions DESC;
