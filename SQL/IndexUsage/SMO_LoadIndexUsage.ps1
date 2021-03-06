<#-------------------------------------------------------------------------------------------------
        NAME: SMO_LoadIndexUsage.ps1
  CREATED BY: Sal Young
 MODIFIED BY: Jyoti Senapati
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Captures index utilization for a database and inserts the result into DBA database. 
              
   EXAMPLE 1: Set-Location D:\SQLScripts
              .\SMO_LoadIndexUsage.ps1 -SQLInstanceSource "SQLInstanceName" -SQLDBSource "DatabaseName"
---------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------#>
param (
        [Parameter(Mandatory=$true)] [string] $SQLInstanceSource,
        [Parameter(Mandatory=$true)] [string] $SQLDBSource
        )

function Write-DataTable { 
<# 
.SYNOPSIS 
Writes data only to SQL Server tables. 
.DESCRIPTION 
Writes data only to SQL Server tables. However, the data source is not limited to SQL Server; any data source can be used, as long as the data can be loaded to a DataTable instance or read with a IDataReader instance. 
.INPUTS 
None 
    You cannot pipe objects to Write-DataTable 
.OUTPUTS 
None 
    Produces no output 
.EXAMPLE 
$dt = Invoke-Sqlcmd2 -ServerInstance "Z003\R2" -Database pubs "select *  from authors" 
Write-DataTable -ServerInstance "Z003\R2" -Database pubscopy -TableName authors -Data $dt 
This example loads a variable dt of type DataTable from query and write the datatable to another database 
.NOTES 
Write-DataTable uses the SqlBulkCopy class see links for additional information on this class. 
Version History 
v1.0   - Chad Miller - Initial release 
v1.1   - Chad Miller - Fixed error message 
.LINK 
http://msdn.microsoft.com/en-us/library/30c3y597%28v=VS.90%29.aspx 
#> 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$true)] [string]$TableName, 
    [Parameter(Position=3, Mandatory=$true)] $Data, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Username, 
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
SELECT GETDATE() [dCaptured]
     , @@SERVERNAME [ServerName]
     , DB_NAME(A.database_id) [DBName]
     , D.[name] [SchemaName]
     , B.[name] [TableName]
     , C.[name] [IndexName]
     , A.user_seeks [IndexSeeks]
     , A.user_scans [IndexScans]
     , A.user_lookups [IndexLookups]
     , A.user_updates [IndexUpdates]
     , COALESCE(A.last_user_seek, A.last_user_scan, A.last_user_lookup) [LastUsed]
     , A.last_user_update [LastUpdated]
     , DATEDIFF(dd, (SELECT sqlserver_start_time FROM sys.dm_os_sys_info), GETDATE()) AS daysServer_up
  FROM sys.tables B
 INNER JOIN sys.indexes C ON B.[object_id] = C.[object_id]
 INNER JOIN sys.schemas D ON B.[schema_id] = D.[schema_id]
  LEFT JOIN sys.dm_db_index_usage_stats A ON A.[object_id] = B.[object_id]
 WHERE A.database_id = db_id()
   AND C.index_id = A.index_id
   AND A.[user_seeks] + A.[user_scans] + A.[user_lookups] <= A.user_updates
   AND OBJECTPROPERTY(A.[object_id], 'IsUserTable') = 1
   AND A.[user_seeks] + A.[user_scans] + A.[user_lookups] >= 100
"@

$oData = Invoke-sqlcmd -ServerInstance $SQLInstanceSource -Database $SQLDBSource -Query "$qSQLCollectData"

if ($oData -ne $null) {
    Write-DataTable -ServerInstance "$MANAGEMENT_INSTANCE" -Database "$MANAGEMENT_DATABASE" -TableName "IndexUsage" -Data $oData
    Write-Host $oData.Count "records inserted."
}
else {
  Write "Index collection returned zero records."
}
