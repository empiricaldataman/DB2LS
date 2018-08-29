/*-------------------------------------------------------------------------------------------------
        NAME: DBA_TableRow_IndexInfo.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays index information
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    07.21.2016  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			  killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

SELECT SC.[name] [schema_name]
     , O.[name] [object_name]
     , O.[type_desc] [object_type]
     , I.[name] [index_name]
     , I.[type_desc] [index_type]
     , P.partition_number [partition_number]
     , P.[rows] [partition_rows]
     , ST.row_count [stat_row_count]
     , ST.used_page_count * 8 [used_size_KB]
     , ST.reserved_page_count * 8 [reserved_size_KB]
  FROM sys.partitions P 
 INNER JOIN sys.dm_db_partition_stats ST ON P.partition_id = ST.partition_id 
   AND P.partition_number = ST.partition_number 
 INNER JOIN sys.objects AS O ON ST.object_id = O.object_id 
 INNER JOIN sys.schemas AS SC ON O.schema_id = SC.schema_id 
 INNER JOIN sys.indexes AS I ON O.object_id = I.object_id 
   AND ST.index_id = I.index_id 
 WHERE 1 = 1
   AND O.[type] NOT IN ('IT','S')
   --AND OBJ.[name] = 'AccountDaily'
 ORDER BY SC.[name]
     , O.[name]
     , I.[name]
     , P.partition_number 
GO
