/*
-------------------------------------------------------------------------------------------------
        NAME: SA_Jobs_Stats.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Returns time and duration for each step of a SQL Agent job.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
--             08.20.2019  SYOUNG        First version
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
USE msdb
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @run_date int
      , @status tinyint

SELECT @run_date = 20190819
SELECT @status = 0

SELECT A.[name] [JobName]
     , B.step_name
     , B.[command]
     , CASE WHEN C.run_status = 0 THEN 'FAILED'
            WHEN C.run_status = 1 THEN 'SUCCEEDED'
            WHEN C.run_status = 2 THEN 'RETRY'
            WHEN C.run_status = 3 THEN 'CANCELLED'
            WHEN C.run_status = 4 THEN 'IN PROGRESS'
            ELSE '' END [run_status]
     , dbo.agent_datetime(C.run_date, C.run_time) [StepStartTime]
     , DATEADD(ss,(CASE WHEN C.run_duration < 100 THEN C.run_duration
                        WHEN C.run_duration < 1000   THEN (LEFT(C.run_duration,1) * 60) + RIGHT(C.run_duration,2)
                        WHEN C.run_duration < 10000  THEN (LEFT(C.run_duration,2) * 60) + RIGHT(C.run_duration,2)
                        WHEN C.run_duration < 100000 THEN ((LEFT(C.run_duration,1) * 60) * 60) + (CAST(SUBSTRING(CAST(C.run_duration AS CHAR(6)),3,1) AS INT) * 60) + RIGHT(C.run_duration,2)
                        WHEN C.run_duration > 99999  THEN ((LEFT(C.run_duration,2) * 60) * 60)+ (CAST(SUBSTRING(CAST(C.run_duration AS CHAR(6)),3,2) AS INT) * 60) + RIGHT(C.run_duration,2)
                        ELSE 0 END),(dbo.agent_datetime(C.run_date, C.run_time))) [StepEndTime]
     , master.dbo.fn_CreateTimeString(CASE WHEN C.run_duration < 100    THEN C.run_duration
                                           WHEN C.run_duration < 1000   THEN (LEFT(C.run_duration,1) * 60) + RIGHT(C.run_duration,2)
                                           WHEN C.run_duration < 10000  THEN (LEFT(C.run_duration,2) * 60) + RIGHT(C.run_duration,2)
                                           WHEN C.run_duration < 100000 THEN ((LEFT(C.run_duration,1) * 60) * 60) + (CAST(SUBSTRING(CAST(C.run_duration AS CHAR(6)),3,1) AS INT) * 60) + RIGHT(C.run_duration,2)
                                           WHEN C.run_duration > 99999  THEN ((LEFT(C.run_duration,2) * 60) * 60)+ (CAST(SUBSTRING(CAST(C.run_duration AS CHAR(6)),3,2) AS INT) * 60) + RIGHT(C.run_duration,2)
                                           ELSE 0 END) [RunTime]
  FROM [dbo].[sysjobs] A
 INNER JOIN [dbo].[sysjobsteps] B ON A.job_id = B.job_id
 INNER JOIN [dbo].[sysjobhistory] C ON B.job_id = C.job_id
   AND B.step_id = C.step_id
 WHERE 1 = 1
   AND C.run_date >= COALESCE(@run_date, C.run_date)
   AND C.run_status = COALESCE(@status, C.run_status)
 ORDER BY A.[name], C.run_date DESC , C.run_time
GO

