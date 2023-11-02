# Simple Jellyfin server backup script for windows.. | By Drew Burgess 2023.

$date = Get-Date -Format "MM-dd-yyyy"
$backupname = "JellyFinServer_Backup-${date}"

New-Item -Path "C:\temp" -Name $backupname -ItemType Directory -Force  

If (Test-Path -Path "C:\Program Files\Jellyfin") {
    Copy-Item -Path "C:\Program Files\Jellyfin" -Destination "C:\temp\$backupname\JellyfinProgramFiles" -Verbose -Recurse -Force
}

If (Test-Path -Path "C:\ProgramData\Jellyfin") {
    Copy-Item -Path "C:\ProgramData\Jellyfin" -Destination "C:\temp\$backupname\JellyfinProgramData" -Verbose -Recurse -Force
}

Write-Host "Creating backup [" -NoNewline
Write-Host "${backupname}.zip" -NoNewline -ForegroundColor Green
Write-Host "] to C:\temp"

Compress-Archive -Path "C:\temp\$backupname" -DestinationPath "C:\temp\$backupname.zip" -Verbose -Force
