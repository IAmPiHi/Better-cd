# 🚀 Better-CD (b-cd)

> A smarter, faster way to navigate directories in Windows PowerShell using a GUI picker and bookmarks.

**Better-CD** replaces the tedious typing of long paths with a native Windows folder picker and a robust bookmarking system. It features a "Strict Mode" to prevent accidental overwrites of your saved locations.

---

## ✨ Features

- **📂 GUI Navigation:** Just type `b-cd` to open a folder picker and jump instantly.
- **🔖 Smart Bookmarks:** Save your favorite project folders with short names.
- **🛡️ Safety First:** Distinct flags for **New** (`-n`) and **Overwrite** (`-o`) actions prevent accidents.
- **📜 Portable:** Install it anywhere; the script automatically registers the path.
- **☁️ Cloud Friendly:** Configuration is saved in your User Home, keeping your bookmarks safe even if you move the executable.

---

## 📦 Installation

### 1. Download & Place
Download and unzip to your preferred location. Note: Do not move this folder after installation.

### 2. Run Installer
1. Open the folder.
2. Right-click `install.ps1` and select **"Run with PowerShell"**.
3. The script will automatically register the `b-cd` command in your PowerShell Profile.

### 3. Restart Terminal
Close and reopen your PowerShell window (or type `. $PROFILE`) to start using it.

---

## 🎮 Usage Guide

### 1. Basic Navigation
Open the folder picker window.
```powershell
b-cd
```

### 2. Jump to a Bookmark
Jump to a saved location immediately.

```powerShell
b-cd project
```

### 3. Create a New Bookmark (-n)
Opens the picker and saves the selected path as "game". Returns an error if "game" already exists.
```powerShell
b-cd -n game
```

### 4. Overwrite a Bookmark (-o)
Updates an existing bookmark with a new path. Returns an error if "game" does not exist (prevents typo creations).
```powerShell
b-cd -o game
```

### 5. Manage Bookmarks
List all saved bookmarks:
```powerShell
b-cd -list
```
Delete a bookmark:
```powerShell
b-cd -d game
```

### 6. Check Version
```powerShell
b-cd -Version
```

## ⚙️ Configuration
Executable: The tool runs from where you installed it.

Bookmarks File: Stored safely in your user directory: %USERPROFILE%\.better-cd\bookmarks.json

## 📝 License
Version: 1.0.0 Author: Chris License: MIT License

Copyright (c) 2025 Chris.
