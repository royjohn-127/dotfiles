## 1. Install the programs

```powershell
winget install --id Microsoft.PowerShell -e
winget install --id Microsoft.WindowsTerminal -e
winget install --id JanDeDobbeleer.OhMyPosh -s winget -e
winget install --id chrisant996.Clink -e        # optional: themed prompt in cmd
```

Close every terminal and open a new one. In Windows Terminal, open a **PowerShell** tab (not the blue "Windows PowerShell") and check:

```powershell
$PSVersionTable.PSVersion     # Major must be 7 or higher
oh-my-posh version
```

## 2. Install the font

```powershell
oh-my-posh font install JetBrainsMono
```

Then set it in Windows Terminal: **Settings → Defaults → Appearance → Font face → `JetBrainsMono Nerd Font Mono` → Save**.

## 3. Allow your profile to run

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

This lets local scripts run and still blocks unsigned scripts downloaded from the internet. No admin rights needed.

## 4. Install Terminal-Icons

```powershell
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
```

Answer `Y` if asked about NuGet or an untrusted repository.

## 5. Connect PowerShell to the repo

`$PROFILE` is the one file PowerShell reads at startup. We put a single pointer line in it that loads the profile from the repo, so editing the repo edits your terminal. No symlinks, no admin rights.

```powershell
# Back up an existing profile, create one if missing, add the pointer
if (Test-Path $PROFILE) { Copy-Item $PROFILE "$PROFILE.bak" }
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
Add-Content $PROFILE '. "F:\dotfiles\powershell\Microsoft.PowerShell_profile.ps1"'

. $PROFILE        # load it now
```

Check: the prompt is themed and `ls` shows icons. Open a new tab to confirm from a clean start.

## 6. (Optional) Lazy Miniconda

```powershell
if (-not (Test-Path $PROFILE.CurrentUserAllHosts)) { New-Item -ItemType File -Path $PROFILE.CurrentUserAllHosts -Force | Out-Null }
Add-Content $PROFILE.CurrentUserAllHosts '. "F:\dotfiles\powershell\profile.ps1"'
```

Expects Miniconda at `%USERPROFILE%\miniconda3`; edit `$condaExe` in `powershell\profile.ps1` otherwise. If you ever run `conda init powershell`, delete the block it adds to that file.

## 7. (Optional) `cmd` prompt with Clink

Restart Windows Terminal, open a **Command Prompt** tab, and run:

```
clink installscripts F:\dotfiles\cmd
```

Open another Command Prompt tab. `clink info` confirms Clink is active. (Terminal-Icons doesn't work in `cmd`; that's a PowerShell-only module.)

## How the pieces fit

- **`theme.txt`** holds a theme name, e.g. `minimal-clean`.
- **`powershell\Microsoft.PowerShell_profile.ps1`** reads it, loads `themes\<name>.omp.json` into Oh My Posh, imports Terminal-Icons, and defines `Set-Theme`.
- **`cmd\oh-my-posh.lua`** reads the same `theme.txt` for `cmd`. Because both shells read one file, switching themes changes both.
- Paths are always found relative to the file itself, so nothing contains a username or drive letter.
