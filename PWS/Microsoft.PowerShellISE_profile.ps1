#if (Get-Module sqlps){Remove-Module -Name sqlps}
#if (Get-Module SQLASCMDLETS) {Remove-Module -Name SQLASCMDLETS}
#if (Get-Module iSQLPS) {Remove-Module -Name 'iSQLPS'}
#if (!(Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) {Add-PSSnapin Quest.ActiveRoles.ADManagement}

Import-Module "sqlps" -DisableNameChecking
Import-Module -Name 'adoLib'
Import-Module -Name 'Agent'
Import-Module -Name 'ShowMbrs'
Import-Module -Name 'SQLMaint'
Import-Module -Name 'SQLServer'
#Import-Module -Name 'iSQLPS'
Import-Module -Name 'ShowUI'
#Import-Module -Name 'Image'
#Import-Module -Name 'PowerBoots'

$host.UI.RawUI.WindowTitle = "Rule your mind or it will rule you."

 
function Prompt {
 "PWS>"
}
 
#Get-Service|WHERE {$_.DisplayName -like 'VMWARE*'}|% {Start-Service $_.Name}

function Get-SYSQLInfo{
<#
	.SYNOPSIS
		Gets general information about the SQL Server instance provided.
		
	.DESCRIPTION
		The Get-SYSQLInfo cmdlet gets general SQL Server information about
		the instance provided.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string[]] $SQLInstances
    )

    PROCESS{
        foreach ($SQLInstance in $SQLInstances) {
            $srv = Get-SqlServer -sqlserver $SQLInstance
            $props = @{'ServerName'=$srv.name;
                       'InstanceName'=$srv.InstanceName;
                       'Product'=$srv.Information.Product +" "+ $srv.Information.Edition;
                       'Version'=$srv.Information.VersionString;
                       'Memory(MB)'=$([math]::round(($srv.Configuration.MaxServerMemory.ConfigValue/1MB),2));
                       'ServerCollaton'=$srv.Information.Collation;
                       'IsClustered'=$srv.Information.IsClustered;
                       'DefaultLanguage'=$srv.Information.Language;
                       'ServiceAccount'=$srv.Information.ServiceAccount}
            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
    }
}

function Get-SYNIC {
	[CmdletBinding()]
	param (
    	[parameter(ValueFromPipeline = $true,
    	ValueFromPipelineByPropertyName = $true)]
    	[string]$computername = "$env:COMPUTERNAME",
    	[int]$device
	)

	PROCESS {
		if ($device) {
			$nics = Get-WmiObject -Class Win32_NetWorkAdapter -ComputerName $computername -Filter "DeviceID = '$device'"
		}
		else {
			$nics = Get-WmiObject -Class Win32_NetWorkAdapter -ComputerName $computername
	}
	
		$nics | select NetConnectionID, Name, DeviceID, AdapterType, AutoSense, GUID, Index, Installed, InterfaceIndex, MACAddress, Manufacturer, MaxSpeed, NetConnectionStatus, NetEnabled, PhysicalAdapter, ProductName, ServiceName, Speed
	}
}

function Get-SYADUserInfo() {
<#
	.SYNOPSIS
		Gets general AD information about the user name provided.

	.DESCRIPTION
		 Queries the Active Directory server and displays general information
		 for user name(s) provided.
#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[String[]]$userName,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false)]
        [String[]]$memberOf)
    
    	foreach ($ADUser in $userName){
    		$a = Get-QADUser $ADUser
    		$data = @{
        		'UserName'=$a.LogonName
        		'FullName'= $a.DisplayName
        		'Email'= $a.Email
        		'Title'= $a.Title
        		'AccountExires'= $a.AccountExpirationStatus
        		'AccountDissabled'= $a.AccountIsDisabled
        		'AccountExpired'= $a.AccountIsExpired
        		'AccountIsLocked'= $a.AccountIsLockedOut
        		'LastLogon'= $a.LastLogon
        		'ModifiedOn'= $a.ModificationDate
        		'PWDExpiresOn'= $a.PasswordExpires
        		'PWDLastChange'= $a.PasswordLastSet
        		'PWDStatus'= $a.PasswordStatus
        	}
		Write-Output (New-Object -TypeName PSObject -Property $data)
	}
}
                          
