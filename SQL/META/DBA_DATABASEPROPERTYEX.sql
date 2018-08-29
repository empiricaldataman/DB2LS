/*-------------------------------------------------------------------------------------------------
        NAME: DBA_DATABASEPROPERTYEX.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Returns property information about the database. USE CTRL + SHIFT + M to provide 
              database name.
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    11.19.2013  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET NOCOUNT ON

SELECT DATABASEPROPERTYEX('<DBName, sysname, DBName>','Collation')                                 [Collation]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','ComparisonStyle')                           [ComparisonStyle]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','Edition')                                   [Edition] 
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAnsiNullDefault')                         [IsAnsiNullDefault]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAnsiNullsEnabled')                        [IsAnsiNullsEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAnsiPaddingEnabled')                      [IsAnsiPaddingEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAnsiWarningsEnabled')                     [IsAnsiWarningsEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsArithmeticAbortEnabled')                  [IsArithmeticAbortEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAutoClose')                               [IsAutoClose]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAutoCreateStatistics')                    [IsAutoCreateStatistics]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAutoCreateStatisticsIncremental')         [IsAutoCreateStatisticsIncremental]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAutoShrink')                              [IsAutoShrink]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsAutoUpdateStatistics')                    [IsAutoUpdateStatistics]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsClone')                                   [IsClone]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsCloseCursorsOnCommitEnabled')             [IsCloseCursorsOnCommitEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsFulltextEnabled')                         [IsFulltextEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsInStandBy')                               [IsInStandBy]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsLocalCursorsDefault')                     [IsLocalCursorsDefault]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsMemoryOptimizedElevateToSnapshotEnabled') [IsMemoryOptimizedElevateToSnapshotEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsMergePublished')                          [IsMergePublished]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsNullConcat')                              [IsNullConcat]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsNumericRoundAbortEnabled')                [IsNumericRoundAbortEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsParameterizationForced')                  [IsParameterizationForced]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsQuotedIdentifiersEnabled')                [IsQuotedIdentifiersEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsPublished')                               [IsPublished]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsRecursiveTriggersEnabled')                [IsRecursiveTriggersEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsSubscribed')                              [IsSubscribed]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsSyncWithBackup')                          [IsSyncWithBackup]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsTornPageDetectionEnabled')                [IsTornPageDetectionEnabled]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsVerifiedClone')                           [IsVerifiedClone]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','IsXTPSupported')                            [IsXTPSupported]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','LastgoodCheckDBTime')                       [LastgoodCheckDBTime]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','LCID')                                      [LCID]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','MaxSizeInBytes')                            [MaxSizeInBytes]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','Recovery')                                  [Recovery]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','ServiceObjective')                          [ServiceObjective]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','ServiceObjectiveId')                        [ServiceObjectiveId]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','SQLSortOrder')                              [SQLSortOrder]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','Status')                                    [Status]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','Updateability')                             [Updateability]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','UserAccess')                                [UserAccess]
     , DATABASEPROPERTYEX('<DBName, sysname, DBName>','Version')                                   [Version]
GO
