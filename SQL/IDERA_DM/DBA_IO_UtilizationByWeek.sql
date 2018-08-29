/*-------------------------------------------------------------------------------------------------
        NAME: DBA_IO_UtilizationByWeek.sql
  WRITTEN BY: Steve Wood
         URL: simplesqlserver.com
 DESCRIPTION: Displays IO utilization by 7 day intervals in order to compare.
              http://simplesqlserver.com/2016/02/29/io-baseline-comparison-idera-diagnostic-manager/
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:CONNECT PI

SET NOCOUNT ON

DECLARE @StartTime DateTime
	, @EndTime DateTime
	, @InstanceName sysname
	, @Weekdays bit
	, @BusinessHours bit
		
SET @EndTime = GetUTCDate()
SET @StartTime = DateAdd(Hour, -24, @EndTime)
SET @InstanceName = NULL --Do 'Server\Instance' for individual server
SET @Weekdays = 1
SET @BusinessHours = 1

SELECT S.InstanceName
	, StartTime = @StartTime 
	, EndTime = @EndTime
	, Reads_GB = CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) 
	, ReadAhead_GB = CAST(SUM(St.ReadAheadPages)/128/1024.0 AS DEC(20,1))
	, Writes_GB = CAST(SUM(St.PageWrites)/128/1024.0 AS DEC(20,1)) 
	, Lookups_GB = CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) 
	, PctPhysical = CAST(CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) / CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) * 100 as DEC(20,1))
	, AvgPLE = Avg(St.PageLifeExpectancy)
	, AvgCache_MB = AVG(St.BufferCacheSizeInKilobytes)/1024
FROM SQLdmRepository..MonitoredSQLServers S
	INNER JOIN SQLdmRepository..ServerStatistics St ON S.SQLServerID = St.SQLServerID
WHERE UTCCollectionDateTime BETWEEN @StartTime AND @EndTime 
	AND (DATEPART(WEEKDAY, UTCCollectionDateTime) BETWEEN 2 and 6 or @Weekdays = 0)
	AND (DATEPART(HOUR, UTCCollectionDateTime) BETWEEN 12 and 21 OR @BusinessHours = 0)
	AND (UPPER(S.InstanceName) = UPPER(@InstanceName) OR @InstanceName IS NULL)
GROUP BY S.InstanceName
ORDER BY 4 DESC

SELECT @StartTime = @StartTime - 7 
	, @EndTime = @EndTime - 7

SELECT S.InstanceName
	, StartTime = @StartTime 
	, EndTime = @EndTime
	, Reads_GB = CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) 
	, ReadAhead_GB = CAST(SUM(St.ReadAheadPages)/128/1024.0 AS DEC(20,1))
	, Writes_GB = CAST(SUM(St.PageWrites)/128/1024.0 AS DEC(20,1)) 
	, Lookups_GB = CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) 
	, PctPhysical = CAST(CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) / CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) * 100 as DEC(20,1))
	, AvgPLE = Avg(St.PageLifeExpectancy)
	, AvgCache_MB = AVG(St.BufferCacheSizeInKilobytes)/1024
FROM SQLdmRepository..MonitoredSQLServers S
	INNER JOIN SQLdmRepository..ServerStatistics St ON S.SQLServerID = St.SQLServerID
WHERE UTCCollectionDateTime BETWEEN @StartTime AND @EndTime 
	AND (DATEPART(WEEKDAY, UTCCollectionDateTime) BETWEEN 2 and 6 or @Weekdays = 0)
	AND (DATEPART(HOUR, UTCCollectionDateTime) BETWEEN 12 and 21 OR @BusinessHours = 0)
	AND (UPPER(S.InstanceName) = UPPER(@InstanceName) OR @InstanceName IS NULL)
GROUP BY S.InstanceName
ORDER BY 4 DESC

SELECT @StartTime = @StartTime - 7 
	, @EndTime = @EndTime - 7

SELECT S.InstanceName
	, StartTime = @StartTime 
	, EndTime = @EndTime
	, Reads_GB = CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) 
	, ReadAhead_GB = CAST(SUM(St.ReadAheadPages)/128/1024.0 AS DEC(20,1))
	, Writes_GB = CAST(SUM(St.PageWrites)/128/1024.0 AS DEC(20,1)) 
	, Lookups_GB = CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) 
	, PctPhysical = CAST(CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) / CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) * 100 as DEC(20,1))
	, AvgPLE = Avg(St.PageLifeExpectancy)
	, AvgCache_MB = AVG(St.BufferCacheSizeInKilobytes)/1024
FROM SQLdmRepository..MonitoredSQLServers S
	INNER JOIN SQLdmRepository..ServerStatistics St ON S.SQLServerID = St.SQLServerID
WHERE UTCCollectionDateTime BETWEEN @StartTime AND @EndTime 
	AND (DATEPART(WEEKDAY, UTCCollectionDateTime) BETWEEN 2 and 6 or @Weekdays = 0)
	AND (DATEPART(HOUR, UTCCollectionDateTime) BETWEEN 12 and 21 OR @BusinessHours = 0)
	AND (UPPER(S.InstanceName) = UPPER(@InstanceName) OR @InstanceName IS NULL)
GROUP BY S.InstanceName
ORDER BY 4 DESC


SELECT @StartTime = @StartTime - 7 
	, @EndTime = @EndTime - 7

SELECT S.InstanceName
	, StartTime = @StartTime 
	, EndTime = @EndTime
	, Reads_GB = CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) 
	, ReadAhead_GB = CAST(SUM(St.ReadAheadPages)/128/1024.0 AS DEC(20,1))
	, Writes_GB = CAST(SUM(St.PageWrites)/128/1024.0 AS DEC(20,1)) 
	, Lookups_GB = CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) 
	, PctPhysical = CAST(CAST(SUM(St.PageReads)/128/1024.0 AS DEC(20,1)) / CAST(SUM(St.PageLookups)/128/1024.0 AS DEC(20,1)) * 100 as DEC(20,1))
	, AvgPLE = Avg(St.PageLifeExpectancy)
	, AvgCache_MB = AVG(St.BufferCacheSizeInKilobytes)/1024
FROM SQLdmRepository..MonitoredSQLServers S
	INNER JOIN SQLdmRepository..ServerStatistics St ON S.SQLServerID = St.SQLServerID
WHERE UTCCollectionDateTime BETWEEN @StartTime AND @EndTime 
	AND (DATEPART(WEEKDAY, UTCCollectionDateTime) BETWEEN 2 and 6 or @Weekdays = 0)
	AND (DATEPART(HOUR, UTCCollectionDateTime) BETWEEN 12 and 21 OR @BusinessHours = 0)
	AND (UPPER(S.InstanceName) = UPPER(@InstanceName) OR @InstanceName IS NULL)
GROUP BY S.InstanceName
ORDER BY 4 DESC
