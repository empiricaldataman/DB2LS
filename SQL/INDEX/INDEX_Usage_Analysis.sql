/*
-------------------------------------------------------------------------------------------------
        NAME: INDEX_Usage_Analysis.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: DETERMINE INDEX FRAGMENTATION FOR ALL TABLES IN THE CURRENT DATABASE
              EXTERNAL FRAGMENTATION IS INDICATED WHEN avg_fragmentation_in_percent
              EXCEEDS 10
              INTERNAL FRAGMENTATION IS INDICATED WHEN avg_page_space_used_in_percent
              FALLS BELOW 75
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/

/*
:CONNECT PD
USE ProofOfConcept
GO
SET NOCOUNT ON
DECLARE @IndexSize int --IN MEGABYTES
SET @IndexSize = 5000

PRINT N'DECLARE @Indexes AS TABLE (ServerName varchar(128), DBName varchar(128), SchemaName varchar(128), TableName nvarchar(128), IndexName nvarchar(128), IndexSize int, UNIQUE CLUSTERED (ServerName, DBName, SchemaName, TableName, IndexName))'
        
SELECT N'INSERT INTO @Indexes (ServerName, DBName, SchemaName, TableName, IndexName, IndexSize) VALUES ('''+ @@SERVERNAME +''', '''+ DB_NAME() +''','''+ S.[name] +''', '''+ O.[name] +''', '''+ I.[name] +''','+ CAST(SUM(P.[used_page_count]) * 8 / 1024 AS varchar) +');'
  FROM sys.indexes I
 INNER JOIN sys.objects O ON I.[object_id] = O.[object_id]
 INNER JOIN sys.schemas S ON O.[schema_id] = S.[schema_id]
 INNER JOIN sys.dm_db_partition_stats P ON I.[object_id] = P.[object_id]
   AND I.[index_id] = P.[index_id]
 WHERE 1 = 1
   AND I.index_id <> 0
   AND S.[schema_id] <> 4
 GROUP BY S.[name], O.[name], I.[name]
HAVING (SUM(P.[used_page_count]) * 8 / 1024) > @IndexSize
GO
*/

:CONNECT M1
USE DBA
GO
SET NOCOUNT ON

--[ PASTE RESULT FROM UPPER QUERY BELOW THIS LINE ]
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[ EXECUTE T-SQL IN THIS ENTIRE WINDOW           ]

SELECT IU.[dCaptured]
      --, I.[ServerName]
      --, I.[DBName]
     , I.[SchemaName]
     , I.[TableName]
     , I.[IndexName]
     , I.IndexSize
     --, IU.[IndexName]
     , IU.[IndexSeeks]
     , IU.[IndexScans]
     , IU.[IndexLookups]
     , IU.[IndexUpdates]
     , IU.[LastUsed]
     , IU.[LastUpdated]
     , IU.[daysServer_up]
  FROM @Indexes I
  LEFT JOIN [DBA].[dbo].[IndexUsage] IU ON I.ServerName = IU.ServerName
   AND I.DBName = IU.DBName
   AND I.SchemaName = IU.SchemaName
   AND I.TableName = IU.TableName
   AND I.IndexName = IU.IndexName
 WHERE 1 = 1
   AND dCaptured >= '20170101'
   AND IU.DBName = 'ProofOfConcept'
 ORDER BY I.[SchemaName], I.[TableName], I.[IndexName], IU.dCaptured DESC
GO
