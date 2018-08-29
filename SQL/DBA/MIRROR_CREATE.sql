--:CONNECT SERVER3
--USE master
--GO

--SET NOCOUNT ON
--------------------------------------------------------------------------------------------------------------------
----[ CHANGE DATABASE RECOVERY MODEL TO FULL
--ALTER DATABASE [AdventureWorks] SET RECOVERY FULL WITH NO_WAIT
--GO


--------------------------------------------------------------------------------------------------------------------
----[ ON PRINCIPAL SERVER DO A FULL AND TLOG BACKUP OF DATABASE
--:CONNECT SERVER3
--USE master
--GO
--BACKUP DATABASE AdventureWorks
--    TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\AdventureWorks.bak'
--  WITH FORMAT
--     , COMPRESSION
--     , INIT
--     , STATS = 5;

--BACKUP LOG [AdventureWorks]
--    TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\AdventureWorks.log'
--  WITH FORMAT
--     , INIT
--     , NAME = N'AdventureWorks-TLog Database Backup'
--     , NOREWIND
--     , NOUNLOAD
--     , COMPRESSION
--     , STATS = 5;
--GO


--------------------------------------------------------------------------------------------------------------------
----[ ON MIRROR SERVER RESTORE FULL AND TLOG WITH NORECOVERY
--:CONNECT SERVER4
--USE [master]
--GO
--RESTORE DATABASE [AdventureWorks] 
--   FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\AdventureWorks.bak'
--   WITH FILE = 1
--      , NORECOVERY
--      , NOUNLOAD
--      , REPLACE
--      , STATS = 5
--GO

--RESTORE LOG [AdventureWorks]
--   FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\AdventureWorks.log'
--   WITH FILE = 1
--      , NORECOVERY
--      , NOUNLOAD
--      , STATS = 10
--GO



--------------------------------------------------------------------------------------------------------------------
--[ CREATE END POINTS 
--:CONNECT SERVER3
--CREATE ENDPOINT endpoint_mirroring
-- STATE = STARTED
--	AS TCP (LISTENER_PORT = 5022)
--   FOR DATABASE_MIRRORING(ROLE = PARTNER)
--GO

--GRANT CONNECT ON ENDPOINT::endpoint_mirroring TO [SYLAB\sqlsvcs]
--GO


--:CONNECT SERVER4
--CREATE ENDPOINT endpoint_mirroring
-- STATE = STARTED
--	AS TCP (LISTENER_PORT = 5022)
--   FOR DATABASE_MIRRORING(ROLE = PARTNER)
--GO

--GRANT CONNECT ON ENDPOINT::endpoint_mirroring TO [SYLAB\sqlsvcs]
--GO

----------------------------------------------------------------------------------------------------------------------
----[ MIRROR SIDE MUST BE SET UP FIRST
--:CONNECT SERVER4
--ALTER DATABASE AdventureWorks
--  SET PARTNER = N'TCP://SERVER3.SYLAB.PTY:5022'
--GO

--:CONNECT SERVER3
--ALTER DATABASE AdventureWorks
--  SET PARTNER = N'TCP://SERVER4.SYLAB.PTY:5022'
--GO


----------------------------------------------------------------------------------------------------------------------
----[ TEST MANUAL FAILOVER
ALTER DATABASE AdventureWorks Set PARTNER FAILOVER
GO

--[ CHANGE MIRROR OPERATING MODE FROM SAFETY TO HIGH PERFORMANCE
--[ MUST BE EXECUTED ON THE PRINCIPAL
--[ The alter database for this partner config values may only be initiated on the current principal server for database "AdventureWorks".
ALTER DATABASE AdventureWorks SET PARTNER SAFETY OFF
--OR
ALTER DATABASE AdventureWorks SET PARTNER SAFETY FULL

--[ TEST MANUAL FAILOVER AFTER CHANGING OPERATING MODE TO HIGH PERFORMANCE WILL FAIL
--[ UNLESS YOU SPECIFY SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS
ALTER DATABASE AdventureWorks SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS


----------------------------------------------------------------------------------------------------------------------
--[
database_mirroring
database_mirroring_endpoints
database_mirroring_witnesses
dm_db_mirroring_auto_page_repair
dm_db_mirroring_connections
dm_db_mirroring_past_actions
