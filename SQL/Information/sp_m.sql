IF OBJECT_ID(N'dbo.sp_m','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_m
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_m.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about drives & mount points
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
CREATE PROCEDURE [dbo].[sp_m]

AS

SET NOCOUNT ON

SELECT DISTINCT LEFT(@@SERVERNAME,30) [instance_name]
     , LEFT(s.volume_mount_point,40) [mount_point]
     , LEFT(s.logical_volume_name,40) [volume_name]
     , RIGHT('        ' + CONVERT(VARCHAR(8),CONVERT(INT,ROUND(s.total_bytes/1024.0/1024/1024,0))),8) [total_gb]
     , RIGHT('        ' + CONVERT(VARCHAR(8),CONVERT(INT,ROUND((s.total_bytes-s.available_bytes)/1024.0/1024/1024,0))),8) [used_gb]
     , RIGHT('        ' + CONVERT(VARCHAR(8),CONVERT(INT,ROUND(s.available_bytes/1024.0/1024/1024,0))),8) [avail_gb]
     , RIGHT('       '  + CONVERT(VARCHAR(7),CONVERT(INT,ROUND((s.total_bytes-s.available_bytes)*100/s.total_bytes,0))),7) + '%' [used_pct]
  FROM sys.master_files AS f
 CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) s
 ORDER BY 1;
GO
