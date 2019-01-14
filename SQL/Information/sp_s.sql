USE [master]
GO

IF OBJECT_ID(N'dbo.sp_s','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_s
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_s.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Searchees for objects, columns, and code containing a pattern
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
CREATE PROCEDURE [dbo].[sp_s]
       @database_name VARCHAR(40) = NULL
     , @search_string VARCHAR(80) = NULL
     , @object_type VARCHAR(2) = NULL
     , @replicated BIT = 0

AS

DECLARE	@sql_string NVARCHAR(1000)

IF @search_string IS NULL SET @search_string = ''
IF @object_type IS NULL SET @object_type = ''

CREATE TABLE #table_list (
       [database_name] VARCHAR(40)
     , [type] VARCHAR(2)
     , schema_name VARCHAR(20)
     , object_name VARCHAR(80)
     , column_name VARCHAR(40)
     , create_date DATETIME
     , [replicated] VARCHAR(10))
	
IF @database_name IS NULL
   BEGIN
   PRINT ''
   PRINT 'Object Search'
   PRINT ''

   DECLARE database_cursor CURSOR
       FOR SELECT name 
             FROM master.sys.databases WITH (NOLOCK)
            WHERE state_desc = 'ONLINE'
			ORDER BY [name]

      OPEN database_cursor
     FETCH NEXT FROM database_cursor INTO @database_name
	
     WHILE @@FETCH_STATUS = 0
           BEGIN
           SET @sql_string = 'INSERT #table_list'
           SET @sql_string = @sql_string + ' SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', o.type, schema_name=LEFT(s.name,20), object_name=LEFT(o.name,80), NULL, o.create_date, replicated=CASE WHEN o.is_published | o.is_schema_published > 0 THEN '' Published'' ELSE '''' END'
           SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.objects o WITH (NOLOCK)'
           SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id'
           SET @sql_string = @sql_string + ' WHERE o.name LIKE ''%' + @search_string + '%'''
           SET @sql_string = @sql_string + ' AND o.type LIKE ''%' + @object_type + '%'''
           SET @sql_string = @sql_string + ' AND o.is_published | o.is_schema_published >= ' + CONVERT(VARCHAR(1),@replicated)
           SET @sql_string = @sql_string + ' ORDER BY o.type, s.name, o.name, o.create_date'
           
           EXEC sp_executesql @sql_string
           FETCH NEXT FROM database_cursor INTO @database_name
	 END
	 CLOSE database_cursor
	 DEALLOCATE database_cursor
	
   SELECT [database_name]
        , [type]
        , schema_name
        , object_name
        , create_date
        , [replicated]
     FROM #table_list
    ORDER BY [database_name], [type], schema_name, object_name

   PRINT ''
   PRINT ''
   PRINT 'Column Search'
   PRINT ''

   TRUNCATE TABLE #table_list
  
   DECLARE database_cursor CURSOR
       FOR SELECT [name] 
             FROM master.sys.databases WITH (NOLOCK)
			WHERE state_desc = 'ONLINE'
            ORDER BY name

      OPEN database_cursor
     FETCH NEXT FROM database_cursor INTO @database_name
	
     WHILE @@FETCH_STATUS = 0
           BEGIN
           SET @sql_string = 'INSERT #table_list'
           SET @sql_string = @sql_string + ' SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', o.type, schema_name=LEFT(s.name,20), object_name=LEFT(o.name,80), column_name=LEFT(c.name,40), o.create_date, replicated=CASE WHEN o.is_published | o.is_schema_published > 0 THEN '' Published'' ELSE '''' END'
           SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.objects o WITH (NOLOCK)'
           SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id'
           SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.columns c WITH (NOLOCK) ON o.object_id = c.object_id'
           SET @sql_string = @sql_string + ' WHERE c.name LIKE ''%' + @search_string + '%'''
           SET @sql_string = @sql_string + ' ORDER BY o.type, s.name, o.name, o.create_date, c.name'
           
           EXEC sp_executesql @sql_string
     FETCH NEXT FROM database_cursor INTO @database_name
    END
	CLOSE database_cursor
	DEALLOCATE database_cursor
	SET NOCOUNT OFF
	SELECT	database_name,
		type,
		schema_name,
		object_name,
		create_date,
		replicated
	FROM #table_list
	ORDER BY
		database_name,
		type,
		schema_name,
		object_name

	PRINT ''
	PRINT ''
	PRINT 'Code Search'
	PRINT ''
	SET NOCOUNT ON
	TRUNCATE TABLE #table_list
	DECLARE database_cursor CURSOR FOR 
	 SELECT [name] 
	   FROM master.sys.databases WITH (NOLOCK)
	  WHERE state_desc = 'ONLINE'
	  ORDER BY [name]
	  
	OPEN database_cursor
	FETCH NEXT FROM database_cursor INTO @database_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql_string = 'INSERT #table_list'
		SET @sql_string = @sql_string + ' SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', o.type, schema_name=LEFT(s.name,20), object_name=LEFT(o.name,80), NULL, o.create_date, replicated=CASE WHEN o.is_published | o.is_schema_published > 0 THEN '' Published'' ELSE '''' END'
		SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.objects o WITH (NOLOCK)'
		SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id'
		SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.sql_modules c WITH (NOLOCK) ON o.object_id = c.object_id'
		SET @sql_string = @sql_string + ' WHERE c.definition LIKE ''%' + @search_string + '%'''
		SET @sql_string = @sql_string + ' ORDER BY o.type, s.name, o.name, o.create_date'
		EXEC sp_executesql @sql_string
		FETCH NEXT FROM database_cursor INTO @database_name
	END
	CLOSE database_cursor
	DEALLOCATE database_cursor
	SET NOCOUNT OFF
	SELECT	database_name,
		type,
		schema_name,
		object_name,
		create_date,
		replicated
	FROM #table_list
	ORDER BY
		database_name,
		type,
		schema_name,
		object_name
