IF OBJECT_ID(N'dbo.sp_refresh_views','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_refresh_views
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_refresh_views.sql
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
CREATE PROCEDURE [dbo].[sp_refresh_views]

AS

DECLARE	@sql_string	NVARCHAR(4000)
      , @database SYSNAME
      , @schema SYSNAME
      , @view SYSNAME
      , @fail bit

SET @database = DB_NAME()
SET @fail = 0

SET @sql_string = '
DECLARE ViewCursor CURSOR GLOBAL FOR
SELECT DISTINCT s.name, v.name
  FROM [' + @database + '].[sys].[views] v WITH (NOLOCK)
  JOIN [' + @database + '].[sys].[schemas] s  WITH (NOLOCK) ON v.schema_id = s.schema_id
  LEFT JOIN [' + @database + '].[sys].[sql_dependencies] sd WITH (NOLOCK) ON v.object_id = sd.object_id 
 WHERE v.is_ms_shipped = 0
   AND (sd.class IS NULL OR sd.class NOT IN (1,2,3,4)) 
 ORDER BY s.name,v.name'

EXEC sp_executesql @sql_string

 OPEN ViewCursor
FETCH NEXT FROM ViewCursor INTO @schema, @view

WHILE @@FETCH_STATUS = 0
      BEGIN
      SELECT @sql_string = 'EXEC sp_refreshview ''' + @database + '.' + @schema + '.' + @view + ''''
      PRINT @sql_string
      BEGIN TRY
         EXECUTE sp_executesql @sql_string
      END TRY
      BEGIN CATCH
         SET @fail = 1
         PRINT ERROR_MESSAGE()
         PRINT ''
      END CATCH
      FETCH NEXT FROM ViewCursor INTO @schema, @view
END
CLOSE ViewCursor
DEALLOCATE ViewCursor

IF @fail = 1
   BEGIN
   PRINT ''
   RAISERROR ('Failed executing sp_refresh_views',16,1)
END
GO
