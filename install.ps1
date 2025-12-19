# install.ps1

Write-Host "[INSTALL] Installing Better-CD..." -ForegroundColor Cyan

# --- 1. Locate the Executable (Dynamic) ---
$currentDir = $PSScriptRoot
$exePathFound = Join-Path -Path $currentDir -ChildPath "\bin\better-cd-core.exe"

if (-not (Test-Path $exePathFound)) {
    Write-Host "[ERROR] 'better-cd-core.exe' not found in: $currentDir" -ForegroundColor Red
    exit
}

Write-Host "[INFO] Detected installation path: $currentDir" -ForegroundColor Gray

# --- 2. Prepare Profile Path ---
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# --- 3. Construct the Function ---
$functionScript = @"

# --- Better-CD Start ---
function b-cd {
    [CmdletBinding()] 
    param (
        [Parameter(Position=0)]
        [string]`$Name = "",
        
        [Parameter(Position=1)]
        [string]`$PathInput = "", 

        [string]`$Name2 = "", 
        
        [switch]`$n,        
        [switch]`$o,        
        [switch]`$d,        
        [switch]`$rn,       
        [switch]`$list,     
        [switch]`$in,       
        [switch]`$io,       
        [switch]`$clear,    
        [switch]`$sw,       
        [switch]`$nw,       
        [switch]`$dw,       
        [switch]`$rw,       
        [switch]`$wlist,    
        [switch]`$Version   
    )

    # --- Version Check ---
    if (`$Version) {
        Write-Host "Better-CD v1.4.0" -ForegroundColor Cyan
        Write-Host "Author:  Chris" -ForegroundColor Gray
        Write-Host "License: MIT License" -ForegroundColor Gray
        return
    }

    # [INJECTED PATH]
    `$exePath = "$exePathFound"
    `$configDir = "`$HOME\.better-cd"
    
    # --- Initialization ---
    if (-not (Test-Path `$configDir)) { New-Item -ItemType Directory -Path `$configDir | Out-Null }

    # [Profile System]
    `$activeProfileFile = "`$configDir\_active_profile.txt"
    
    # Default to 'bookmarks' if no active profile is set
    if (-not (Test-Path `$activeProfileFile)) { Set-Content `$activeProfileFile "bookmarks" }
    
    `$currentProfileName = (Get-Content `$activeProfileFile -Raw).Trim()
    if ([string]::IsNullOrWhiteSpace(`$currentProfileName)) { `$currentProfileName = "bookmarks" }

    `$currentJsonPath = "`$configDir\`$currentProfileName.json"

    # --- Helper Function: Load Bookmarks from a specific file ---
    function Get-BookmarksFromFile(`$path) {
        `$b = @{}
        if (Test-Path `$path) {
            try {
                `$c = Get-Content `$path -Raw
                if (-not [string]::IsNullOrWhiteSpace(`$c)) {
                    `$j = `$c | ConvertFrom-Json
                    if (`$j) {
                        foreach (`$p in `$j.PSObject.Properties) { `$b[`$p.Name] = `$p.Value }
                    }
                }
            } catch {}
        }
        return `$b
    }

    # --- Helper Function: Save Bookmarks to current file ---
    function Save-Bookmarks(`$data) {
        `$data | ConvertTo-Json | Set-Content `$currentJsonPath
    }

    # --- Load CURRENT Bookmarks (Needed for display/logic) ---
    `$bookmarks = Get-BookmarksFromFile `$currentJsonPath

    # --- Mode: Workspace Operations ---
    
    # 1. List Workspaces (-wlist)
    if (`$wlist) {
        Write-Host "--- Available Profiles (JSON) ---" -ForegroundColor Cyan
        `$files = Get-ChildItem -Path `$configDir -Filter "*.json"
        if (`$files.Count -eq 0) {
            Write-Host "[INFO] No profiles found." -ForegroundColor Red
        } else {
            foreach (`$f in `$files) {
                `$baseName = `$f.BaseName
                if (`$baseName -eq `$currentProfileName) {
                     Write-Host " * `$baseName (Active)" -ForegroundColor Green
                } else {
                     Write-Host "   `$baseName" -ForegroundColor Gray
                }
            }
        }
        return
    }

    # 2. New Workspace (-nw)
    if (`$nw) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "[ERROR] Specify a name for the new profile." -ForegroundColor Red; return }
        `$targetFile = "`$configDir\`$Name.json"
        if (Test-Path `$targetFile) {
            Write-Host "[ERROR] Profile '`$Name' already exists." -ForegroundColor Red
        } else {
            "{}" | Set-Content `$targetFile
            Write-Host "[SUCCESS] Profile '`$Name' created." -ForegroundColor Green
            Write-Host "Tip: Use 'b-cd -sw `$Name' to switch to it." -ForegroundColor Gray
        }
        return
    }

    # 3. Switch Workspace (-sw)
    if (`$sw) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "[ERROR] Specify a profile name to switch to." -ForegroundColor Red; return }
        `$targetFile = "`$configDir\`$Name.json"
        if (-not (Test-Path `$targetFile)) {
            Write-Host "[ERROR] Profile '`$Name' does not exist." -ForegroundColor Red
        } else {
            Set-Content `$activeProfileFile `$Name
            Write-Host "[SWITCH] Active profile: '`$Name'" -ForegroundColor Green
            
            # Show list of the new profile
            `$newB = Get-BookmarksFromFile `$targetFile
            if (`$newB.Count -gt 0) {
                Write-Host "--- Bookmarks in '`$Name' ---" -ForegroundColor Cyan
                `$newB.GetEnumerator() | Format-Table -AutoSize
            } else {
                Write-Host "[INFO] This profile is empty." -ForegroundColor Yellow
            }
        }
        return
    }

    if (`$rw) {
        `$src = ""
        `$dst = ""
        `$srcFile = ""

        if (-not [string]::IsNullOrWhiteSpace(`$Name) -and (-not [string]::IsNullOrWhiteSpace(`$PathInput) -or -not [string]::IsNullOrWhiteSpace(`$Name2))) {
            `$src = `$Name
            `$dst = if (-not [string]::IsNullOrWhiteSpace(`$Name2)) { `$Name2 } else { `$PathInput }
            `$srcFile = "`$configDir\`$src.json"
        } elseif (-not [string]::IsNullOrWhiteSpace(`$Name)) {
            `$src = `$currentProfileName
            `$dst = `$Name
            `$srcFile = `$currentJsonPath
        } else {
            Write-Host "[ERROR] Usage: b-cd -rw [old] new" -ForegroundColor Red
            return
        }

        if (-not (Test-Path `$srcFile)) {
            Write-Host "[ERROR] Source '`$src' not found." -ForegroundColor Red
            return
        }

        `$dstFile = "`$configDir\`$dst.json"
        if (Test-Path `$dstFile) {
            Write-Host "[ERROR] Name '`$dst' already exists." -ForegroundColor Red
            return
        }

        Write-Host "--- Workspace Rename ---" -ForegroundColor Yellow
        Write-Host "From: `$src" -ForegroundColor Gray
        Write-Host "  To: `$dst" -ForegroundColor Cyan
        
        `$confirm = Read-Host "Type 'v' to confirm"
        if (`$confirm -eq "v") {
            try {
                Move-Item -Path `$srcFile -Destination `$dstFile -Force
                if (`$src -eq `$currentProfileName) {
                    Set-Content `$activeProfileFile `$dst
                }
                Write-Host "[SUCCESS] Renamed to '`$dst'." -ForegroundColor Green
            } catch {
                Write-Host "[ERROR] Failed: `$(`$_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "Cancelled." -ForegroundColor Gray
        }
        return
    }
    
    # 5. Delete Workspace (-dw)
    if (`$dw) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "[ERROR] Specify a profile name to delete." -ForegroundColor Red; return }
        `$targetFile = "`$configDir\`$Name.json"
        
        if (`$Name -eq `$currentProfileName) {
            Write-Host "[ERROR] Cannot delete the currently active profile." -ForegroundColor Red
            Write-Host "Tip: Switch to another profile first." -ForegroundColor Gray
            return
        }

        if (-not (Test-Path `$targetFile)) {
            Write-Host "[ERROR] Profile '`$Name' does not exist." -ForegroundColor Red
            return
        }

        # Load content to show user what they are deleting
        `$delB = Get-BookmarksFromFile `$targetFile
        Write-Host "--- Deleting Profile: `$Name ---" -ForegroundColor Red
        if (`$delB.Count -gt 0) {
            `$delB.GetEnumerator() | Format-Table -AutoSize
        } else {
            Write-Host "(Empty Profile)" -ForegroundColor Gray
        }
        
        `$confirm = Read-Host "Are you sure? This cannot be undone. Type 'v' to confirm"
        if (`$confirm -eq "v") {
            Remove-Item `$targetFile -Force
            Write-Host "[DELETE] Profile '`$Name' deleted." -ForegroundColor Yellow
        } else {
            Write-Host "Cancelled." -ForegroundColor Gray
        }
        return
    }

    # --- Standard Operations ---

    # [Mode] List (-list)
    if (`$list) {
        `$targetListName = `$currentProfileName
        `$targetListObj = `$bookmarks

        if (-not [string]::IsNullOrWhiteSpace(`$Name)) {
            # User wants to peek at another list
            `$peekFile = "`$configDir\`$Name.json"
            if (Test-Path `$peekFile) {
                `$targetListName = `$Name
                `$targetListObj = Get-BookmarksFromFile `$peekFile
            } else {
                Write-Host "[ERROR] Profile '`$Name' not found." -ForegroundColor Red
                return
            }
        }

        if (`$targetListObj.Count -eq 0) {
            Write-Host "[INFO] Profile '`$targetListName' is empty." -ForegroundColor Yellow
        } else {
            Write-Host "--- Bookmarks (`$targetListName) ---" -ForegroundColor Cyan
            `$targetListObj.GetEnumerator() | Format-Table -AutoSize
        }
        return
    }

    # [Mode] Clear All (-clear)
    if (`$clear) {
        if (`$bookmarks.Count -eq 0) {
            Write-Host "[INFO] Current list is already empty." -ForegroundColor Gray
            return
        }
        Write-Host "--- WARNING: CLEARING ALL BOOKMARKS ---" -ForegroundColor Red
        Write-Host "Current Profile: `$currentProfileName" -ForegroundColor Yellow
        `$bookmarks.GetEnumerator() | Format-Table -AutoSize
        
        `$confirm = Read-Host "Type 'v' to confirm deletion of ALL bookmarks above"
        if (`$confirm -eq "v") {
            `$bookmarks = @{}
            Save-Bookmarks `$bookmarks
            Write-Host "[SUCCESS] All bookmarks cleared." -ForegroundColor Green
        } else {
            Write-Host "Cancelled." -ForegroundColor Gray
        }
        return
    }

    # [Mode] Rename Bookmark (-rn)
    if (`$rn) {
        if ([string]::IsNullOrWhiteSpace(`$Name) -or [string]::IsNullOrWhiteSpace(`$PathInput)) {
            Write-Host "[ERROR] Usage is 'b-cd -rn <old> <new>'" -ForegroundColor Red
            return
        }
        if (-not `$bookmarks.ContainsKey(`$Name)) { Write-Host "[ERROR] Bookmark '`$Name' not found." -ForegroundColor Red; return }
        if (`$bookmarks.ContainsKey(`$PathInput)) { Write-Host "[ERROR] Name '`$PathInput' already taken." -ForegroundColor Red; return }

        `$path = `$bookmarks[`$Name]
        Write-Host "Rename: '`$Name' -> '`$PathInput'" -ForegroundColor Yellow
        Write-Host "Target: `$path" -ForegroundColor Gray
        
        if ((Read-Host "Type 'v' to confirm") -eq "v") {
            `$bookmarks[`$PathInput] = `$path
            `$bookmarks.Remove(`$Name)
            Save-Bookmarks `$bookmarks
            Write-Host "[SUCCESS] Renamed." -ForegroundColor Green
        } else {
            Write-Host "Cancelled." -ForegroundColor Gray
        }
        return
    }

    # [Mode] Delete Bookmark (-d)
    if (`$d) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "[ERROR] Name required." -ForegroundColor Red; return }
        if (`$bookmarks.ContainsKey(`$Name)) {
            `$bookmarks.Remove(`$Name)
            Save-Bookmarks `$bookmarks
            Write-Host "[DELETE] Bookmark '`$Name' removed." -ForegroundColor Yellow
        } else {
            Write-Host "[ERROR] Bookmark '`$Name' not found." -ForegroundColor Red
        }
        return
    }

    # [Mode] Instant Operations (-in / -io)
    if (`$in -or `$io) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "[ERROR] Name required." -ForegroundColor Red; return }
        
        `$finalPath = if (-not [string]::IsNullOrWhiteSpace(`$PathInput)) { (Resolve-Path `$PathInput).Path } else { `$PWD.Path }
        if (-not (Test-Path `$finalPath)) { Write-Host "[ERROR] Path not found." -ForegroundColor Red; return }

        if (`$in) {
            if (`$bookmarks.ContainsKey(`$Name)) { Write-Host "[ERROR] '`$Name' exists." -ForegroundColor Red; return }
            `$bookmarks[`$Name] = `$finalPath
            Save-Bookmarks `$bookmarks
            Write-Host "[CREATED] '`$Name' -> `$finalPath" -ForegroundColor Green
        } elseif (`$io) {
            if (-not `$bookmarks.ContainsKey(`$Name)) { Write-Host "[ERROR] '`$Name' not found." -ForegroundColor Red; return }
            `$old = `$bookmarks[`$Name]
            `$bookmarks[`$Name] = `$finalPath
            Save-Bookmarks `$bookmarks
            Write-Host "[UPDATED] '`$Name' (`$old -> `$finalPath)" -ForegroundColor Yellow
        }
        return
    }

    # [Mode] GUI Operations ($n, $o, Jump)
    `$targetPath = ""
    `$saveMode = `$false
    `$isUpdate = `$false

    if (-not `$n -and -not `$o) {
        # Jump
        if ([string]::IsNullOrWhiteSpace(`$Name)) {
            Write-Host "Opening folder picker..." -ForegroundColor Cyan
            `$raw = & `$exePath; if (`$raw) { `$targetPath = `$raw.Trim() }
        } elseif (`$bookmarks.ContainsKey(`$Name)) {
            `$targetPath = `$bookmarks[`$Name]
            Write-Host "[JUMP] Jumping to '`$Name'..." -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Bookmark '`$Name' not found." -ForegroundColor Red
            return
        }
    } elseif (`$n) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "[ERROR] Name required." -ForegroundColor Red; return }
        if (`$bookmarks.ContainsKey(`$Name)) { Write-Host "[ERROR] Exists." -ForegroundColor Red; return }
        Write-Host "[NEW] Pick a folder for '`$Name'..." -ForegroundColor Cyan
        `$saveMode = `$true; `$isUpdate = `$false
    } elseif (`$o) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "[ERROR] Name required." -ForegroundColor Red; return }
        if (-not `$bookmarks.ContainsKey(`$Name)) { Write-Host "[ERROR] Not found." -ForegroundColor Red; return }
        Write-Host "[OVERWRITE] Pick new folder for '`$Name'..." -ForegroundColor Yellow
        `$saveMode = `$true; `$isUpdate = `$true
    }

    if (`$saveMode) {
        `$raw = & `$exePath
        if (`$raw -and (`$picked = `$raw.Trim())) {
            `$targetPath = `$picked
            `$bookmarks[`$Name] = `$targetPath
            Save-Bookmarks `$bookmarks
            Write-Host "[SAVED] '`$Name' -> `$targetPath" -ForegroundColor Green
        } else {
            Write-Host "Cancelled." -ForegroundColor Gray; `$targetPath = ""
        }
    }

    if (-not [string]::IsNullOrWhiteSpace(`$targetPath)) {
        if (Test-Path -LiteralPath `$targetPath) { Set-Location -LiteralPath `$targetPath }
        else { Write-Host "[ERROR] Path not found." -ForegroundColor Red }
    }
}
# --- Better-CD End ---
"@

# --- 4. Write to Profile ---
$currentProfile = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

if ($currentProfile -match "Better-CD Start") {
    Write-Host "[WARN] Found existing Better-CD block. Please manually check your profile or delete the old block first." -ForegroundColor Yellow
    Write-Host "       Path: $profilePath" -ForegroundColor Gray
} else {
    Add-Content -Path $profilePath -Value $functionScript
    Write-Host "[SUCCESS] Function registered! Pointing to: $exePathFound" -ForegroundColor Green
    Write-Host "[DONE] Installation Complete! Try: b-cd -rw newname" -ForegroundColor Cyan
}