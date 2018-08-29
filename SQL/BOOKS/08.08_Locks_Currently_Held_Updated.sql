-- Listing 8.8 How to discover which locks are currently held
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET NOCOUNT ON

IF OBJECT_ID(N'tempdb..#Locks') IS NOT NULL DROP TABLE #Locks;

WITH CTE0 
  AS (SELECT DB_NAME(resource_database_id) AS DatabaseName
           , request_session_id [session_id]
           , resource_type
           , resource_associated_entity_id
           , request_status
           , request_mode
        FROM sys.dm_tran_locks l
       WHERE request_session_id ! = @@spid)

SELECT A.[session_id]
     , A.DatabaseName
     , A.resource_associated_entity_id
     , A.request_mode
     , CASE A.request_mode WHEN 'Sch-S' THEN 'Schema Stability'
                           WHEN 'X' THEN 'Exclusive'
                           WHEN 'S' THEN 'Shared'
                           WHEN 'IX' THEN 'Intent Exclusive'
                           WHEN 'Sch-M' THEN 'Schema Modification'
                           WHEN 'IS' THEN 'Intent Shared'
                           WHEN 'SIX' THEN 'Shared with Intent Exclusive'
                           WHEN 'IU' THEN 'Intent Update'
                           WHEN 'SIU' THEN 'Shared Intent Update'
                           WHEN 'UIX' THEN 'Update Intent Exclusive' END [LockMode]
     , S.[host_name]
     , S.login_name
     , COUNT(*) [LockCount]
  INTO #Locks
  FROM CTE0 A
 INNER JOIN sys.dm_exec_sessions S ON A.[session_id] = S.[session_id]
   AND S.[status] = 'Running'
 GROUP BY A.DatabaseName
     , A.[session_id]
     , A.resource_associated_entity_id
     , A.request_mode
     , S.[host_name]
     , S.login_name
-- ORDER BY A.[session_id], A.DatabaseName, D.[name];

 ALTER TABLE #Locks
   ADD [ObjectName] nvarchar(256)

 EXEC sp_MSForEachdb 'USE [?]
 UPDATE L
   SET [ObjectName] = A.[name] 
  FROM sys.objects A WITH (NOLOCK)
 INNER JOIN #Locks L ON L.resource_associated_entity_id = A.[object_id]
   AND ''?'' = L.DatabaseName'

SELECT [session_id]
     , DatabaseName
     , [ObjectName]
     , request_mode
     , [host_name]
     , login_name
  FROM #Locks