
:CONNECT PI
USE SQLdmRepository
GO
/*
SELECT [name]
  FROM sys.objects
 WHERE [type] = 'p'
   AND [name] LIKE '%Summary%'
*/
--SELECT * FROM MonitoredSQLServers
--SELECT * FROM SQLServerDatabaseNames
-- WHERE Active = 1
--EXEC p_GetMonitoredServersSummary
--p_GetVMSummaryReport
--EXEC p_GetChangeLogSummary @AuditName = @mynvarchar1, @UTCStart = @mydatetime2, @UTCEnd = @mydatetime3, @UTCOffset = @myint4, @Workstation = @mynvarchar5, @WorkstationUser = @mynvarchar6, @SQLUser = @mynvarchar7
DECLARE @start_date datetime
      , @end_date datetime

SET @start_date = DATEADD(m,-4,GETDATE())
SET @end_date = GETDATE()

--EXEC p_GetCPUSummary @ServerID = 8, @UTCStart = @start_date, @UTCEnd = @end_date, @UTCOffset = -6, @Interval = 1
--EXEC p_GetDiskSummary @ServerID = 8, @UTCStart = @start_date, @UTCEnd = @end_date, @UTCOffset = 0, @Interval = 0
--exec p_GetTempdbSummaryData @SQLServerID = 8, @UTCSnapshotCollectionDateTime = NULL, @HistoryInMinutes = 140232
EXEC p_GetMemorySummary @ServerID = 8, @UTCStart = @start_date, @UTCEnd = @end_date, @UTCOffset = 0, @Interval = 1

--EXEC p_GetCPUSummaryBaseline @ServerID = 8, @UTCStart = @start_date, @UTCEnd = @end_date, @UTCOffset = -6, @Interval = 1
--p_GetRecommendationSummary
--p_GetReplicationSummary
--EXEC p_GetServerSummary @SQLServerID = 7, @UTCSnapshotCollectionDateTime = @end_date, @HistoryInMinutes = 120
--p_GetServerSummaryReport
--p_GetSessionsSummary
--p_GetSessionSummaryBaseline
--p_GetMemorySummaryBaseline
--SELECT DATEDIFF(n,'20171012',GETDATE())