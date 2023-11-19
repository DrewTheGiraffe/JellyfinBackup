# Simple Jellyfin server backup script for windows.. | By Drew Burgess 2023.

$date = Get-Date -Format "MM-dd-yyyy"
$backupname = "JellyFinServer_Backup-${date}"

If (Test-Path "C:\temp") {
    New-Item -Path "C:\temp" -Name $backupname -ItemType Directory -Force  
}
else {
    New-Item -Path "C:\" -Name "temp" -ItemType Directory -Force
    Start-Sleep -Milliseconds 200
    New-Item -Path "C:\temp" -Name $backupname -ItemType Directory -Force  
}

If (Test-Path -Path "C:\Program Files\Jellyfin") {
    Copy-Item -Path "C:\Program Files\Jellyfin" -Destination "C:\temp\$backupname\JellyfinProgramFiles" -Verbose -Recurse -Force
}

If (Test-Path -Path "C:\ProgramData\Jellyfin") {
    Copy-Item -Path "C:\ProgramData\Jellyfin" -Destination "C:\temp\$backupname\JellyfinProgramData" -Verbose -Recurse -Force
}

Clear-Host

Write-Host "Creating backup [" -NoNewline
Write-Host "${backupname}.zip" -NoNewline -ForegroundColor Green
Write-Host "] to C:\temp"

Start-Sleep -Seconds 2

Compress-Archive -Path "C:\temp\$backupname" -DestinationPath "C:\temp\$backupname.zip" -Verbose -Force

Remove-Item -Path "C:\temp\JellyFinServer_Backup-${date}" -Recurse -Force

start C:\temp