function Format-SYOSTime([String] $osTime){
	return $osTime.SUBSTRING(0, 4) + "-" + $osTime.SUBSTRING(4, 2) + '-' + $osTime.SUBSTRING(6, 2) + ' ' + $osTime.SUBSTRING(8, 2) + ':' + $osTime.SUBSTRING(10, 2)
}

function Get-SYOSInfo{
    param ($serverName = $env:COMPUTERNAME )
    $os = Get-WMIObject -computerName $serverName -class Win32_OperatingSystem
    $data = @{
        'CountryCode' = $os.CountryCode
        'LastBootUpTime' = (Format-SYOSTime $os.LastBootUpTime)
        'Locale' = $os.Locale
        'OSName' = $os.Name
        'OSVersion' = $os.Version
        'OSSPMajor' = $os.ServicePackMajorVersion
        'OSSPMinor' = $os.ServicePackMinorVersion
        'OSBuildNumber' = $os.BuildNumber
        'OSInstallDate' = (Format-SYOSTime $os.InstallDate)
        'VisibleMemory' = $os.TotalVisibleMemorySize
        'VirtualMemory' = $os.TotalVirtualMemorySize
        'PageFile' = $os.SizeStoredInPagingFiles
    }
    Write-Output (New-Object -TypeName PSObject -Property $data)
}

function Get-SYMPInfo{
<#
	.SYNOPSIS
		Displays information about mount points.

	.DESCRIPTION
		 Queries the Win32_MountPoint & Win32_Volume classes to display general information about
         mount points.  Use this fuction to discover and detail volume mount points on a 
         specified Windows server.
    
    .EXAMPLE
        Get-SYMPInfo "COMPUT856056SJ9"
        
    .NOTES
        This function is a modified version of one written by Eric Woodford.
#>
    param(
    [Parameter(Mandatory = $true)] [string[]] $oHostList,
    [Parameter(Mandatory = $false,ValueFromPipeline=$True)] $oCred ##########
	)
	)
    
	foreach ($oHost in $oHostList) {
    	$sHostName = $oHost
        $MountPoints = Get-WmiObject -Class "Win32_MountPoint" -ComputerName $sHostName
        $Volumes = Get-WmiObject -Class "Win32_Volume" -ComputerName $sHostName | SELECT Name, FreeSpace, Capacity

        foreach ($MP in $MountPoints) {
            $MP.Directory = $MP.Directory.Replace("\\","\")        

            foreach ($v in $Volumes) {
                $vshort = $v.Name.Substring(0,$v.Name.Length-1 )
                $vshort = """$vshort""" 
                if ($mp.Directory.Contains($vshort)) { 
                    $Record = New-Object -Typename System.Object
                    $DestFolder = "Microsoft.PowerShell.Core\FileSystem::\\"+ $sHostName + "\"+ $v.Name.Substring(0,$v.Name.Length-1 ).Replace(":","$")
                    $colItems = (Get-ChildItem $destfolder -Recurse | WHERE {$_.Length -ne $null} | Measure-Object -Property Length -sum)

                    if($colItems.Sum -eq $null) {
                        $fsize = 0
                    } 
                    else {
                        $fsize = $colItems.sum
                    }

                    $TotFolderSize = $fsize + $v.Freespace
                    $percFree = "{0:P0}" -f ( $v.Freespace/$TotFolderSize)
                    $Record | foreach {
                        Add-Member -In $_ -MemberType NoteProperty -name HostName -Value $sHostName
                        Add-Member -In $_ -memberType NoteProperty -Name MountPoint -Value $V.name
                        Add-Member -In $_ -memberType NoteProperty -Name SizeGB -Value $([math]::round(($v.Capacity/1GB),2))
                        Add-Member -In $_ -memberType NoteProperty -Name FileSize -Value $([math]::round(($fsize/1GB),2))
                        Add-Member -In $_ -memberType NoteProperty -Name FreeGB -Value $([math]::round(($v.FreeSpace/1GB),2))
                        Add-Member -In $_ -memberType NoteProperty -Name PercentFree -Value $([math]::round(((([float]$v.Freespace/[float]$TotFolderSize) * 100)),2)) -PassThru } #|Format-Table -Auto -HideTableHeaders
                }
            }
        }
    }
}

