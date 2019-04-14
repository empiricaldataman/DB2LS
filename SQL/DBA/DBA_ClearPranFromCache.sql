/*-----------------------------------------------------------------------------------------------
        NAME: DBA_ClearPlanFromCache.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Removes an execution plan from the cache

              You must specify avalue for the template parameter. Hit CTRL + SHIFT + M and enter '
              the object name.'
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

DECLARE @handle varbinary(64)

SELECT @handle = cp.plan_handle
  FROM sys.dm_exec_cached_plans cp 
 CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
 WHERE OBJECT_NAME(st.objectid, st.[dbid]) = '<ObjectName, sysname, Operator Name>'

DBCC FREEPROCCACHE(@handle)
GO
