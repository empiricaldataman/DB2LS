/*-------------------------------------------------------------------------------------------------
        NAME: DBA_ShowStats.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: DBCC SHOW_STATISTICS displays current query optimization statistics for a table or 
              indexed view.
              http://msdn.microsoft.com/en-us/library/ms174384.aspx
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:CONNECT <server_name, sysname, SQL_Server_Instance>

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

DBCC SHOW_STATISTICS ("<table_name, sysname, Table Name>", <index_name, sysname, Index Name>)
GO
