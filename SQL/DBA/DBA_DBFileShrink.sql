/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_DBFileShrink.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: This script is a template for shrinking data/log files.  Use CTRL+SHIFT+M to replace
              parameters
-------------------------------------------------------------------------------------------------
     HISTORY:
   TR/PROJ#    DATE        MODIFIED      DESCRIPTION
               10.28.2013  SYOUNG        Added reference to sys.master_files in order to find the
                                         logical name.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
:CONNECT <SQLInstance, sysname, SQLInstance>
USE <DBName, sysname, DBName>
GO

SELECT * FROM master.sys.master_files WHERE [name] LIKE '%DatabaseName%'

DBCC SHRINKFILE('<FileLogicName, sysname, FileLogicName>', 90000)
GO
DBCC SHRINKFILE('<FileLogicName, sysname, FileLogicName>', 85000)
GO
DBCC SHRINKFILE('<FileLogicName, sysname, FileLogicName>', 80000)
GO
DBCC SHRINKFILE('<FileLogicName, sysname, FileLogicName>', 75000)
GO
DBCC SHRINKFILE('<FileLogicName, sysname, FileLogicName>', 70000)
GO
DBCC SHRINKFILE('<FileLogicName, sysname, FileLogicName>', 65000)
GO
DBCC SHRINKFILE('<FileLogicName, sysname, FileLogicName>', 60000)
GO
