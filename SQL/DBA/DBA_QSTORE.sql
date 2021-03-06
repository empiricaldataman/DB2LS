/*-----------------------------------------------------------------------------------------------
        NAME: DBA_QSTORE.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays basic information about data in the query store
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    04.14.2019  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET NOCOUNT ON

SELECT CAST(GETDATE() AS DATE) [date]
     , @@SERVERNAME [instance_name]
     , A.query_id
     , COUNT(C.plan_id) plan_count
     , A.object_id
     , MAX(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), C.last_execution_time)) local_last_execution_time
     , MAX(B.query_sql_text) query_text
  FROM sys.query_store_query A
 INNER JOIN sys.query_store_query_text B ON A.query_text_id = B.query_text_id
 INNER JOIN sys.query_store_plan C ON A.query_id = C.query_id
 GROUP BY A.query_id, A.object_id
GO
