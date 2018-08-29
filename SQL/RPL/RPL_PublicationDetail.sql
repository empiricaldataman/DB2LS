/*-------------------------------------------------------------------------------------------------
        NAME: RPL_PublicationDetail.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to get detailed information about publications 
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/

SET NOCOUNT ON

SELECT P.[name] [publication]
     , P.[description]
     , A.[name] [article]
     , S.srvname
     , S.dest_db
     , A.[dest_table]
  FROM [dbo].[sysarticles] A
 INNER JOIN [dbo].[syspublications] P ON A.pubid = P.pubid
 INNER JOIN [dbo].[syssubscriptions] S ON A.artid = S.artid
GO

