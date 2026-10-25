# Dotfiles for Windows Terminal

A good-looking, fast terminal on Windows.

- A themed prompt (**Oh My Posh**) showing your folder, Git status, and Node/Python/Go versions when relevant
- File icons in `ls` (**Terminal-Icons**)
- The same prompt in `cmd.exe` (**Clink**), optional
- Lazy-loaded Miniconda so terminals start fast, optional
- Swap themes in one command: `Set-Theme <name>`

---

## Quick start (new machine)

**Needs:** Windows 10 (1809+) or Windows 11.


### 1. Clone the repo using Git


```powershell
git clone https://github.com/royjohn-127/dotfiles.git F:\dotfiles
```

> If `winget` isn't recognized, install **App Installer** from the Microsoft Store and retry.

### 2. Run the installer

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File F:\dotfiles\install.ps1
```

This installs PowerShell 7, Windows Terminal, Oh My Posh, the font, Terminal-Icons, and Clink, and connects them to this repo. It skips anything already installed, so running it again is safe. Some installers show a Windows permission prompt; say yes.

> `-ExecutionPolicy Bypass` applies to this one command only. It changes nothing permanently.

Options (add to the end of the command above):

| Option | Effect |
|---|---|
| `-Conda` | Also set up lazy-loaded Miniconda (expects `%USERPROFILE%\miniconda3`) |
| `-NoClink` | Skip the themed prompt in `cmd.exe` |

### 3. Set the font (one-time, 30 seconds)

Without a Nerd Font, icons show up as `□` boxes.

1. Open **Windows Terminal** → click the **down arrow** next to `+` → **Settings**.
2. **Defaults** → **Appearance** → **Font face** → `JetBrainsMono Nerd Font Mono` → **Save**.
3. Optional: **Startup** → **Default profile** → **PowerShell** → **Save**.

VS Code: `Ctrl + ,` → search `terminal font` → set **Terminal › Integrated: Font Family** to `JetBrainsMono Nerd Font Mono`.

### 4. Restart and check

Close Windows Terminal completely, open it again, and choose a **PowerShell** tab (not the old blue "Windows PowerShell"). You should see the themed prompt, and `ls` should show icons.

Something off? See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

---

## Changing the theme (plug and play)

No setup guide needed. This is the whole process:

1. Get a theme file ending in `.omp.json`.
2. Drop it into `F:\dotfiles\themes\`.
3. In PowerShell:

```powershell
Set-Theme            # lists your themes and shows the active one
Set-Theme mytheme    # switches (Tab completes names)
```

PowerShell changes **immediately**. `cmd` tabs pick it up the next time you open one. The choice is saved in `theme.txt`, so it applies to every new window.

To go back: `Set-Theme minimal-clean`.

**Editing a theme:** change colors or segments directly in `themes\<name>.omp.json`, then run `Set-Theme <name>` again to reload it.

> Theme names may only contain letters, digits, `_`, `-` and `.`. Anything else in `theme.txt` is ignored and the default theme is used. This is deliberate, so a bad file can't run commands.

---

## Repo structure

```
dotfiles/
├── install.ps1                              One-command setup (safe to re-run)
├── theme.txt                                Name of the active theme
├── themes/
│   └── minimal-clean.omp.json               Your themes live here
├── powershell/
│   ├── Microsoft.PowerShell_profile.ps1     Runs at PowerShell start: prompt, icons, Set-Theme
│   └── profile.ps1                          Optional lazy-loaded Miniconda
├── cmd/
│   └── oh-my-posh.lua                       Themed prompt for cmd.exe (via Clink)
└── docs/
    ├── MANUAL-SETUP.md                      Every step by hand, with explanations
    └── TROUBLESHOOTING.md                   Symptom → fix
```

Nothing inside is tied to a username or drive letter. Every file finds its neighbors relative to itself.

---

## Everyday use

**Save a change to GitHub:**

```powershell
cd F:\dotfiles
git add .
git commit -m "Describe what you changed"
git push
```

**On another computer:** do the Quick start once. After that, `git pull` inside `F:\dotfiles` updates everything. `theme.txt` is tracked, so your chosen theme follows you.

---

## Security

- **Your profile runs on every terminal start.** Anything in the `.ps1` files runs with your permissions. Only use repos you trust, and after pulling someone else's changes, look at what changed (`git diff "HEAD@{1}"`).
- **Never put secrets in this repo.** No tokens, API keys or passwords. It's public. Use environment variables or a password manager. `.gitignore` already blocks `.env` files and `*.bak`.
- **Only install themes you trust.** A theme is a config file, not a program, but it can run commands through segments such as `command`. Skim unfamiliar themes for anything beyond colors and text.
- **The installer is plain text.** Read `install.ps1` before running it. It only uses `winget` with official package IDs, plus Oh My Posh's own font command.
- **Execution policy is `RemoteSigned`** (current user only), never `Unrestricted`.

---

## Limits

- Targets **PowerShell 7**. The old blue Windows PowerShell 5.1 isn't themed by this repo.
- Terminal-Icons works only in PowerShell, not `cmd`.
- WSL/Linux isn't covered.
