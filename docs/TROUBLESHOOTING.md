# Troubleshooting

Find your symptom, apply the fix, then open a **new** terminal tab.

| What you see | Fix |
|---|---|
| `running scripts is disabled on this system` | Run `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`, answer `Y`. Or re-run `install.ps1`. |
| `winget` is not recognized | Install **App Installer** from the Microsoft Store. |
| `oh-my-posh` is not recognized | Close **all** terminal windows and reopen. Still no? Reboot, then re-run `install.ps1`. |
| Prompt works but shows `□` or `?` | The font isn't applied. Windows Terminal → Settings → **Defaults → Appearance → Font face** = `JetBrainsMono Nerd Font Mono`. Restart Windows Terminal fully. |
| No themed prompt at all | You may be in the old blue **Windows PowerShell**. Run `$PSVersionTable.PSVersion`; `Major` must be 7+. Pick the **PowerShell** tab. Then run `Get-Content $PROFILE` and check it contains a line starting with `. "F:\dotfiles\powershell\...`. If not, re-run `install.ps1`. |
| Red error on startup mentioning a path that "does not exist" | The repo isn't where the profile expects. Make sure `F:\dotfiles` exists (`Test-Path F:\dotfiles`). If you moved it, run `install.ps1` from the new location, then delete the old pointer line (`notepad $PROFILE`). |
| `Warning: Theme file not found` | `theme.txt` names a theme that isn't in `themes\`. Run `Set-Theme` to see what's there, or `Set-Theme minimal-clean`. |
| `Set-Theme` is not recognized | The profile didn't load. See "No themed prompt at all" above. |
| `Set-Theme` changed `theme.txt` but the prompt looks the same | Open a new tab. Also check the theme file is valid: `oh-my-posh print primary --config F:\dotfiles\themes\<name>.omp.json`. |
| `ls` shows no icons | Re-run `install.ps1`, open a new tab, and check the font. |
| Terminals start slowly | If you use conda, make sure `conda init` didn't add its own block to a profile (`notepad $PROFILE.CurrentUserAllHosts`). Delete anything between `#region conda initialize` and `#endregion` that isn't this repo's lazy version, then run `install.ps1 -Conda`. |
| `cmd` tab has no themed prompt | Run `clink info` in a Command Prompt tab. If `clink` isn't found, restart the terminal. If it's found, run `clink installscripts F:\dotfiles\cmd` and open a new tab. If Clink isn't injecting at all, run `clink autorun install`. |
| Install failed halfway | Just run `install.ps1` again. Finished steps are skipped. |
| Miniconda isn't found | Default location is `%USERPROFILE%\miniconda3`. If yours differs, edit the `$condaExe` line in `powershell\profile.ps1`. |

## Undo everything

1. `notepad $PROFILE` → delete the line that starts with `. "F:\dotfiles`.
2. `notepad $PROFILE.CurrentUserAllHosts` → delete the matching line, if you used `-Conda`.
3. `clink uninstallscripts F:\dotfiles\cmd` (only if you used Clink).
4. Optional: `winget uninstall JanDeDobbeleer.OhMyPosh`.

The installer saved your previous profile as `Microsoft.PowerShell_profile.ps1.bak` next to it, if you had one.
