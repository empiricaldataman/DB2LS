$SQLInst = 'YOGA920'

$HostName = $SQLInst.Split("\")
if ($HostName.Count -eq 1) {
	$sqlcntr = 'SQLServer'
	$boxnm = $SQLInst
	}
	else {
	$sqlcntr = 'MSSQL$' + $HostName[1]
	$boxnm = $HostName[0]
}

$cfg = @"
\Processor(_Total)\% Processor Time
\Memory\Available MBytes
\Paging File(_Total)\% Usage
\PhysicalDisk(_Total)\Avg. Disk sec/Read
\PhysicalDisk(_Total)\Avg. Disk sec/Write
\System\Processor Queue Length
\$($sqlcntr):Access Methods\Forwarded Records/sec
\$($sqlcntr):Access Methods\Page Splits/sec
\$($sqlcntr):Buffer Manager\Buffer cache hit ratio
\$($sqlcntr):Buffer Manager\Page life expectancy
\$($sqlcntr):Databases(_Total)\Log Growths
\$($sqlcntr):General Statistics\Processes blocked
\$($sqlcntr):SQL Statistics\Batch Requests/sec
\$($sqlcntr):SQL Statistics\SQL Compilations/sec
\$($sqlcntr):SQL Statistics\SQL Re-Compilations/sec
"@
$cfg | out-file "C:\SQLPerf\$boxnm.config" -encoding ASCII

logman create counter SQLPerf -f bincirc -max 100 -si 60 --v -o "C:\SQLPerf\$boxnm" -cf "C:\SQLPerf\$boxnm.config"
logman start SQLPerf
logman stop SQLPerf