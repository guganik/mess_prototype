$ErrorActionPreference = "Stop"

$baseUrl = "https://googa-talk.ru/downloads"
$certUrl = "$baseUrl/Googa.cer"
$appInstallerUrl = "$baseUrl/mess_prototype.appinstaller"

$tempDir = Join-Path $env:TEMP "GoogaInstaller"

Write-Host "Подготовка установки Googa..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

$certPath = Join-Path $tempDir "Googa.cer"
$appInstallerPath = Join-Path $tempDir "mess_prototype.appinstaller"

Write-Host "Скачивание сертификата..."
Invoke-WebRequest -Uri $certUrl -OutFile $certPath

Write-Host "Установка сертификата..."
Import-Certificate `
    -FilePath $certPath `
    -CertStoreLocation "Cert:\CurrentUser\TrustedPeople" | Out-Null

Write-Host "Скачивание установщика..."
Invoke-WebRequest -Uri $appInstallerUrl -OutFile $appInstallerPath

Write-Host "Запуск установки Googa..." -ForegroundColor Green

Start-Process $appInstallerPath

Write-Host ""
Write-Host "Готово. Откроется установщик Googa." -ForegroundColor Green
Read-Host "Нажмите Enter для выхода"