# Simple Jellyfin server backup script for windows.. 
# Source: https://github.com/DrewTheGiraffe/JellyfinBackup/edit/main/backup-jellyfin.ps1

$date = Get-Date -Format "MM-dd-yyyy"
$backupname = "JellyFinServer_Backup-${date}"
$public_backup_path = "${env:USERPROFILE}\Desktop"

# Stop server before backing up to avoid file corruption
If (-not(Get-service -Name "*Jellyfin*")) {
    Get-Process | Where {$_.ProcessName -like "*jellyfin*"} | Stop-Process -Force
} # Handle Jellyfin as a service not a process fix 2/15/2025
else {
    If (-not(Get-Service -Name "*Jellyfin*").Status -eq "Stopped") {
        Stop-Service -Name "*Jellyfin*" -Force -verbose
    }
}
# Check for process existance before running backup...
If (-not(Get-service -Name "*Jellyfin*"))) {
    $verified = (-not(Get-Process | Where {$_.ProcessName -like "*jellyfin*"} | select $_))
}
else {
     If (-not(Get-Service -Name "*Jellyfin*").Status -eq "Stopped") { 
        Write-Host "Waiting for Jellyfin Service to stop" -NoNewline
        Stop-Service -Name "*Jellyfin*" -Force
        Do {
            Start-Sleep -Seconds 1
            Write-Host "." -NoNewline
        }
        Until ((Get-Service -Name "*Jellyfin*").Status -eq "Stopped")
        $verified = $true
    }
}
If ($verified) {

    $DestinationPath = "$public_backup_path\$backupname"

    If (Test-Path $DestinationPath -eq $false) {
        New-Item -Path "$env:USERPROFILE\Desktop" -Name $backupname -ItemType Directory -Force  
    }
    
    If (Test-Path -Path "$env:PROGRAMFILES\Jellyfin") {
        Copy-Item -Path "$env:PROGRAMFILES\Jellyfin" -Destination "$DestinationPath\JellyfinProgramFiles" -Verbose -Recurse -Force
    }

    If (Test-Path -Path "$env:PROGRAMDATA\Jellyfin") {
        Copy-Item -Path "$env:PROGRAMDATA\Jellyfin" -Destination "$DestinationPath\JellyfinProgramData" -Verbose -Recurse -Force
    }

    If (-not(Test-Path -Path "$env:USERPROFILE\Documents\mediashare")) {
        $prompt = Read-Host -Prompt "Do you want to backup any MediaArt / custom logos?(Y/n)"
        If ($prompt -eq "Y" -or $prompt -eq "y") {
            $path = Read-Host "Enter Full path to Folder containing images(eg. C:\Users\user\Documents\media_art)"
            If (-not(Test-Path -Path $path) { Write-Host "Invalid path : $path" -NoNewline; Write-Host "Skipping for now..." }
            else { Copy-Item -Path "$path" -Destination "$DestinationPath\customimages" -ErrorAction SilentlyContinue -Verbose -Recurse -Force }
        }
    }
    # Are you copying me ;) ?
    else {
        Copy-Item -Path "$env:USERPROFILE\Documents\mediashare" -Destination "$DestinationPath\customimages" -ErrorAction SilentlyContinue -Verbose -Recurse -Force
    }

    Compress-Archive -Path "$public_backup_path\$backupname" -DestinationPath "$public_backup_path\$backupname.zip" -Verbose -Force

    Remove-Item -Path "$public_backup_path\$backupname" -Recurse -Force

    Start-Sleep -Milliseconds 100

    Clear-Host

    Write-Host "Created backup [" -NoNewline
    Write-Host "${backupname}.zip" -NoNewline -ForegroundColor Green
    Write-Host "] to $public_backup_path"

}
# start server when backup is finished
If (-not(Get-Service -Name "*Jellyfin*" -Erroraction Ignore)) {
    If (Test-Path -Path "C:\Program Files\Jellyfin\Server") {
        Start-Process -FilePath "C:\Program Files\Jellyfin\Server" -ArgumentList ".\jellyfin.exe"
    }
}
else {
    Start-Service -Name "*Jellyfin*" -Force -Verbose
}
