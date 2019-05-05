IF OBJECT_ID(N'dbo.sp_i','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_i
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_i.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about file IO
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
CREATE PROCEDURE [dbo].[sp_i]

AS

SET NOCOUNT ON

CREATE TABLE #filelist (
       [dbid] int
     , dbname varchar(255)
     , fileid int
     , [filename] varchar(255))

INSERT INTO #filelist
  EXEC sp_foreachdb 'use [?] select db_id(),db_name(),fileid,name from sysfiles'

DECLARE @dbid int
      , @dbname varchar(255)
      , @fileid int
      , @filename varchar(255)

DECLARE loop_cursor CURSOR 
    FOR SELECT [dbid],dbname,fileid,filename 
   FROM #filelist 
  ORDER BY dbname, [filename]

   OPEN loop_cursor
  FETCH NEXT FROM loop_cursor 
   INTO @dbid,@dbname,@fileid,@filename

WHILE @@FETCH_STATUS = 0
      BEGIN
      SELECT SUBSTRING(@dbname,1,20) [dbname]
		   , SUBSTRING(@filename,1,20) [filename]
		   , [timestamp]
           , numberreads
           , numberwrites
           , bytesread
           , byteswritten
           , iostallms
		FROM ::fn_virtualfilestats(@dbid,@fileid)
	
      FETCH NEXT FROM loop_cursor 
       INTO @dbid, @dbname, @fileid, @filename
END
CLOSE loop_cursor
DEALLOCATE loop_cursor
GO

