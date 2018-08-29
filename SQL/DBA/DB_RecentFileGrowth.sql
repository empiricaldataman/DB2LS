/*
-------------------------------------------------------------------------------------------------
        NAME: DB_RecentFileGrowth.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about database files growth events
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000     02.12.2012  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SET NOCOUNT ON

IF(SELECT CONVERT(int,value_in_use) FROM sys.configurations WHERE [name] = 'default trace enabled' ) = 1

BEGIN
  
    DECLARE @curr_tracefilename varchar(500)
          , @base_tracefilename varchar(500)
          , @indx int;

    SELECT @curr_tracefilename = [path]
      FROM sys.traces where is_default = 1 ;

       SET @curr_tracefilename = REVERSE(@curr_tracefilename);

    SELECT @indx  = PATINDEX('%\%', @curr_tracefilename) ;

       SET @curr_tracefilename = REVERSE(@curr_tracefilename) ;
       SET @base_tracefilename = LEFT( @curr_tracefilename,LEN(@curr_tracefilename) - @indx) + '\log.trc' ;  

    SELECT (DENSE_RANK() OVER(ORDER BY StartTime DESC))%2 AS [l1]
         , CONVERT(int, EventClass) [EventClass]
         , DatabaseName
         , [Filename]
         , msdb.dbo.fn_CreateTimeString((CAST(Duration AS numeric)/1000000.0)) [Duration]
         , StartTime
         , EndTime
         , (IntegerData*8.0/1024) [ChangeInSize]
      FROM ::fn_trace_gettable( @base_tracefilename, default )
     WHERE EventClass >= 92
       AND EventClass <= 95
     ORDER BY StartTime DESC;

END
GO
