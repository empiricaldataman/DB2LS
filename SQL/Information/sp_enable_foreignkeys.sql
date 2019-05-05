IF OBJECT_ID(N'dbo.sp_enable_foreignkeys','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_enable_foreignkeys
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_enable_foreignkeys.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: 
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
CREATE PROCEDURE [dbo].[sp_enable_foreignkeys]
       @database SYSNAME
     , @schema SYSNAME = 'dbo'
     , @table SYSNAME = NULL

AS

DECLARE	@sql_string NVARCHAR(4000)
      , @foreignkey SYSNAME

BEGIN TRY
-- Check if the database exists

   IF NOT EXISTS (SELECT * FROM master.sys.databases WHERE name = @database) 
      BEGIN
      PRINT @database + ' database does not exist.'
      RAISERROR ('Invalid @database parameter',16,1)
   END

-- Check if the table exists or has disabled foreign keys
   IF @table IS NOT NULL
      BEGIN
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
				JOIN ' + @database + '.sys.foreign_keys f ON t.object_id = f.parent_object_id
				WHERE s.name = ''' + @schema + '''
				AND t.name = ''' + @table + '''
				AND f.is_disabled = 1
			)
			BEGIN
				PRINT ''[' + @database + '].[' + @schema + '].[' + @table + '] does not have any disabled foreign keys.''
			END
			'
	
      EXEC sp_executesql @sql_string
   END
END TRY
BEGIN CATCH
   DECLARE @error_message VARCHAR(1000)
   SET @error_message=ERROR_MESSAGE() 
   RAISERROR (@error_message,16,1)
   RETURN -1
END CATCH

-- Enable foreign keys
IF @table IS NULL
   BEGIN
   SET @sql_string = '
		DECLARE ForeignKeyCursor CURSOR FOR
		SELECT s.name AS SchemaName, t.name AS TableName, f.name AS ForeignKeyName
		FROM ' + @database + '.sys.schemas s
		JOIN ' + @database + '.sys.tables t ON s.schema_id = t.schema_id
		JOIN ' + @database + '.sys.foreign_keys f ON t.object_id = f.parent_object_id
		WHERE f.is_disabled = 1
		ORDER BY s.name, t.name, f.name'
END
ELSE
   BEGIN
   SET @sql_string = '
		DECLARE ForeignKeyCursor CURSOR FOR
		SELECT s.name AS SchemaName, t.name AS TableName, f.name AS ForeignKeyName
		FROM ' + @database + '.sys.schemas s
		JOIN ' + @database + '.sys.tables t ON s.schema_id = t.schema_id
		JOIN ' + @database + '.sys.foreign_keys f ON t.object_id = f.parent_object_id
		WHERE s.name = ''' + @schema + '''
		AND t.name = ''' + @table + '''
		AND f.is_disabled = 1
		ORDER BY s.name, t.name, f.name'
END
	
EXEC sp_executesql @sql_string
	
 OPEN ForeignKeyCursor
FETCH NEXT FROM ForeignKeyCursor 
 INTO @schema, @table, @foreignkey
	
WHILE @@FETCH_STATUS = 0
      BEGIN
      SELECT @sql_string = 'ALTER TABLE [' + @database + '].[' + @schema + '].[' + @table + '] WITH CHECK CHECK CONSTRAINT [' + @foreignkey + ']'
      PRINT @sql_string
      EXEC sp_executesql @sql_string
      FETCH NEXT FROM ForeignKeyCursor 
       INTO @schema, @table, @foreignkey
END
CLOSE ForeignKeyCursor
DEALLOCATE ForeignKeyCursor
GO
