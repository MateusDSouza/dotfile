# Windows 11 entry point. Run in an *Administrator* PowerShell:
#   Set-ExecutionPolicy -Scope Process Bypass; .\bootstrap.ps1
# Installs the Windows-side apps and WSL2 Ubuntu. Your shell, CLI tools and configs
# then live inside Ubuntu: open it and run  ~/dotfiles/bootstrap.sh  (see README).
$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Run this from an Administrator PowerShell."
}

function Log($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# 1. Apps (Ghostty has no official Windows build yet, so Windows Terminal it is)
$apps = @(
    "Git.Git",
    "Microsoft.WindowsTerminal",
    "Microsoft.VisualStudioCode",
    "Docker.DockerDesktop"   # enables `docker` inside WSL via its WSL integration
)
foreach ($id in $apps) {
    Log "Installing $id"
    winget install --id $id --exact --silent --accept-source-agreements --accept-package-agreements
    # winget exits non-zero when the app is already installed; that's fine
}

# Pick up PATH changes (e.g. the `code` CLI) without reopening the shell
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path", "User")

# 2. VS Code settings (copied: symlinks on Windows need Developer Mode) + extensions
Log "Configuring VS Code"
$codeUser = Join-Path $env:APPDATA "Code\User"
New-Item -ItemType Directory -Force -Path $codeUser | Out-Null
$target = Join-Path $codeUser "settings.json"
if (Test-Path $target) { Copy-Item $target "$target.bak" -Force }
Copy-Item (Join-Path $PSScriptRoot "vscode\settings.json") $target -Force

Get-Content (Join-Path $PSScriptRoot "vscode\extensions.txt") |
    Where-Object { $_ -and -not $_.StartsWith("#") } |
    ForEach-Object { code --force --install-extension $_ }

# 3. WSL2 + Ubuntu
$distros = (wsl --list --quiet 2>$null) -replace "`0", ""
if ($distros -notcontains "Ubuntu") {
    Log "Installing WSL2 + Ubuntu (a reboot may be required)"
    wsl --install -d Ubuntu
} else {
    Log "WSL Ubuntu already installed"
}

Log "Done. Next: reboot if asked, open Ubuntu, then run:"
Write-Host "  git clone https://github.com/MateusDSouza/dotfiles ~/dotfiles && ~/dotfiles/bootstrap.sh"
