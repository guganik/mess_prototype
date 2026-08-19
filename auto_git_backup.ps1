Set-Location $PSScriptRoot

# Проверяем, есть ли изменения
$status = git status --porcelain

if (-not $status) {
    exit 0
}

# Добавляем изменения
git add .

# Время для сообщения commit
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Создаём commit
git commit -m "Auto backup: $timestamp"

# Отправляем на GitHub
git push