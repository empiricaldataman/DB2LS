/*
-------------------------------------------------------------------------------------------------
        NAME: IderaDM_Alerts.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: 
-------------------------------------------------------------------------------------------------
CHANGE HISTORY:
DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
01.04.2017  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/

DECLARE @servername varchar(256)
      , @active bit
      , @datetime datetime

SET @servername = NULL
SET @active = 1
SET @datetime = CAST(GETDATE() AS DATE)

SELECT TOP 100  A.[AlertID]
     , A.[UTCOccurrenceDateTime]
     , DATEADD(hh,DATEDIFF(hh,GETUTCDATE(),GETDATE()),A.[UTCOccurrenceDateTime]) CurrentLocalTime
     , A.[ServerName]
     , A.[DatabaseName]
     , A.[TableName]
     , A.[Active]
     --, A.[Metric]
     , MI.[Category]
     , MI.[Name]
     , MI.[Description]
     --, A.[Severity]
     --, A.[StateEvent]
     , A.[Value]
     , A.[Heading]
     , A.[Message]
  FROM [SQLdmRepository].[dbo].[Alerts] A WITH (NOLOCK)
 INNER JOIN [SQLdmRepository].[dbo].[MetricInfo] MI WITH (NOLOCK) ON A.Metric = MI.Metric
 WHERE 1 = 1
   AND A.Active = @active
   AND DATEADD(hh,DATEDIFF(hh,GETUTCDATE(),GETDATE()),A.[UTCOccurrenceDateTime]) > @datetime
   AND A.ServerName = COALESCE(@servername, A.ServerName)
 ORDER BY [UTCOccurrenceDateTime] DESC