/*-------------------------------------------------------------------------------------------------
        NAME: fn_HexToChar.sql
  CREATED BY: Gregory A. Larsen
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: This function will take any binary value and return the hex value as a character
              representation. In order to use this function you need to pass the binary hex value 
              and the number of bytes you want to convert.
   PARAMETER: 
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    05.25.2004  GLarsen       Initial creation.
--            07.13.2018  SYoung        Add code to handle days.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
USE master
GO

CREATE FUNCTION dbo.fn_HexToChar (
       @x varbinary(100), -- binary hex value
       @l int -- number of bytes
  ) 
  
RETURNS VARCHAR(200)

AS 

BEGIN

DECLARE @i varbinary(10)
      , @digits char(16)
      , @s varchar(100)
      , @h varchar(100)
      , @j int

SELECT @digits = '0123456789ABCDEF'
     , @j = 0 
     , @h = ''

-- process all  bytes
WHILE @j < @l
      BEGIN
      SET @j= @j + 1
      -- get first character of byte
      SET @i = substring(cast(@x as varbinary(100)),@j,1)
      -- get the first character
      SET @s = cast(substring(@digits,@i%16+1,1) as char(1))
      -- shift over one character
      SET @i = @i/16 
      -- get the second character
      SET @s = cast(substring(@digits,@i%16+1,1) as char(1)) + @s
      -- build string of hex characters
      SET @h = @h + @s
END

RETURN(@h)
END
GO
