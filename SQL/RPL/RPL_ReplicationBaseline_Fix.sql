/*-------------------------------------------------------------------------------------------------
        NAME: RPL_ReplicationBaseline_Fix.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to add or remove records from [DBA].[dbo].[Replication_Baseline_Hist]
              This is the base table used for the MaintenanceDaily > MonitorReplication SQL job
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
USE DBA
GO

SET NOCOUNT ON

DECLARE @ServerName VARCHAR(255)
      , @Publication VARCHAR(255)
      , @Article VARCHAR(255)
      , @IncludedColumn VARCHAR(255)

SELECT @ServerName = 'RCHPWCCRPSQL01A\SERVICING'
     , @Publication = 'Servicing - Reporting - 02'
     , @Article = 'VehicleReturnHistory'
     , @IncludedColumn = 'nAdjustedLeaseBalance' --'cGarageState' --'bIsRequiredInHomePage'

/*
Step 1:
=======
1) Run the below proc to make a BackUP
*/
--EXEC pr_ArchiveReplicationBaseline 
--GO
/*

Step 2:
=======
1) Assign a value to the @Publication, @Article and the optional @IncludedColumn variables from the alert mail attachment.
2) Run both below queries and check the difference.
3) This shows the difference in replication out of sync with baseline.
4) The first query show the baseline articles and the second query shows the articles currently being replicated.
*/
--Query 1
SELECT * 
  FROM dbo.Replication_Included_Columns
 WHERE 1 = 1 
   AND ServerName = @ServerName
   AND RunDate = '19000101'
   AND PublicationName = @Publication
   AND Article = @Article
   AND IncludedColumn = COALESCE(@IncludedColumn, IncludedColumn)
 ORDER BY ServerName, PublicationName, Article, IncludedColumn

--Query 2
SELECT * 
  FROM dbo.Replication_Included_Columns
 WHERE 1 = 1 
   AND ServerName = @ServerName
   AND RunDate >= CONVERT(VARCHAR,GETDATE()-1,112)
   AND PublicationName = @Publication
   AND Article = @Article
   AND IncludedColumn = COALESCE(@IncludedColumn, IncludedColumn)
 ORDER BY ServerName, PublicationName, Article, IncludedColumn




/*
Step 3:
=======
1) Based on the difference on the output of the query in Step 2, run query 3a or 3b.
2) Run query 3a to DELETE the articles.
3) Run query 3b to INSERT the articles.
4) Before DELETE/INSERT please check the row count using the SELECT Statement.
*/
--Query 3a
--Check before you DELETE if row count is as baseline (just a precaution)

--DELETE - Change the select statement below to a DELETE when ready to perform action
SELECT * 
  FROM dbo.Replication_Included_Columns
--DELETE FROM dbo.Replication_Included_Columns
 WHERE 1 = 1 
   AND ServerName = @ServerName
   AND RunDate = '19000101'
   AND PublicationName = @Publication
   AND Article = @Article
   AND IncludedColumn = COALESCE(@IncludedColumn, IncludedColumn)


--Query 3b
--Check before you INSERT if row count is as baseline (just a precaution)

--INSERT INTO dbo.Replication_Included_Columns (ServerName, PublicationName, description, DestServerName, DestDB, Article, ArticleType, Filter_Clause, SubscriptionType, TableSizeMB, RowCnt, IncludedColumn,RunDate)
SELECT ServerName
     , PublicationName
     , [description]
     , DestServerName
     , DestDB
     , Article
     , ArticleType
     , Filter_Clause
     , SubscriptionType
     , TableSizeMB
     , RowCnt
     , IncludedColumn
     , '1900-01-01'
  FROM dbo.Replication_Included_Columns
 WHERE 1 = 1 
   AND ServerName = @ServerName
   AND RunDate >= CONVERT(VARCHAR,GETDATE()-1,112)
   AND PublicationName = @Publication
   AND Article = @Article
   AND IncludedColumn = COALESCE(@IncludedColumn, IncludedColumn)
GO


/*

Step 4:
=======
1) Rerun the query in Step 2 to ensure both replication and baseline are in sync.

*/


