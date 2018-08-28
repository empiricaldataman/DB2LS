USE [master]
GO

IF OBJECT_ID(N'dbo.sp_enable_indexes','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_enable_indexes
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_enable_indexes.sql
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
CREATE PROCEDURE [dbo].[sp_enable_indexes]
       @database SYSNAME
     , @schema SYSNAME = 'dbo'
     , @table SYSNAME

AS

DECLARE	@sql_string	NVARCHAR(4000)
      , @index SYSNAME
      , @compression CHAR(4)
      , @version TINYINT

-- Get the version of SQL Server (8 = 2000, 9 = 2005, 10 = 2008)
SET @version = LEFT(CONVERT(VARCHAR,SERVERPROPERTY('productversion')),CHARINDEX('.',CONVERT(VARCHAR,SERVERPROPERTY('productversion')))-1)

BEGIN TRY
-- Check if the database exists
   IF NOT EXISTS (SELECT * FROM master.sys.databases WHERE name = @database) 
      BEGIN
      PRINT @database + ' database does not exist.'
      RAISERROR ('Invalid @database parameter',16,1)
   END

-- Check if the table exists or has disabled nonclustered indexes
   SET @sql_string = '
		IF NOT EXISTS 
		(
			SELECT *
			FROM ' + @database + '.sys.schemas s
			JOIN ' + @database + '.sys.tables  t ON s.schema_id = t.schema_id
			WHERE s.name = ''' + @schema + '''
			AND t.name = ''' + @table + '''
		)
		BEGIN
			PRINT ''[' + @database + '].[' + @schema + '].[' + @table + '] does not exist.''
			RAISERROR (''Invalid @schema or @table parameter'',16,1)
		END
		ELSE
		IF NOT EXISTS 
		(
			SELECT *
			FROM ' + @database + '.sys.schemas s
			JOIN ' + @database + '.sys.tables  t ON s.schema_id = t.schema_id
			JOIN ' + @database + '.sys.indexes i ON t.object_id = i.object_id
			WHERE s.name = ''' + @schema + '''
			AND t.name = ''' + @table + '''
			AND i.type > 1
			AND i.is_disabled = 1
		)
		BEGIN
			PRINT ''[' + @database + '].[' + @schema + '].[' + @table + '] does not have any disabled nonclustered indexes.''
		END
		'

   EXEC sp_executesql @sql_string
END TRY
BEGIN CATCH
   DECLARE @error_message VARCHAR(1000)
   SET @error_message=ERROR_MESSAGE() 
   RAISERROR (@error_message,16,1)
   RETURN -1
END CATCH

-- Enable nonclustered indexes
IF @version < 10
   BEGIN -- compression unavailable
   SET @sql_string = '
		DECLARE IndexCursor CURSOR FOR
		SELECT i.name AS IndexName
		FROM ' + @database + '.sys.schemas s
		JOIN ' + @database + '.sys.tables  t ON s.schema_id = t.schema_id
		JOIN ' + @database + '.sys.indexes i ON t.object_id = i.object_id
		WHERE s.name = ''' + @schema + '''
		AND t.name = ''' + @table + '''
		AND i.type > 1
		AND i.is_disabled = 1
		ORDER BY i.type, i.name'

   EXEC sp_executesql @sql_string

   OPEN IndexCursor
   FETCH NEXT FROM IndexCursor 
   INTO @index

   WHILE @@FETCH_STATUS = 0
         BEGIN
         SELECT @sql_string = 'SET QUOTED_IDENTIFIER ON ALTER INDEX [' + @index + '] ON [' + @database + '].[' + @schema + '].[' + @table + '] REBUILD'
         PRINT @sql_string
         EXEC sp_executesql @sql_string
         FETCH NEXT FROM IndexCursor 
          INTO @index
   END
END
ELSE
BEGIN -- compression available
   SET @sql_string = '
		DECLARE @compression CHAR(4)
		SELECT @compression = p.data_compression_desc
		FROM ' + @database + '.sys.schemas s
		JOIN ' + @database + '.sys.tables t ON s.schema_id = t.schema_id
		JOIN ' + @database + '.sys.partitions p WITH (NOLOCK) ON t.object_id = p.object_id
		WHERE t.name = ''' + @table + '''
		AND p.index_id IN (0,1)


		DECLARE IndexCursor CURSOR FOR
		SELECT i.name AS IndexName, @compression
		FROM ' + @database + '.sys.schemas s
		JOIN ' + @database + '.sys.tables  t ON s.schema_id = t.schema_id
		JOIN ' + @database + '.sys.indexes i ON t.object_id = i.object_id
		WHERE s.name = ''' + @schema + '''
		AND t.name = ''' + @table + '''
		AND i.type > 1
		AND i.is_disabled = 1
		ORDER BY i.type, i.name'

   EXEC sp_executesql @sql_string

   OPEN IndexCursor
   FETCH NEXT FROM IndexCursor INTO @index, @compression

   WHILE @@FETCH_STATUS = 0
         BEGIN
         SELECT @sql_string = 'SET QUOTED_IDENTIFIER ON ALTER INDEX [' + @index + '] ON [' + @database + '].[' + @schema + '].[' + @table + '] REBUILD WITH (DATA_COMPRESSION = ' + @compression + ')'
         PRINT @sql_string
         EXEC sp_executesql @sql_string
         FETCH NEXT FROM IndexCursor 
          INTO @index, @compression
   END
END
CLOSE IndexCursor
DEALLOCATE IndexCursor

GO
