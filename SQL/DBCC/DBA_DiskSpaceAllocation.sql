/*-------------------------------------------------------------------------------------------------
        NAME: DBA_DiskSpaceAllocation.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Checks the consistency of disk space allocation structures for a specified database.
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    04.23.2015  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
/*
DBCC CHECKALLOC 
[ 
( 
     [ 'database_name' | database_id | 0 ] 
          [ , NOINDEX 
     | 
     { REPAIR_ALLOW_DATA_LOSS 
     | REPAIR_FAST 
     | REPAIR_REBUILD 
     } ] 
)
]
     [ WITH { [ ALL_ERRORMSGS ]
              [ , NO_INFOMSGS ] 
              [ , TABLOCK ] 
              [ , ESTIMATEONLY ] 
            } 
     ] 
*/
DBCC CHECKALLOC ('AdventureWorks');
