-- Listing 3.5 The most-fragmented indexes
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME() AS DatbaseName
     , SCHEMA_NAME(o.Schema_ID) AS SchemaName
     , OBJECT_NAME(s.[object_id]) AS TableName
     , i.name AS IndexName
     , ROUND(s.avg_fragmentation_in_percent,2) AS [Fragmentation %]
  INTO #TempFragmentation
  FROM sys.dm_db_index_physical_stats(db_id(),null, null, null, null) s
 INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
	 AND s.index_id = i.index_id
 INNER JOIN sys.objects o ON i.object_id = O.object_id
 WHERE 1 = 2

EXEC sp_MSForEachDB 'USE [?];
INSERT INTO #TempFragmentation
SELECT TOP 20
	DB_NAME() AS DatbaseName
	, SCHEMA_NAME(o.Schema_ID) AS SchemaName
	, OBJECT_NAME(s.[object_id]) AS TableName
	, i.name AS IndexName
	, ROUND(s.avg_fragmentation_in_percent,2) AS [Fragmentation %]
FROM sys.dm_db_index_physical_stats(db_id(),null, null, null, null) s
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
	AND s.index_id = i.index_id
INNER JOIN sys.objects o ON i.object_id = O.object_id
WHERE s.database_id = DB_ID()
	AND i.name IS NOT NULL
	AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0
ORDER BY [Fragmentation %] DESC'

SELECT top 20 * FROM #TempFragmentation ORDER BY [Fragmentation %] DESC

DROP TABLE #TempFragmentation
