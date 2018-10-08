USE [master]
GO

IF OBJECT_ID(N'dbo.sp_t','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_t
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_t.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about all tables in database
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    08.21.2018  SYoung        Re-format T-SQL code
--            10.07.2018  SYoung        Added create_date column
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_t] (
       @database_name VARCHAR(40) = NULL,
       @order CHAR(1) = 's' -- (d = data_size, i = index_size, r = row_count, s = total_size, t = table_name)
       )

AS

SET NOCOUNT ON

IF @database_name IS NULL SET @database_name = DB_NAME()

DECLARE	@object_id	INT
      , @type CHAR(1)
      , @schema_name VARCHAR(40)
      , @table_name VARCHAR(200)
      , @create_date smalldatetime
      , @row_count BIGINT
      , @data_size INT
      , @index_size INT
      , @page_size INT
      , @sql_string NVARCHAR(1000)

SELECT @page_size = low/1024
  FROM [master].dbo.spt_values
 WHERE number = 1
   AND [type] = 'E'

CREATE TABLE #table_list (
       [object_id] INT
     , [type] CHAR(1)
     , [schema_name] VARCHAR(40)
     , table_name VARCHAR(200)
     , create_date smalldatetime)

CREATE TABLE #table_statistics (
       instance_name VARCHAR(40)
     , [database_name] VARCHAR(40)
     , [type] CHAR(1)
     , [schema_name] VARCHAR(40)
     , table_name VARCHAR(200)
     , create_date smalldatetime
     , row_count BIGINT
     , data_size INT
     , index_size INT
     , total_size INT)

SELECT @sql_string = 'INSERT #table_list SELECT DISTINCT o.object_id, o.type, s.name, o.name, o.create_date FROM [' + @database_name + '].sys.objects o WITH (NOLOCK) JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id JOIN [' + @database_name + '].sys.indexes i WITH (NOLOCK) ON o.object_id = i.object_id WHERE o.type IN (''U'',''V'')'

EXECUTE sp_executesql @sql_string

DECLARE table_cursor CURSOR 
    FOR SELECT object_id
      , [type]
      , [schema_name]
      , table_name
      , create_date
   FROM #table_list

   OPEN table_cursor
  FETCH NEXT FROM table_cursor INTO @object_id, @type, @schema_name, @table_name, @create_date

WHILE @@FETCH_STATUS = 0
      BEGIN
      SELECT @sql_string = N'SELECT   
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

	EXECUTE sp_executesql @sql_string
        ,	N'@d INT OUTPUT, @i INT OUTPUT, @r BIGINT OUTPUT'
        ,	@d = @data_size OUTPUT
        ,	@i = @index_size OUTPUT
        ,	@r = @row_count OUTPUT

	INSERT #table_statistics
  SELECT @@SERVERNAME
       , @database_name
       , @type
       , @schema_name
       , @table_name
       , @create_date
       , @row_count
       , @data_size * @page_size
       , @index_size * @page_size
       , (@data_size + @index_size) * @page_size

	FETCH NEXT FROM table_cursor INTO @object_id, @type, @schema_name, @table_name, @create_date
END
CLOSE table_cursor
DEALLOCATE table_cursor

SET NOCOUNT OFF

IF @order = 'd'
	SELECT instance_name
         , [database_name]
         , [type]
         , [schema_name]
         , LEFT(table_name,60) table_name
         , create_date
         , row_count
         , data_size
         , index_size
         , total_size
      FROM #table_statistics
     ORDER BY data_size DESC
ELSE
IF @order = 'i'
	SELECT instance_name
         , [database_name]
         , [type]
         , [schema_name]
         , LEFT(table_name,60) table_name
         , create_date
         , row_count
         , data_size
         , index_size
         , total_size
      FROM #table_statistics
     ORDER BY index_size DESC
ELSE
IF @order = 'r'
	SELECT instance_name
         , [database_name]
         , [type]
         , [schema_name]
         , LEFT(table_name,60) table_name
         , create_date
         , row_count
         , data_size
         , index_size
         , total_size
      FROM #table_statistics
     ORDER BY row_count DESC
ELSE
IF @order = 's'
	SELECT instance_name
         , [database_name]
         , [type]
         , [schema_name]
         , LEFT(table_name,60) table_name
         , create_date
         , row_count
         , data_size
         , index_size
         , total_size
      FROM #table_statistics
     ORDER BY total_size DESC
ELSE
	SELECT instance_name
         , [database_name]
         , [type]
         , [schema_name]
         , LEFT(table_name,60) table_name
         , create_date
         , row_count
         , data_size
         , index_size
         , total_size
      FROM #table_statistics
     ORDER BY [schema_name] ASC, table_name ASC
GO
