/*-----------------------------------------------------------------------------------------------
        NAME: LiteSpeed_Object_Level_Restore.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: As Max would say "Self explained"
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
--[ WITH DIFFERENTIAL RESTORE ]
EXEC master.dbo.xp_objectrecovery
     @filename = 'U:\backup\DW_ServicingMart\DW_ServicingMart_20091128220009500_U_sls.bak'
   , @difffilename = 'U:\backup\DW_ServicingMart\DW_ServicingMart_20091129220002550_U_sls.dff'
   , @objectname = 'dbo.AssignedRepos'
   , @destinationdatabase = 'dw_ServicingMart'
   , @destinationtable = 'AssignedRepos_20091129'
   , @TempDirectory='d:\temp'


--[ FROM FULL BACKUP ]
EXEC master.dbo.xp_objectrecovery
@filename = 'X:\Backup\EDW_UAT\EDW_UAT_20130206220929393_X_sls.bak',
@ObjectName='Accounting.TheMatrix',
@DestinationServer='DAA30144SQL013',
@DestinationDatabase='EDW_UAT',
@DestinationTable='TheMatrix',
@TempDirectory='R:\Temp'