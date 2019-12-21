/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_Az_XE_Create.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this statement to create an extended event that will capture general databas
              activity.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
USE [<DBNAME, sysname,Database Name>]
GO

DROP EVENT SESSION [XE_Monitor_Activity] ON DATABASE 
GO

CREATE EVENT SESSION [XE_Monitor_Activity] ON DATABASE 
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)))),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4))))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO
