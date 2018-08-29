/*
-------------------------------------------------------------------------------------------------
        NAME: INDEX_MaintenanceAnalysis_LOCAL.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: USE THESE QUERIES TO DO ANALYSIS ON PREVIOUS INDEX MAINTENANCE METADATA.  RUN THESE
              QUERIES ON THE SQL INSTANCE WHERE THE INDEX REBUILD WAS EXECUTED.

              RCHPWCCRPSQL01J\ABS
              RCHPWVCRPSQL02\TFS
              RCHPWCCRPSQL50A\REPORTING01
              RCHPWCCRPSQL01D\INFRASTRUCTURE
              RCHPWVCRPSQL10\TAXENGINE
              RCHPWCCRPSQL01A\SERVICING
              RCHPWCCRPSQL01B\ORIGINATIONS
              RCHPWCCRPSQL01G\SHAREPOINT
              RCHPWCCRPSQL01E\THIRDPARTY
              RCHPWCCRPSQL01H\ARCHIVE
              RCHPWCCRPSQL01C\WEB
              RCHPWCCRPSQL50B\DATAWAREHOUSE
              RCHPWVCRPSQL01\CONTROLM
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
:CONNECT RCHPWCCRPSQL01A\SERVICING
USE DBA_BACKUP
GO

SET NOCOUNT ON

DECLARE @date_last_run smalldatetime
      , @date_previous_run smalldatetime
      , @dDate date

-------------------------------------------------------------------------------------------------
--[ DATE OF LAST INDEX FRAGMENTATION STATISTICS CAPTURE                                         ]
SELECT @date_last_run = CAST(MAX(load_date_start) AS DATE) FROM [dbo].[fragmentation_statistics]
SELECT @date_previous_run = CAST(MAX(load_date_start) AS DATE) FROM [dbo].[fragmentation_statistics] WHERE load_date_start < CAST(@date_last_run AS DATE)
SELECT @dDate = GETDATE()
SELECT DATENAME(weekday, @date_last_run) +', '+ CONVERT(VARCHAR(40), @date_last_run, 100) [load_date_last_collection]
     , DATENAME(weekday, @date_previous_run) +', '+ CONVERT(VARCHAR(40), @date_previous_run, 100) [load_date_previous_collection]


---------------------------------------------------------------------------------------------------
----[ USE THE ENTIRE DATA SET AS THE INPUT IN AN EXCEL SPREADSHEET FOR A PIVOT TABLE              ]
--SELECT *
--  FROM [dbo].[fragmentation_statistics]
-- WHERE 1 = 1


-----------------------------------------------------------------------------------------------------
----[ DISPLAY INDEXES WAITING FOR REBUILD                                                           ]
--SELECT *
--  FROM [dbo].[fragmentation_statistics]
-- WHERE 1 = 1
--   AND active = 1


-----------------------------------------------------------------------------------------------------
----[ DISPLAY INDEXES REBUILT TODAY                                                                 ]
--SELECT [load_date_start]
--     , [database_name]
--     , [schema_name]
--     , [table_name]
--     , [index_name]
--     , [page_count] * 8 / 1024 [index_size_MB]
--     , [avg_fragmentation_in_percent]
--     , [maintenance_start]
--     , [maintenance_end]
--     , [error_message]
--  FROM DBA_Backup.dbo.fragmentation_statistics 
-- WHERE maintenance_start >= @dDate
-- ORDER BY maintenance_start



---------------------------------------------------------------------------------------------------
----[ DURATION OF INDEX REBUILD PER DATABASE DURING THE LAST RUN                                  ]
--SELECT [database_name]
--     , COUNT(*) [index_count]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss, MIN(maintenance_start) ,  MAX(maintenance_end))) [duration]
--  FROM [dbo].[fragmentation_statistics]
-- WHERE 1 = 1
--   AND load_date_start >= @date_last_run
-- GROUP BY [database_name]


---------------------------------------------------------------------------------------------------
----[ IDENTIFY PERSISTENT LONG RUNNING INDEX REBUILDS                                             ]
--SELECT load_date_start
--     , [database_name]
--     , [table_name]
--     , [index_name]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss,maintenance_start, maintenance_end)) [duration] 
--  FROM [dbo].[fragmentation_statistics] 
-- WHERE 1 = 1
--   AND DATEDIFF(ss,maintenance_start, maintenance_end) > 600  --THIS VALUE IS IN SECONDS
-- ORDER BY [database_name], [table_name], [index_name]

---------------------------------------------------------------------------------------------------
----[ DURATION OF INDEX REBUILD PER INDEX                                                         ]
--SELECT load_date_start
--     , [database_name]
--     , [schema_name]
--     , [table_name]
--     , index_name
--     , CAST(avg_fragmentation_in_percent AS numeric(6,3)) [fragment_%]
--     , CAST(maintenance_start AS smalldatetime) [maintenance_start]
--     , CAST(maintenance_end AS smalldatetime) [maintenance_end]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss,maintenance_start, maintenance_end)) [duration]
--  FROM [dbo].[fragmentation_statistics]
-- WHERE 1 = 1
--   AND load_date_start >= @date_previous_run
-- ORDER BY DATEDIFF(ss,maintenance_start, maintenance_end) DESC






 