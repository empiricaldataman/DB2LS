IF OBJECT_ID(N'dbo.sp_control_login','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_control_login
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_control_login.sql
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
CREATE PROCEDURE [dbo].[sp_control_login]
       @login_string SYSNAME -- login pattern, such as 'DOMAIN\AD_GROUP_'
     , @grant_or_deny VARCHAR(5) -- 'GRANT' or 'DENY'

AS

DECLARE	@sql_string NVARCHAR(1000)
      , @login_name SYSNAME

BEGIN TRY
   DECLARE login_cursor CURSOR 
       FOR SELECT [name] 
      FROM master.sys.server_principals WITH (NOLOCK) 
     WHERE [name] LIKE @login_string + '%' 
     ORDER BY [name]

      OPEN login_cursor
     FETCH NEXT FROM login_cursor INTO @login_name
    
     WHILE @@FETCH_STATUS = 0
           BEGIN
           SET @sql_string = @grant_or_deny + ' CONNECT SQL TO [' + @login_name + ']'
           PRINT @sql_string
           EXEC sp_executesql @sql_string
           FETCH NEXT FROM login_cursor INTO @login_name
     END
     CLOSE login_cursor
     DEALLOCATE login_cursor
END TRY

BEGIN CATCH
     DECLARE @error_message VARCHAR(1000)
     SET @error_message=ERROR_MESSAGE() 
     RAISERROR (@error_message,16,1)
     CLOSE login_cursor
     DEALLOCATE login_cursor
     RETURN -1
END CATCH
GO