function Get-SYSTGInfo{
<#
	.SYNOPSIS
		Displays information about local storage.

	.DESCRIPTION
		Queries the Win32_LogicalDisk class to display general information about local storage.  
         
    .EXAMPLE
        Get-SYSTGInfo "COMPUT856056SJ9"
#>
    param(
		[Parameter(Mandatory = $true)] [array]$oHostList = "$env:COMPUTERNAME"
	)
	
    
	foreach ($oHost in $oHostList) {
		if ($oHostList.Count -gt 1){
            $sHostName = $oHost.Name
        } else {
            $sHostName = $oHostList
        }
        
        if (Test-Connection $sHostName) {
    		$oDrives = Get-WmiObject -computername "$sHostName" Win32_LogicalDisk -filter "DriveType=3" | foreach{
    			add-member -in $_ -membertype NoteProperty -Name HostName -Value $sHostName
                add-member -in $_ -membertype NoteProperty -Name UsageDT -Value $((Get-Date).ToString("yyyy-MM-dd"))
    			add-member -in $_ -membertype NoteProperty -Name SizeGB -Value $([math]::round(($_.Size/1GB),2))
    			add-member -in $_ -membertype NoteProperty -Name FreeGB -Value $([math]::round(($_.FreeSpace/1GB),2))
    			add-member -in $_ -membertype NoteProperty -Name PercentFree -Value $([math]::round((([float]$_.FreeSpace/[float]$_.Size) * 100),2)) -passThru}

            $oDrives|SELECT HostName, DeviceID, VolumeName, SizeGB, FreeGB, PercentFree
        }            
	}
}

function Test-SYSQLService ([string] $hostName, [string] $instanceName){
<#
 This function will check for the host to be availabe and the MS SQL service 
 to be running.
              
 EXAMPLE: Test-SYSQLService -hostName <servername> -instanceName <MSSQLSERVER|instanceName>
#>
    
    try {
        If($instanceName -eq "MSSQLSERVER" -or $instanceName -eq ""){
            $result = Get-Service -ComputerName $hostName|WHERE {$_.Name -like "MSSQLSERVER" -and $_.Status -eq "Running"}
        }
        Else{
            $result = Get-Service -ComputerName $hostName|WHERE {$_.Name -like "MSSQL`$$instanceName" -and $_.Status -eq "Running"}
        }
    }
    catch{
        [bool] $result = $false
        #$Error[0].Exception
        #$Error[0].InvocationInfo
    }
    [bool] $result
}

