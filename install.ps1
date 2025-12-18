# install.ps1

Write-Host "Installing Better-CD..." -ForegroundColor Cyan

# --- 1. Locate the Executable (Dynamic) ---

$currentDir = $PSScriptRoot


$exePathFound = Join-Path -Path $currentDir -ChildPath "\bin\better-cd-core.exe"


if (-not (Test-Path $exePathFound)) {
    Write-Host "Error: 'better-cd-core.exe' not found in: $currentDir" -ForegroundColor Red
    Write-Host "Please ensure the .exe is in the same folder as this script." -ForegroundColor Gray
    exit
}

Write-Host "Detected installation path: $currentDir" -ForegroundColor Gray

# --- 2. Prepare Profile Path ---
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}


$functionScript = @"

# --- Better-CD Start ---
function b-cd {
    param (
        [string]`$Name = "",
        [switch]`$n,  # New
        [switch]`$o,  # Overwrite
        [switch]`$d,  # Delete
        [switch]`$list, # List
        [switch]`$Version  # <--- [NEW] Version Flag
    )
    if (`$Version) {
        Write-Host "Better-CD v1.0.0" -ForegroundColor Cyan
        Write-Host "Author:  Chris" -ForegroundColor Gray
        Write-Host "License: MIT License" -ForegroundColor Gray
        return
    }

    # [INJECTED PATH] This points to where you installed the tool
    `$exePath = "$exePathFound"
    
    # Config stays in User Home (so bookmarks survive if you move the exe)
    `$configDir = "`$HOME\.better-cd"
    `$configFile = "`$configDir\bookmarks.json"

    # --- Initialization ---
    if (-not (Test-Path `$configDir)) { New-Item -ItemType Directory -Path `$configDir | Out-Null }
    
    `$bookmarks = @{}
    if (Test-Path `$configFile) {
        try {
            `$content = Get-Content `$configFile -Raw
            if (-not [string]::IsNullOrWhiteSpace(`$content)) {
                `$jsonObj = `$content | ConvertFrom-Json
                if (`$jsonObj) {
                    foreach (`$prop in `$jsonObj.PSObject.Properties) {
                        `$bookmarks[`$prop.Name] = `$prop.Value
                    }
                }
            }
        } catch {
            Write-Host "Warning: Could not read bookmarks. Starting fresh." -ForegroundColor Yellow
        }
    }

    # --- Safety Checks ---
    if (`$n -and `$o) {
        Write-Host "Error: Cannot use '-n' and '-o' together." -ForegroundColor Red
        return
    }

    # --- Logic ---

    # [Mode 1] Delete
    if (`$d) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) {
            Write-Host "Error: Specify a name to delete." -ForegroundColor Red
            return
        }
        if (`$bookmarks.ContainsKey(`$Name)) {
            `$bookmarks.Remove(`$Name)
            `$bookmarks | ConvertTo-Json | Set-Content `$configFile
            Write-Host "Trash: Bookmark '`$Name' deleted." -ForegroundColor Yellow
        } else {
            Write-Host "Warning: Bookmark '`$Name' not found." -ForegroundColor Red
        }
        return
    }

    # [Mode 2] List
    if (`$list) {
        if (`$bookmarks.Count -eq 0) {
            Write-Host "Empty: No bookmarks saved yet." -ForegroundColor Red
        } else {
            Write-Host "--- Saved Bookmarks ---" -ForegroundColor Cyan
            `$bookmarks.GetEnumerator() | Format-Table -AutoSize
        }
        return
    }

    # [Mode 3] Jump / New / Overwrite
    `$targetPath = ""
    `$saveMode = `$false
    `$isUpdate = `$false

    # Case A: Jump
    if (-not `$n -and -not `$o) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) {
            Write-Host "Opening folder picker..." -ForegroundColor Cyan
            `$raw = & `$exePath
            if (`$raw) { `$targetPath = `$raw.Trim() }
        } elseif (`$bookmarks.ContainsKey(`$Name)) {
            `$targetPath = `$bookmarks[`$Name]
            Write-Host "Rocket: Jumping to bookmark '`$Name'..." -ForegroundColor Green
        } else {
            Write-Host "Error: Bookmark '`$Name' not found." -ForegroundColor Red
            Write-Host "Tips: Use '-n' for new, '-o' for overwrite." -ForegroundColor Yellow
            return
        }
    
    # Case B: New
    } elseif (`$n) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "Error: Name required." -ForegroundColor Red; return }
        if (`$bookmarks.ContainsKey(`$Name)) {
            Write-Host "Error: Bookmark '`$Name' already exists!" -ForegroundColor Red
            return
        }
        Write-Host "New: Creating bookmark '`$Name'..." -ForegroundColor Cyan
        `$saveMode = `$true; `$isUpdate = `$false

    # Case C: Overwrite
    } elseif (`$o) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "Error: Name required." -ForegroundColor Red; return }
        if (-not `$bookmarks.ContainsKey(`$Name)) {
            Write-Host "Error: Bookmark '`$Name' not found." -ForegroundColor Red
            return
        }
        Write-Host "Refresh: Overwriting bookmark '`$Name'..." -ForegroundColor Yellow
        `$saveMode = `$true; `$isUpdate = `$true
    }

    # --- Save Execution ---
    if (`$saveMode) {
        `$raw = & `$exePath
        if (`$raw) {
            `$picked = `$raw.Trim()
            if (-not [string]::IsNullOrWhiteSpace(`$picked)) {
                `$targetPath = `$picked
                `$oldPath = ""; if (`$isUpdate) { `$oldPath = `$bookmarks[`$Name] }
                
                `$bookmarks[`$Name] = `$targetPath
                `$bookmarks | ConvertTo-Json | Set-Content `$configFile
                
                if (`$isUpdate) {
                    Write-Host "Updated: '`$Name'" -ForegroundColor Yellow
                    Write-Host "   From: `$oldPath" -ForegroundColor Gray
                    Write-Host "     To: `$targetPath" -ForegroundColor Green
                } else {
                    Write-Host "Created: '`$Name' -> `$targetPath" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "Action Cancelled." -ForegroundColor Gray
            `$targetPath = ""
        }
    }

    # --- Jump Execution ---
    if (-not [string]::IsNullOrWhiteSpace(`$targetPath)) {
        if (Test-Path -LiteralPath "`$targetPath") {
            Set-Location -LiteralPath "`$targetPath"
        } else {
            Write-Host "Error: Path '`$targetPath' not found!" -ForegroundColor Red
        }
    }
}
# --- Better-CD End ---
"@

# --- 4. Write to Profile ---

$currentProfile = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if ($currentProfile -match "Better-CD Start") {
    Write-Host "Better-CD function already found in profile." -ForegroundColor Yellow
    Write-Host "To update logic or path, please delete the old 'b-cd' block in your profile manually." -ForegroundColor Gray
} else {
    Add-Content -Path $profilePath -Value $functionScript
    Write-Host "Function registered! Pointing to: $exePathFound" -ForegroundColor Green
    Write-Host "Installation Complete! Restart terminal to use 'b-cd'." -ForegroundColor Cyan
}
