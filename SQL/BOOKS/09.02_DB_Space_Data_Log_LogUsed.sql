-- Listing 9.2 Total amount of space (data, log, and log used) by database
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

SELECT instance_name
     , counter_name
     , cntr_value / 1024.0 AS [Size(MB)]
  FROM sys.dm_os_performance_counters
 WHERE object_name = 'SQLServer:Databases'
   AND counter_name IN ('Data File(s) Size (KB)', 'Log File(s) Size (KB)', 'Log File(s) Used Size (KB)')
 ORDER BY instance_name, counter_name;
GO