function Get-SYLogs {
<#
	.SYNOPSIS
		Displays entries from a system log file.

	.DESCRIPTION
		Returns entries from a specific log file that matches the $Type and $LogFile parameters.  
         
    .EXAMPLE
        Get-SYLogs "DALLAP856056SJ9"
        Get-SYLogs "DALLAP856056SJ9" | SELECT @{Name="TimeGenerated";Expression={$_.ConvertToDateTime($_.TimeGenerated)}}, LogFile, Message, Sourcename -Last 10|Format-Table -AutoSize
        Get-SYLogs "DALLAP856056SJ9" -LogFile "System" -ExludeSource "Guardium_STAP" -FromDate (Get-Date).AddDays(-3) | SELECT @{Name="TimeGenerated";Expression={$_.ConvertToDateTime($_.TimeGenerated)}}, LogFile, Message, Sourcename -Last 150|Format-Table -AutoSize
        
#>
    param (
        [Parameter(Mandatory = $false)] $HostName = "$env:COMPUTERNAME",
        [Parameter(Mandatory = $false)] [string] $LogFile = 'Application',
        [Parameter(Mandatory = $false)] [string] $Type = 'Error',
        [Parameter(Mandatory = $false)] [string] $ExcludeSource,
        [Parameter(Mandatory = $false)] [string] $ExcludeMessage,
        [Parameter(Mandatory = $false)] [datetime] $FromDate = (Get-Date).AddDays(-2)
    )
    
    if ($ExcludeSource -eq $null){
        $LogEvents = Get-WmiObject -ComputerName $HostName -Class Win32_NTLogEvent -Filter "LogFile='$LogFile' and Type='$Type' and TimeGenerated>='$FromDate'"
    }
    else {
        $LogEvents = Get-WmiObject -ComputerName $HostName -Class Win32_NTLogEvent -Filter "LogFile='$LogFile' and Type='$Type' and TimeGenerated>='$FromDate' and SourceName!='$ExcludeSource'"
    }

    $LogEvents
}

function Get-SystemInfo {
    param($ComputerName = $env:COMPUTERNAME)
    $header = 'Host Name','OS Name','OS Version','OS Manufacturer','OS Configuration','OS Build Type','Registered Owner','Registered Organization','Product ID','Original Install Date','System Boot Time','System Manufacturer','System Model','System Type','Processor(s)','BIOS Version','Windows Directory','System Directory','Boot Device','System Locale','Input Locale','Time Zone','Total Physical Memory','Available Physical Memory','Virtual Memory: Max Size','Virtual Memory: Available','Virtual Memory: In Use','Page File Location(s)','Domain','Logon Server','Hotfix(s)','Network Card(s)'
    systeminfo.exe /FO CSV /S $ComputerName | Select-Object -Skip 1 | ConvertFrom-Csv -Header $header
}

function Get-Software{
<#
	.SYNOPSIS
		Displays installed software from registry.

	.DESCRIPTION
		Queries the 32 and 64-bit locations for sofware installed for all users. 
    
  .EXAMPLE
    Get-Software
    This is the default and it will display all installed software. 

	.EXAMPLE
		Get-Software -DisplayName *SQL*
    This example provides a pattern for the DisplayName parameter which is used for filtering the result.
        
  .NOTES
    Published on PowerTip of the Day by Idera.com
#>
    param  (
        [string] $DisplayName='*',
 
        [string] $UninstallString='*'
    )
 
    $keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
   
    Get-ItemProperty -Path $keys |
      Where-Object { $_.DisplayName } |
      Select-Object -Property DisplayName, DisplayVersion, UninstallString |
      Where-Object { $_.DisplayName -like $DisplayName } |
      Where-Object { $_.UninstallString -like $UninstallString }
}
 
