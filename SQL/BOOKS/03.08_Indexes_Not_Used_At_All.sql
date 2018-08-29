-- Listing 3.8 Indexes that aren’t used at all
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME() AS DatbaseName
     , SCHEMA_NAME(O.Schema_ID) AS SchemaName
     , OBJECT_NAME(I.object_id) AS TableName
     , I.name AS IndexName
  INTO #TempNeverUsedIndexes
  FROM sys.indexes I 
 INNER JOIN sys.objects O ON I.object_id = O.object_id
 WHERE 1 = 2

EXEC sp_MSForEachDB 'USE [?];
INSERT INTO #TempNeverUsedIndexes
SELECT
	DB_NAME() AS DatbaseName
	, SCHEMA_NAME(O.Schema_ID) AS SchemaName
	, OBJECT_NAME(I.object_id) AS TableName
	, I.NAME AS IndexName
FROM sys.indexes I INNER JOIN sys.objects O ON I.object_id = O.object_id
LEFT OUTER JOIN sys.dm_db_index_usage_stats S ON S.object_id = I.object_id
	AND I.index_id = S.index_id
	AND DATABASE_ID = DB_ID()
WHERE OBJECTPROPERTY(O.object_id,''IsMsShipped'') = 0
	AND I.name IS NOT NULL
	AND S.object_id IS NULL'

SELECT * FROM #TempNeverUsedIndexes
ORDER BY DatbaseName, SchemaName, TableName, IndexName

DROP TABLE #TempNeverUsedIndexes
