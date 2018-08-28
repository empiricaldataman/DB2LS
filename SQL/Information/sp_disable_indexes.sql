USE [master]
GO

IF OBJECT_ID(N'dbo.sp_disable_indexes','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_disable_indexes
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_disable_indexes.sql
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
CREATE PROCEDURE [dbo].[sp_disable_indexes]
       @database SYSNAME
     , @schema SYSNAME = 'dbo'
     , @table SYSNAME

AS

DECLARE	@sql_string NVARCHAR(4000)
      , @index SYSNAME


BEGIN TRY
-- Check if the database exists
   IF NOT EXISTS (SELECT * FROM master.sys.databases WHERE name = @database) 
      BEGIN
      PRINT @database + ' database does not exist.'
      RAISERROR ('Invalid @database parameter',16,1)
   END

-- Check if the table exists or has enabled nonclustered indexes
   SET @sql_string = 'IF NOT EXISTS (
			SELECT *
			FROM ' + @database + '.sys.schemas s
			JOIN ' + @database + '.sys.tables  t ON s.schema_id = t.schema_id
			WHERE s.name = ''' + @schema + '''
			AND t.name = ''' + @table + ''')
		BEGIN
			PRINT ''[' + @database + '].[' + @schema + '].[' + @table + '] does not exist.''
			RAISERROR (''Invalid @schema or @table parameter'',16,1)
		END
		ELSE
		IF NOT EXISTS (
			SELECT *
			FROM ' + @database + '.sys.schemas s
			JOIN ' + @database + '.sys.tables  t ON s.schema_id = t.schema_id
			JOIN ' + @database + '.sys.indexes i ON t.object_id = i.object_id
			WHERE s.name = ''' + @schema + '''
			AND t.name = ''' + @table + '''
			AND i.type > 1
			AND i.is_disabled = 0)
		BEGIN
			PRINT ''[' + @database + '].[' + @schema + '].[' + @table + '] does not have any enabled nonclustered indexes.''
		END'
   
   EXEC sp_executesql @sql_string
END TRY
BEGIN CATCH
   DECLARE @error_message VARCHAR(1000)
   SET @error_message=ERROR_MESSAGE() 
   RAISERROR (@error_message,16,1)
   RETURN -1
END CATCH

-- Disable nonclustered indexes
SET @sql_string = '
	DECLARE IndexCursor CURSOR FOR
	SELECT i.name AS IndexName
	FROM ' + @database + '.sys.schemas s
	JOIN ' + @database + '.sys.tables  t ON s.schema_id = t.schema_id
	JOIN ' + @database + '.sys.indexes i ON t.object_id = i.object_id
	WHERE s.name = ''' + @schema + '''
	AND t.name = ''' + @table + '''
	AND i.type > 1
	AND i.is_disabled = 0
	ORDER BY i.type DESC, i.name'

EXEC sp_executesql @sql_string

 OPEN IndexCursor
FETCH NEXT FROM IndexCursor 
 INTO @index

WHILE @@FETCH_STATUS = 0
      BEGIN
      SELECT @sql_string = 'ALTER INDEX [' + @index + '] ON [' + @database + '].[' + @schema + '].[' + @table + '] DISABLE'
      PRINT @sql_string
      EXEC sp_executesql @sql_string
      FETCH NEXT FROM IndexCursor
       INTO @index
END
CLOSE IndexCursor
DEALLOCATE IndexCursor

GO
