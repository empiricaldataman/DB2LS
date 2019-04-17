/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_DDLEvents.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays DDL events in a hierarchy format
-------------------------------------------------------------------------------------------------
     HISTORY:
   TR/PROJ#    DATE        MODIFIED      DESCRIPTION
               01.02.2019  SYOUNG        Create date
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH [EventsHierarchy] (name, parent_type, type, level, sort)
  AS (SELECT CONVERT(varchar(255),type_name)
           , parent_type
           , type
           , 1
           , CONVERT(varchar(255),type_name)  
        FROM sys.trigger_event_types   
       WHERE parent_type IS NULL  
       UNION ALL  
      SELECT CONVERT(varchar(255), REPLICATE ('|   ' , level) + e.type_name)
           , e.parent_type
           , e.type
           , level + 1
           , CONVERT (varchar(255), RTRIM(sort) + '|   ' + e.type_name)  
        FROM sys.trigger_event_types AS e  
       INNER JOIN [EventsHierarchy] AS d ON e.parent_type = d.type)  

SELECT parent_type
     , [type]
     , [name]
  FROM [EventsHierarchy]
 WHERE 1 = 1
 ORDER BY sort;

