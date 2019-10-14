/*
-------------------------------------------------------------------------------------------------
        NAME: AG_Health.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: USE THIS QUERY TO VIEW HEALTH OF AG
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SELECT GETDATE() [collection_time]
     , @@SERVERNAME [instance_name]
     , ag.[name] [ag_name]
     , ar.replica_server_name [replica_instance]
     , dr_state.database_id [database_id]
     , CASE WHEN ar_state.is_local = 1 THEN N'LOCAL'
            ELSE 'REMOTE' END [location] 
     , CASE WHEN ar_state.role_desc IS NULL THEN N'DISCONNECTED'
            ELSE ar_state.role_desc END [role]
     , ar_state.connected_state_desc [connection_state]
     , ar.availability_mode_desc [mode]
     , dr_state.synchronization_state_desc [state]
  FROM ((sys.availability_groups ag 
       JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id )
       JOIN sys.dm_hadr_availability_replica_states ar_state ON ar.replica_id = ar_state.replica_id)
  JOIN sys.dm_hadr_database_replica_states dr_state ON ag.group_id = dr_state.group_id 
   AND dr_state.replica_id = ar_state.replica_id;
   