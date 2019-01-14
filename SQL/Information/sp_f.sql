USE [master]
GO

SET NOCOUNT ON

IF OBJECT_ID(N'dbo.sp_f','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_f
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_f.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about data and log files
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
CREATE PROCEDURE [dbo].[sp_f] (
       @file_type CHAR(1) = 'a', -- (a = all files, d = data files, l = log files)
       @database_name VARCHAR(128) = NULL,
       @include_mnts bit = 0)

AS

SET NOCOUNT ON

DECLARE @sql_string NVARCHAR(1000)

CREATE TABLE #log_statistics (
       [database_name] VARCHAR(200),
       [log_size_mb] NUMERIC(18,2),
       [log_used_pct] NUMERIC(18,2),
       [log_status] INT)

CREATE TABLE #file_list	(
       [database_name] VARCHAR(200),
       [filegroup_name] VARCHAR(200) NULL,
       [file_id] INT,
       [file_name] VARCHAR(200),
       [volume_mount_point] VARCHAR(200),
       [file_path] VARCHAR(200),
       [file_size] INT,
       [max_size] BIGINT,
       [growth_size] INT,
       [growth_type] INT,
       [file_type] INT,
       [drive] CHAR(1),
       [used_size] INT NULL,
       [disk_size] INT NULL,
       [free_space] INT NULL)

CREATE TABLE #file_statistics (
       [file_id] INT,
       [filegroup_id] INT,
       [total_extents] INT,
       [used_extents] INT,
       [database_name] VARCHAR(200),
       [file_path] VARCHAR(200))

INSERT #log_statistics EXEC('DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS')

