$folders = @("SQLDB","USERDB1","TRANSLOG","TEMPDB","BACKUPS\FullDBBackups")

foreach ($folder in $folders) {
    if (!(Test-Path -Path "D:\DEFAULT_$folder")) {
        New-Item -Path "D:\DEFAULT_$folder\" -ItemType Directory -Force
    }
}