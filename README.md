# Oh My Posh + Terminal-Icons + JetBrainsMono Nerd Font
### Cross-shell setup for PowerShell 7, CMD, and WSL Ubuntu — synced via GitHub

**Your setup:** Windows Terminal (primary) + VS Code integrated terminal, PowerShell 7.6.4, Miniconda installed, dotfiles repo will live on `F:\dotfiles`.

**Miniconda note:** PowerShell actually loads up to **four** separate profile files on startup, not just one. `$PROFILE` only points to one of them (`Microsoft.PowerShell_profile.ps1`, called `CurrentUserCurrentHost`). `conda init powershell` writes its hook into a *different* one — `profile.ps1` (`CurrentUserAllHosts`) — which loads for every PowerShell host (pwsh, VS Code's terminal, etc.), not just interactive pwsh sessions. Both files get folded into the repo in Step 5, and WSL's `.bashrc` gets its own line in Step 7.

**Performance note:** by default, `conda init` writes an *eager* hook that spawns `conda.exe` and rebuilds the shell hook on **every single shell start** — this alone added ~4.4 seconds to every new terminal here. Step 5 replaces it with a *lazy* version: startup defines a lightweight stub, and the real hook only runs the first time you actually type `conda` in a session (paying that cost once, not every launch).

---

## Step 1 — Install Oh My Posh

Open **PowerShell 7** (pwsh) — not old Windows PowerShell — and run:

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```

**Close the terminal completely and reopen it** (PATH only refreshes in a new session).

**Verify:**
```powershell
oh-my-posh version
```
You should see a version number (e.g. `24.x.x`). If you get "command not found," the PATH hasn't refreshed — reboot if reopening the terminal didn't fix it.

---

## Step 2 — Install the Nerd Font

No manual downloading or unzipping needed — Oh My Posh installs fonts for you:

```powershell
oh-my-posh font install JetBrainsMono
```

This installs "JetBrainsMono Nerd Font Mono" (and related weights) for your Windows user account.

---

## Step 3 — Point your terminals at the font

**Windows Terminal** (covers PowerShell, CMD, and WSL profiles all at once if set at the Defaults level):
1. Open Windows Terminal → click the dropdown arrow next to the `+` tab → **Settings**.
2. In the left sidebar, click **Defaults** → **Appearance**.
3. Under **Font face**, choose `JetBrainsMono Nerd Font Mono`.
4. Save.

Setting it under **Defaults** (rather than per-profile) means PowerShell, CMD, and Ubuntu (WSL) tabs all pick it up automatically, since none of them have a profile-specific override yet.

**VS Code integrated terminal:**
1. `Ctrl + ,` to open Settings → search `terminal font`.
2. Set **Terminal › Integrated: Font Family** to `JetBrainsMono Nerd Font Mono`.

(Or in `settings.json`: `"terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono"`)

**Verify:** open a new Windows Terminal tab — text should render normally, no missing-glyph boxes (☐).

---

## Step 4 — Create your dotfiles repo on F:\

```powershell
mkdir F:\dotfiles
cd F:\dotfiles
git init
mkdir themes, powershell, cmd, wsl
```

Save your existing `minimal-clean.omp.json` to `F:\dotfiles\themes\minimal-clean.omp.json` (just copy the file there — no need to retype it).

Worth knowing about what's in it, since it affects what you'll see in the prompt:
- It has `node` and `python` segments with `fetch_version: true` — these only appear when you're inside a folder containing the relevant project files (e.g. `package.json`, `.py` files), so your prompt won't be cluttered outside those folders. With Miniconda installed, the python segment will pick up whichever Python is active (base env or an activated conda env).
- It uses Nerd Font glyphs directly (e.g. `\uf044`, `\ue718`, `\ue235`, `\uf252`) — these will render correctly once JetBrainsMono Nerd Font Mono is set in Step 3, and show as boxes (☐) if the font isn't applied yet.
- It sets a `transient_prompt` — once a command finishes, the multi-segment prompt on that line collapses down to just `❯`, keeping your scrollback clean. This requires the `oh-my-posh init` line to be present (Steps 5–7 below) — transient prompts don't work from a static theme file alone.

---

## Step 5 — PowerShell 7 profile (Terminal-Icons + Oh My Posh + conda)

Two separate files get folded into the repo here — same symlink pattern for both, so editing the repo is the same as editing your live profiles.

### 5a. `Microsoft.PowerShell_profile.ps1` (Terminal-Icons + Oh My Posh)

```powershell
# Where does your live profile currently point?
$PROFILE

# Copy the EXISTING profile into the repo
Copy-Item $PROFILE F:\dotfiles\powershell\Microsoft.PowerShell_profile.ps1 -Force

# Replace the original with a symlink into the repo
Remove-Item $PROFILE
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "F:\dotfiles\powershell\Microsoft.PowerShell_profile.ps1"
```

> If `New-Item -ItemType SymbolicLink` errors with a permissions message: turn on **Developer Mode** (Settings → Privacy & security → For developers → Developer Mode), which lets a non-admin account create symlinks. Then retry.

Install Terminal-Icons:
```powershell
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
```

Final content of `F:\dotfiles\powershell\Microsoft.PowerShell_profile.ps1`:
```powershell
Import-Module Terminal-Icons
oh-my-posh init pwsh --config 'F:\dotfiles\themes\minimal-clean.omp.json' | Invoke-Expression
```

### 5b. `profile.ps1` (conda, lazy-loaded)

This is the file `conda init powershell` actually wrote to (`C:\Users\rj\OneDrive\Documents\PowerShell\profile.ps1`) — separate from the one above, and it's what was adding several seconds to every shell start.

```powershell
Copy-Item 'C:\Users\rj\OneDrive\Documents\PowerShell\profile.ps1' F:\dotfiles\powershell\profile.ps1 -Force
Remove-Item 'C:\Users\rj\OneDrive\Documents\PowerShell\profile.ps1'
New-Item -ItemType SymbolicLink -Path 'C:\Users\rj\OneDrive\Documents\PowerShell\profile.ps1' -Target 'F:\dotfiles\powershell\profile.ps1'
```

Final content of `F:\dotfiles\powershell\profile.ps1` (the lazy-load swap — startup defines a stub, real hook only runs the first time `conda` is actually typed):
```powershell
#region conda initialize (lazy — see note below)
function conda {
    Remove-Item Function:\conda -ErrorAction SilentlyContinue
    If (Test-Path "C:\Users\rj\miniconda3\Scripts\conda.exe") {
        (& "C:\Users\rj\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
    }
    conda @args
}
#endregion
# NOTE: if Miniconda is reinstalled/updated and it re-runs `conda init powershell`,
# it will overwrite this back to the slow eager version. Reapply the lazy wrapper above.
```

Reload without closing the window:
```powershell
. $PROFILE
```

**Verify:** open a *fresh* tab — prompt is themed, `ls` shows icons, and startup feels fast (~2.5s here, down from ~7s with the eager conda hook). Then run `conda activate base` — first call in a session takes a few seconds (the one-time hook load), every `conda` command after that in the same session is instant.

---

## Step 6 — CMD via Clink

Oh My Posh doesn't hook into `cmd.exe` on its own — it needs **Clink** as the plumbing.

```powershell
winget install chrisant996.Clink
```

Restart your terminal. Open a new **Command Prompt** tab and confirm Clink is active:
```
clink info
```

Create `F:\dotfiles\cmd\oh-my-posh.lua`:

```lua
load(io.popen('oh-my-posh init cmd --config "F:/dotfiles/themes/minimal-clean.omp.json"'):read("*a"))()
```

Tell Clink to load scripts from that folder:
```
clink installscripts F:\dotfiles\cmd
```

Open a fresh CMD tab. **Verify:** themed prompt appears.

> Terminal-Icons will **not** show icons in CMD's `dir` — that module only hooks into PowerShell. That's a real platform limit, not a missed setting.

---

## Step 7 — WSL Ubuntu

Windows Terminal's font setting (Step 3) already covers the WSL profile — nothing to install for fonts inside Linux.

Install Oh My Posh inside WSL (it's a separate Linux binary, independent of the Windows install):

```bash
curl -s https://ohmyposh.dev/install.sh | bash -s
```

This installs to `~/.local/bin`. If `oh-my-posh version` doesn't work afterward, add this to `~/.bashrc`:
```bash
export PATH=$PATH:$HOME/.local/bin
```

Your F:\ drive is reachable from WSL at `/mnt/f/`. Add this line to the **end** of `~/.bashrc` (below conda's block — leave that untouched):

```bash
eval "$(oh-my-posh init bash --config /mnt/f/dotfiles/themes/minimal-clean.omp.json)"
```

Reload:
```bash
source ~/.bashrc
```

**Verify:** themed prompt appears in the WSL tab.

*(For reference/portability, that same line is saved at `F:\dotfiles\wsl\oh-my-posh.sh` — but the "live" copy Bash actually reads is the one you pasted into `~/.bashrc`, since symlinking across the Windows/Linux boundary isn't worth the complexity here.)*

---

## Step 8 — Push everything to GitHub

```powershell
cd F:\dotfiles
git add .
git commit -m "Initial oh-my-posh + Terminal-Icons setup"
```

Create an empty repo at github.com/new (e.g. named `dotfiles`), then:

```powershell
git remote add origin https://github.com/<your-username>/dotfiles.git
git branch -M main
git push -u origin main
```

### Restoring on a new device
1. Clone the repo to that device's equivalent path (e.g. `F:\dotfiles` if it also has an F: drive).
2. Repeat Steps 1–3 (Oh My Posh, font, Clink) on the new machine.
3. Install Miniconda if not already there, then re-run the symlink commands from **both** 5a and 5b — check `$PROFILE`, `$PROFILE.CurrentUserAllHosts`, and where conda actually installed (the `conda.exe` path inside `profile.ps1` may differ per device/username and need updating).
4. Re-run `clink installscripts` (Step 6) and re-run `Install-Module Terminal-Icons`.
5. Paste the one WSL line from Step 7 into the new device's `~/.bashrc`.

**Known limitations:**
- Paths in the theme configs are hardcoded to `F:\dotfiles\...`. If a future device doesn't have an F: drive, update the `--config` path in both profile files, the `.lua` file, and `.bashrc`.
- The conda lazy-load block in `profile.ps1` hardcodes the `conda.exe` path and username (`C:\Users\rj\miniconda3\...`). On a new device, update that path to match where Miniconda actually installs.
- If Miniconda gets reinstalled/updated on any device and re-runs `conda init powershell`, it will silently overwrite `profile.ps1` back to the slow eager version — reapply the lazy wrapper from Step 5b afterward.

---

## Final checklist

- [ ] New Windows Terminal → PowerShell tab: themed prompt + icons on `ls`, starts in ~2.5s not ~7s
- [ ] New Windows Terminal → CMD tab: themed prompt (icons not expected here)
- [ ] New Windows Terminal → Ubuntu (WSL) tab: themed prompt
- [ ] VS Code integrated terminal (PowerShell): themed prompt
- [ ] `conda activate base` works (slow the first time per session, instant after)
- [ ] `git log` inside `F:\dotfiles` shows your commit, and the files are visible on GitHub
