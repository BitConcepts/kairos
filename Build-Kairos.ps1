<#
.SYNOPSIS
    Build and launch the Kairos terminal.

.DESCRIPTION
    Ensures the Rust toolchain and protoc are on PATH, builds the kairos
    binary, and launches it. Always targets --bin kairos.

.PARAMETER Release
    Build with --release optimisations (slower build, faster runtime).
    Defaults to debug build for faster iteration.

.PARAMETER NoBuild
    Skip the cargo build step and run the last compiled binary directly.
    Equivalent to running Open-Kairos.ps1.

.PARAMETER NoLaunch
    Build only — do not launch after compiling.

.EXAMPLE
    .\Build-Kairos.ps1
    # Debug build + launch

.EXAMPLE
    .\Build-Kairos.ps1 -Release
    # Release build + launch

.EXAMPLE
    .\Build-Kairos.ps1 -NoLaunch
    # Build only (debug), do not launch

.EXAMPLE
    .\Build-Kairos.ps1 -Release -NoLaunch
    # Release build only
#>
param(
    [switch]$Release,
    [switch]$NoBuild,
    [switch]$NoLaunch
)

# If running under Windows PowerShell 5.x, re-invoke under pwsh 7 if available.
if ($PSVersionTable.PSEdition -ne 'Core') {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        & $pwsh.Source -NoLogo -File $PSCommandPath @PSBoundParameters
        exit $LASTEXITCODE
    }
    Write-Warning "PowerShell 7 (pwsh) not found. Running under PS $($PSVersionTable.PSVersion)."
}

$ErrorActionPreference = "Stop"

# ── Resolve repo root ────────────────────────────────────────────────────────
$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) { $RepoRoot = $PWD.Path }

# ── Ensure cargo is on PATH ──────────────────────────────────────────────────
$CargoBin = "$env:USERPROFILE\.cargo\bin"
if (Test-Path $CargoBin) {
    $env:PATH = "$CargoBin;$env:PATH"
}

if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Error "cargo not found. Install Rust via: winget install Rustlang.Rustup"
    exit 1
}

# ── Ensure protoc is on PATH (required for proto API crates) ─────────────────
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH","User")

# ── Build ────────────────────────────────────────────────────────────────────
if (-not $NoBuild) {
    $BuildArgs = @("build", "--bin", "kairos")
    if ($Release) { $BuildArgs += "--release" }

    Write-Host "Building Kairos$(if ($Release) { ' (release)' })..." -ForegroundColor Cyan
    Push-Location $RepoRoot
    try {
        & cargo @BuildArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Build failed (exit $LASTEXITCODE). See output above."
            exit $LASTEXITCODE
        }
    } finally {
        Pop-Location
    }
    Write-Host "Build complete." -ForegroundColor Green
}

# ── Locate binary ────────────────────────────────────────────────────────────
$Profile = if ($Release) { "release" } else { "debug" }
$Binary  = Join-Path $RepoRoot "target\$Profile\kairos.exe"

if (-not (Test-Path $Binary)) {
    Write-Error "Binary not found at: $Binary`nRun without -NoBuild to compile first."
    exit 1
}

# ── Launch ───────────────────────────────────────────────────────────────────
if (-not $NoLaunch) {
    Write-Host "Launching Kairos ($Profile)..." -ForegroundColor Green
    & $Binary
} else {
    Write-Host "Binary ready: $Binary" -ForegroundColor Green
}
