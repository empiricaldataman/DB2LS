$DataSources = get-content -LiteralPath C:\Users\salomon.young\Documents\VSCODE\DB2LS\PWS\azDataSource.csv|ConvertFrom-String -Delimiter "," -PropertyNames alias, server, environment, resourcegroup
$Subscriptions = get-content -LiteralPath C:\Users\salomon.young\Documents\VSCODE\DB2LS\PWS\azSubscription.csv|ConvertFrom-String -Delimiter "," -PropertyNames name, tenantid, environment

foreach ($subscription in $Subscriptions|WHERE {$_.environment -eq "P"}) {
    $environment = $subscription.environment
    $subscription.name
    Select-AzSubscription -Name $subscription.name -TenantId $subscription.tenantid #-Confirm $false
    foreach ($datasource in ($DataSources|WHERE {$_.environment -eq "P"})) {
        #$datasource.server
        Get-AzSqlDatabase -ServerName $datasource.server -ResourceGroupName $datasource.resourcegroup|Format-Table -Property * -AutoSize
    }
}



#Get storage context
$context = New-AzureStorageContext -ConnectionString "DefaultEndpointsProtocol=https;AccountName=edhccasetrakkerstorage;AccountKey=D//RwUsLXPuIukOsZiph13YINQ37k/47+bgylQAMkbPBCQ2hHVf4NZ91wxDTK6Xa+GmrHaOdqqPURsiZmAAfNA==;EndpointSuffix=core.windows.net"

#Production
#Remove .bak file older than 1 month 
$CleanupTime = [DateTime]::UtcNow.AddMonths(-1)
Get-AzureStorageBlob -Container "edhccasetrakkercontainer" -Context $context | 
Where-Object { $_.LastModified.UtcDateTime -lt $CleanupTime -and $_.BlobType -eq "BlockBlob" -and $_.Name -like "*.bak"} |
Remove-AzureStorageBlob

#Remove .trn files older that 1 day
$CleanupTime = [DateTime]::UtcNow.AddHours(-26)
Get-AzureStorageBlob -Container "edhccasetrakkercontainer" -Context $context | 
Where-Object { $_.LastModified.UtcDateTime -lt $CleanupTime -and $_.BlobType -eq "BlockBlob" -and $_.Name -like "*.trn"} |
Remove-AzureStorageBlob

#Non-prod
#Remove .bak file older than 2 weeks 
$CleanupTime = [DateTime]::UtcNow.AddDays(-14)
Get-AzureStorageBlob -Container "nightly-backup-nprod" -Context $context | 
Where-Object { $_.LastModified.UtcDateTime -lt $CleanupTime -and $_.BlobType -eq "BlockBlob" -and $_.Name -like "*.bak"} |
Remove-AzureStorageBlob




Powershell.exe -Command "& {. 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DBA\Remove-AzBackup.ps1'; Remove-ADHCAzBackup -StorageAccount edhcsql -StorageAccountKey 5o2JyCDAVwBq6ZSLb+3kSKaQ68+g7kmcEQoxh8RjhrsPE06A5DBjUHJtrWrMkN8rnn+Hwtjd89UMEaWeZhHkAA== -Container edhmscuvpwsql01-mssqlserver -BackupType trn -RetentionHours 48}"




select-azsubscription -Name "EHDC Cloud" -TenantId "682e6fb4-6d2b-4adb-b15f-8be9868df7ed"
$a = Get-AzResourceGroup #|WHERE {$_.ResourceGroupName -match "etl"}
foreach ($g in $a) {
 get-azresource -ResourceGroupName $g.ResourceGroupName |SELECT Kind, Location, ResourceName, ResourceGroupName, Type  | Export-Csv -LiteralPath C:\install\ResourceGroup.csv -Append
}