/*-------------------------------------------------------------------------------------------------
        NAME: RPL_MonitorDistributions.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to get execution details of the distribution job for a specific
              publication.  
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
	      killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:CONNECT PO
USE Distribution
GO

SET NOCOUNT ON

DECLARE @name nvarchar(100)
      , @hours int = 0 /* @hours < 0 will return TOP 100 */
      , @session_type int = 1 /* Return all sessions */
      , @notstarted int
    	, @succeed int
      , @retry int
      , @failure int
      , @min_time datetime
      , @agent_id int

--ASSIGN VALUE TO @name SELECTING A JOB NAME FROM QUERY BELOW
/*
SELECT J.[name]
     , C.[name] [Category]
  FROM [msdb].[dbo].[sysjobs] J
 INNER JOIN [msdb].[dbo].[syscategories] C ON J.category_id = C.category_id
 WHERE C.[name] = 'REPL-Distribution'
*/

select @name = N'RCPSQL01\ORG-Facts-Facts - Reporting-RCHPSQL50.-102'
     , @notstarted = 0
     , @succeed = 2
     , @retry = 5
     , @failure = 6
     , @min_time = NULL

SELECT @agent_id = id 
  FROM MSdistribution_agents 
 WHERE name = @name

IF @hours < 0
   SET rowcount 100
ELSE IF @hours > 0
   SELECT @min_time = DATEADD(HOUR, -@hours, GETDATE())

SELECT rh.runstatus
     , sys.fn_replformatdatetime(rh.start_time) [start_time]
     , sys.fn_replformatdatetime(rh.time) [time]
     , rh.comments
     , msdb.[dbo].[fn_CreateTimeString](rh.duration) [duration]
     , rh.delivery_rate                                            --The average number of commands delivered per second since the last history entry.
     , (rh.delivery_latency * 1.0) / 1000 [delivery_latency (sec)] --The latency between the command entering the distribution database and being applied to the Subscriber since the last history entry. In milliseconds.
     , rh.delivered_transactions                                   --The total number of transactions delivered in the session.
     , rh.delivered_commands                                       --The total number of commands delivered in the session.
     , rh.average_commands
     , hs.action_count [action_count]
     , rh.error_id
  FROM MSdistribution_history rh WITH (READPAST) 
  JOIN (SELECT agent_id
             , start_time
             , COUNT(start_time) [action_count]
             , MAX(timestamp) [max_timestamp] 
          FROM MSdistribution_history WITH (READPAST)
         WHERE agent_id = @agent_id
           AND runstatus != @notstarted
           AND comments not like N'<stats state%'	
           AND (@session_type = 1
               OR runstatus = @failure)
         GROUP BY agent_id, start_time) AS hs ON rh.agent_id = hs.agent_id
   AND rh.start_time = hs.start_time
   AND rh.timestamp = hs.max_timestamp
-- if min time is specified then return sessions after that 
 WHERE (@min_time IS NULL 
       OR time >= @min_time)
-- AND (rh.duration) > 300 --APPLY THIS FILTER WHEN YOU WANT TO SEE EXECUTION THAT TOOK 5 MIN OR LONGER
 ORDER BY timestamp DESC
GO

