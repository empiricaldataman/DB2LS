/*-------------------------------------------------------------------------------------------------
        NAME: fn_ParseCommaDelimitedList.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Returns a table with rows from a comma delimited list
   PARAMETER: @myString - String of comma delimited values
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    01.04.2005  SYoung          Initial creation
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
USE master
GO

IF OBJECT_ID(N'dbo.fn_ParseCommaDelimitedList') IS NOT NULL
   DROP FUNCTION dbo.fn_ParseCommaDelimitedList
GO

CREATE FUNCTION dbo.fn_ParseCommaDelimitedList (
       @myString varchar(255))

RETURNS @TableNames TABLE (
        [table_name] varchar(255))

AS

BEGIN

DECLARE @myPosition int,
        @myLen int,
        @myStart int

SELECT @myPosition = -1,
       @myString = @myString + ',',
       @myLen = LEN(@myString),
       @myStart = 1

WHILE @myPosition < @myLen
BEGIN
      INSERT @TableNames
      SELECT SUBSTRING(@myString,@myStart,CHARINDEX(',',@myString,@myPosition + 1) - @myStart)

      SELECT @myPosition = CHARINDEX(',',@myString,@myPosition + 1)
      SELECT @myStart = @myPosition
END

RETURN
END
GO
