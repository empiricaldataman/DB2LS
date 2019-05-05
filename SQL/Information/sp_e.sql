IF OBJECT_ID(N'dbo.sp_e','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_e
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_e.sql
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

CREATE PROCEDURE [dbo].[sp_e]
       @database_name VARCHAR(100),
       @schema_name VARCHAR(100) = 'dbo',
       @object_name VARCHAR(200)

AS

DECLARE	@sql_string NVARCHAR(1000)

BEGIN
	PRINT ''
	PRINT 'Referencing Objects'
	PRINT ''
	SET @sql_string = N'USE [' + @database_name + ']'
	SET @sql_string = @sql_string + 'SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', referencing_schema_name = LEFT(referencing_schema_name,20), referencing_entity_name = LEFT(referencing_entity_name,80)'
	SET @sql_string = @sql_string + ' FROM [sys].[dm_sql_referencing_entities] (''[' + @schema_name + '].[' + @object_name + ']'', ''OBJECT'')'
	SET @sql_string = @sql_string + ' ORDER BY referencing_schema_name, referencing_entity_name;'
	EXEC sp_executesql @sql_string

	PRINT ''
	PRINT 'Referenced Objects'
	PRINT ''
	SET @sql_string = N'USE [' + @database_name + ']'
	SET @sql_string = @sql_string + 'SELECT referenced_server_name = LEFT(referenced_server_name,30), referenced_database_name = LEFT(referenced_database_name,30), referenced_schema_name = LEFT(referenced_schema_name,20), referenced_entity_name = LEFT(referenced_entity_name,80), referenced_minor_name = LEFT(referenced_minor_name,40)'
	SET @sql_string = @sql_string + ' FROM [sys].[dm_sql_referenced_entities] (''[' + @schema_name + '].[' + @object_name + ']'', ''OBJECT'')'
	SET @sql_string = @sql_string + ' ORDER BY referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, referenced_minor_name;'
	EXEC sp_executesql @sql_string
END
GO