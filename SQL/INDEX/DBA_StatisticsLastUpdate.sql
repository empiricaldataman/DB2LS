:CONNECT <server_name, sysname, SQL_Server_Instance>
USE Finance
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT name AS index_name,
STATS_DATE(OBJECT_ID, index_id) AS StatsUpdated
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('GL.DailyGLAccruedInterest')
GO