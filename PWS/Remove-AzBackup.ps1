Import-Module Az.Storage

function Remove-ADHCAzBackup {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)] [string] $StorageAccount,
            [Parameter(Mandatory=$true)] [string] $StorageAccountKey,
            [Parameter(Mandatory=$true)] [string] $Container,
            [Parameter(Mandatory=$true)] [string] $BackupType,
            [Parameter(Mandatory=$true)] [string] $RetentionHours
        )
    
        Begin {
            $processStartTime = $(Get-Date) -F "YYYYmmdd"
            $msg = "$processStartTime - Begin removal of expire database backup files of type $($BackupType).`r`n"
            Write-Host("$msg")
        }

        Process {
            $context = New-AzStorageContext -StorageAccountName "$StorageAccount" -StorageAccountKey "$StorageAccountKey"
            [System.DateTimeOffset] $retentionDateTime = (Get-Date).AddHours(- $RetentionHours)
            $blobs = Get-AzStorageBlob -Container "$Container" -blob "*.$BackupType" -Context $context | Where-Object {$_.LastModified -le $retentionDateTime}
            $fileCount = 0

            foreach ($blob in $blobs) {
                $lastModified = ($blob.LastModified).LocalDateTime
                if ((New-TimeSpan -Start "$lastModified" -End (Get-Date)).TotalHours -ge $RetentionHours) {
                    Remove-AzStorageBlob -Blob "$($blob.Name)" -Context $context -Container $Container # -Whatif
                    $fileCount ++
                }
            }
        }

        End {
            $processEndTime = $(Get-Date) -F "YYYYmmdd"
            $duration = New-TimeSpan -Start $processStartTime -End $processEndTime
            $msg = @"
$processEndTime - End removal of expire databse backup files of type $($BackupType) is complete. $fileCount files were removed from storage in $($duration).
"@
            Write-Host("$msg")
        }
}