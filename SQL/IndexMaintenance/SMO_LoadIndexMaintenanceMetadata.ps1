<#-------------------------------------------------------------------------------------------------
        NAME: SMO_LoadIndexMaintenanceMetadata.ps1
 MODIFIED BY: Sal Young
 Modified By: 
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Consolidates data into RCHPWVMGMSQL01\MANAGEMENT01.DBA from each SQL instance
              configured for the new index maintenance. 
              
   EXAMPLE 1: Set-Location D:\SQLScripts
              .\SMO_LoadIndexMaintenanceMetadata.ps1
---------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------#>
if ($MANAGEMENT_INSTANCE -eq $null) {. ManagementEnvironment.ps1}

Push-Location
Import-Module SQLPS -DisableNameChecking
Pop-Location

function Write-DataTable { 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$true)] [string]$TableName, 
    [Parameter(Position=3, Mandatory=$true)] $Data, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=5, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$BatchSize=50000, 
    [Parameter(Position=7, Mandatory=$false)] [Int32]$QueryTimeout=0, 
    [Parameter(Position=8, Mandatory=$false)] [Int32]$ConnectionTimeout=15 
    ) 
     
    $conn=new-object System.Data.SqlClient.SQLConnection 
 
    if ($Username) 
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout } 
 
    $conn.ConnectionString=$ConnectionString 
 
    try 
    { 
        $conn.Open() 
        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString 
        $bulkCopy.DestinationTableName = $tableName 
        $bulkCopy.BatchSize = $BatchSize 
        $bulkCopy.BulkCopyTimeout = $QueryTimeOut 
        $bulkCopy.WriteToServer($Data) 
        $conn.Close() 
    } 
    catch 
    { 
        $ex = $_.Exception 
        Write-Error "$ex.Message" 
        continue 
    } 
 
}

$qSQLCollectData = @"
SELECT [load_date_start]
     , [load_date_end]
     , @@SERVERNAME [server_name]
     , [database_name]
     , [schema_name]
     , [object_id]
     , [table_name]
     , [index_id]
     , [index_name]
     , [partition_number]
     , [page_count]
     , [avg_fragmentation_in_percent]
     , [avg_page_space_used_in_percent]
     , [maintenance_start]
     , [maintenance_end]
     , [active]
     , [large_db]
     , [error_message]
  FROM [DBA_Backup].[dbo].[fragmentation_statistics]
 WHERE [active] <> 1
"@

$qSQLRemoveData = @"
DELETE FROM [DBA_Backup].[dbo].[fragmentation_statistics] WHERE [active] <> 1
"@


function Import-Data {
  [CmdletBinding()] 
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string[]] $SQLInstances)

  Begin {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
  }
  
  Process{
    foreach($SQLInstance in $SQLInstances){
      try{
        $oData = Invoke-sqlcmd -ServerInstance $SQLInstance -Database "DBA_Backup" -Query "$qSQLCollectData"
        if ($oData -ne $null) {
          try{
            Write-DataTable -ServerInstance "$MANAGEMENT_INSTANCE" -Database "$MANAGEMENT_DATABASE" -TableName "[IndexMaintenance]" -Data $oData
            #Invoke-sqlcmd -ServerInstance $SQLInstance -Database "DBA_Backup" -Query "$qSQLRemoveData"
          }
          catch{
            $Error[0].Exception
            $Error[0].InvocationInfo    
          }
        }
      }
      catch {
        $Error[0].Exception
        $Error[0].InvocationInfo
      }
    }
  }
}

$SQLInstanceSource = Get-Content $SQL_IDX
Import-Data -SQLInstances $SQLInstanceSource