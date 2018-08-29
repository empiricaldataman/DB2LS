/*-------------------------------------------------------------------------------------------------
        NAME: INDEX_Usage.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: 
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME(A.database_id) [DBName]
     , D.[name] [SchemaName]
     , B.[name] [TableName]
     , C.[name] [IndexName]
     , A.user_seeks [IndexSeeks]
     , A.user_scans [IndexScans]
     , A.user_lookups [IndexLookups]
     , A.user_updates [IndexUpdates]
     , COALESCE(A.last_user_seek, A.last_user_scan, A.last_user_lookup) [LastUsed]
     , A.last_user_update [LastUpdated]
  FROM sys.tables B
 INNER JOIN sys.indexes C ON B.[object_id] = C.[object_id]
 INNER JOIN sys.schemas D ON B.[schema_id] = D.[schema_id]
  LEFT JOIN sys.dm_db_index_usage_stats A ON A.[object_id] = B.[object_id]
 WHERE database_id = db_id() AND
       C.index_id = A.index_id
 ORDER BY 1, 2