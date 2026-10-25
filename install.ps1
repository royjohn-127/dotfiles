<#
.SYNOPSIS
  One-command setup for these dotfiles. Safe to run again at any time.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File F:\dotfiles\install.ps1

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File F:\dotfiles\install.ps1 -Conda -NoClink

.PARAMETER Conda
  Also hook up the lazy-loaded Miniconda block (powershell\profile.ps1).

.PARAMETER NoClink
  Skip Clink (the themed prompt in cmd.exe).

.NOTES
  Needs no administrator rights for the script itself (some installers may show a Windows prompt).
  Keep this file ASCII-only: Windows PowerShell 5.1 misreads other characters.
#>
[CmdletBinding()]
param(
    [switch]$Conda,
    [switch]$NoClink
)

$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot

function Say([string]$Message) { Write-Host "==> $Message" -ForegroundColor Cyan }

function Update-SessionPath {
    # Newly installed programs are not on PATH in already-open windows. Re-read it.
    $parts = [Environment]::GetEnvironmentVariable('Path', 'Machine'), [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = ($parts | Where-Object { $_ }) -join ';'
}

function Install-App([string]$Id, [string]$Source) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    winget list --id $Id -e --accept-source-agreements | Out-Null
    $found = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = $previous
    if ($found) { Write-Host "    already installed: $Id"; return }

    $wingetArgs = @('install', '--id', $Id, '-e', '--accept-source-agreements', '--accept-package-agreements')
    if ($Source) { $wingetArgs += @('-s', $Source) }
    & winget @wingetArgs
    if ($LASTEXITCODE -ne 0) { throw "winget could not install $Id (exit code $LASTEXITCODE)." }
}

function Add-ProfileLine([string]$File, [string]$Line) {
    if (-not (Test-Path $File)) { New-Item -ItemType File -Path $File -Force | Out-Null }
    if (Select-String -Path $File -SimpleMatch -Pattern $Line -Quiet) {
        Write-Host "    already set: $File"
        return
    }
    # Keep a one-time backup of whatever was there before.
    if ((Get-Item $File).Length -gt 0 -and -not (Test-Path "$File.bak")) { Copy-Item $File "$File.bak" }
    Add-Content -Path $File -Value $Line
    Write-Host "    updated: $File"
}

# ---------------------------------------------------------------- Part 1: programs (any PowerShell version)
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget was not found. Install 'App Installer' from the Microsoft Store, then run this script again."
}

Say 'Installing programs (anything already installed is skipped)'
Install-App 'Microsoft.PowerShell'
Install-App 'Microsoft.WindowsTerminal'
Install-App 'JanDeDobbeleer.OhMyPosh' 'winget'
if (-not $NoClink) { Install-App 'chrisant996.Clink' }
Update-SessionPath

# ---------------------------------------------------------------- Part 2 needs PowerShell 7: relaunch if needed
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $found = Get-Command pwsh -ErrorAction SilentlyContinue
    $pwsh = if ($found) { $found.Source } else { Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe' }
    if (-not (Test-Path $pwsh)) {
        throw 'PowerShell 7 is installed but could not be found yet. Close this window, open a new one, and run this script again.'
    }
    Say 'Continuing in PowerShell 7'
    $passThrough = @()
    if ($Conda)   { $passThrough += '-Conda' }
    if ($NoClink) { $passThrough += '-NoClink' }
    & $pwsh -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @passThrough
    exit $LASTEXITCODE
}

# ---------------------------------------------------------------- Part 2: configuration (PowerShell 7)
Say 'Installing the JetBrainsMono Nerd Font'
$omp = (Get-Command oh-my-posh -ErrorAction SilentlyContinue).Source
$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
if (Get-ChildItem -Path $fontDir -Filter 'JetBrainsMono*' -ErrorAction SilentlyContinue) {
    Write-Host '    already installed'
} elseif ($omp) {
    & $omp font install JetBrainsMono
} else {
    Write-Warning 'oh-my-posh is not on PATH yet. Open a new window and run: oh-my-posh font install JetBrainsMono'
}

Say 'Allowing local scripts to run (RemoteSigned, current user only)'
if ((Get-ExecutionPolicy -Scope CurrentUser) -in 'Undefined', 'Restricted') {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
} else {
    Write-Host "    left as is: $(Get-ExecutionPolicy -Scope CurrentUser)"
}

Say 'Installing Terminal-Icons (file icons for ls)'
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Write-Host '    already installed'
} else {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force
}

Say 'Connecting PowerShell to this repo'
Add-ProfileLine $PROFILE ('. "{0}"' -f (Join-Path $Root 'powershell\Microsoft.PowerShell_profile.ps1'))
if ($Conda) {
    Add-ProfileLine $PROFILE.CurrentUserAllHosts ('. "{0}"' -f (Join-Path $Root 'powershell\profile.ps1'))
}

if (-not $NoClink) {
    Say 'Connecting cmd.exe (Clink) to this repo'
    $clink = Get-Command clink -ErrorAction SilentlyContinue
    if ($clink) {
        & $clink.Source installscripts (Join-Path $Root 'cmd')
    } else {
        Write-Warning ('Clink is not on PATH yet. Open a new Command Prompt and run:  clink installscripts "{0}"' -f (Join-Path $Root 'cmd'))
    }
}

Write-Host ''
Write-Host 'Done. Two things left:' -ForegroundColor Green
Write-Host '  1. Windows Terminal > Settings > Defaults > Appearance > Font face > "JetBrainsMono Nerd Font Mono" > Save'
Write-Host '  2. Close Windows Terminal completely and open it again.'
