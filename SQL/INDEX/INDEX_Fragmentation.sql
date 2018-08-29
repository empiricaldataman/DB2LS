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


SELECT OBJECT_NAME(dt.object_id), 
       si.name,
       dt.avg_fragmentation_in_percent,
       dt.avg_page_space_used_in_percent
  FROM (SELECT object_id,
               index_id,
               avg_fragmentation_in_percent,
               avg_page_space_used_in_percent
          FROM sys.dm_db_index_physical_stats(DB_ID(DB_NAME()), NULL, NULL, NULL, 'SAMPLED')
         WHERE index_id != 0) AS dt
  INNER JOIN sys.indexes si ON si.object_id = dt.object_id AND
        si.index_id = dt.index_id

