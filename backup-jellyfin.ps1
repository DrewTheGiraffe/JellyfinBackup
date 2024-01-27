# Simple Jellyfin server backup script for windows.. 
# Source: https://github.com/DrewTheGiraffe/JellyfinBackup/edit/main/backup-jellyfin.ps1

$date = Get-Date -Format "MM-dd-yyyy"
$backupname = "JellyFinServer_Backup-${date}"
$public_backup_path = "${env:USERPROFILE}\Desktop"

# Stop server before backing up to avoid file corruption
Get-Process | Where {$_.ProcessName -like "*jellyfin*"} | Stop-Process -Force

# Check for process existance before running backup...
$verify = (Get-Process | Where {$_.ProcessName -like "*jellyfin*"} | select $_)
If ($null -eq $verify) {

    $DestinationPath = "$public_backup_path\$backupname"

    If (Test-Path $DestinationPath -eq $false) {
        New-Item -Path "${env:USERPROFILE}\Desktop" -Name $backupname -ItemType Directory -Force  
    }
    

    If (Test-Path -Path "C:\Program Files\Jellyfin") {
        Copy-Item -Path "C:\Program Files\Jellyfin" -Destination "$DestinationPath\JellyfinProgramFiles" -Verbose -Recurse -Force
    }

    If (Test-Path -Path "C:\ProgramData\Jellyfin") {
        Copy-Item -Path "C:\ProgramData\Jellyfin" -Destination "$DestinationPath\JellyfinProgramData" -Verbose -Recurse -Force
    }

    If (Test-Path -Path "C:\Users\user1\Documents\mediashare") {
        Copy-Item -Path "C:\Users\user1\Documents\mediashare" -Destination "$DestinationPath\customimages" -Verbose -Recurse -Force

        Clear-Host

        Start-Sleep -Seconds 2

    }

    Compress-Archive -Path "$public_backup_path\$backupname" -DestinationPath "$public_backup_path\$backupname.zip" -Verbose -Force

    Remove-Item -Path "$public_backup_path\$backupname" -Recurse -Force

    Start-Sleep -Milliseconds 100

    Clear-Host

    Write-Host "Created backup [" -NoNewline
    Write-Host "${backupname}.zip" -NoNewline -ForegroundColor Green
    Write-Host "] to $public_backup_path"

    write-Host "`nYou will need to start jellyfin manually." -ForegroundColor Green

}
# start server when backup is finished
If (Test-Path -Path "C:\Program Files\Jellyfin\Server") {
    Start-Process -FilePath "C:\Program Files\Jellyfin\Server" -ArgumentList ".\jellyfin.exe"
}