function Invoke-Sqlcmd2 { 
<# 
.SYNOPSIS 
Runs a T-SQL script. 
.DESCRIPTION 
Runs a T-SQL script. Invoke-Sqlcmd2 only returns message output, such as the output of PRINT statements when -verbose parameter is specified.
Paramaterized queries are supported. 
.INPUTS 
None 
    You cannot pipe objects to Invoke-Sqlcmd2 
.OUTPUTS 
   System.Data.DataTable 
.EXAMPLE 
Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -Query "SELECT login_time AS 'StartTime' FROM sysprocesses WHERE spid = 1" 
This example connects to a named instance of the Database Engine on a computer and runs a basic T-SQL query. 
StartTime 
----------- 
2010-08-12 21:21:03.593 
.EXAMPLE 
Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -InputFile "C:\MyFolder\tsqlscript.sql" | Out-File -filePath "C:\MyFolder\tsqlscript.rpt" 
This example reads a file containing T-SQL statements, runs the file, and writes the output to another file. 
.EXAMPLE 
Invoke-Sqlcmd2  -ServerInstance "MyComputer\MyInstance" -Query "PRINT 'hello world'" -Verbose 
This example uses the PowerShell -Verbose parameter to return the message output of the PRINT command. 
VERBOSE: hello world 
.NOTES 
Version History 
v1.0   - Chad Miller - Initial release 
v1.1   - Chad Miller - Fixed Issue with connection closing 
v1.2   - Chad Miller - Added inputfile, SQL auth support, connectiontimeout and output message handling. Updated help documentation 
v1.3   - Chad Miller - Added As parameter to control DataSet, DataTable or array of DataRow Output type 
v1.4   - Justin Dearing <zippy1981 _at_ gmail.com> - Added the ability to pass parameters to the query.
v1.4.1 - Paul Bryson <atamido _at_ gmail.com> - Added fix to check for null values in parameterized queries and replace with [DBNull]
#>
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$false)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$false)] [string]$Query, 
    [Parameter(Position=3, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=5, Mandatory=$false)] [Int32]$QueryTimeout=600, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$ConnectionTimeout=15, 
    [Parameter(Position=7, Mandatory=$false)] [ValidateScript({test-path $_})] [string]$InputFile, 
    [Parameter(Position=8, Mandatory=$false)] [ValidateSet("DataSet", "DataTable", "DataRow")] [string]$As="DataRow" ,
    [Parameter(Position=9, Mandatory=$false)] [System.Collections.IDictionary]$SqlParameters 
    ) 
 
    if ($InputFile) 
    { 
        $filePath = $(resolve-path $InputFile).path 
        $Query =  [System.IO.File]::ReadAllText("$filePath") 
    } 
 
    $conn=new-object System.Data.SqlClient.SQLConnection 
      
    if ($Username) 
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout } 
 
    $conn.ConnectionString=$ConnectionString 
     
    #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
    if ($PSBoundParameters.Verbose) 
    { 
        $conn.FireInfoMessageEventOnUserErrors=$true 
        $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"} 
        $conn.add_InfoMessage($handler) 
    } 
     
    $conn.Open() 
    $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn) 
    $cmd.CommandTimeout=$QueryTimeout
    if ($SqlParameters -ne $null)
    {
        $SqlParameters.GetEnumerator() |
            ForEach-Object {
                If ($_.Value -ne $null)
                { $cmd.Parameters.AddWithValue($_.Key, $_.Value) }
                Else
                { $cmd.Parameters.AddWithValue($_.Key, [DBNull]::Value) }
            } > $null
    }
    
    $ds=New-Object system.Data.DataSet 
    $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
    [void]$da.fill($ds) 
    $conn.Close() 
    switch ($As) 
    { 
        'DataSet'   { Write-Output ($ds) } 
        'DataTable' { Write-Output ($ds.Tables) } 
        'DataRow'   { Write-Output ($ds.Tables[0]) } 
    } 
 
}

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

