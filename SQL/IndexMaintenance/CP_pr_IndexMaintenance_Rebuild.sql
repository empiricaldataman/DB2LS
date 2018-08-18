SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
-------------------------------------------------------------------------------------------------
        NAME: pr_IndexMaintenance_Rebuild.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Performs index rebuild on previoiusly collected index metadata.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- DATE        MODIFIED      DESCRIPTION   
-- 10.21.2017  SYOUNG        First version.
-- 12.21.2017  SYOUNG        Format T-SQL code and added large_db column.
-- 02.16.2018  SYOUNG        Add error message column to dbo.fragmentation_statistics
-- 02.21.2018  SYOUNG        Add condition based on SQL edition.
-- 02.27.2018  SYOUNG        Add break if past @timetostoprebuilding
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[pr_IndexMaintenance_Rebuild] 
      @DatabaseName sysname,
      @BuildOnline BIT = 1

AS

BEGIN	
DECLARE @o_id INT
      , @i_id INT
      , @p_num BIGINT
      , @pg_count BIGINT
      , @s_name NVARCHAR(200)
      , @o_name NVARCHAR(200)
      , @i_name NVARCHAR(200)
      , @p_count BIGINT
      , @sql NVARCHAR(1000)
      , @page_locks BIT
      , @fragmentation VARCHAR(20)
      , @maintenance_start smalldatetime
      , @edition VARCHAR(30)
      , @daytorebuild VARCHAR(60)
      , @timetostoprebuilding VARCHAR(6)

--[ FORCE NOT TO USE THE ONLINE OPTION ON STANDARD EDITION OF SQL SERVER ]
SET @edition = CAST(SERVERPROPERTY('Edition') AS VARCHAR(30))
IF @edition LIKE '%Standard%' 
   SET @BuildOnline = 0

SELECT @daytorebuild = [value] FROM [msdb].[dbo].[IndexMaintenanceConfig] WHERE [name] = 'DayToRebuild'
SELECT @timetostoprebuilding = [value] FROM [msdb].[dbo].[IndexMaintenanceConfig] WHERE [name] = 'TimeToStopRebuilding'

IF (CHARINDEX(DATENAME(weekday, GETDATE()), @daytorebuild) > 0)
   BEGIN   
   DECLARE partition_cursor CURSOR FAST_FORWARD
       FOR SELECT [object_id]
         , [schema_name]
         , table_name
         , index_id
         , index_name
         , partition_number
         , page_count
         , avg_fragmentation_in_percent
      FROM DBA_BACKUP.dbo.fragmentation_statistics
     WHERE [database_name] = @DatabaseName
       AND [active] = 1
       AND large_db <> 9
     ORDER BY load_date_start, [database_name], [schema_name], table_name, index_id
      	
      OPEN partition_cursor
     FETCH NEXT FROM partition_cursor INTO @o_id, @s_name, @o_name, @i_id, @i_name, @p_num, @pg_count, @fragmentation
      	
   WHILE @@FETCH_STATUS = 0
         BEGIN
         IF DATEDIFF(n, GETDATE(), CAST(CAST(GETDATE() AS DATE) AS VARCHAR(20)) +' '+ @timetostoprebuilding) <= 0
            BREAK
   
         SET @sql = N'USE [' + @DatabaseName + ']; ALTER INDEX [' + @i_name + '] ON [' + @s_name + '].[' + @o_name + '] '
          IF @BuildOnline = 0
             SET @sql = @sql + 'REBUILD WITH (MAXDOP=8)'
         ELSE
             SET @sql = @sql + 'REBUILD WITH (MAXDOP=8, ONLINE=ON)'

         SELECT @maintenance_start = GETDATE()
                 
         BEGIN TRY 
               EXEC (@sql)
   
               PRINT ' Index ['+ @i_name +'] on table ['+ @s_name +'].['+ @o_name +'] was defragmented ('+ @fragmentation +') - '+ CAST(GETDATE() AS VARCHAR) + CHAR(10)
               UPDATE DBA_BACKUP.dbo.fragmentation_statistics
                  SET maintenance_start = @maintenance_start, maintenance_end = GETDATE(), Active = 0 --[ RECORD AS SUCCESS ] 
                WHERE [database_name] = @DatabaseName
                  AND [object_id] = @o_id
                  AND index_id = @i_id
                  AND Active = 1
         END TRY
         BEGIN CATCH
               SELECT ERROR_NUMBER() [ErrorNumber]
                    , ERROR_SEVERITY() [ErrorSeverity]
                    , ERROR_STATE() [ErrorState]  
                    , ERROR_PROCEDURE() [ErrorProcedure]  
                    , ERROR_LINE() [ErrorLine]  
                    , ERROR_MESSAGE() [ErrorMessage];
   
               PRINT ' Index ['+ @i_name +'] on table ['+ @s_name +'].['+ @o_name +'] returned error ('+ CAST(ERROR_MESSAGE() AS VARCHAR(256)) +') - '+ CAST(GETDATE() AS VARCHAR) + CHAR(10)
               UPDATE DBA_BACKUP.dbo.fragmentation_statistics
                  SET maintenance_start = @maintenance_start, maintenance_end = GETDATE(), error_message = CAST(ERROR_MESSAGE() AS VARCHAR(256)), Active = 2 --[ RECORD AS FAILURE ]
                WHERE [database_name] = @DatabaseName
                  AND [object_id] = @o_id
                  AND index_id = @i_id
                  AND Active = 1
         END CATCH
      
         FETCH NEXT FROM partition_cursor INTO @o_id, @s_name, @o_name, @i_id, @i_name, @p_num, @pg_count, @fragmentation
   END

   CLOSE partition_cursor
   DEALLOCATE partition_cursor
END
END
GO
