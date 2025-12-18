# install.ps1

Write-Host "Installing Better-CD..." -ForegroundColor Cyan

# --- 1. Locate the Executable (Dynamic) ---
$currentDir = $PSScriptRoot
$exePathFound = Join-Path -Path $currentDir -ChildPath "\bin\better-cd-core.exe"

if (-not (Test-Path $exePathFound)) {
    Write-Host "Error: 'better-cd-core.exe' not found in: $currentDir" -ForegroundColor Red
    exit
}

Write-Host "Detected installation path: $currentDir" -ForegroundColor Gray

# --- 2. Prepare Profile Path ---
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# --- 3. Construct the Function ---
$functionScript = @"

# --- Better-CD Start ---
function b-cd {
    [CmdletBinding()] # <--- [NEW] Enforces strict parameter checking
    param (
        [Parameter(Position=0)]
        [string]`$Name = "",
        
        [Parameter(Position=1)]
        [string]`$PathInput = "", 
        
        [switch]`$n,       # GUI New
        [switch]`$o,       # GUI Overwrite
        [switch]`$d,       # Delete
        [switch]`$list,    # List
        [switch]`$in,      # Instant New
        [switch]`$io,      # Instant Overwrite
        [switch]`$Version  # Version
    )

    # --- 1. Strict Parameter Validation ---
    # If the user typed a flag that doesn't exist (like -dsadha), 
    # [CmdletBinding()] above handles the error automatically before code runs.
    
    # Extra Check: If User types 'b-cd -invalid' inside quotes or somehow bypasses,
    # prevent names starting with '-' from being treated as bookmarks.
    if (`$Name.StartsWith("-")) {
        Write-Error "Invalid Parameter or Name: '`$Name' looks like a flag, not a bookmark name."
        return
    }

    # --- 2. Version Check ---
    if (`$Version) {
        Write-Host "Better-CD v1.1.0" -ForegroundColor Cyan
        Write-Host "Author:  Chris" -ForegroundColor Gray
        Write-Host "License: MIT License" -ForegroundColor Gray
        return
    }

    # [INJECTED PATH]
    `$exePath = "$exePathFound"
    
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
    if ((`$n -and `$o) -or (`$in -and `$io)) {
        Write-Host "Error: Conflicting flags used." -ForegroundColor Red
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

    # [Mode 3] Instant Operations (-in / -io)
    if (`$in -or `$io) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) {
             Write-Host "Error: Please specify a bookmark name." -ForegroundColor Red
             return
        }

        `$finalPath = ""
        if (-not [string]::IsNullOrWhiteSpace(`$PathInput)) {
            if (Test-Path `$PathInput) {
                `$finalPath = (Resolve-Path `$PathInput).Path
            } else {
                Write-Host "Error: The path '`$PathInput' does not exist." -ForegroundColor Red
                return
            }
        } else {
            `$finalPath = `$PWD.Path
        }

        # Instant New
        if (`$in) {
            if (`$bookmarks.ContainsKey(`$Name)) {
                Write-Host "Error: Bookmark '`$Name' already exists!" -ForegroundColor Red
                return
            }
            `$bookmarks[`$Name] = `$finalPath
            `$bookmarks | ConvertTo-Json | Set-Content `$configFile
            Write-Host "Created: '`$Name' -> `$finalPath" -ForegroundColor Green
            return
        }

        # Instant Overwrite
        if (`$io) {
            if (-not `$bookmarks.ContainsKey(`$Name)) {
                Write-Host "Error: Bookmark '`$Name' does not exist." -ForegroundColor Red
                return
            }
            `$oldPath = `$bookmarks[`$Name]
            `$bookmarks[`$Name] = `$finalPath
            `$bookmarks | ConvertTo-Json | Set-Content `$configFile
            
            Write-Host "Updated: '`$Name'" -ForegroundColor Yellow
            Write-Host "   From: `$oldPath" -ForegroundColor Gray
            Write-Host "     To: `$finalPath" -ForegroundColor Green
            return
        }
    }

    # [Mode 4] GUI Operations
    `$targetPath = ""
    `$saveMode = `$false
    `$isUpdate = `$false

    # Case A: Jump
    if (-not `$n -and -not `$o) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) {
            # Only open GUI if Name is TRULY empty and no other flags triggered
            Write-Host "Opening folder picker..." -ForegroundColor Cyan
            `$raw = & `$exePath
            if (`$raw) { `$targetPath = `$raw.Trim() }
        } elseif (`$bookmarks.ContainsKey(`$Name)) {
            `$targetPath = `$bookmarks[`$Name]
            Write-Host "Rocket: Jumping to bookmark '`$Name'..." -ForegroundColor Green
        } else {
            Write-Host "Error: Bookmark '`$Name' not found." -ForegroundColor Red
            return
        }
    
    # Case B: New (GUI)
    } elseif (`$n) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "Error: Name required." -ForegroundColor Red; return }
        if (`$bookmarks.ContainsKey(`$Name)) {
            Write-Host "Error: Bookmark '`$Name' already exists!" -ForegroundColor Red
            return
        }
        Write-Host "New: Creating bookmark '`$Name'..." -ForegroundColor Cyan
        `$saveMode = `$true; `$isUpdate = `$false

    # Case C: Overwrite (GUI)
    } elseif (`$o) {
        if ([string]::IsNullOrWhiteSpace(`$Name)) { Write-Host "Error: Name required." -ForegroundColor Red; return }
        if (-not `$bookmarks.ContainsKey(`$Name)) {
            Write-Host "Error: Bookmark '`$Name' not found." -ForegroundColor Red
            return
        }
        Write-Host "Refresh: Overwriting bookmark '`$Name'..." -ForegroundColor Yellow
        `$saveMode = `$true; `$isUpdate = `$true
    }

    # --- Save Execution (GUI) ---
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
    Write-Host "Found existing Better-CD block. Please manually check your profile or delete the old block first." -ForegroundColor Yellow
    Write-Host "   Path: $profilePath" -ForegroundColor Gray
} else {
    Add-Content -Path $profilePath -Value $functionScript
    Write-Host "Function registered! Pointing to: $exePathFound" -ForegroundColor Green
    Write-Host "Installation Complete! Restart your shell and Try: b-cd -version" -ForegroundColor Cyan
}