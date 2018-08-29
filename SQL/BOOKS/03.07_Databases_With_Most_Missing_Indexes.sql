-- Listing 3.7 The databases with the most missing indexes

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DB_NAME(database_id) AS DatabaseName
     , COUNT(*) AS [Missing Index Count]
  FROM sys.dm_db_missing_index_details
 GROUP BY DB_NAME(database_id)
 ORDER BY [Missing Index Count] DESC
