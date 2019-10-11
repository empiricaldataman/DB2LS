/*
-------------------------------------------------------------------------------------------------
        NAME: INDEX_Fragmentation.sql
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
SELECT CONVERT(VARCHAR(24), GETDATE(), 120) [date_time]
     , @@SERVERNAME [instance_name]
     , SC.[name] [schema_name]
     , OBJECT_NAME(DT.object_id) [table_name]
     , I.[name] [index_name]
     , I.fill_factor
     , DT.avg_fragmentation_in_percent
     , DT.avg_page_space_used_in_percent
     , I.[type_desc] [index_type]
     , P.[rows] [partition_rows]
     , ST.used_page_count * 8 [used_size_KB]
     , ST.reserved_page_count * 8 [reserved_size_KB]
  FROM (SELECT object_id,
               index_id,
               avg_fragmentation_in_percent,
               avg_page_space_used_in_percent
          FROM sys.dm_db_index_physical_stats(DB_ID(DB_NAME()), NULL, NULL, NULL, 'SAMPLED')
         WHERE index_id != 0
           AND alloc_unit_type_desc = 'IN_ROW_DATA') DT
 INNER JOIN sys.indexes I ON I.object_id = dt.object_id
   AND I.index_id = DT.index_id
 INNER JOIN sys.objects O ON O.object_id = I.object_id
 INNER JOIN sys.schemas SC ON SC.schema_id = O.schema_id 
 INNER JOIN sys.dm_db_partition_stats ST ON ST.index_id = I.index_id
   AND O.object_id = ST.object_id
 INNER JOIN sys.partitions P ON ST.partition_id = P.partition_id
   AND P.partition_number = ST.partition_number
 WHERE 1 = 1
   AND O.[type] NOT IN ('IT','S')
 ORDER BY SC.[name], 4, I.[name], I.index_id

