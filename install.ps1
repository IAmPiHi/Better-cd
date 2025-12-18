# install.ps1

Write-Host "🚀 Installing Better-CD..." -ForegroundColor Cyan

# 1. 設定安裝路徑 (預設裝在使用者家目錄下的 .better-cd)
$installDir = "$HOME\.better-cd"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# 2. 下載或複製執行檔
# (假設使用者是把整個 repo 下載下來，exe 就在旁邊)
# 如果你是發布到網路，這裡可以用 Invoke-WebRequest 去下載
$exeSource = "$PSScriptRoot\better-cd-core.exe" 

if (Test-Path $exeSource) {
    Copy-Item -Path $exeSource -Destination "$installDir\better-cd-core.exe" -Force
    Write-Host "✅ Core executable installed to $installDir" -ForegroundColor Green
} else {
    Write-Host "❌ Error: better-cd-core.exe not found in current folder!" -ForegroundColor Red
    exit
}

# 3. 把函數寫入 PowerShell Profile
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# 定義要寫入的函數內容
$functionScript = @"

# --- Better-CD Start ---
function b-cd {
    `$targetPath = (& "$installDir\better-cd-core.exe").Trim()
    if (-not [string]::IsNullOrWhiteSpace(`$targetPath)) {
        if (Test-Path -LiteralPath "`$targetPath") {
            Set-Location -LiteralPath "`$targetPath"
        }
    }
}
# --- Better-CD End ---
"@

# 檢查是否已經安裝過，避免重複寫入
$currentProfileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if ($currentProfileContent -match "Better-CD Start") {
    Write-Host "⚠️  Better-CD function already exists in your profile. Skipping." -ForegroundColor Yellow
} else {
    Add-Content -Path $profilePath -Value $functionScript
    Write-Host "✅ PowerShell function added to $profilePath" -ForegroundColor Green
}

Write-Host "🎉 Installation Complete! Please restart your terminal or type '. `$PROFILE' to start using 'b-cd'." -ForegroundColor Cyan