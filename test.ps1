$ErrorActionPreference = "Stop"

$baseUrl = "https://googa-talk.ru/downloads"

$certUrl = "$baseUrl/Googa.cer"
$appInstallerUrl = "$baseUrl/mess_prototype.appinstaller"

$tempDir = Join-Path $env:TEMP "GoogaInstaller"

New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

$certPath = Join-Path $tempDir "Googa.cer"
$appInstallerPath = Join-Path $tempDir "mess_prototype.appinstaller"

Write-Host "Downloading certificate..."
Invoke-WebRequest -Uri $certUrl -OutFile $certPath

Write-Host "Installing certificate..."
Import-Certificate `
    -FilePath $certPath `
    -CertStoreLocation "Cert:\LocalMachine\TrustedPeople"

Write-Host "Downloading installer..."
Invoke-WebRequest -Uri $appInstallerUrl -OutFile $appInstallerPath

Write-Host "Starting Googa installer..."
Start-Process -FilePath $appInstallerPath

Write-Host ""
Write-Host "Done." -ForegroundColor Green

Read-Host "Press Enter to exit"