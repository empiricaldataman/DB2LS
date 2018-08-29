/*-------------------------------------------------------------------------------------------------
        NAME: DBA_IO_ReadWriteByDB.sql
  WRITTEN BY: Steve Wood
         URL: simplesqlserver.com
 DESCRIPTION: 
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:CONNECT PI

USE SQLdmRepository
GO

SET NOCOUNT ON 

DECLARE 
    @SQLServerID int,
    @UTCSnapshotCollectionDateTime datetime,
    @HistoryInMinutes int

declare @BeginDateTime datetime
declare @EndDateTime datetime

SET @SQLServerID = 7
SET @HistoryInMinutes = 2880 -- 129830

if (@UTCSnapshotCollectionDateTime is null)
    select @EndDateTime = (select max(UTCCollectionDateTime) from [DiskDrives] (NOLOCK) where [SQLServerID] = @SQLServerID)
else
    select @EndDateTime = @UTCSnapshotCollectionDateTime

if (@HistoryInMinutes is null)
    select @BeginDateTime = @EndDateTime
else
    select @BeginDateTime = dateadd(n, -@HistoryInMinutes, @EndDateTime)

select CAST(da.UTCCollectionDateTime AS DATE) [UTCCollectionDateTime],
    --DriveName = dd.DriveName,
    DatabaseName,
    --[FileName]= rtrim([FileName]),
    --FileType = rtrim(FileType),
    --FilePath = rtrim(FilePath),
    --SUM(DiskReadsPerSecond) [DiskReadsPerSecond],    
    --SUM(DiskWritesPerSecond) [DiskWritesPerSecond],
    --SUM((da.Reads / nullif(TimeDeltaInSeconds,0))) [FileReadsPerSecond],
    --SUM((da.Writes / nullif(TimeDeltaInSeconds,0))) [FileWritesPerSecond],
    --SUM(DiskTransfersPerSecond) [DiskTransfersPerSecond],
    SUM(((da.Reads + da.Writes) / nullif(TimeDeltaInSeconds,0))) [FileTransfersPerSecond]
from DiskDrives dd (NOLOCK)
left join SQLServerDatabaseNames dn (NOLOCK) on dd.SQLServerID = dn.SQLServerID
left join DatabaseFiles df (NOLOCK) on dn.DatabaseID = df.DatabaseID
 and lower(df.DriveName) = lower(dd.DriveName)
left join DatabaseFileActivity da (NOLOCK) on df.FileID = da.FileID
 and (da.UTCCollectionDateTime = ISNULL(dd.DatabaseSizeTime,dd.UTCCollectionDateTime))
where dd.SQLServerID = @SQLServerID
  and dn.SQLServerID = @SQLServerID
  and dd.[UTCCollectionDateTime] >= @BeginDateTime 
  and dd.[UTCCollectionDateTime] <= @EndDateTime
  and da.[UTCCollectionDateTime] >= @BeginDateTime 
  and da.[UTCCollectionDateTime] <= @EndDateTime
  --and DatabaseName = 'DW_ShawStore'
  GROUP BY da.UTCCollectionDateTime, DatabaseName
  ORDER BY 3
