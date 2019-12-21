/*
-------------------------------------------------------------------------------------------------
        NAME: azColumn.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Creates a stored procedure on an Azure SQL database to gather column metadata.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dba].[column]

AS

SELECT GETDATE() [collection_time]
     , @@SERVERNAME [instance_name]
     , DB_NAME() [databse_name]
     , c.[object_id]
     , c.[name]
     , c.[column_id]
     , st.[name]
     , st.[schema_id]
     , c.[system_type_id]
     , c.[user_type_id]
     , c.[max_length]
     , c.[precision]
     , c.[collation_name]
     , c.[is_nullable]
     , c.[is_ansi_padded]
     , c.[is_rowguidcol]
     , c.[is_identity]
     , c.[is_computed]
     , c.[is_filestream]
  FROM [sys].[columns] c
 INNER JOIN [sys].[types] st ON st.[system_type_id] = c.[system_type_id]
   AND st.[user_type_id] = c.[user_type_id]
   AND [object_id] IN (SELECT [object_id] FROM sys.all_objects WHERE is_ms_shipped = 0)
 WHERE 1 = 1
 ORDER BY c.[object_id], c.column_id
GO
 