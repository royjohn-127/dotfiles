# OPTIONAL: lazy-loaded Miniconda. Hooked up by `install.ps1 -Conda` (via $PROFILE.CurrentUserAllHosts).
# `conda init` normally adds a block that costs several seconds on every terminal start.
# This version only loads conda the first time you type `conda`.
# Assumes Miniconda's default per-user install. Edit $condaExe if yours is elsewhere.
#region conda initialize (lazy)
$condaExe = Join-Path $env:USERPROFILE 'miniconda3\Scripts\conda.exe'
function conda {
    Remove-Item Function:\conda -ErrorAction SilentlyContinue
    If (Test-Path $condaExe) {
        (& $condaExe "shell.powershell" "hook") | Out-String | Invoke-Expression
    }
    conda @args
}
#endregion
