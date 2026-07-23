<#
.SYNOPSIS
    TorStream Phase 1 - Environment Setup Script (Windows)

.DESCRIPTION
    Installs all tools required to build TorStream for Android:
      1. Rust stable toolchain (via rustup)
      2. Android cross-compilation targets
      3. cargo-ndk  (simplifies NDK cross-compilation)
      4. flutter_rust_bridge_codegen  (FRB codegen tool)

    Run this ONCE after cloning the repository.

.REQUIREMENTS
    - Internet connection
    - Android SDK installed with NDK 27.2.12479018
      (Android Studio > SDK Manager > SDK Tools > NDK Side by side)
    - Flutter SDK on PATH
    - PowerShell 5+ or PowerShell Core 7+

.USAGE
    .\scripts\setup.ps1

#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step([string]$msg) {
    Write-Host ""
    Write-Host "-- $msg" -ForegroundColor Cyan
}

function Write-Ok([string]$msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Skip([string]$msg) {
    Write-Host "  [SKIP] $msg (skipped -- already installed)" -ForegroundColor DarkGray
}

# ---- VS Build Tools check ---------------------------------------------------
$needVSBuildTools = $false
if (-not (Get-Command link.exe -ErrorAction SilentlyContinue)) {
    $needVSBuildTools = $true
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vsWhere) {
        $vsPath = & $vsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>&1
        if ($vsPath) {
            $needVSBuildTools = $false
        }
    }
}

if ($needVSBuildTools) {
    Write-Step "Installing Visual Studio Build Tools (C++ workload)"
    Write-Host "  The Rust MSVC toolchain requires the Visual C++ linker (link.exe)" -ForegroundColor Yellow
    Write-Host "  Downloading VS Build Tools..." -ForegroundColor DarkGray
    $vsInstaller = "$env:TEMP\vs_buildtools.exe"
    Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_buildtools.exe" -OutFile $vsInstaller
    Write-Host "  Installing 'Desktop development with C++' workload..." -ForegroundColor DarkGray
    $proc = Start-Process -FilePath $vsInstaller -ArgumentList "--quiet", "--wait", "--norestart", "--nocache", "--add", "Microsoft.VisualStudio.Workload.VCTools", "--includeRecommended" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
        Write-Ok "VS Build Tools installed (exit code $($proc.ExitCode))"
    } else {
        Write-Host "  [!] VS Build Tools installer exited with code $($proc.ExitCode)" -ForegroundColor Red
        Write-Host "  You may need to manually install Visual Studio Build Tools from:" -ForegroundColor Yellow
        Write-Host "    https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor Yellow
        Write-Host "  Select 'Desktop development with C++' workload." -ForegroundColor Yellow
    }
}

# ---- 1. Rust + rustup -------------------------------------------------------
Write-Step "Checking Rust installation"

if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Rust via rustup..." -ForegroundColor Yellow
    $rustupScript = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $rustupScript
    & $rustupScript -y --default-toolchain stable --no-modify-path
    # Refresh PATH for this session
    $env:PATH += ";$env:USERPROFILE\.cargo\bin"
    Write-Ok "Rust installed"
} else {
    & rustup update stable
    Write-Skip "rustup already installed (updated stable toolchain)"
}

# Ensure cargo is on PATH for the rest of this script
$env:PATH += ";$env:USERPROFILE\.cargo\bin"

# ---- 2. Android cross-compilation targets -----------------------------------
Write-Step "Adding Android Rust targets"

$targets = @(
    "aarch64-linux-android",    # arm64-v8a  - primary Android target
    "armv7-linux-androideabi",  # armeabi-v7a - 32-bit ARM
    "x86_64-linux-android"      # x86_64     - emulator
)

foreach ($target in $targets) {
    Write-Host "  Adding $target..." -ForegroundColor DarkGray
    & rustup target add $target
}
Write-Ok "All Android targets added"

# ---- 3. Rust toolchain components -------------------------------------------
Write-Step "Installing Rust toolchain components"

& rustup component add rustfmt clippy
Write-Ok "rustfmt + clippy installed"

# ---- 4. cargo-ndk -----------------------------------------------------------
Write-Step "Installing cargo-ndk"

$installed = & cargo install --list 2>&1
if (-not ($installed -match "cargo-ndk")) {
    Write-Host "  Running cargo install cargo-ndk..." -ForegroundColor DarkGray
    & cargo install cargo-ndk
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "cargo-ndk installed"
    } else {
        Write-Host "  [FAIL] cargo-ndk installation failed (exit code $LASTEXITCODE)" -ForegroundColor Red
    }
} else {
    Write-Skip "cargo-ndk"
}

# ---- 5. flutter_rust_bridge_codegen -----------------------------------------
Write-Step "Installing flutter_rust_bridge_codegen"

if (-not ($installed -match "flutter_rust_bridge_codegen")) {
    Write-Host "  Running cargo install flutter_rust_bridge_codegen..." -ForegroundColor DarkGray
    & cargo install flutter_rust_bridge_codegen
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "flutter_rust_bridge_codegen installed"
    } else {
        Write-Host "  [FAIL] flutter_rust_bridge_codegen installation failed (exit code $LASTEXITCODE)" -ForegroundColor Red
    }
} else {
    Write-Skip "flutter_rust_bridge_codegen"
}

# ---- 6. Verify NDK ----------------------------------------------------------
Write-Step "Verifying Android NDK"

$ndkVersion = "27.2.12479018"
$ndkPath = "$env:LOCALAPPDATA\Android\sdk\ndk\$ndkVersion"

if (Test-Path $ndkPath) {
    Write-Ok "NDK $ndkVersion found at $ndkPath"
} else {
    Write-Host ""
    Write-Host "  [!] NDK $ndkVersion NOT found at:" -ForegroundColor Yellow
    Write-Host "     $ndkPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Install via Android Studio:" -ForegroundColor Yellow
    Write-Host "    SDK Manager > SDK Tools > NDK (Side by side) > $ndkVersion" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Or via sdkmanager:" -ForegroundColor Yellow
    Write-Host "    sdkmanager `"ndk;$ndkVersion`"" -ForegroundColor Yellow
}

# ---- 7. Flutter pub get -----------------------------------------------------
Write-Step "Running flutter pub get"

Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    & flutter pub get
    Write-Ok "flutter pub get complete"
} finally {
    Pop-Location
}

# ---- Done -------------------------------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Setup complete! Next steps:" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Generate the FFI bridge:" -ForegroundColor White
Write-Host "     .\scripts\generate_bridge.ps1" -ForegroundColor Green
Write-Host ""
Write-Host "  2. Build & run on Android:" -ForegroundColor White
Write-Host "     .\scripts\build_android.ps1" -ForegroundColor Green
Write-Host ""
