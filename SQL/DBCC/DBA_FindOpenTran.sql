/*-------------------------------------------------------------------------------------------------
        NAME: DBA_FindOpenTran.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: DBCC OPENTRAN displays information about the oldest active transaction and the oldest 
              distributed and nondistributed replicated transactions, if any, within the transaction 
              log of the specified database.
              http://msdn.microsoft.com/en-us/library/ms182792.aspx
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

DBCC OPENTRAN('tempdb') WITH TABLERESULTS
GO
