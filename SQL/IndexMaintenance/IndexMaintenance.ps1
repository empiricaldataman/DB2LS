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
       [Parameter(Mandatory=$false)] [string] $Action)

Push-Location
Import-Module SQLPS -DisableNameChecking
Pop-Location

workflow IndexFragmentation {
    param ([string[]] $Databases,
           [string] $SQLInstance,
           [string] $Action)

    switch -casesensitive ($Action) {
        'Collect' {$query = "EXEC dbo.pr_IndexMaintenance_CollectFragmentation @DatabaseName = "}
        'Rebuild' {$query = "EXEC dbo.pr_IndexMaintenance_Rebuild @DatabaseName = "}
        'Update'  {$query = "EXEC dbo.pr_IndexMaintenance_UpdateStats @DatabaseName = "}
    }


    foreach -parallel ($Database in $Databases) {
        #$db = $Database
        $db = $Database
        $S = $WORKFLOW:query +"'"+ $db +"'"

        InlineScript {Write-Verbose "Executing $USING:S"}
        Invoke-Sqlcmd -ServerInstance "$SQLInstance" -Database "msdb" -Query "$S" -QueryTimeout 0 -ErrorAction "stop"

        #if ($Action -eq 'Collect'){
            #Invoke-Sqlcmd -ServerInstance "$SQLInstance" -Database "msdb" -Query "EXEC dbo.pr_IndexMaintenance_CollectFragmentation @DatabaseName = '$db'" -QueryTimeout 0 -ErrorAction "stop"
        #}
        #if ($Action -eq 'Rebuild'){
            #Invoke-Sqlcmd -ServerInstance "$SQLInstance" -Database "msdb" -Query "EXEC dbo.pr_IndexMaintenance_Rebuild @DatabaseName = '$db'" -QueryTimeout 0 -ErrorAction "stop"
        #}
        #if ($Action -eq 'Update') {
        #    Invoke-Sqlcmd -ServerInstance "$SQLInstance" -Database "msdb" -Query "EXEC dbo.pr_IndexMaintenance_UpdateStats @DatabaseName = '$db'" -QueryTimeout 0 -ErrorAction "stop"
        #}
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


function Save-IndexFragmentation {
    [CmdletBinding()]
    Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string[]] $SQLInstances,
          [Parameter(Mandatory=$false)] [string] $DatabasesL)

    Process{
        foreach ($SQLInstance in $SQLInstances) {
            try {
                if($DatabasesL) {
                    $Databases = (Get-Databases -SQLInstance $SQLInstance -DatabasesL $DatabasesL).database_name    
                } else {
                    $Databases = (Get-Databases $SQLInstance).database_name
                }
                
                IndexFragmentation -Databases $Databases -SQLInstance $SQLInstance -Action "Collect"
            }
            catch {
                $Error[0].Exception
                $Error[0].InvocationInfo
            }
        }
    }
}

function Step-IndexRebuild {
    [CmdletBinding()]
    Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string[]] $SQLInstances,
          [Parameter(Mandatory=$false)] [string] $DatabasesL)

    Process{
        foreach ($SQLInstance in $SQLInstances) {
            try {
                if($DatabasesL) {
                    $Databases = (Get-Databases -SQLInstance $SQLInstance -DatabaseL $DatabasesL).database_name    
                } else {
                    $Databases = (Get-Databases $SQLInstance).database_name
                }
                
                IndexFragmentation -Databases $Databases -SQLInstance $SQLInstance -Action "Rebuild"
            }
            catch {
                $Error[0].Exception
                $Error[0].InvocationInfo
            }
        }
    }
}

if($Action -eq "Collect") {
    if($DatabasesL) {
        Save-IndexFragmentation -SQLInstances "$SQLInstance" -DatabasesL $DatabasesL
        } else {
        Save-IndexFragmentation -SQLInstances "$SQLInstance"
    }
}

if($Action -eq "Rebuild") {
    if($DatabasesL) {
        Step-IndexRebuild -SQLInstances "$SQLInstance" -DatabasesL $DatabasesL
        } else {
        Step-IndexRebuild -SQLInstances "$SQLInstance"
    }
}