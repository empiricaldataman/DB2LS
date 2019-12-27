/*
-------------------------------------------------------------------------------------------------
        NAME: azTable.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Creates a stored procedure on an Azure SQL database to gather table metadata.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE dba.[table] 

AS

SELECT GETDATE() [collection_time]
     , @@SERVERNAME [instance_name]
     , DB_NAME() [databse_name]
     , s.[name] [schema_name]
     , t.[name] [table_name]
     , t.[object_id]
     , t.[schema_id]
     , t.[type]
     , t.[type_desc]
     , t.[create_date]
     , t.[modify_date]
     , t.[is_ms_shipped]
     , t.[is_published]
     , t.[lob_data_space_id]
  FROM sys.tables t
 INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
 ORDER BY s.name, t.name
GO

