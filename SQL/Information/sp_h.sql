USE [master]
GO

IF OBJECT_ID(N'dbo.sp_h','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_h
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_h.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Called by sp_r
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
CREATE PROCEDURE [dbo].[sp_h]
       @binvalue varbinary(256)
     , @hexvalue varchar (514) OUTPUT

AS

DECLARE @charvalue varchar (514)
      , @i int
      , @length int
      , @hexstring char(16)

SELECT @charvalue = '0x'
SELECT @i = 1
SELECT @length = DATALENGTH (@binvalue)
SELECT @hexstring = '0123456789ABCDEF'

WHILE (@i <= @length)
      BEGIN
      DECLARE @tempint int
            , @firstint int
            , @secondint int

      SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
      SELECT @firstint = FLOOR(@tempint/16)
      SELECT @secondint = @tempint - (@firstint*16)
      SELECT @charvalue = @charvalue +
      SUBSTRING(@hexstring, @firstint+1, 1) +
      SUBSTRING(@hexstring, @secondint+1, 1)
      SELECT @i = @i + 1
END
SELECT @hexvalue = @charvalue
GO
