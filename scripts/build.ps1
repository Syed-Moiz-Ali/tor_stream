<#
.SYNOPSIS
    TorStream — One-Command Build (Android APK)

.DESCRIPTION
    Smart build that checks each prerequisite and only runs what's needed:
      1. Rust toolchain + Android targets    (skip if done)
      2. cargo-ndk + FRB codegen             (skip if done)
      3. FRB bridge codegen                  (skip if generated files are newer)
      4. Compile Rust .so for Android ABIs
      5. Build Flutter APK

.PARAMETER Release
    Build in release mode (default: debug)

.PARAMETER Run
    Install and launch on connected device after build

.PARAMETER Force
    Force re-run all steps even if already done

.EXAMPLE
    .\scripts\build.ps1                   # smart debug build
    .\scripts\build.ps1 -Release          # smart release build
    .\scripts\build.ps1 -Release -Run     # build + run on device
#>

param(
    [switch]$Release,
    [switch]$Run,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot  = Split-Path $PSScriptRoot -Parent
$RustDir      = Join-Path $ProjectRoot "rust"
$JniLibsDir   = Join-Path $ProjectRoot "android/app/src/main/jniLibs"

$ProfileName  = if ($Release) { "release" } else { "debug" }

$AbiList = @("arm64-v8a", "armeabi-v7a", "x86_64")
$AbiToTarget = @{
    "arm64-v8a"     = "aarch64-linux-android"
    "armeabi-v7a"   = "armv7-linux-androideabi"
    "x86_64"        = "x86_64-linux-android"
}

function Write-Step([string]$msg) { Write-Host "`n--- $msg" -ForegroundColor Cyan }
function Write-Skip([string]$msg) { Write-Host "  [SKIP] $msg" -ForegroundColor DarkGray }
function Write-Ok([string]$msg)   { Write-Host "  [OK]   $msg" -ForegroundColor Green }
function Write-Info([string]$msg) { Write-Host "  [INFO] $msg" -ForegroundColor Yellow }

# -- Step 1: Rust + Android targets -------------------------------------------
Write-Step "1/5  Rust toolchain + Android targets"

$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"

if (-not (Get-Command "rustup" -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Rust via rustup..."
    $installer = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $installer
    & $installer -y --default-toolchain stable --no-modify-path
}
$targets = @("aarch64-linux-android", "armv7-linux-androideabi", "x86_64-linux-android")
$needTargets = $false
foreach ($t in $targets) {
    $installed = & rustup target list --installed
    if ($installed -notcontains $t) { $needTargets = $true; break }
}
if ($needTargets -or $Force) {
    foreach ($t in $targets) { & rustup target add $t }
} else {
    Write-Skip "All Android targets already installed"
}

# -- Step 2: cargo-ndk + FRB codegen ------------------------------------------
Write-Step "2/5  cargo-ndk + flutter_rust_bridge_codegen"

$installedList = & cargo install --list 2>&1 | Out-String
if ($installedList -notcontains "cargo-ndk" -or $Force) {
    Write-Info "Installing cargo-ndk..."; & cargo install cargo-ndk
} else {
    Write-Skip "cargo-ndk already installed"
}
if ($installedList -notcontains "flutter_rust_bridge_codegen" -or $Force) {
    Write-Info "Installing flutter_rust_bridge_codegen..."; & cargo install flutter_rust_bridge_codegen
} else {
    Write-Skip "flutter_rust_bridge_codegen already installed"
}

# -- Step 3: FRB bridge codegen -----------------------------------------------
Write-Step "3/5  flutter_rust_bridge codegen"

$rustApiPath   = Join-Path $RustDir "crates/ffi_bridge/src/api.rs"
$rustTypesPath = Join-Path $RustDir "crates/ffi_bridge/src/types.rs"
$dartApiPath   = Join-Path $ProjectRoot "lib/bridge/generated/api.dart"
$dartTypesPath = Join-Path $ProjectRoot "lib/bridge/generated/types.dart"

$needCodegen = $Force -or -not (Test-Path $dartApiPath) -or -not (Test-Path $dartTypesPath)
if (-not $needCodegen) {
    $rustApiTime   = (Get-Item $rustApiPath).LastWriteTime
    $rustTypesTime = (Get-Item $rustTypesPath).LastWriteTime
    $dartApiTime   = (Get-Item $dartApiPath).LastWriteTime
    $dartTypesTime = (Get-Item $dartTypesPath).LastWriteTime
    if ($rustApiTime -gt $dartApiTime -or $rustTypesTime -gt $dartTypesTime) {
        $needCodegen = $true
    }
}
if ($needCodegen) {
    Push-Location $ProjectRoot
    & flutter_rust_bridge_codegen generate `
        --rust-input "crate::api" `
        --dart-output "lib/bridge/generated" `
        --rust-root "rust/crates/ffi_bridge"
    if ($LASTEXITCODE -ne 0) { throw "FRB codegen failed" }
    Pop-Location
} else {
    Write-Skip "FRB bridge is up-to-date"
}

# -- Step 4: Build Rust .so for Android ---------------------------------------
Write-Step "4/5  Rust cross-compile for Android ($ProfileName)"

# aws-lc-sys: use C code instead of NASM assembly
$env:AWS_LC_SYS_NO_ASM = "1"

Push-Location $RustDir
foreach ($abi in $AbiList) {
    Write-Info "Building $abi..."

    # aws-lc-sys: tell CMake the correct Android ABI so it doesn't add -march=armv7-a
    $env:AWS_LC_SYS_NO_ASM = "1"
    $env:ANDROID_ABI = "arm64-v8a"
    $env:ANDROID_NATIVE_API_LEVEL = "21"

    $cargoArgs = @("ndk", "-t", $abi.Trim(), "build", "--package", "ffi_bridge")
    if ($Release) { $cargoArgs += "--release" }
    & cargo @cargoArgs
    if ($LASTEXITCODE -ne 0) { throw "Rust build failed for $abi" }
}
Pop-Location

# Copy .so to jniLibs
$soProfileDir = if ($Release) { "release" } else { "debug" }
foreach ($abi in $AbiList) {
    $target = $AbiToTarget[$abi.Trim()]
    $soSrc  = Join-Path $RustDir "target/$target/$soProfileDir/libtor_stream.so"
    $dest   = Join-Path $JniLibsDir $abi.Trim()
    if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
    Copy-Item -Path $soSrc -Destination (Join-Path $dest "libtor_stream.so") -Force
    Write-Ok "libtor_stream.so -> jniLibs/$abi/"
}

# -- Step 5: Flutter APK ------------------------------------------------------
Write-Step "5/5  Flutter APK ($ProfileName)"

Push-Location $ProjectRoot
if (-not (Test-Path ".dart_tool/package_config.json") -or $Force) {
    & flutter pub get
}
if ($Run) {
    & flutter run @(if ($Release) { "--release" } else { "--debug" })
} else {
    & flutter build apk @(if ($Release) { "--release" } else { "--debug" })
    if ($LASTEXITCODE -ne 0) { throw "Flutter build failed" }
}
Pop-Location

Write-Host "`n BUILD COMPLETE!" -ForegroundColor Cyan
