param ($computer = $(throw "Please specity a computer name."), $path = $(throw "Please specify a registry path."))

if ($path -match '^HKLM:\\(.*)') {
    $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
} elseif ($path -match '^HKCU:\\(.*)') {
    $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('CurrentUser', $computer)
} else {
    Write-Error ("Please specify a fully-qualified registry path " + "(i.e.: HKLM:\Software) of the registry key to open.")
    return
}

$key = $baseKey.OpensubKey($matches[1])

foreach($subkeyName in $key.GetSubKeyNames()){
    $subkey = $key.OpensubKey($subkeyName)
    $returnObject = [PSObject] $subkey
    $returnObject | Add-Member NoteProperty PsChildName $subkeyName
    $returnObject | Add-Member NoteProperty Property $subkey.GetValueNames()

    $returnObject
    $subkey.close()
}

$key.close()
$baseKey.Close()