function Out-DataTable{
<#
.SYNOPSIS
Creates a DataTable for an object
.DESCRIPTION
Creates a DataTable based on an objects properties.
.INPUTS
Object
    Any object can be piped to Out-DataTable
.OUTPUTS
   System.Data.DataTable
.EXAMPLE
$dt = Get-Alias | Out-DataTable
This example creates a DataTable from the properties of Get-Alias and assigns output to $dt variable
.NOTES
Adapted from script by Marc van Orsouw see link
Version History
v1.0  - Chad Miller - Initial Release
v1.1  - Chad Miller - Fixed Issue with Properties
v1.2  - Chad Miller - Added setting column datatype by property as suggested by emp0
v1.3  - Chad Miller - Corrected issue with setting datatype on empty properties
v1.4  - Chad Miller - Corrected issue with DBNull
.LINK
http://thepowershellguy.com/blogs/posh/archive/2007/01/21/powershell-gui-scripblock-monitor-script.aspx
#>
    [CmdletBinding()]
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject)

    Begin
    {
        $dt = new-object Data.datatable  
        $First = $true 
    }
    Process
    {
        foreach ($object in $InputObject)
        {
            $DR = $DT.NewRow()  
            foreach($property in $object.PsObject.get_properties())
            {  
                if ($first)
                {  
                    $Col =  new-object Data.DataColumn  
                    $Col.ColumnName = $property.Name.ToString()  
                    if ($property.value)
                    {
                        if ($property.value -isnot [System.DBNull])
                        { $Col.DataType = $property.value.gettype() }
                    }
                    $DT.Columns.Add($Col)
                }  
                if ($property.IsArray)
                { $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1 }  
                else { $DR.Item($property.Name) = $property.value }  
            }  
            $DT.Rows.Add($DR)  
            $First = $false
        }
    } 
     
    End
    {
        Write-Output @(,($dt))
    }

}

function Set-SqlAlias {
    [Cmdletbinding()]

    param (
        [parameter(Mandatory=$true)] [string] $SqlInstanceName,
        [parameter(Mandatory=$true)] [string] $Alias,
        [parameter(Mandatory=$true)] [string] $Port,
        [parameter(Mandatory=$false)] $OverWrite = 0
    )

    BEGIN{
        $x64 = "HKLM:SOFTWARE\Wow6432Node\Microsoft\MSSQLServer\Client\ConnectTo"

        if (!(Test-Path "$x64")) {
            New-Item -Path "$x64" -Name "ConnectTo"
        }
    }

    PROCESS{
        if($OverWrite -ne 0){
            Get-Item -path "$x64"|Remove-ItemProperty -Name "$Alias"|Out-Null
        }

        if (!(Get-Item -Path "$x64").GetValue("$Alias")) {
            New-ItemProperty -Path "$x64" -Name "$Alias" -PropertyType String -Value $("DBMSSOCN,{0},{1}" -f "$SqlInstanceName", $Port)|Out-Null
        }
    }
}

function Export-DBUser { 
<#
	.SYNOPSIS
		Captures database users information.

	.DESCRIPTION
		Captures database user metadata and inserts the result into DBA database. 
         
  .EXAMPLE
    Export-DBUser -InstanceName "M1"
#>
param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string[]] $SQLInstances
      )

    BEGIN {
        if ($MANAGEMENT_INSTANCE -eq $null) {. ManagementEnvironment.ps1}
        Import-Module "SQLPS" -DisableNameChecking -WarningAction:SilentlyContinue
        $dStartDateTime = Get-Date
        $DateString = "{0:yyyyMMdd}" -f $dStartDateTime
    }

    PROCESS {
        foreach ($SQLInstance in $SQLInstances) {
		    if ($SQLInstances.Count -gt 1){
                $sSQLInstanceName = $SQLInstance
            } else {
                $sSQLInstanceName = $SQLInstances
            }
        
            #if (Test-Connection -ComputerName $sHostName -Count 1) { ###TODO/FIX###
                $InstanceObject = New-Object "Microsoft.SqlServer.Management.SMO.Server" "$sSQLInstanceName"
                $oDatabases = $InstanceObject.Databases

                $qSQLCollectData = @"
SELECT CAST(GETDATE() AS [date]) [load_date]
     , @@SERVERNAME [instance_name]
     , DB_NAME() [database_name]
     , dp.name [user_name]
     , dp.[type] [user_type]
     , dp.create_date
     , dp.modify_date
     , dp.default_schema_name [default_schema]
     , sp.name [login_name]
     , COALESCE(dpr.name, '') [database_role]
  FROM [sys].[database_principals] dp
  LEFT JOIN [sys].[database_role_members] drm ON dp.principal_id = drm.member_principal_id
  LEFT JOIN [sys].[database_principals] dpr ON drm.role_principal_id = dpr.principal_id
  LEFT JOIN [master].[sys].[server_principals] sp ON dp.sid = sp.sid
 WHERE dp.type IN ('G','S','U')
"@

                Write-host("Data capture start time $dStartDateTime.")
                Write-Host("")

                foreach ($oDatabase in $oDatabases) {
                    $SQLDBSource = $oDatabase.Name
                    $oData = Invoke-Sqlcmd -ServerInstance "$sSQLInstanceName" -Database $SQLDBSource -Query "$qSQLCollectData"

                    if ($oData -ne $null){
                        Write-DataTable -ServerInstance "DA" -Database "DBA" -TableName "dbo.Users" -Data $oData
                        Write-Host $oData.Count "records inserted for $SQLDBSource."
                    }
                }
            #} ###TODO/FIX###
        }
    }
    
    END {
        "Data captured in $(((Get-Date).Subtract($dStartDateTime)).ToString())."
    }
}

