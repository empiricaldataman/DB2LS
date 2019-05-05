IF OBJECT_ID(N'dbo.sp_d','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_d
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_d.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about databases
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    08.16.2018  SYoung        Re-format T-SQL code
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_d] (
       @database_name VARCHAR(128) = NULL )
  
AS  
  
SET NOCOUNT ON  
  
DECLARE @sql_string NVARCHAR(1000)  

CREATE TABLE #file_list (  
       [database_owner] VARCHAR(200)
     , [database_name] VARCHAR(200)
     , [filegroup_name] VARCHAR(200) NULL
     , [file_id] INT
     , [file_name] VARCHAR(200)
     , [file_path] VARCHAR(200)
     , [file_size] INT
     , [max_size] BIGINT
     , [growth_size] INT
     , [growth_type] INT
     , [file_type] INT
     , [drive] CHAR(1)
     , [used_size] INT NULL
     , [free_space] INT NULL
     , [database_level] TINYINT
     , [page_verify] VARCHAR(20)
     , [database_option] VARCHAR(500))  
  
CREATE TABLE #file_statistics (  
       [file_id] INT
     , [filegroup_id] INT
     , [total_extents] INT
     , [used_extents] INT
     , [database_name] VARCHAR(200)
     , [file_path] VARCHAR(200))  
  
