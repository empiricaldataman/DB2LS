/*-------------------------------------------------------------------------------------------------
        NAME: DBA_Cluster_Status_OLTP.sql
  CREATED BY: Sal Young
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: RETURNS CURRENT SQL INSTANCE LOCATION IN THE OLTP FAILOVER CLUSTER
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/

:CONNECT <SQLInstance, sysname, SQLInstance>
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

SELECT LEFT(@@SERVERNAME,30) [sql_instance]
     , LEFT(CAST(B.create_date AS smalldatetime),20) [date_time_last_restart]
     , LEFT(NodeName, 20) [node_name]
     , LEFT([status], 7) [status]
     , status_description
     , is_current_owner
  FROM master.sys.dm_os_cluster_nodes A
  FULL JOIN master.sys.databases B ON 1 = 1
 WHERE B.[name] = 'tempdb'
GO
