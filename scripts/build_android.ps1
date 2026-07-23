<#
.SYNOPSIS
    TorStream - Full Android Build Pipeline (Windows)

.DESCRIPTION
    Performs the complete Android build in order:
      1. Compile Rust crates for all Android ABI targets via cargo-ndk
      2. Copy compiled .so files to android/app/src/main/jniLibs/<abi>/
      3. Run flutter build apk (or flutter run if a device is connected)

.PARAMETERS
    -Release    Build in release mode (default: debug)
    -Run        After building, install and run on connected device/emulator
    -Abi        Comma-separated ABI list (default: "arm64-v8a,armeabi-v7a,x86_64")

.REQUIREMENTS
    - setup.ps1 must have been run
    - generate_bridge.ps1 must have been run
    - Android device or emulator connected (if using -Run)
    - NDK 27.2.12479018 installed

.USAGE
    .\scripts\build_android.ps1                  # debug APK
    .\scripts\build_android.ps1 -Release         # release APK
    .\scripts\build_android.ps1 -Release -Run    # release + install + run

#>

param(
    [switch]$Release,
    [switch]$Run,
    [string]$Abi = "arm64-v8a,armeabi-v7a,x86_64"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Ensure cargo-installed tools (cargo-ndk) are on PATH
$env:PATH += ";$env:USERPROFILE\.cargo\bin"

$ProjectRoot  = Split-Path $PSScriptRoot -Parent
$RustDir      = Join-Path $ProjectRoot "rust"
$JniLibsDir   = Join-Path $ProjectRoot "android\app\src\main\jniLibs"
$NdkVersion   = "27.2.12479018"
$CargoProfile = if ($Release) { "release" } else { "dev" }
$FlutterMode  = if ($Release) { "--release" } else { "--debug" }

$AbiList = $Abi -split ","

function Write-Step([string]$msg) {
    Write-Host ""
    Write-Host "-- $msg" -ForegroundColor Cyan
}

function Write-Ok([string]$msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Fail([string]$msg) {
    Write-Host "  [FAIL] $msg" -ForegroundColor Red
}

# Map Android ABI to Rust target triple
$AbiToTarget = @{
    "arm64-v8a"     = "aarch64-linux-android"
    "armeabi-v7a"   = "armv7-linux-androideabi"
    "x86_64"        = "x86_64-linux-android"
}

# ---- Step 1: Compile Rust ---------------------------------------------------
Write-Step "Compiling Rust crates for Android (profile: $CargoProfile)"

Push-Location $RustDir
try {
    foreach ($abi in $AbiList) {
        $target = $AbiToTarget[$abi.Trim()]
        if (-not $target) {
            Write-Fail "Unknown ABI: $abi"
            continue
        }

        Write-Host "  Building $abi ($target)..." -ForegroundColor DarkGray

        $cargoArgs = @(
            "ndk",
            "-t", $abi.Trim(),
            "build",
            "--package", "ffi_bridge"
        )
        if ($Release) { $cargoArgs += "--release" }

        & cargo @cargoArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Rust build failed for $abi"
            exit $LASTEXITCODE
        }
        Write-Ok "Built $abi"
    }
} finally {
    Pop-Location
}

# ---- Step 2: Copy .so files to jniLibs --------------------------------------
Write-Step "Copying .so files to jniLibs"

$ProfileDir = if ($Release) { "release" } else { "debug" }

foreach ($abi in $AbiList) {
    $target   = $AbiToTarget[$abi.Trim()]
    $soSrc    = Join-Path $RustDir "target\$target\$ProfileDir\libtor_stream.so"
    $destDir  = Join-Path $JniLibsDir $abi.Trim()
    $soDest   = Join-Path $destDir "libtor_stream.so"

    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }

    if (Test-Path $soSrc) {
        Copy-Item -Path $soSrc -Destination $soDest -Force
        Write-Ok "Copied libtor_stream.so to jniLibs/$abi/"
    } else {
        Write-Fail "Expected .so not found: $soSrc"
        Write-Host "  (This is normal in Phase 1 before codegen is run)" -ForegroundColor DarkGray
    }
}

# ---- Step 3: Flutter build / run --------------------------------------------
Write-Step "Building Flutter APK"

Push-Location $ProjectRoot
try {
    if ($Run) {
        Write-Host "  Running flutter run $FlutterMode..." -ForegroundColor DarkGray
        & flutter run $FlutterMode
    } else {
        Write-Host "  Running flutter build apk $FlutterMode..." -ForegroundColor DarkGray
        & flutter build apk $FlutterMode
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Flutter build failed"
        exit $LASTEXITCODE
    }

    $apkPath = if ($Release) {
        "build\app\outputs\flutter-apk\app-release.apk"
    } else {
        "build\app\outputs\flutter-apk\app-debug.apk"
    }
    Write-Ok "APK: $(Join-Path $ProjectRoot $apkPath)"
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Build complete!" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
