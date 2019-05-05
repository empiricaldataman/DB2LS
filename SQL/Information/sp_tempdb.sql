IF OBJECT_ID(N'dbo.sp_tempdb','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_tempdb
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_tempdb.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about databases
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    08.16.2018  SYoung        Re-format T-SQL code
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_tempdb]
AS

SET NOCOUNT ON

--TempDB_Size
print 'TempDB_Size'
SELECT * 
  FROM dbo.vw_TempDB_Size

--TempDB_Used_By_Active_Session
PRINT 'TempDB_Used_By_Active_Session'
SELECT *
  FROM dbo.vw_TempDB_Used_By_Active_Session
 ORDER BY total_alloc_MB DESC

-----------------------
--get the trace file
-----------------------
DECLARE @curr_tracefilename VARCHAR(500);
DECLARE @base_tracefilename VARCHAR(500);
DECLARE @indx INT;

SELECT @curr_tracefilename = path FROM sys.traces WHERE is_default = 1 ;
SET @curr_tracefilename = REVERSE( @curr_tracefilename );
SELECT @indx  = PATINDEX('%\%', @curr_tracefilename );
SET @curr_tracefilename = REVERSE( @curr_tracefilename );
SET @base_tracefilename = LEFT( @curr_tracefilename, LEN(
@curr_tracefilename ) - @indx ) + '\log.trc';

SELECT DatabaseName, LoginName, StartTime, objectid, spid
  INTO #trace
  FROM ::fn_trace_gettable( @base_tracefilename, default )
 WHERE ServerName = @@servername  
   AND ObjectType = 8277  -- '(User-defined) Table'
   AND EventClass = 46    --Object:Created
   AND EventSubClass = 1    -- Commit
   AND DatabaseName = 'tempdb'
   AND StartTime > dateadd(hour,-12,getdate()) -- last 12 hour

-----------------------
--get the table size
-----------------------
DECLARE @database_name VARCHAR(40) 
  
SET @database_name = 'tempdb'  
  
DECLARE @object_id INT
      , @schema_name VARCHAR(40)
      , @table_name VARCHAR(200)
      , @row_count BIGINT
      , @data_size INT
      , @index_size INT
      , @page_size INT
      , @sql_string NVARCHAR(1000)
      , @create_date datetime  
  
SELECT @page_size = low/1024  
  FROM master.dbo.spt_values  
 WHERE number = 1  
   AND [type] = 'E'  
  
CREATE TABLE #table_list (  
       object_id INT
     , schema_name VARCHAR(40)
     , table_name VARCHAR(200)
     , create_date datetime)  
  
CREATE TABLE #table_statistics (  
       object_id int
     , instance_name VARCHAR(40)
     , database_name VARCHAR(40)
     , schema_name VARCHAR(40)
     , table_name VARCHAR(200)
     , create_date datetime
     , row_count BIGINT
     , data_size INT
     , index_size INT
     , total_size INT)  
  
SELECT @sql_string = 'INSERT #table_list SELECT t.object_id, s.name, t.name, t.create_date FROM [' + @database_name + '].sys.tables t WITH (NOLOCK) JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON t.schema_id = s.schema_id'  
  
EXECUTE sp_executesql @sql_string  
  
DECLARE table_cursor CURSOR 
    FOR SELECT object_id, schema_name, table_name, create_date 
          FROM #table_list WITH (NOLOCK)  

   OPEN table_cursor  
  FETCH NEXT FROM table_cursor INTO @object_id, @schema_name, @table_name, @create_date   
  
WHILE @@FETCH_STATUS = 0  
      BEGIN  
      SELECT @sql_string = 'SELECT     
@d = SUM(  
CASE WHEN (index_id < 2)   
THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)  
ELSE lob_used_page_count + row_overflow_used_page_count  
END  
),  
@i = SUM(used_page_count) - SUM(  
CASE WHEN (index_id < 2)   
THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)  
ELSE lob_used_page_count + row_overflow_used_page_count  
END  
),  
@r = SUM(CASE WHEN (index_id < 2) THEN row_count ELSE 0 END)  
FROM [' + @database_name + '].sys.dm_db_partition_stats WITH (NOLOCK)  
WHERE object_id = ' + CONVERT(VARCHAR,@object_id)  
        
      EXECUTE sp_executesql @sql_string,  
      N'@d INT OUTPUT, @i INT OUTPUT, @r BIGINT OUTPUT',  
      @d = @data_size OUTPUT,  
      @i = @index_size OUTPUT,  
      @r = @row_count OUTPUT  
  
      INSERT #table_statistics  
      SELECT @object_id
           , @@SERVERNAME
           , @database_name
           , @schema_name
           , @table_name
           , @create_date
           , @row_count
           , @data_size * @page_size
           , @index_size * @page_size
           , (@data_size + @index_size) * @page_size  
      
      FETCH NEXT FROM table_cursor INTO @object_id, @schema_name, @table_name, @create_date  
END  
CLOSE table_cursor  
DEALLOCATE table_cursor  

-----------------------
--return the result
-----------------------
ALTER TABLE #table_statistics add RowNumber int IDENTITY(1, 1)
ALTER TABLE #trace ADD RowNumber int IDENTITY(1, 1)

SELECT a.RowNumber as tableStat_rn
     , b.RowNumber as trace_rn
     , a.database_name
     , a.schema_name
     , a.table_name
     , a.row_count
     , a.data_size
     , a.index_size
     , a.total_size
     , b.spid
     , b.LoginName
     , b.StartTime
     , a.create_date
     , b.objectid
  INTO #final_1
  FROM #table_statistics a 
 INNER JOIN #trace b ON b.objectid = a.object_id
 ORDER BY table_name DESC

SELECT tableStat_rn
     , [database_name]
     , [schema_name]
     , table_name
     , row_count
     , data_size
     , index_size
     , total_size
     , LoginName
     , objectid
     , min(abs(DATEDIFF(SECOND,StartTime,create_date))) [time_diff]
  INTO #final_2
  FROM #final_1
 GROUP BY tableStat_rn, [database_name], [schema_name], table_name, row_count, data_size, index_size, total_size, LoginName, objectid
 ORDER BY table_name DESC

PRINT 'TempDB Objects'
SELECT a.schema_name
     , a.table_name
     , a.row_count
     , cast(a.data_size/1024.0 as numeric(10,2)) as data_size_MB
     , cast(a.index_size/1024.0 as numeric(10,2)) as index_size_MB
     , cast(a.total_size/1024.0 as numeric(10,2)) as total_size_MB
     , a.LoginName as login_name
     , a.SPID
  FROM #final_2 b 
 INNER JOIN #final_1 a ON a.tableStat_rn = b.tableStat_rn 
 WHERE b.time_diff = abs(DATEDIFF(SECOND,a.StartTime,a.create_date))
   AND a.total_size/1024.0 >1
 ORDER BY a.total_size DESC

GO
