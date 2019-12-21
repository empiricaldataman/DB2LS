<#-------------------------------------------------------------------------------------------------
        NAME: SMO_LoadStatisticsMetadata.ps1
 MODIFIED BY: Sal Young
 Modified By: Jyoti Senapati
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Collects statistics from each user database in a SQL instance and inserts the result into DBA database. 
              
   EXAMPLE 1: Set-Location D:\SQLScripts
              .\SMO_LoadStatisticsMetadata.ps1 -SQLInstanceSource "DAASQL11"
---------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------#>
param (
        [Parameter(Mandatory=$true)] [string] $SQLInstanceSource
        )

$dStartDateTime = Get-Date
$DateString = "{0:yyyyMMdd}" -f $dStartDateTime

$dStartDateTime
$headers += "--------------------------------------------------------------------------------------------------------`n"
$headers += "Collecting statistics from $SQLInstanceSource ....`n"
Write-Host $headers

if ($MANAGEMENT_INSTANCE -eq $null) {. ManagementEnvironment.ps1}

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
SELECT CAST(GETDATE() AS smalldatetime) [collection_time]
     , @@SERVERNAME [instance_name]
     , DB_NAME() [database_name]
     , sc.[name] [schema_name]
     , o.[name] table_name
     , [s].[name] [stat_name]
     , [ddsp].[last_updated] [stat_last_updated]
     , [ddsp].[rows] [rows_in_table]
     , [ddsp].[modification_counter] [rows_modified]
     , CAST(100 * [ddsp].[modification_counter] / [ddsp].[rows] AS DECIMAL(18,2)) [per_rows_modified]
     , CASE WHEN ddsp.[rows] > 1000 AND CAST(100 * [ddsp].[modification_counter] / [ddsp].[rows] AS DECIMAL(18,2)) > 25 THEN N'UPDATE STATISTICS ['+ sc.[name] +'].['+ o.[name] +']' ELSE NULL END [command]
  FROM sys.objects o
  JOIN sys.stats s ON o.[object_id] = s.[object_id]
  JOIN sys.schemas sc ON o.[schema_id] = sc.[schema_id]
 OUTER APPLY sys.dm_db_stats_properties(s.[object_id], s.stats_id) ddsp
 WHERE 1 = 1
   AND o.[type] = 'U'       --user tables
   AND s.auto_created = 0 --stats creates as part of index creation
   AND ddsp.[rows] > 1000   --stat having greater than or equal to 1000 rows 
 ORDER BY CAST(100 * [ddsp].[modification_counter] / [ddsp].[rows] AS DECIMAL(18,2)) DESC
"@

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
$InstanceObject = New-Object "Microsoft.SqlServer.Management.SMO.Server" "$SQLInstanceSource"

$Databases = $InstanceObject.Databases|WHERE {$_.IsSystemObject -eq $false}

foreach ($database in $Databases) {
    $SQLDBSource = $database.name

    $headers = "Collecting statistics from $SQLDBSource ....`n"
    Write-Host $headers

    $oData = Invoke-sqlcmd -ServerInstance $SQLInstanceSource -Database "$SQLDBSource" -Query "$qSQLCollectData"
    if ($oData -ne $null) {
        Write-DataTable -ServerInstance "$MANAGEMENT_INSTANCE" -Database "$MANAGEMENT_DATABASE" -TableName "[statistics]" -Data $oData
    }
}
