    USE TempDB
GO
--===== Create a Tally table here because we don't know where other's 
     -- Tally tables are...
SELECT TOP 11000 --equates to more than 30 years of dates
        IDENTITY(INT,1,1) AS N
   INTO dbo.Tally
   FROM Master.dbo.SysColumns sc1,
        Master.dbo.SysColumns sc2

--===== Add a Primary Key to maximize performance
  ALTER TABLE dbo.Tally
    ADD CONSTRAINT PK_Tally_N 
        PRIMARY KEY CLUSTERED (N) WITH FILLFACTOR = 100

--===== Allow the general public to use it
  GRANT SELECT ON dbo.Tally TO PUBLIC
GO

CREATE FUNCTION dbo.fProperCase (@MyString VARCHAR(8000))
/******************************************************************************
Purpose:
This function takes the input string, changes all characters to lower case,
and then changes the leading character of each word to uppercase.

Dependencies:
The dbo.Tally table must exist prior to use of this function.

Revision History:
10/23/2005 - Jeff Moden - Initial creation and unit test
******************************************************************************/
RETURNS VARCHAR(8000)
AS
BEGIN
    --===== First, set the whole string to lowercase so we know the condition
        SET @MyString = LOWER(@MyString)
    
    --===== Set the first character to uppercase, no matter what        
        SET @MyString = STUFF(@MyString,1,1,UPPER(SUBSTRING(@MyString,1,1)))
    
    --===== Set the first character following a "separator" to uppercase
     SELECT @MyString = STUFF(@MyString,N+1,1,UPPER(SUBSTRING(@MyString,N+1,1)))
       FROM tempdb.dbo.Tally
      WHERE N<LEN(@MyString)
        AND SUBSTRING(@MyString,N,1) LIKE '[^A-Z]'

--===== Return the proper case value
RETURN @MySTRING
END


SELECT * FROM tempdb..tally

UPDATE tchpadron
   SET nombre = dbo.fProperCase(apellido)