function Export-SQLLogin { 
<#
	.SYNOPSIS
		Captures SQL logins information.

	.DESCRIPTION
		Captures SQL Server login metadata and inserts the result into DBA database. 
         
  .EXAMPLE
    Export-SQLLogin -InstanceName "M1"
#>
param (
        [Parameter(Mandatory=$true)] [string] $InstanceName
      )

if ($MANAGEMENT_INSTANCE -eq $null) {. ManagementEnvironment.ps1}

    Import-Module "SQLPS" -DisableNameChecking -WarningAction:SilentlyContinue

    $dStartDateTime = Get-Date
    $DateString = "{0:yyyyMMdd}" -f $dStartDateTime

    $qSQLCollectData = @"
SELECT CAST(GETDATE() AS [date]) [load_date]
     , @@SERVERNAME [instance_name]
     , A.[name] [login_name]
     , A.[type] [login_type]
     , A.is_disabled [disabled]
     , A.create_date
     , A.modify_date
     , COALESCE(D.default_database_name,'') [default_database]
     , CONVERT(CHAR(1),ISNULL(B.is_policy_checked,0))
     , CONVERT(CHAR(1),ISNULL(B.is_expiration_checked,0))
     , ISNULL(D.[name],'')
  FROM sys.server_principals A
  LEFT JOIN sys.sql_logins B ON A.principal_id = B.principal_id
  LEFT JOIN sys.server_role_members C ON A.principal_id = C.member_principal_id
  LEFT JOIN sys.server_principals D ON C.role_principal_id = D.principal_id
 WHERE A.[type] IN ('G','S','U')
   AND A.[name] IS NOT NULL
"@

    Write-host("Data capture start time $dStartDateTime.")
    Write-Host("")

   # foreach ($oDatabase in $oDatabases) {
        #$SQLDBSource = $oDatabase.Name
        $oData = Invoke-Sqlcmd -ServerInstance "$InstanceName" -Database "master" -Query "$qSQLCollectData"

        if ($oData -ne $null){
            Write-DataTable -ServerInstance "DA" -Database "DBA" -TableName "dbo.Logins" -Data $oData
            Write-Host $oData.Count "records inserted for $SQLDBSource."
        }
    #}

    "Data captured in $(((Get-Date).Subtract($dStartDateTime)).ToString())."
}


function Invoke-Robocopy {
    param ([string] [Parameter(Mandatory)] $Source,
           [string] [Parameter(Mandatory)] $Destination,
           [string] $Filter,
           [switch] $Recurse,
           [switch] $Open)

    if ($Recurse) {
        $DoRecurse = '/S'
    }
    else {
        $DoRecurse = ''
    }

    robocopy $Source $Destination $Filter $DoRecurse /R:0

    if ($Open) {
        exploers.exe $Destination
    }
}
