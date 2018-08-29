-- Listing 6.1 Why are you waiting?
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TOP 20 wait_type
     , wait_time_ms
     , signal_wait_time_ms
     , wait_time_ms - signal_wait_time_ms AS RealWait
     , CONVERT(DECIMAL(12,2), wait_time_ms * 100.0 / SUM(wait_time_ms) OVER()) AS [% Waiting]
     , CONVERT(DECIMAL(12,2), (wait_time_ms - signal_wait_time_ms) * 100.0 / SUM(wait_time_ms) OVER()) AS [% RealWait]
  FROM sys.dm_os_wait_stats
 WHERE wait_type NOT LIKE '%SLEEP%'
   AND wait_type != 'WAITFOR'
 ORDER BY wait_time_ms DESC;
