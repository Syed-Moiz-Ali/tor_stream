<#
.SYNOPSIS
    TorStream - Generate flutter_rust_bridge FFI bindings (Windows)

.DESCRIPTION
    Runs flutter_rust_bridge_codegen to generate:
      - Rust side: rust/crates/ffi_bridge/src/frb_generated.rs
      - Dart side: lib/bridge/generated/frb_generated.dart (and companions)

    After this script completes:
      1. Uncomment `mod frb_generated;` in rust/crates/ffi_bridge/src/lib.rs
      2. Update lib/main.dart to call `await RustLib.init();`
      3. Run .\scripts\build_android.ps1

.REQUIREMENTS
    - setup.ps1 must have been run first
    - flutter_rust_bridge_codegen must be on PATH (cargo install flutter_rust_bridge_codegen)

.USAGE
    .\scripts\generate_bridge.ps1

#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Ensure cargo-installed tools are on PATH
$env:PATH += ";$env:USERPROFILE\.cargo\bin"

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$RustInput   = Join-Path $ProjectRoot "rust\crates\ffi_bridge\src\lib.rs"
$DartOutput  = Join-Path $ProjectRoot "lib\bridge\generated"
$RustOutput  = Join-Path $ProjectRoot "rust\crates\ffi_bridge\src"

function Write-Step([string]$msg) {
    Write-Host ""
    Write-Host "-- $msg" -ForegroundColor Cyan
}

Write-Step "Generating flutter_rust_bridge bindings"
Write-Host "  Rust input : $RustInput"
Write-Host "  Dart output: $DartOutput"
Write-Host "  Rust output: $RustOutput"

# Ensure output directory exists
if (-not (Test-Path $DartOutput)) {
    New-Item -ItemType Directory -Path $DartOutput | Out-Null
}

Push-Location $ProjectRoot
try {
    & flutter_rust_bridge_codegen generate `
        --rust-input       "crate::api" `
        --dart-output      "lib/bridge/generated" `
        --rust-root        "rust/crates/ffi_bridge"

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "  [FAIL] Codegen failed (exit code $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host ""
    Write-Host "  [OK] Codegen complete" -ForegroundColor Green

    $apiFile = Join-Path $DartOutput "api.dart"
    $typesFile = Join-Path $DartOutput "types.dart"
    $frbFile = Join-Path $DartOutput "frb_generated.dart"

    if ((Test-Path $apiFile) -and (Test-Path $typesFile)) {
        $content = Get-Content $apiFile -Raw
        if ($content -notmatch "export 'types.dart';") {
            $content = $content -replace "import 'types.dart';", "import 'types.dart';`nexport 'types.dart';"
            Set-Content -Path $apiFile -Value $content -NoNewline
            Write-Host "  [OK] Re-exported types.dart in api.dart" -ForegroundColor Green
        }
    }

    if ((Test-Path $frbFile) -and (Test-Path $typesFile)) {
        $content = Get-Content $frbFile -Raw
        if ($content -notmatch "export 'types.dart';") {
            $content = $content -replace "import 'types.dart';", "import 'types.dart';`nexport 'api.dart';`nexport 'types.dart';"
            Set-Content -Path $frbFile -Value $content -NoNewline
            Write-Host "  [OK] Re-exported api.dart & types.dart in frb_generated.dart" -ForegroundColor Green
        }
    }

} finally {
    Pop-Location
}

# ---- Post-codegen instructions ----------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Codegen done! Manual steps required:" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. In rust\crates\ffi_bridge\src\lib.rs, uncomment:" -ForegroundColor White
Write-Host "       mod frb_generated;" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. In lib\main.dart, in main(), add before runApp():" -ForegroundColor White
Write-Host "       await RustLib.init();" -ForegroundColor Yellow
Write-Host "     And add the import:" -ForegroundColor White
Write-Host "       import 'bridge/generated/frb_generated.dart';" -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. Run the Android build:" -ForegroundColor White
Write-Host "       .\scripts\build_android.ps1" -ForegroundColor Green
Write-Host ""