IF @database_name IS NULL  
   BEGIN  
   DECLARE database_cursor CURSOR FOR SELECT [name] FROM [master].sys.databases WITH (NOLOCK) WHERE state_desc = 'ONLINE' ORDER BY [name]
   OPEN database_cursor  
   FETCH NEXT FROM database_cursor INTO @database_name  
   WHILE @@FETCH_STATUS = 0  
         BEGIN  
         SET @sql_string = 'USE [' + @database_name +']'  
         SET @sql_string = @sql_string + ' TRUNCATE TABLE #file_statistics'  
         SET @sql_string = @sql_string + ' INSERT #file_statistics EXEC(''DBCC SHOWFILESTATS WITH NO_INFOMSGS'')'  
         EXEC sp_executesql @sql_string  
         SET @sql_string = 'INSERT #file_list'  
         SET @sql_string = @sql_string + ' SELECT database_owner=SUSER_SNAME(owner_sid), database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', fg.name, df.file_id, df.name, df.physical_name, df.size, df.max_size, df.growth, df.is_percent_growth, df.type, drive=UPPER(LEFT(df.physical_name,1)), fs.used_extents, NULL, d.compatibility_level, d.page_verify_option_desc, '''''  
         SET @sql_string = @sql_string + ' FROM master.sys.databases d WITH (NOLOCK),'  
         SET @sql_string = @sql_string + ' [' + @database_name + '].sys.database_files df WITH (NOLOCK)'  
         SET @sql_string = @sql_string + ' LEFT OUTER JOIN [' + @database_name + '].sys.filegroups fg WITH (NOLOCK) ON df.data_space_id = fg.data_space_id'  
         SET @sql_string = @sql_string + ' LEFT OUTER JOIN #file_statistics fs WITH (NOLOCK) ON df.file_id = fs.file_id'  
         SET @sql_string = @sql_string + ' WHERE d.name = ''' + @database_name + ''''  
         EXEC sp_executesql @sql_string  
         FETCH NEXT FROM database_cursor INTO @database_name  
   END  
   CLOSE database_cursor  
   DEALLOCATE database_cursor  
END  
ELSE  
   BEGIN  
   SET @sql_string = 'USE [' + @database_name +']'  
   SET @sql_string = @sql_string + ' TRUNCATE TABLE #file_statistics'  
   SET @sql_string = @sql_string + ' INSERT #file_statistics EXEC(''DBCC SHOWFILESTATS WITH NO_INFOMSGS'')'  
   EXEC sp_executesql @sql_string  
   SET @sql_string = 'INSERT #file_list'  
   SET @sql_string = @sql_string + ' SELECT database_owner=SUSER_SNAME(owner_sid), database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', fg.name, df.file_id, df.name, df.physical_name, df.size, df.max_size, df.growth, df.is_percent_growth, df.type, drive=UPPER(LEFT(df.physical_name,1)), fs.used_extents, NULL, d.compatibility_level, d.page_verify_option_desc, '''''  
   SET @sql_string = @sql_string + ' FROM master.sys.databases d WITH (NOLOCK),'  
   SET @sql_string = @sql_string + ' [' + @database_name + '].sys.database_files df WITH (NOLOCK)'  
   SET @sql_string = @sql_string + ' LEFT OUTER JOIN [' + @database_name + '].sys.filegroups fg WITH (NOLOCK) ON df.data_space_id = fg.data_space_id'  
   SET @sql_string = @sql_string + ' LEFT OUTER JOIN #file_statistics fs WITH (NOLOCK) ON df.file_id = fs.file_id'  
   SET @sql_string = @sql_string + ' WHERE d.name = ''' + @database_name + ''''  
   EXEC sp_executesql @sql_string  
END  
  
--UPDATE fl  
--SET used_size = ls.log_size_mb * ls.log_used_pct / 100 * 1024 / 64  
--FROM #file_list fl  
--JOIN #log_statistics ls ON fl.database_name = ls.database_name  --WHERE fl.file_type = 1  
  
UPDATE #file_list SET database_option = database_option + 'AnsiNullDefault,'  WHERE DATABASEPROPERTYEX(database_name,'IsAnsiNullDefault') = 1  
UPDATE #file_list SET database_option = database_option + 'AnsiNulls,'   WHERE DATABASEPROPERTYEX(database_name,'IsAnsiNullsEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'AnsiPadding,'  WHERE DATABASEPROPERTYEX(database_name,'IsAnsiPaddingEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'AnsiWarnings,'  WHERE DATABASEPROPERTYEX(database_name,'IsAnsiWarningsEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'ArithmeticAbort,'  WHERE DATABASEPROPERTYEX(database_name,'IsArithmeticAbortEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'AutoClose,'   WHERE DATABASEPROPERTYEX(database_name,'IsAutoClose') = 1  
UPDATE #file_list SET database_option = database_option + 'AutoCreateStats,'  WHERE DATABASEPROPERTYEX(database_name,'IsAutoCreateStatistics') = 1  
UPDATE #file_list SET database_option = database_option + 'AutoShrink,'  WHERE DATABASEPROPERTYEX(database_name,'IsAutoShrink') = 1  
UPDATE #file_list SET database_option = database_option + 'AutoUpdateStats,'  WHERE DATABASEPROPERTYEX(database_name,'IsAutoUpdateStatistics') = 1  
UPDATE #file_list SET database_option = database_option + 'CloseCursorsOnCommit,' WHERE DATABASEPROPERTYEX(database_name,'IsCloseCursorsOnCommitEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'FullText,'   WHERE DATABASEPROPERTYEX(database_name,'IsFullTextEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'InStandby,'   WHERE DATABASEPROPERTYEX(database_name,'IsInStandby') = 1  
UPDATE #file_list SET database_option = database_option + 'LocalCursorsDefault,' WHERE DATABASEPROPERTYEX(database_name,'IsLocalCursorsDefault') = 1  
UPDATE #file_list SET database_option = database_option + 'MergePublished,'  WHERE DATABASEPROPERTYEX(database_name,'IsMergePublished') = 1  
UPDATE #file_list SET database_option = database_option + 'NullConcat,'  WHERE DATABASEPROPERTYEX(database_name,'IsNullConcat') = 1  
UPDATE #file_list SET database_option = database_option + 'NumericRoundAbort,'  WHERE DATABASEPROPERTYEX(database_name,'IsNumericRoundAbortEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'ParameterizationForced,' WHERE DATABASEPROPERTYEX(database_name,'IsParameterizationForced') = 1  
UPDATE #file_list SET database_option = database_option + 'Published,'   WHERE DATABASEPROPERTYEX(database_name,'IsPublished') = 1  
UPDATE #file_list SET database_option = database_option + 'QuotedIdentifiers,'  WHERE DATABASEPROPERTYEX(database_name,'IsQuotedIdentifiersEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'RecursiveTriggers,'  WHERE DATABASEPROPERTYEX(database_name,'IsRecursiveTriggersEnabled') = 1  
UPDATE #file_list SET database_option = database_option + 'Subscribed,'  WHERE DATABASEPROPERTYEX(database_name,'IsSubscribed') = 1  
UPDATE #file_list SET database_option = database_option + 'SyncWithBackup,'  WHERE DATABASEPROPERTYEX(database_name,'IsSyncWithBackup') = 1  
UPDATE #file_list SET database_option = database_option + 'TornPageDetection,'  WHERE DATABASEPROPERTYEX(database_name,'IsTornPageDetectionEnabled') = 1  
  
UPDATE f SET database_option = database_option + 'ReadCommittedSnapshot,' FROM #file_list f JOIN master.sys.databases d ON f.database_name = d.name WHERE is_read_committed_snapshot_on = 1  
UPDATE f SET database_option = database_option + 'SnapshotIsolation,' FROM #file_list f JOIN master.sys.databases d ON f.database_name = d.name WHERE snapshot_isolation_state = 1  
  
SET NOCOUNT OFF  
  
SELECT CONVERT(CHAR(10),GETDATE(),101) [date]
     , LEFT(@@SERVERNAME,30) [instance_name]
     , LEFT(fl_data.database_owner,15) [database_owner]
     , LEFT(fl_data.database_name,40) [database_name]
     , RIGHT('       ' + CONVERT(VARCHAR(7),SUM(fl_data.file_size * 8 / 1024)),7) [d_size]
     , RIGHT('       ' + CONVERT(VARCHAR(7),SUM(ISNULL(fl_data.used_size,0) * 64 / 1024)),7) [d_used]
     , RIGHT('       ' + CONVERT(VARCHAR(7),SUM(fl_data.file_size * 8 / 1024) - SUM((ISNULL(fl_data.used_size,0) * 64 / 1024))),7) [d_free]
     , RIGHT('     ' + CONVERT(VARCHAR(5),SUM(ISNULL(fl_data.used_size,0) * 64 / 1024) * 100 / SUM(fl_data.file_size * 8 / 1024 + 1)),5) + '%' [d_pct]
     , CASE DATABASEPROPERTYEX(fl_data.database_name,'Recovery') WHEN 'FULL' THEN ' FULL' WHEN 'BULK_LOGGED' THEN ' BULK'  WHEN 'SIMPLE' THEN ' SIMPLE' ELSE '' END [recovery]
     , UPPER(CONVERT(CHAR(10),DATABASEPROPERTYEX(fl_data.database_name,'Status'))) [status]
     , CASE DATABASEPROPERTYEX(fl_data.database_name,'Updateability') WHEN 'READ_ONLY' THEN 'R/O' WHEN 'READ_WRITE' THEN 'R/W' ELSE '' END [mode]
     , CASE DATABASEPROPERTYEX(fl_data.database_name,'UserAccess') WHEN 'SINGLE_USER' THEN 'S/U' WHEN 'RESTRICTED_USER' THEN 'R/U'  WHEN 'MULTI_USER' THEN 'M/U' ELSE '' END [user]
     , CASE fl_data.page_verify WHEN 'TORN_PAGE_DETECTION' THEN 'TORN' WHEN 'CHECKSUM' THEN 'CSUM' ELSE '' END [page]
     , fl_data.database_level [lvl]
     , LEFT(fl_data.database_option,80) [database_option]
  FROM #file_list fl_data
 WHERE fl_data.file_type != 1
 GROUP BY fl_data.database_owner, fl_data.database_name, fl_data.page_verify, fl_data.database_level, LEFT(fl_data.database_option,80)  
 ORDER BY LEFT(fl_data.database_name,40)  
GO
