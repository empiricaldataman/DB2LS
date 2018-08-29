/*-----------------------------------------------------------------------------------------------
        NAME: LiteSpeed_DB_Restore_With_Move.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to restore a database from a LiteSpeed backup file and to drives
              different from the original location.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
exec master.dbo.xp_restore_database @database = N'EDW_Staging_SAL' ,
@filename = N'\\DAA30144SQL013\Backup\EDW_Staging\OLD\EDW_Staging_20130514080250877_V_sls.bak',
@filenumber = 1,
@with = N'REPLACE',
@with = N'STATS = 10',
@with = N'MOVE N''EDW_Staging_data_01'' TO N''F:\SQLData\EDW_Staging_SAL.mdf''',
@with = N'MOVE N''EDW_Staging_log_01'' TO N''T:\SQLLogs\EDW_Staging_SAL_1.ldf''',
@affinity = 0,
@logging = 0
GO
