/*
-------------------------------------------------------------------------------------------------
        NAME: INDEX_MaintenanceAnalysis_ENVIRONMENT.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: USE THESE QUERIES TO DO ANALYSIS ON PREVIOUS INDEX MAINTENANCE METADATA.  RUN THESE
              QUERIES ON RCHPWVMGMSQL01\MANAGEMENT01.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
:CONNECT RCHPWVMGMSQL01\MANAGEMENT01
USE [DBA]
GO
---------------------------------------------------------------------------------------------------
----[ LAST INDEX FRAGMENTATION CAPTURE RUN                                                        ]
--WITH LD
--  AS (SELECT CAST(MAX(load_date_start) AS DATE) [load_date_start]
--           , [instance_name]
--        FROM [dbo].[IndexMaintenance]
--       GROUP BY [instance_name])

--SELECT I.[load_date_start]
--     , I.[instance_name]
--     , I.[database_name]
--     , N'['+ I.[schema_name] +'].['+ I.[table_name] +']' [table_name]
--     , I.[index_name]
--     , I.[page_count] * 8 / 1024 [index_size_MB]
--     , I.[avg_fragmentation_in_percent]
--     , I.[maintenance_start]
--     , I.[maintenance_end]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss, I.[maintenance_start], I.[maintenance_end])) [duration] 
--     , I.[error_message]
--  FROM dbo.IndexMaintenance I
-- INNER JOIN LD ON I.load_Date_start >= LD.load_date_start
--   AND I.instance_name = LD.instance_name
-- WHERE 1 = 1

---------------------------------------------------------------------------------------------------
----[ LAST INDEX REBUILD RUN                                                                      ]
--WITH LD
--  AS (SELECT CAST(MAX(maintenance_start) AS DATE) [maintenance_start]
--           , [instance_name]
--        FROM [dbo].[IndexMaintenance]
--       GROUP BY [instance_name])

--SELECT I.[load_date_start]
--     , I.[instance_name]
--     , I.[database_name]
--     , N'['+ I.[schema_name] +'].['+ I.[table_name] +']' [table_name]
--     , I.[index_name]
--     , I.[page_count] * 8 / 1024 [index_size_MB]
--     , I.[avg_fragmentation_in_percent]
--     , I.[maintenance_start]
--     , I.[maintenance_end]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss, I.[maintenance_start], I.[maintenance_end])) [duration] 
--     , I.[error_message]
--  FROM dbo.IndexMaintenance I
-- INNER JOIN LD ON I.maintenance_start >= LD.maintenance_start
--   AND I.instance_name = LD.instance_name
-- WHERE 1 = 1

---------------------------------------------------------------------------------------------------
----[ INDEXES REBUILT TODAY                                                                       ]
--SELECT I.[load_date_start]
--     , I.[instance_name]
--     , I.[database_name]
--     , N'['+ I.[schema_name] +'].['+ I.[table_name] +']' [table_name]
--     , I.[index_name]
--     , I.[page_count] * 8 / 1024 [index_size_MB]
--     , I.[avg_fragmentation_in_percent]
--     , I.[maintenance_start]
--     , I.[maintenance_end]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss, I.[maintenance_start], I.[maintenance_end])) [duration] 
--     , I.[error_message]
--  FROM dbo.IndexMaintenance I
-- WHERE 1 = 1
--   AND I.[maintenance_start] >= CAST(GETDATE() AS DATE)

---------------------------------------------------------------------------------------------------
----[ INDEXES REBUILT IN THE PAST 7 DAYS                                                          ]
--SELECT I.[load_date_start]
--     , I.[instance_name]
--     , I.[database_name]
--     , N'['+ I.[schema_name] +'].['+ I.[table_name] +']' [table_name]
--     , I.[index_name]
--     , I.[page_count] * 8 / 1024 [index_size_MB]
--     , I.[avg_fragmentation_in_percent]
--     , I.[maintenance_start]
--     , I.[maintenance_end]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss, I.[maintenance_start], I.[maintenance_end])) [duration] 
--     , I.[error_message]
--  FROM dbo.IndexMaintenance I
-- WHERE 1 = 1
--   AND I.[maintenance_start] >= CAST(GETDATE() - 7 AS DATE)
-- ORDER BY I.[instance_name], I.[database_name], I.[object_id], I.[index_id], I.[load_date_start]


---------------------------------------------------------------------------------------------------
----[ INDEXES REBUILT FAILURES IN THE PAST 7 DAYS                                                 ]
--SELECT I.[load_date_start]
--     , I.[instance_name]
--     , I.[database_name]
--     , N'['+ I.[schema_name] +'].['+ I.[table_name] +']' [table_name]
--     , I.[index_name]
--     , I.[page_count] * 8 / 1024 [index_size_MB]
--     , I.[avg_fragmentation_in_percent]
--     , I.[maintenance_start]
--     , I.[maintenance_end]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss, I.[maintenance_start], I.[maintenance_end])) [duration] 
--     , I.[error_message]
--  FROM dbo.IndexMaintenance I
-- WHERE 1 = 1
--   AND I.[maintenance_start] >= CAST(GETDATE() - 7 AS DATE)
--   AND active = 2
-- ORDER BY I.[instance_name], I.[database_name], I.[object_id], I.[index_id], I.[load_date_start]


---------------------------------------------------------------------------------------------------
----[ DURATION OF INDEX REBUILD PER DATABASE IN THE PAST 7 DAYS                                   ]
--SELECT CAST(load_date_start AS DATE) [load_date_start]
--     , I.[instance_name]
--     , I.[database_name]
--     , COUNT(*) [index_count]
--     , SUM(I.[page_count] * 8 / 1024) [index_size_MB]
--     , msdb.[dbo].[fn_CreateTimeString](DATEDIFF(ss, MIN(I.[maintenance_start]), max(I.[maintenance_end]))) [duration] 
--  FROM dbo.IndexMaintenance I
-- WHERE 1 = 1
--   AND I.[maintenance_start] >= CAST(GETDATE() - 7 AS DATE)
 --GROUP BY CAST(load_date_start AS DATE), I.[instance_name], I.[database_name]
 --ORDER BY I.[instance_name], I.[database_name], CAST(load_date_start AS DATE)



 