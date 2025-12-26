# 🚀 Better-CD for Windows (b-cd)

> **Eliminate the friction of directory navigation.** Better-CD provides a seamless bridge between the command line and the Windows GUI, allowing for instantaneous path jumping via bookmarks and a native folder picker.

---

## ✨ Key Features

- **📂 GUI-Enhanced Navigation:** Invoke `b-cd` to trigger a native Windows folder picker for visual directory selection.
- **🔖 Persistent Bookmarking:** Assign intuitive aliases to your most-frequented project directories.
- **🛡️ Safeguarded Operations:** Integrated "Strict Mode" utilizes distinct flags for **Creation** (`-n`) and **Modification** (`-o`) to prevent accidental bookmark overwrites.
- **📜 Portable & Lightweight:** A zero-dependency tool that persists your configuration within the `%USERPROFILE%` directory, ensuring portability across environments.
- **🗂️ Workspace Isolation:** Organize bookmarks into logical "Workspaces" (e.g., Development, Research, Personal) for a clutter-free workflow.

---

## 📦 Installation

### 1. Deployment
Download the latest release and extract the archive to a permanent location. 
*Note: Ensure the directory remains static after installation to maintain path integrity.*

### 2. Execution of Installer
1. Navigate to the extracted folder.
2. Right-click `install.ps1` and select **"Run with PowerShell"**.
3. The script will automatically append the necessary aliases to your `$PROFILE`.
4. **Note:** The `src` folder is provided for transparency and can be safely deleted after the installation is complete.

---

## 🎮 Usage Guide

### Persistent Bookmarks
| Command | Action |
| :--- | :--- |
| `b-cd` | Opens the GUI folder picker. |
| `b-cd <alias>` | Jumps to a saved bookmark instantly. |
| `b-cd -n <alias>` | Creates a **new** bookmark (Errors if alias exists). |
| `b-cd -o <alias>` | **Overwrites** an existing bookmark (Errors if alias is missing). |

### ⚡ Instant Mode (Headless CLI)
Manage your paths without leaving the terminal:
```powershell
# Save CURRENT directory as 'work'
b-cd -in work

# Save a SPECIFIC path as 'game'
b-cd -in game "D:\Games\SteamLibrary"
