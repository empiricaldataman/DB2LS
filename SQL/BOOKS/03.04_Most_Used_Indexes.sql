-- Listing 3.4 The most-used indexes
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME() AS DatabaseName
     , SCHEMA_NAME(o.Schema_ID) AS SchemaName
     , OBJECT_NAME(s.[object_id]) AS TableName
     , i.name AS IndexName
     , (s.user_seeks + s.user_scans + s.user_lookups) AS [Usage]
     , s.user_updates
     , i.fill_factor
  INTO #TempUsage
  FROM sys.dm_db_index_usage_stats s
 INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
   AND s.index_id = i.index_id
 INNER JOIN sys.objects o ON i.object_id = O.object_id
 WHERE 1 = 2

EXEC sp_MSForEachDB 'USE [?];
INSERT INTO #TempUsage
SELECT TOP 20
	DB_NAME() AS DatabaseName
	, SCHEMA_NAME(o.Schema_ID) AS SchemaName
	, OBJECT_NAME(s.[object_id]) AS TableName
	, i.name AS IndexName
	, (s.user_seeks + s.user_scans + s.user_lookups) AS [Usage]
	, s.user_updates
	, i.fill_factor
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
	AND s.index_id = i.index_id
INNER JOIN sys.objects o ON i.object_id = O.object_id
WHERE s.database_id = DB_ID()
	AND i.name IS NOT NULL
	AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0
ORDER BY [Usage] DESC'

SELECT TOP 20 * FROM #TempUsage ORDER BY [Usage] DESC

DROP TABLE #TempUsage