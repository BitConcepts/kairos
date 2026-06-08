<#
.SYNOPSIS
    Launch the Kairos terminal (no build).

.DESCRIPTION
    Opens the last compiled Kairos binary. Use Build-Kairos.ps1 to compile first.

.PARAMETER Release
    Launch the release binary instead of the debug binary.

.EXAMPLE
    .\Open-Kairos.ps1
    # Launch the debug binary

.EXAMPLE
    .\Open-Kairos.ps1 -Release
    # Launch the release binary
#>
param(
    [switch]$Release
)

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) { $RepoRoot = $PWD.Path }

$Profile = if ($Release) { "release" } else { "debug" }
$Binary  = Join-Path $RepoRoot "target\$Profile\kairos.exe"

if (-not (Test-Path $Binary)) {
    Write-Error "Binary not found at: $Binary`nRun .\Build-Kairos.ps1 first."
    exit 1
}

Write-Host "Launching Kairos ($Profile)..." -ForegroundColor Green
& $Binary
