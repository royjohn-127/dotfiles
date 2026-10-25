# Loaded by PowerShell 7 on every start. install.ps1 adds a one-line pointer to $PROFILE that loads this file.
# Everything is found relative to this file, so the repo can live anywhere (yours: F:\dotfiles).

$DotfilesRoot      = Split-Path -Parent $PSScriptRoot
$DotfilesThemeDir  = Join-Path $DotfilesRoot 'themes'
$DotfilesThemeFile = Join-Path $DotfilesRoot 'theme.txt'

# --- Theme selection: the name inside theme.txt picks themes\<name>.omp.json ---
function Get-ThemeName {
    $name = Get-Content -Path $DotfilesThemeFile -TotalCount 1 -ErrorAction SilentlyContinue
    if ($name -and $name.Trim() -match '^[A-Za-z0-9_.-]+$') { $name.Trim() } else { 'minimal-clean' }
}

function Get-ThemePath([string]$Name) {
    Join-Path $DotfilesThemeDir "$Name.omp.json"
}

# Set-Theme            -> lists themes
# Set-Theme <name>     -> switches now (this tab) and for every new tab/shell
function Set-Theme {
    param([string]$Name)
    $available = (Get-ChildItem -Path $DotfilesThemeDir -Filter '*.omp.json').BaseName -replace '\.omp$', ''
    if (-not $Name) {
        Write-Host "Active theme: $(Get-ThemeName)"
        $available
        return
    }
    if ($Name -notin $available) {
        Write-Warning "No theme named '$Name'. Available: $($available -join ', ')"
        return
    }
    Set-Content -Path $DotfilesThemeFile -Value $Name
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        # Oh My Posh ignores a second init in the same session, so reset it first.
        Remove-Module oh-my-posh-core -ErrorAction SilentlyContinue
        $global:_ompInitialized = $false
        oh-my-posh init pwsh --config (Get-ThemePath $Name) | Invoke-Expression
    }
}

Register-ArgumentCompleter -CommandName Set-Theme -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    Get-ChildItem -Path $DotfilesThemeDir -Filter "$wordToComplete*.omp.json" |
        ForEach-Object { $_.Name -replace '\.omp\.json$', '' }
}

# --- Prompt (Oh My Posh) ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $DotfilesTheme = Get-ThemePath (Get-ThemeName)
    if (Test-Path $DotfilesTheme) {
        oh-my-posh init pwsh --config $DotfilesTheme | Invoke-Expression
    } else {
        Write-Warning "Theme file not found: $DotfilesTheme  (run Set-Theme to pick one)"
    }
}

# --- File icons in `ls` ---
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module -Name Terminal-Icons
}

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
if (Get-Module -ListAvailable -Name Microsoft.WinGet.CommandNotFound) {
    Import-Module -Name Microsoft.WinGet.CommandNotFound
}
#f45873b3-b655-43a6-b217-97c00aa0db58
