/*-----------------------------------------------------------------------------------------------
        NAME: DB_InstancePort.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays the port number of a SQL instance
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-----------------------------------------------------------------------------------------------*/
SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT value_data [sql_instance_port]
  FROM sys.dm_server_registry 
 WHERE value_name LIKE '%tcp%' 
   AND value_data <> '' 
   AND registry_key NOT LIKE '%AdminConnection%'
