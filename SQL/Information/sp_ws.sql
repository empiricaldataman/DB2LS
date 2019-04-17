USE [master]
GO

IF OBJECT_ID(N'dbo.sp_ws','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_ws
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_ws.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about wait stats
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    08.21.2018  SYoung        Re-format T-SQL code
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_ws]
       @order CHAR(1) = 'c' -- (c = waiting_tasks_count, t = wait_time_ms, m =  max_wait_time_ms, s = signal_wait_time_ms)

AS

SELECT wait_type
     , waiting_tasks_count
     , wait_time_ms
     , max_wait_time_ms
     , signal_wait_time_ms
  FROM sys.dm_os_wait_stats WITH (NOLOCK)
 ORDER BY CASE @order WHEN 't' THEN wait_time_ms
                      WHEN 'm' THEN max_wait_time_ms
                      WHEN 's' THEN signal_wait_time_ms
                      ELSE waiting_tasks_count END DESC
GO
