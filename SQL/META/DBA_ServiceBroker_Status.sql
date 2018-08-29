/*-----------------------------------------------------------------------------------------------
        NAME: DBA_ServiceBroker_Status.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays Service Broker information. It shows if the
              feature is enabled and if a db master key exist.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000     02.12.2012  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON
GO

USE master
GO

SELECT name [DatabaseName]
     , is_broker_enabled [IsServiceBrokerEnabled]
     , is_master_key_encrypted_by_server [HasDatabaseMasterKey]
  FROM sys.databases
 WHERE is_broker_enabled = 1;
GO
