:CONNECT PR
USE [master]
GO
RESTORE DATABASE [<TargetDBName, sysname, DBName>] 
   FROM DISK = N'<SourceBackupFile, sysname, \\rbackup.corpint.net\SQL_Prod\....bak>' 
   WITH FILE = 1
      , MOVE N'DW_LossMitMart_data_01' TO N'F:\MSSQL\REPORTING\DATA08\Data\DW_LossMitMart_20170110_2108_data_01.mdf'
	  , MOVE N'DW_LossMitMart_log_01' TO N'F:\MSSQL\REPORTING\TRAN05\Data\DW_LossMitMart_20170110_2108_log_01.ldf'
	  , NORECOVERY  --LEAVE DB READY FOR T-LOG OR DIFF RESTORE
	  , NOUNLOAD
	  , STATS = 5
GO


:CONNECT PR
USE [master]
GO
RESTORE DATABASE [<TargetDBName, sysname, DBName>] 
   FROM DISK = N'<SourceDiffFile, sysname, \\rbackup.corpint.net\SQL_Prod\....dff>' 
   WITH FILE = 1
      , MOVE N'DW_LossMitMart_data_01' TO N'F:\MSSQL\REPORTING\DATA08\Data\DW_LossMitMart_20170110_2108_data_01.mdf'
	  , MOVE N'DW_LossMitMart_log_01' TO N'F:\MSSQL\REPORTING\TRAN05\Data\DW_LossMitMart_20170110_2108_log_01.ldf'
	  , RECOVERY  --BRING DB ONLINE
	  , NOUNLOAD
	  , STATS = 5
GO
