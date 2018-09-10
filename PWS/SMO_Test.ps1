[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Smo")|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Common")|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Wmi")|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")|Out-Null


[string] $InstanceName = 'MSSQLSERVER'
[string]$ServerName = 'REMSYOUNDM101'
[string]$Environment = 'P'


$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)

[string] $iSQLPSServer = "REMSYOUNDM101" #Replace with the name of your SQL server name
[string] $iSQLPSDatabase = "DPR"   

function Get-Port1 ([String] $pHostName, [String] $pInstanceName) {
    $m = New-Object ('Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer') 'REMSYOUNDM101'
    
    $m.ServerInstances | ForEach-Object { 
        #$port = 
        $m.ServerInstances[$_.Name].ServerProtocols #['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpPort'].Value
    
        #if (!($port)) {$port = $m.ServerInstances[$_.Name].ServerProtocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpDynamicPorts'].Value}
       #$m.Name + '\' + $_.Name + ', ' +
       #$m.ServerInstances[$_.Name].ServerProtocols['Tcp'].IPAddresses['IP1'].IPAddress.IPAddressToString + ':' + $port
    }
    $port
}

function Get-Proto1  ([String] $pHostName, [String] $pInstanceName) {
    $protocol = $null
    $m = New-Object ('Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer') 'REMSYOUNDM101'
    
    $m.ServerInstances | ForEach-Object { 
        $prot = $m.ServerInstances[$_.Name].ServerProtocols #['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpPort'].Value
        foreach ($p in $prot) {
            if($p.IsEnabled) {
                $protocol += $p.Name +','
            }            
        }
    }
    $protocol -replace 
}
function execSQL([String] $pHostName, [String] $pInstanceName, [String] $pSQL, [String] $pTCPPort) {
<#-------------------------------------------------------------------------------------
 This function connects with a SQL Server instance [$pHostName\$pInstanceName,$pTcpPort]
 to execute a SQL query $pSql.
--------------------------------------------------------------------------------------#>
	if ($pInstanceName -eq 'MSSQLSERVER') {
        try {
            Write-Host Invoke-Sqlcmd -Query "$pSQL" -ServerInstance "$pHostName,$pTCPPort" -Database master
            (Invoke-Sqlcmd -Query "$pSQL" -ServerInstance "$pHostName,$pTCPPort" -Database master).Column1
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
<#-------------------------------------------------------------------------------------
 This function connects to the HKLM registry hive of the SQL Server host $pHostName 
 and retrieve the TCP/IP port number that the instance $pInstanceName is listening on. 
-------------------------------------------------------------------------------------#>
	$strTCPPort = ""

	$reg = [WMIClass]"\\$pHostName\root\default:stdRegProv"
	$HKEY_LOCAL_MACHINE = 2147483650

	# Default instance
	if ($pInstanceName -eq 'MSSQLSERVER') {
		#SQL Server 2000 or SQL Server 2005/2008 resides on the same server as SQL Server 2000
		$strKeyPath = "SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp"
		if ($strKeyPath -eq $Null) {
			$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MOSS\MSSQLServer\SuperSocketNetLib\Tcp"
		}
		$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
		if ($strTcpPort) {
			Set-Variable -Name instanceRegPath -Value "SOFTWARE\Microsoft\MSSQLServer\MSSQLServer" -Scope 1
			return $strTcpPort
		}
		
	}
	else {
		#SQL Server 2000 or SQL Server 2005/2008 resides on the same server as SQL Server 2000
		$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp"
		$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
		if ($strTcpPort) {
			Set-Variable -Name instanceRegPath -Value "SOFTWARE\Microsoft\Microsoft SQL Server\$pInstanceName\MSSQLServer" -Scope 1
			return $strTcpPort
		}
	}

	#SQL Server 2005
	for ($i=1; $i -le 50; $i++) {
		$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$i"
		$strInstanceName=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"").svalue
			
		if ($strInstanceName -eq $pInstanceName) {
			$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$i\MSSQLServer\SuperSocketNetLib\tcp\IPAll"
			$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue

			Set-Variable -Name instanceRegPath -Value "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$i\MSSQLServer" -Scope 1
			return $strTcpPort	
		}
	}

	#SQL Server 2008
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		Set-Variable -Name instanceRegPath -Value "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10.$pInstanceName\MSSQLServer" -Scope 1
		return $strTcpPort
	}

	#SQL Server 2012
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL11.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		Set-Variable -Name instanceRegPath -Value "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL11.$pInstanceName\MSSQLServer" -Scope 1
		return $strTcpPort
	}
	
	return ""
}


function getServerNetWorkProtocols([String] $pHostName, [String] $pInstanceName){
<#-------------------------------------------------------------------------------------
 This function connects to the HKLM registry hive of the SQL Server host $pHostName 
 and retrieve the network protocols used by the instance $pInstanceName. 
-------------------------------------------------------------------------------------#>
	$strProtocols = ""

	$reg = [WMIClass]"\\$pHostName\root\default:stdRegProv"
	$HKEY_LOCAL_MACHINE = 2147483650

	$strKeyPath = "$instanceRegPath\SuperSocketNetLib"		
	#SQL Server 2000
	$arrValues=$reg.GetMultiStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"ProtocolList").sValue 
	if ($arrValues) {
		$arrValues | foreach -process { $strProtocols=$strProtocols + $_ + ',' }
		return $strProtocols.Substring(0, $strProtocols.Length-1)
	}
	#SQL Server 2005 or 2008
	else {
		$strKeyPath = "$instanceRegPath\SuperSocketNetLib\Tcp"
		$intEnabled=$reg.GetDWORDValue($HKEY_LOCAL_MACHINE,$strKeyPath,"Enabled").uvalue
		if ($intEnabled) {
			if ($intEnabled -eq 1) { $strProtocols='tcp,' }
				
			$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$instanceNo\MSSQLServer\SuperSocketNetLib\Np"
			$intEnabled=$reg.GetDWORDValue($HKEY_LOCAL_MACHINE,$strKeyPath,"Enabled").uvalue
			if ($intEnabled -eq 1) { $strProtocols=$strProtocols + 'np,' }

			$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$instanceNo\MSSQLServer\SuperSocketNetLib\Sm"
			$intEnabled=$reg.GetDWORDValue($HKEY_LOCAL_MACHINE,$strKeyPath,"Enabled").uvalue
			if ($intEnabled -eq 1) { $strProtocols=$strProtocols + 'sm,' }
				
			$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$instanceNo\MSSQLServer\SuperSocketNetLib\Via"
			$intEnabled=$reg.GetDWORDValue($HKEY_LOCAL_MACHINE,$strKeyPath,"Enabled").uvalue
			if ($intEnabled -eq 1) { $strProtocols=$strProtocols + 'via,' }	

	 		return $strProtocols.Substring(0, $strProtocols.Length-1) 
		}
	}
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

#$tcpPort=(getTcpPort $windowsNetworkName $instanceName)
$tcpPort=(get-Port1 $windowsNetworkName $instanceName)
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

$strQuerySql = "SELECT CASE SUBSTRING(CONVERT(nvarchar, ServerProperty ('ProductVersion')), 1, CHARINDEX('.', convert(nvarchar, ServerProperty('ProductVersion')))-1 ) WHEN '10' THEN '2008' WHEN '9' THEN '2005' WHEN '8' THEN '2000' END"
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