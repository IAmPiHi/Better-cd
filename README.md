# Better-CD (`b-cd`)

[![Stars](https://img.shields.io/github/stars/IAmPiHi/Better-cd?style=for-the-badge&logo=github&color=yellow)](https://github.com/IAmPiHi/Better-cd)
[![License](https://img.shields.io/github/license/IAmPiHi/Better-cd?style=for-the-badge&logo=mit&color=blue)](https://github.com/IAmPiHi/Better-cd/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D4?style=for-the-badge&logo=windows)](https://github.com/IAmPiHi/Better-cd)
[![PowerShell](https://img.shields.io/badge/PowerShell-%3E%3D_5.1-blue?style=for-the-badge&logo=powershell)](https://github.com/IAmPiHi/Better-cd)
[![Version](https://img.shields.io/badge/Version-1.5.0-success?style=for-the-badge)](https://github.com/IAmPiHi/Better-cd)

> A smarter directory navigator for Windows PowerShell — combining a native GUI folder picker with a multi-workspace bookmarking system.

Stop typing long paths. With `b-cd`, you jump to any saved location in seconds, or browse visually with a native Windows folder picker. Multiple workspaces let you keep separate bookmark sets for different projects or contexts.

(doc/DEMO.gif)

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Command Reference](#command-reference)
  - [Navigation](#navigation)
  - [Bookmark Management](#bookmark-management)
  - [Instant Mode (No GUI)](#instant-mode-no-gui)
  - [Workspace Management](#workspace-management)
- [How Workspaces Work](#how-workspaces-work)
- [Configuration](#configuration)
- [License](#license)

---

## Features

- **GUI folder picker** — run `b-cd` with no arguments to browse and jump visually
- **Named bookmarks** — save paths with short aliases and jump to them instantly
- **Safe overwrite model** — `-n` (new) and `-o` (overwrite) flags prevent accidental changes
- **Instant mode** — create or update bookmarks from the CLI, no GUI required
- **Multiple workspaces** — separate bookmark collections for different projects or roles
- **Cloud-friendly** — config lives in `%USERPROFILE%\.better-cd`, not next to the executable

---

## Installation

**1. Download and unzip** the release to a permanent location.
> ⚠️ Do not move the folder after installation — the installer registers its current path.

**2. Run the installer** — right-click `install.ps1` and select **Run with PowerShell**.

**3. Reload your profile** — restart PowerShell, or run:
```powershell
. $PROFILE
```

**4. Verify the install:**
```powershell
b-cd -Version
```

> The `src` folder contains only source code and can be deleted after installation.

---

## Quick Start

```powershell
# Open a GUI folder picker and navigate there
b-cd

# Save your current directory as a bookmark named "work"
b-cd -in work

# Jump to that bookmark any time
b-cd work
```

---

## Command Reference

### Navigation

| Command | Description |
|---|---|
| `b-cd` | Open the GUI folder picker and navigate to the selected folder |
| `b-cd <name>` | Jump to a saved bookmark |

### Bookmark Management

| Command | Description |
|---|---|
| `b-cd -list` | List all bookmarks in the current workspace |
| `b-cd -list <workspace>` | Peek at bookmarks in another workspace without switching |
| `b-cd -n <name>` | Open GUI picker and save as a **new** bookmark (errors if name exists) |
| `b-cd -o <name>` | Open GUI picker and **overwrite** an existing bookmark (errors if name doesn't exist) |
| `b-cd -d <name>` | Delete a bookmark |
| `b-cd -rn <old> <new>` | Rename a bookmark |
| `b-cd -clear` | Delete all bookmarks in the current workspace (prompts for confirmation) |

### Instant Mode (No GUI)

Manage bookmarks directly from the command line without opening the folder picker.

| Command | Description |
|---|---|
| `b-cd -in <name>` | Save the **current directory** as a new bookmark |
| `b-cd -in <name> <path>` | Save a **specific path** as a new bookmark |
| `b-cd -io <name>` | Update an existing bookmark to the **current directory** |
| `b-cd -io <name> <path>` | Update an existing bookmark to a **specific path** |

**Examples:**
```powershell
# Bookmark current directory as "proj"
b-cd -in proj

# Bookmark a specific path as "games"
b-cd -in games "D:\Games\SteamLibrary"

# Update "games" to a new path
b-cd -io games "E:\NewLibrary"
```

### Workspace Management

Workspaces are independent sets of bookmarks. Switch between them to keep projects, clients, or contexts cleanly separated.

| Command | Description |
|---|---|
| `b-cd -wlist` | List all workspaces (active workspace marked with `*`) |
| `b-cd -nw <name>` | Create a new workspace |
| `b-cd -sw <name>` | Switch to a workspace |
| `b-cd -rw <new>` | Rename the **current** workspace |
| `b-cd -rw <old> <new>` | Rename a **specific** workspace |
| `b-cd -dw <name>` | Delete a workspace (prompts for confirmation; cannot delete the active one) |

**Example workflow:**
```powershell
b-cd -nw client-a        # Create a workspace for a client
b-cd -sw client-a        # Switch to it
b-cd -in api "C:\Projects\ClientA\api"  # Add bookmarks
b-cd -in docs "C:\Projects\ClientA\docs"

b-cd -nw client-b        # Create another workspace
b-cd -sw client-b        # Switch contexts instantly
```

---

## How Workspaces Work

Each workspace is a separate JSON file stored in `%USERPROFILE%\.better-cd\`. The active workspace is tracked in `_active_profile.txt`. The default workspace is named `bookmarks`.

```
%USERPROFILE%\.better-cd\
├── _active_profile.txt   ← tracks the active workspace
├── bookmarks.json        ← default workspace
├── client-a.json
└── client-b.json
```

---

## Configuration

| Item | Location |
|---|---|
| Bookmark files | `%USERPROFILE%\.better-cd\<workspace>.json` |
| Active workspace tracker | `%USERPROFILE%\.better-cd\_active_profile.txt` |
| PowerShell function | Injected into `$PROFILE` by the installer |
| Core executable | `<install-dir>\bin\better-cd-core.exe` |

---

## License

MIT License — © 2025 Chris
