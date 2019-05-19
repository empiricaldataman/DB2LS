USE master
GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE [name]='XE_Monitor_Performance')  
   DROP EVENT SESSION [XE_Monitor_Performance] ON SERVER 
GO

CREATE EVENT SESSION [XE_Monitor_Performance]
    ON SERVER 
   ADD EVENT sqlserver.rpc_completed (
   SET collect_statement = (1)
       ACTION ( sqlserver.client_hostname
              , sqlserver.database_name
              , sqlserver.query_hash
              , sqlserver.server_principal_name
              , sqlserver.session_id
              , sqlserver.sql_text
              , sqlserver.transaction_id
              , sqlserver.transaction_sequence
              , sqlserver.username)
 WHERE ([package0].[greater_than_equal_uint64]([logical_reads],(200000)) OR [package0].[greater_than_equal_uint64]([duration],(3000000)))),
   ADD EVENT sqlserver.sql_batch_completed (
   SET collect_batch_text = (1)
       ACTION ( sqlserver.client_hostname
              , sqlserver.database_name
              , sqlserver.query_hash
              , sqlserver.server_principal_name
              , sqlserver.session_id
              , sqlserver.sql_text
              , sqlserver.transaction_id
              , sqlserver.transaction_sequence
              , sqlserver.username)
 WHERE ([package0].[greater_than_equal_uint64]([logical_reads],(200000)) OR [package0].[greater_than_equal_uint64]([duration],(3000000))))
   ADD TARGET package0.ring_buffer (
   SET max_events_limit=(10000))
  WITH ( MAX_MEMORY=10240 KB
       , EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS
       , MAX_DISPATCH_LATENCY=10 SECONDS
       , MAX_EVENT_SIZE=0 KB
       , MEMORY_PARTITION_MODE=NONE
       , TRACK_CAUSALITY=OFF
       , STARTUP_STATE=OFF)
GO