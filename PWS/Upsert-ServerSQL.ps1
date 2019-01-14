[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null


<#----------------------------------------------------------------------------------
        NAME: Upsert-ServerSQL.ps1
       EMAIL: saleyoun@hotmail.com
 DESCRIPTION: This script adds a ServerSQL record into inventory. If the record
              already exists, then this script updates the existing ServerSQL record.
              
     EXAMPLE: Upsert-ServerSQL -InstanceName "MSSQLSERVER" -ServerName "POWERPC" -Environment "P"
     ------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR ASSUMES NO RESPONSIBILITY FOR ANYTHING, including the 
  destruction of personal property, creating singularities, making deep fried chicken,
  causing your toilet to explode, making your animals spin around like mad, causing 
  hair loss, killing your buzz or ANYTHING else that can be thought up.
------------------------------------------------------------------------------------#>
# Initialize parameters 
#param ( 
#	[switch]$help,
	[string]$InstanceName = 'MSSQLSERVER' #{}, # Name of the SQL Server instance to add into inventory. For a default instance, it is MSSQLSERVER.
	[string]$ServerName = 'YOGA920' #{}, # Name of the SQL Server host. 	
	[string]$Environment = 'P' #{} # Status of the SQL Server instance. Possible values include D, Q, P, U and R.
#    )

$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)

#. "$scriptRoot\iSQLPSCommon.ps1"
[string] $iSQLPSServer = "YOGA920" #Replace with the name of your SQL server name
[string] $iSQLPSDatabase = "iSQLPS"   


function execSQL([String] $pHostName, [String] $pInstanceName, [String] $pSQL, [String] $pTCPPort) {
<#-------------------------------------------------------------------------------------
 This function connects with a SQL Server instance [$pHostName\$pInstanceName,$pTcpPort]
 to execute a SQL query $pSql.
--------------------------------------------------------------------------------------#>
	if ($pInstanceName -eq 'MSSQLSERVER') {
        try {
            Write-Host Invoke-Sqlcmd -Query "$pSQL" -ServerInstance "$pHostName,$pTCPPort" -Database master
            (Invoke-Sqlcmd -Query "$pSQL" -ServerInstance "$pHostName" -Database master).Column1
            }
        catch {
            Write-Host "The execution of $pSQL has failed!"
            break;
            }
	}
	else {
        try {
            (Invoke-Sqlcmd -Query "$pSQL" -ServerInstance "$pHostName\$pInstanceName" -Database master).Column1
            }
        catch {
            Write-Host "The execution of $pSQL has failed!"
            }
	}
}

function getTcpPort([String] $pHostName, [String] $pInstanceName) {
    $m = New-Object ('Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer') "$pHostName"
    
    $m.ServerInstances | ForEach-Object { 
       $port = $m.ServerInstances[$_.Name].ServerProtocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpPort'].Value
       if (!($port)) {$port = $m.ServerInstances[$_.Name].ServerProtocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpDynamicPorts'].Value}
       }
       $port
}


function getServerNetWorkProtocols([String] $pHostName, [String] $pInstanceName){
	$m = New-Object ('Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer') "$pHostName"
    
    $m.ServerInstances | ForEach-Object { 
	   $protocols = $m.ServerInstances[$_.Name].ServerProtocols
	   foreach ($protocol in $protocols) {
			if($protocol.IsEnabled) {
				$p += $protocol.Name +','
			}
	   }
    }
    $p -replace ",$"
}


function getStartupParameters([String] $pHostName, [String] $pInstanceName){
<#-------------------------------------------------------------------------------------
 This function connects to the HKLM registry hive of the SQL Server host $pHostName 
 and retrieve the startup parameters used by the instance $pInstanceName. 
-------------------------------------------------------------------------------------#>
    $reg = [WMIClass]"\\$pHostName\root\default:stdRegProv"
	$HKEY_LOCAL_MACHINE = 2147483650

	$strKeyPath = "$instanceRegPath\Parameters"
	$arrValues=$reg.EnumValues($HKEY_LOCAL_MACHINE,$strKeyPath).sNames
	
	#SQL Server 2000
	if ($arrValues) {
		for ($i=0; $i -lt $arrValues.Length; $i++) {
			$strParameters=$strParameters + $reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,$arrValues[$i]).svalue + ";"
		}
		#Write-Host $strParameters
		return $strParameters
	}

	#SQL Server 2005
	for ($i=1; $i -le 50; $i++) {
		$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$i"
		$strInstanceName=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"").svalue
			
		if ($strInstanceName -eq $pInstanceName) {
			$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$i\MSSQLServer\Parameters"
			$arrValues=$reg.EnumValues($HKEY_LOCAL_MACHINE,$strKeyPath).sNames

			if ($arrValues) {
				for ($i=0; $i -lt $arrValues.Length; $i++) {
					$strParameters=$strParameters + $reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,$arrValues[$i]).svalue + ";"
				}
				return $strParameters
			}
		}	
	}

	#SQL Server 2008
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10.$pInstanceName\MSSQLServer\Parameters"
	$arrValues=$reg.EnumValues($HKEY_LOCAL_MACHINE,$strKeyPath).sNames
	
	if ($arrValues) {
		for ($i=0; $i -lt $arrValues.Length; $i++) {
			$strParameters=$strParameters + $reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,$arrValues[$i]).svalue + ";"
		}
		return $strParameters
	}
}