IF @database_name IS NULL
   BEGIN
   DECLARE database_cursor CURSOR FOR SELECT [name] FROM master.sys.databases WITH (NOLOCK) WHERE state_desc = 'ONLINE' ORDER BY [name]
   OPEN database_cursor
   FETCH NEXT FROM database_cursor INTO @database_name
   WHILE @@FETCH_STATUS = 0
         BEGIN
         SET @sql_string = 'USE [' + @database_name +']'
         SET @sql_string = @sql_string + ' TRUNCATE TABLE #file_statistics'
         SET @sql_string = @sql_string + ' INSERT #file_statistics EXEC(''DBCC SHOWFILESTATS WITH NO_INFOMSGS'')'
         EXEC sp_executesql @sql_string
         SET @sql_string = 'INSERT #file_list'
         SET @sql_string = @sql_string + ' SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', fg.name, df.file_id, df.name, s.volume_mount_point, df.physical_name, df.size, df.max_size, df.growth, df.is_percent_growth, df.type, drive=UPPER(LEFT(df.physical_name,1)), fs.used_extents, CONVERT(INT,ROUND(s.total_bytes /1024.0/1024/1024,0)), CONVERT(INT,ROUND(s.available_bytes/1024.0/1024/1024,0))'
         SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.database_files df WITH (NOLOCK)'
         SET @sql_string = @sql_string + ' LEFT OUTER JOIN [' + @database_name + '].sys.filegroups fg WITH (NOLOCK) ON df.data_space_id = fg.data_space_id'
         SET @sql_string = @sql_string + ' LEFT OUTER JOIN #file_statistics fs WITH (NOLOCK) ON df.file_id = fs.file_id'
         SET @sql_string = @sql_string + ' CROSS APPLY sys.dm_os_volume_stats(DB_ID(''' + @database_name + '''), df.file_id) s'
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
   SET @sql_string = @sql_string + ' SELECT database_name=''' + DB_NAME(DB_ID(@database_name)) + ''', fg.name, df.file_id, df.name, s.volume_mount_point, df.physical_name, df.size, df.max_size, df.growth, df.is_percent_growth, df.type, drive=UPPER(LEFT(df.physical_name,1)), fs.used_extents, CONVERT(INT,ROUND(s.total_bytes /1024.0/1024/1024,0)), CONVERT(INT,ROUND(s.available_bytes/1024.0/1024/1024,0))'
   SET @sql_string = @sql_string + ' FROM [' + @database_name + '].sys.database_files df WITH (NOLOCK)'
   SET @sql_string = @sql_string + ' LEFT OUTER JOIN [' + @database_name + '].sys.filegroups fg WITH (NOLOCK) ON df.data_space_id = fg.data_space_id'
   SET @sql_string = @sql_string + ' LEFT OUTER JOIN #file_statistics fs WITH (NOLOCK) ON df.file_id = fs.file_id'
   SET @sql_string = @sql_string + ' CROSS APPLY sys.dm_os_volume_stats(DB_ID(''' + @database_name + '''), df.file_id) s'
   EXEC sp_executesql @sql_string
END

UPDATE fl
   SET used_size = ls.log_size_mb * ls.log_used_pct / 100 * 1024 / 64
  FROM #file_list fl
  JOIN #log_statistics ls ON fl.[database_name] = ls.[database_name]
 WHERE fl.file_type = 1

SET NOCOUNT OFF

IF @include_mnts = 1
   BEGIN
   SELECT CONVERT(CHAR(10),GETDATE(),101) [date]
        , LEFT(@@SERVERNAME,30) [instance_name]
        , LEFT([database_name],30) [database_name]
        , LEFT(file_name,40) [file_name]
        , LEFT(volume_mount_point,40) [mount_point]
        , LEFT(file_path,80) [file_path]
        , RIGHT('      ' + CONVERT(VARCHAR(6),file_size * 8 / 1024),6) [size]
        , RIGHT('      ' + CONVERT(VARCHAR(6),ISNULL(used_size,0) * 64 / 1024),6) [used]
        , RIGHT('      ' + CONVERT(VARCHAR(6),(file_size * 8 / 1024) - (ISNULL(used_size,0) * 64 / 1024)),6) [free]
        , RIGHT('     ' + CONVERT(VARCHAR(5),(ISNULL(used_size,0) * 64 / 1024 * 100) / (file_size * 8 / 1024 + 1)),5) + '%' [pct]
        , CASE WHEN growth_size = 0 THEN '' WHEN growth_type = 1 THEN RIGHT('       ' + CONVERT(VARCHAR(6),growth_size) + '%',7) ELSE RIGHT('      ' + CONVERT(VARCHAR(6),growth_size * 8 / 1024),6) END [growth]
        , CASE max_size WHEN 0 THEN '' WHEN -1 THEN '' WHEN 268435456 THEN '' ELSE RIGHT('       ' + CONVERT(VARCHAR(7),max_size * 8 / 1024),7) END [max]
        , RIGHT('       '+CONVERT(VARCHAR(7),disk_size),7) [drive_size]
        , RIGHT('       '+CONVERT(VARCHAR(7),free_space),7) [drive_free]
     FROM #file_list
    WHERE file_type != CASE @file_type WHEN 'd' THEN 1 WHEN 'l' THEN 0 ELSE 5 END
    ORDER BY [database_name], file_type, [filegroup_name], [file_id] 
END
ELSE
BEGIN
   SELECT date=CONVERT(CHAR(10),GETDATE(),101)
        , LEFT(@@SERVERNAME,30) [instance_name]
        , LEFT(database_name,30) [database_name]
        , LEFT(file_name,40) [file_name]
        , LEFT(file_path,80) [file_path]
        , RIGHT('      ' + CONVERT(VARCHAR(6),file_size * 8 / 1024),6) [size]
        , RIGHT('      ' + CONVERT(VARCHAR(6),ISNULL(used_size,0) * 64 / 1024),6) [used]
        , RIGHT('      ' + CONVERT(VARCHAR(6),(file_size * 8 / 1024) - (ISNULL(used_size,0) * 64 / 1024)),6) [free]
        , RIGHT('     ' + CONVERT(VARCHAR(5),(ISNULL(used_size,0) * 64 / 1024 * 100) / (file_size * 8 / 1024 + 1)),5) + '%' [pct]
        , CASE WHEN growth_size = 0 THEN '' WHEN growth_type = 1 THEN RIGHT('       ' + CONVERT(VARCHAR(6),growth_size) + '%',7) ELSE RIGHT('      ' + CONVERT(VARCHAR(6),growth_size * 8 / 1024),6) END [growth]
        , CASE max_size WHEN 0 THEN '' WHEN -1 THEN '' WHEN 268435456 THEN '' ELSE RIGHT('       ' + CONVERT(VARCHAR(7),max_size * 8 / 1024),7) END [max]
        , RIGHT('       '+CONVERT(VARCHAR(7),disk_size),7) [drive_size]
        , RIGHT('       '+CONVERT(VARCHAR(7),free_space),7) [drive_free]
     FROM #file_list
    WHERE file_type != CASE @file_type WHEN 'd' THEN 1 WHEN 'l' THEN 0 ELSE 5 END
    ORDER BY [database_name], file_type, [filegroup_name], [file_id]
END

GO
