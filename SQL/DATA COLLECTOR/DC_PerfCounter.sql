/*-----------------------------------------------------------------------------------------------
        NAME: DC_PerfCounter.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information captured by the "Collect Performance Counter" SQL Agent job.'
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    05.03.2019  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

WITH C
  AS (SELECT [collection_time]
           , [processes_blocked] - LAG([processes_blocked]) OVER (ORDER BY [collection_time]) [processes_blocked]
           , [user_connections] - LAG([user_connections]) OVER (ORDER BY [collection_time]) [user_connections]
           , ([free_list_stalls_sec] - LAG([free_list_stalls_sec]) OVER (ORDER BY [collection_time])) / 60. [free_list_stalls_sec]
           , CAST(([lazy_writes_sec] - LAG([lazy_writes_sec]) OVER (ORDER BY [collection_time])) / 60. AS numeric(19,2)) [lazy_writes_sec]
           , [page_life_expectancy] - LAG([page_life_expectancy]) OVER (ORDER BY [collection_time]) [page_life_expectancy]
           , CAST(([full_scans_sec] - LAG([full_scans_sec]) OVER (ORDER BY [collection_time])) / 60. AS numeric(19,2))[full_scans_sec]
           , CAST(([index_searches_sec] - LAG([index_searches_sec]) OVER (ORDER BY [collection_time])) / 60. AS numeric(19,2)) [index_searches_sec]
           , CAST(([batch_requests_sec] - LAG([batch_requests_sec]) OVER (ORDER BY [collection_time])) / 60. AS numeric(19,2)) [batch_requests_sec]
           , CAST(([sql_compilations_sec] - LAG([sql_compilations_sec]) OVER (ORDER BY [collection_time])) / 60. AS numeric(19,2)) [sql_compilations_sec]
           , ([sql_re-compilations_sec] - LAG([sql_re-compilations_sec]) OVER (ORDER BY [collection_time])) / 60. [sql_re-compilations_sec]
           , [memory_grants_pending] - LAG([memory_grants_pending]) OVER (ORDER BY [collection_time]) [memory_grants_pending]
        FROM [dbo].[PerfCounter]
       WHERE 1 = 1)

SELECT *
  FROM C
  WHERE page_life_expectancy < 1000000
 ORDER BY 1 DESC