# Main Program 
[String] $strUpsertSql = ""
[String] $instanceRegPath = '' # Registry path for the instance

if ( $help ) {
	"Usage: Upsert-Server -serverName <string[]> <<-hostName <string[]>|-clusterName <string[]>> -status <string[]>"
	exit 0
}

if ( $instanceName.Length -eq 0 ) {
	"Please enter an instance name."

	if ($instanceName -ieq 'mssqlserver') {
		$instanceName = 'MSSQLSERVER'
	}
        exit 1
}

if ( $Environment -notmatch '^D|Q|P|U|R|I$' ) {
	"The status is invalid. Please enter D, Q, P, U or R."
        exit 1
}

[String] $sqlNetworkName = ""
[String] $windowsNetworkName = ""

if ($ServerName.Length -gt 0) {
	$sqlNetworkName = $ServerName
	$windowsNetworkName = $ServerName
}

$tcpPort=(getTcpPort $windowsNetworkName $instanceName)
# If tcpPort is not available, the server or the host doesn't exist.
if ($tcpPort -eq "") {
	"Tcp port is not found. Please check the server name and the host/cluster name."	
	exit 2
}


if ($ServerName.Length -gt 0) {
	$strUpsertSql = $strUpsertSql + "EXEC UpsertServerSQL '$instanceName', '$Environment', '$ServerName', '$tcpPort', "
}

if ($InstanceName -notmatch "MSSQLSERVER") { $ServerName = "$ServerName\$InstanceName"}

$oServer = Get-SQLServer -sqlserver $ServerName

$strUpsertSql = $strUpsertSql + "'" + (getServerNetWorkProtocols $windowsNetworkName $instanceName) + "', "

$strQuerySql = "SELECT CASE SUBSTRING(CONVERT(nvarchar, ServerProperty ('ProductVersion')), 1, CHARINDEX('.', convert(nvarchar, ServerProperty('ProductVersion')))-1 ) WHEN '11' THEN '2012' WHEN '12' THEN '2014' WHEN '13' THEN '2016' WHEN '14' THEN '2017' WHEN '10' THEN '2008' WHEN '9' THEN '2005' WHEN '8' THEN '2000' WHEN '7' THEN '7.0' END"
$strUpsertSql = $strUpsertSql + "'" + (execSQL $sqlNetworkName $instanceName $strQuerySql $tcpPort) + "', "

$strUpsertSql = $strUpsertSql + "'" + $oServer.Edition + "', "

$strUpsertSql = $strUpsertSql + "'" + $oServer.VersionString + "', "

$strUpsertSql = $strUpsertSql + "'" + $oServer.ProductLevel + "', "

$strParameters =(getStartupParameters $windowsNetworkName $instanceName)
$strUpsertSql = $strUpsertSql + "'" + $strParameters + "', "

$strUpsertSql = $strUpsertSql + "'" + $oServer.MasterDBPath + "', "

$strUpsertSql = $strUpsertSql + "'" + $oServer.ErrorLogPath + "', "

$strUpsertSql = $strUpsertSql + "'" + $oServer.Collation + "', "

$strUpsertSql = $strUpsertSql + $oServer.Configuration.MinServerMemory.RunValue + ", "

$strUpsertSql = $strUpsertSql + $oServer.Configuration.MaxServerMemory.RunValue + ", "

if($oServer.Configuration.AweEnabled.RunValue -eq $null) {$AweEnabled = 0} else {$AweEnabled = 1}
$strUpsertSql = $strUpsertSql + $AweEnabled + ", "

$strUpsertSql = $strUpsertSql + $oServer.Configuration.UserConnections.RunValue + " "

$strUpsertSql = $strUpsertSql + ", 1;"
$strUpsertSql

#Invoke-Sqlcmd -Query $strUpsertSql -ServerInstance $iSQLPSServer -Database $iSQLPSDatabase