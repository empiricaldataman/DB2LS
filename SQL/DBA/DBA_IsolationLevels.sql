/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_IsolationLevels.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Lists the 6 isolation levels available in SQL Server 2012 and above.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
--             2018.05.20  SYOUNG        Created on.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
--[ PESSIMISTIC LEVEL ]
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL READ COMMITTED   --[ DEFAULT        ]
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --[ SAME AS NOLOCK ]

--[ OPTIMISTIC LEVEL ]
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	ALTER [DatabaseName]
	SET ALLOW_SNAPSHOT_ISOLATION ON;
SET TRANSACTION ISOLATION LEVEL Read Committed SnapShot
	ALTER [DatabaseName]
	SET READ_COMMITTED_SNAPSHOT ON;