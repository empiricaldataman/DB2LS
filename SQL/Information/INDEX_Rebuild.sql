/*-------------------------------------------------------------------------------------------------
        NAME: INDEX_Rebuild.sql
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
-------------------------------------------------------------------------------------------------*/
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#tblIndexDefrag') IS NOT NULL DROP TABLE #tblIndexDefrag
GO

SELECT dt.[schema],
       OBJECT_NAME(dt.[object_id]) [TableName], 
       si.name [IndexName],
       dt.avg_fragmentation_in_percent,
       dt.avg_page_space_used_in_percent
  INTO #tblIndexDefrag
  FROM (SELECT S.[name] [schema],
               A.[object_id],
               A.index_id,
               A.avg_fragmentation_in_percent,
               A.avg_page_space_used_in_percent
          FROM sys.dm_db_index_physical_stats(DB_ID(DB_NAME()), NULL, NULL, NULL, 'SAMPLED') A
         INNER JOIN sys.objects O ON A.object_id = O.object_id
         INNER JOIN sys.schemas S ON O.schema_id = S.schema_id
         WHERE index_id != 0) AS dt
  INNER JOIN sys.indexes si ON si.[object_id] = dt.[object_id] AND
        si.index_id = dt.index_id

DECLARE @vTableName varchar(128),
        @vIndexName varchar(128),
		@vSchemaName varchar(128),
		@vFragmentation varchar(12),
        @vSQL nvarchar(4000)
        
DECLARE C CURSOR FAST_FORWARD
    FOR SELECT [Schema],
	           [TableName],
               [IndexName],
			   [avg_fragmentation_in_percent]
          FROM #tblIndexDefrag
         WHERE avg_fragmentation_in_percent > 20
--		   AND [TableName] <> 'table_to_exclude'
         ORDER BY 2 DESC, 1 DESC

   OPEN C
  FETCH NEXT FROM C
   INTO @vSchemaName, @vTableName, @vIndexName, @vFragmentation

  WHILE @@FETCH_STATUS = 0
        BEGIN
        SELECT @vSQL = N'ALTER INDEX '+ @vIndexName + CHAR(10) +
                        '   ON ['+ @vSchemaName +'].['+ @vTableName +']'+ CHAR(10) +
                        '      REBUILD WITH (ONLINE = ON)'
                        
        EXEC(@vSQL)
        --SELECT @vSQL
        
        PRINT 'Index '+ @vIndexName +' on table '+ @vSchemaName +'.'+ @vTableName +' has been defragmented ('+ CAST(@vFragmentation AS VARCHAR) +') - '+ CAST(GETDATE() AS VARCHAR)
        FETCH NEXT FROM C INTO @vSchemaName, @vTableName, @vIndexName, @vFragmentation             
  END
  CLOSE C
DEALLOCATE C
