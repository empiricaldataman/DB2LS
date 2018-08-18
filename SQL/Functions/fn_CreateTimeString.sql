/*-------------------------------------------------------------------------------------------------
        NAME: fn_CreateTimeString.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Returns a string representation of time.
   PARAMETER: @seconds
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    03.20.2018  SYoung        Initial creation.
--            07.13.2018  SYoung        Add code to handle days.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			  killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
USE master
GO

IF OBJECT_ID(N'fn_CreateTimeString','FN') IS NOT NULL
   DROP FUNCTION dbo.fn_CreateTimeString
GO

CREATE FUNCTION dbo.fn_CreateTimeString (
       @seconds int)

RETURNS varchar(50) AS 

BEGIN
    DECLARE @d int,
            @h int,
            @m int,
            @s int,
            @secs int,
            @BuildDate varchar(50)

    SELECT @secs = @seconds
    SELECT @d = @secs / 86400
    SELECT @secs = @secs - (@d*86400)
    SELECT @h = @secs / 3600
    SELECT @secs = @secs - (@h*3600)
    SELECT @m = @secs / 60
    SELECT @secs = @secs - (@m*60)
    SELECT @s = @secs

    IF @d = 0
       BEGIN

       IF @h = 0
          BEGIN
          IF @m = 0
             BEGIN
             SELECT @BuildDate = CAST(@s AS varchar) + CASE WHEN @s = 1 THEN ' second' ELSE ' seconds' END
          END
          ELSE
             BEGIN
             SELECT @BuildDate = CAST(@m AS varchar) + CASE WHEN @m = 1 THEN ' minute with ' ELSE ' minutes with ' END + CAST(@s AS varchar) + CASE WHEN @s = 1 THEN ' second' ELSE ' seconds' END
          END
       END
       ELSE
          BEGIN
          SELECT @BuildDate = CAST(@h AS varchar) + CASE WHEN @h = 1 THEN ' hour ' ELSE ' hours ' END + CAST(@m AS varchar) + CASE WHEN @m = 1 THEN ' minute with ' ELSE ' minutes with ' END + CAST(@s AS varchar) + CASE WHEN @s = 1 THEN ' second' ELSE ' seconds' END
       END
    END
    ELSE
        BEGIN
        SELECT @BuildDate = CAST(@d AS varchar) + CASE WHEN @d = 1 THEN ' day ' ELSE ' days ' END + CAST(@h AS varchar) + CASE WHEN @h = 1 THEN ' hour ' ELSE ' hours ' END + CAST(@m AS varchar) + CASE WHEN @m = 1 THEN ' minute with ' ELSE ' minutes with ' END + CAST(@s AS varchar) + CASE WHEN @s = 1 THEN ' second' ELSE ' seconds' END
    END

    RETURN CONVERT(varchar(50), @BuildDate)
END
GO