END
ELSE
BEGIN
	PRINT ''
	PRINT 'Object Search'
	PRINT ''
	SET @sql_string = 'SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', o.type, schema_name=LEFT(s.name,20), object_name=LEFT(o.name,80), o.create_date, replicated=CASE WHEN o.is_published | o.is_schema_published > 0 THEN '' Published'' ELSE '''' END'
	SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.objects o WITH (NOLOCK)'
	SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id'
	SET @sql_string = @sql_string + ' WHERE o.name LIKE ''%' + @search_string + '%'''
	SET @sql_string = @sql_string + ' AND o.type LIKE ''%' + @object_type + '%'''
	SET @sql_string = @sql_string + ' AND o.is_published | o.is_schema_published >= ' + CONVERT(VARCHAR(1),@replicated)
	SET @sql_string = @sql_string + ' ORDER BY o.type, s.name, o.name, o.create_date'
	EXEC sp_executesql @sql_string

	PRINT ''
	PRINT ''
	PRINT 'Column Search'
	PRINT ''
	SET @sql_string = 'SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', o.type, schema_name=LEFT(s.name,20), object_name=LEFT(o.name,80), column_name=LEFT(c.name,40), o.create_date, replicated=CASE WHEN o.is_published | o.is_schema_published > 0 THEN '' Published'' ELSE '''' END'
	SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.objects o WITH (NOLOCK)'
	SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id'
	SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.columns c WITH (NOLOCK) ON o.object_id = c.object_id'
	SET @sql_string = @sql_string + ' WHERE c.name LIKE ''%' + @search_string + '%'''
	SET @sql_string = @sql_string + ' ORDER BY o.type, s.name, o.name, o.create_date, c.name'
	EXEC sp_executesql @sql_string

	PRINT ''
	PRINT ''
	PRINT 'Code Search'
	PRINT ''
	SET @sql_string = 'SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', o.type, schema_name=LEFT(s.name,20), object_name=LEFT(o.name,80), o.create_date, replicated=CASE WHEN o.is_published | o.is_schema_published > 0 THEN '' Published'' ELSE '''' END'
	SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.objects o WITH (NOLOCK)'
	SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id'
	SET @sql_string = @sql_string + ' JOIN [' + @database_name + '].sys.sql_modules c WITH (NOLOCK) ON o.object_id = c.object_id'
	SET @sql_string = @sql_string + ' WHERE c.definition LIKE ''%' + @search_string + '%'''
	SET @sql_string = @sql_string + ' ORDER BY o.type, s.name, o.name, o.create_date'
	EXEC sp_executesql @sql_string
END

GO
