<#-------------------------------------------------------------------------------------------------
       NAME: IndexMaintenance.ps1
MODIFIED BY: Sal Young
      EMAIL: saleyoun@yahoo.com
DESCRIPTION: Collects index fragmentation statistics from each user database in a SQL instance and
             inserts the result into DBA_BACKUP.dbo.fragmentation_statistics.
              
  EXAMPLE 1: Set-Location D:\SQLScripts
             .\IndexMaintenance.ps1 -SQLInstance "RCHPWCCRPSQL50B\DATAWAREHOUSE"
---------------------------------------------------------------------------------------------------
 DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of
             personal property, creating singularities, making deep fried chicken, causing your
             toilet to  explode, making  your animals spin  around like mad, causing hair loss,
             killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------#>
param ([Parameter(Mandatory=$true)] [string] $SQLInstance,
       [Parameter(Mandatory=$false)] [string] $DatabasesL,
       [Parameter(Mandatory=$false)] [string] $Action,
       [Parameter(Mandatory=$false)] [int] $Online = 0)
 
Push-Location
Import-Module SQLPS -DisableNameChecking
Pop-Location
 
workflow RunDBMaintenance {
    param ([string[]] $Databases,
           [string] $SQLInstance,
           [string] $Action,
           [int] $Online)
 
    switch -casesensitive ($Action) {
        'IndexCollect'  {$query = "EXEC dbo.pr_IndexMaintenance_CollectFragmentation @DatabaseName = "}
        'IndexRebuild'  {$query = "EXEC dbo.pr_IndexMaintenance_Rebuild @BuildOnline = $Online, @DatabaseName = "}
        'CollectStatistics' {$query = "EXEC dbo.pr_IndexMaintenance_CollectStatistics @DatabaseName = "}
        'StatisticsUpdate'  {$query = "EXEC dbo.pr_IndexMaintenance_UpdateStatistics @DatabaseName = "}
    }
 
    foreach -parallel ($Database in $Databases) {
        $db = $Database
        $S = $WORKFLOW:query +"'"+ $db +"'"
 
        InlineScript {
            Write-Verbose "Executing $USING:S"
            try{
                Invoke-Sqlcmd -ServerInstance "$USING:SQLInstance" -Database "msdb" -Query "$USING:S" -QueryTimeout 0 -ErrorAction "stop"
            } catch {
                $Error.Exception
            }
        }
    }
}
 

function Get-Databases {
    Param([Parameter(Mandatory=$true,ValueFromPipeline=$false)] [string] $SQLInstance,
        [Parameter(Mandatory=$false)] [string] $DatabasesL)
 
    if($DatabasesL) {
        $query = "EXEC dbo.pr_IndexMaintenance_GetDatabaseList @Name='$DatabasesL'"
    } else {
        $query = "EXEC dbo.pr_IndexMaintenance_GetDatabaseList"
    }
 
    try {
        $Databases = Invoke-Sqlcmd -ServerInstance "$SQLInstance" -Database msdb -Query "$query" -ErrorAction "stop"
    } catch {
        $Error.Exception
        $Error.InvocationInfo
    }
    Write-Output ($Databases)
}
 
function Start-DBMaintenance {
    [CmdletBinding()]
    Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string[]] $SQLInstances,
          [Parameter(Mandatory=$false)] [string] $DatabasesL,
          [Parameter(Mandatory=$false)] [int] $Online,
          [Parameter(Mandatory=$false)] [string] $Action         
          )
 
    Process{
        foreach ($SQLInstance in $SQLInstances) {
            try {
                if($DatabasesL) {
                    $Databases = (Get-Databases -SQLInstance $SQLInstance -DatabasesL $DatabasesL).database_name   
                } else {
                    $Databases = (Get-Databases -SQLInstance $SQLInstance).database_name
                }
               
                RunDBMaintenance -Databases $Databases -SQLInstance $SQLInstance -Action $Action
            }
            catch {
                $Error[0].Exception
                $Error[0].InvocationInfo
            }
        }
    }
}
 

switch ($Action) {
    'Collect'  {Start-DBMaintenance -SQLInstances "$SQLInstance" -DatabasesL $DatabasesL -Action "IndexCollect"}  # INDEX
    'Rebuild'  {Start-DBMaintenance -SQLInstances "$SQLInstance" -DatabasesL $DatabasesL -Online $Online -Action "IndexRebuild"} #INDEX
    'Collects' {Start-DBMaintenance -SQLInstances "$SQLInstance" -DatabasesL $DatabasesL -Action "StatisticsCollect"} #STATS
    'Update'   {Start-DBMaintenance -SQLInstances "$SQLInstance" -DatabasesL $DatabasesL -Action "StatisticsUpdate"}   #STATS
}
