-- Listing 3.2 The most-costly unused indexes
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME() AS DatabaseName
     , SCHEMA_NAME(o.Schema_ID) AS SchemaName
     , OBJECT_NAME(s.[object_id]) AS TableName
     , i.name AS IndexName
     , s.user_updates
     , s.system_seeks + s.system_scans + s.system_lookups AS [System usage]
  INTO #TempUnusedIndexes
  FROM sys.dm_db_index_usage_stats s
 INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
   AND s.index_id = i.index_id
 INNER JOIN sys.objects o ON i.object_id = O.object_id
 WHERE 1 = 2

EXEC sp_MSForEachDB 'USE [?];
INSERT INTO #TempUnusedIndexes
SELECT TOP 20
	DB_NAME() AS DatabaseName
	, SCHEMA_NAME(o.Schema_ID) AS SchemaName
	, OBJECT_NAME(s.[object_id]) AS TableName
	, i.name AS IndexName
	, s.user_updates
	, s.system_seeks + s.system_scans + s.system_lookups
							AS [System usage]
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
	AND s.index_id = i.index_id
INNER JOIN sys.objects o ON i.object_id = O.object_id
WHERE s.database_id = DB_ID()
	AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0
	AND s.user_seeks = 0
	AND s.user_scans = 0
	AND s.user_lookups = 0
	AND i.name IS NOT NULL
ORDER BY s.user_updates DESC'

SELECT TOP 20 * FROM #TempUnusedIndexes ORDER BY [user_updates] DESC

DROP TABLE #TempUnusedIndexes
