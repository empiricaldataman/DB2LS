SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
-------------------------------------------------------------------------------------------------
        NAME: IndexMaintenance_CollectFragmentation.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Collects index fragmentation metadata.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- DATE        MODIFIED      DESCRIPTION   
-- 10.21.2017  SYOUNG        First version.
-- 12.21.2017  SYOUNG        Format T-SQL code and added large_db column.
-- 02.16.2018  SYOUNG        Add error message column to dbo.fragmentation_statistics
-- 02.22.2018  SYOUNG        Added @LoadDateStart parameter and load_date_start & load_date_end
                             columns to dbo.fragmentation_statistics
-- 02.28.2018  SYOUNG        Added @pagecount and @daytocollect parameters
-- 03.01.2018  SYOUNG        Added @timetostopcollecting functionality and "IF NOT EXISTS" to 
                             prevent duplicate records insertion in subsequent runs.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[pr_IndexMaintenance_CollectFragmentation] 
      @DatabaseName sysname

AS

BEGIN

DECLARE @fragmentationpercent VARCHAR(6)
      , @sql NVARCHAR(4000)		 
      , @largedbsize VARCHAR(6)
      , @daytocollect VARCHAR(60)
      , @pagecount VARCHAR(6)
      , @loaddatestart DATETIME
      , @timetostopcollecting VARCHAR(10)

SELECT @loaddatestart = GETDATE()
--Create the fragmentation_statistics in DBA_Backup if does not exist
SELECT @sql = N'IF OBJECT_ID(N''DBA_BACKUP.dbo.fragmentation_statistics'',''U'') IS NULL AND DB_ID(''DBA_BACKUP'') IS NOT NULL
   BEGIN
   CREATE TABLE [DBA_BACKUP].[dbo].[fragmentation_statistics](
          [load_date_start] smalldatetime,
          [load_date_end] smalldatetime,
          [database_name] sysname NOT NULL,
          [schema_name] [sysname] NOT NULL,
          [object_id] int,
          [table_name] [nvarchar](128) NULL,
          [index_id] int,
          [index_name] [sysname] NULL,
          [partition_number] int,
          [page_count] bigint,
          [avg_fragmentation_in_percent] [float] NULL,
          [avg_page_space_used_in_percent] [float] NULL,
          [maintenance_start] smalldatetime NULL,
          [maintenance_end] smalldatetime NULL,
          [active] tinyint NULL DEFAULT(1),
          [large_db] tinyint NOT NULL,
          [error_message] varchar(256) NULL)
END'
EXEC(@sql)

--Grab values from the msdb..IndexMaintenanceConfig table
SELECT @daytocollect = [value] FROM [msdb].[dbo].[IndexMaintenanceConfig] WHERE [name] = 'DayToCollect'
SELECT @fragmentationpercent = [value] FROM [msdb].[dbo].[IndexMaintenanceConfig] WHERE [name] = 'FragmentationPercentage'
SELECT @largedbsize = [value] FROM [msdb].[dbo].[IndexMaintenanceConfig] WHERE [name] = 'LargeDBSize'
SELECT @pagecount = [value] FROM [msdb].[dbo].[IndexMaintenanceConfig] WHERE [name] = 'PageCount'
SELECT @timetostopcollecting = [value] FROM [msdb].[dbo].[IndexMaintenanceConfig] WHERE [name] = 'TimeToStopCollecting'

IF DATEDIFF(n, GETDATE(), CAST(CAST(GETDATE() AS DATE) AS VARCHAR(20)) +' '+ @timetostopcollecting) <= 0
   RETURN;

IF (CHARINDEX(DATENAME(weekday, GETDATE()), @daytocollect) > 0)
   BEGIN
   SELECT @sql = N'USE [' + @DatabaseName + '];'
   SELECT 'Collecting for database: ' + @DatabaseName

   SET @sql = @sql + 'INSERT INTO DBA_BACKUP.dbo.fragmentation_statistics (
          load_date_start
        , load_date_end
        , [database_name]
        , schema_name
        , [object_id]
        , table_name
        , index_id
        , index_name
        , partition_number
        , page_count
        , avg_fragmentation_in_percent
        , avg_page_space_used_in_percent
        , active
        , large_db)
   SELECT '''+ CONVERT(varchar(30), @loaddatestart, 121) +''',
          GETDATE(),
          '''+ @DatabaseName +''' [database_name],
          dt.[schema],
          dt.[object_id],
          OBJECT_NAME(dt.[object_id]) [table_name], 
          si.index_id [index_id],
          si.[name] [index_name],
          dt.partition_number,
          dt.page_count,
          dt.avg_fragmentation_in_percent,
          dt.avg_page_space_used_in_percent,
          1 [active],
          CASE WHEN (SELECT SUM(size * 8 / 1024) FROM [dbo].[sysfiles] WHERE groupid != 0) > '+ @largedbsize +' THEN 1 ELSE 0 END [large_db] 
     FROM (SELECT S.[name] [schema],
                  A.[object_id],
                  A.index_id,
                  A.partition_number,
                  A.page_count,
                  A.avg_fragmentation_in_percent,
                  A.avg_page_space_used_in_percent
             FROM sys.dm_db_index_physical_stats(DB_ID(''' + @DatabaseName + '''), NULL, NULL, NULL, ''SAMPLED'') A
            INNER JOIN sys.objects O ON A.object_id = O.object_id
            INNER JOIN sys.schemas S ON O.schema_id = S.schema_id
            WHERE index_id != 0
              AND avg_fragmentation_in_percent >= '+ @fragmentationpercent +'
              AND A.page_count >= '+ @pagecount +') AS dt
    INNER JOIN sys.indexes si ON si.[object_id] = dt.[object_id]
      AND si.index_id = dt.index_id
      AND NOT EXISTS (SELECT object_id
                        FROM dba_backup.dbo.fragmentation_statistics S
                       WHERE S.[database_name] = '''+ @DatabaseName +'''
                         AND S.[object_id] = dt.object_id
                         AND S.[index_id] = si.index_id
                         AND S.active = 1)'
   EXEC(@sql)
END
END
GO