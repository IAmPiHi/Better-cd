# Better-CD 🚀
> A lightning-fast CLI directory switcher for Windows. No more `cd ../../../`.

**Better-CD** integrates the native Windows "Browse Folder" dialog into your terminal (PowerShell & CMD). It solves the classic "child process cannot change parent directory" problem using a smart shell wrapper.

## ✨ Features
- **GUI Selection:** Use the modern Windows folder picker to `cd`.
- **Zero Config:** Just install and type `b-cd`.
- **Safe:** Handles Unicode paths (Chinese/Japanese) perfectly.
- **Cross-Shell:** Works seamlessly in PowerShell.

## 📦 Installation

### Option 1: One-Click Install (Recommended)
1. Download the latest release.
2. Right-click `install.ps1` and select **"Run with PowerShell"**.
3. Restart your terminal.

### Option 2: Manual Install
1. Place `better-cd-core.exe` anywhere (e.g., `C:\Tools`).
2. Add the following function to your PowerShell profile (`notepad $PROFILE`):
   ```powershell
   function b-cd {
       $target = (& "C:\Tools\better-cd-core.exe").Trim()
       if ($target) { Set-Location $target }
   }
   ```

   ###🛠 Usage
   ```powershell
   b-cd
   ```