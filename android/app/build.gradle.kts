plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tor_stream"
    compileSdk = flutter.compileSdkVersion

    // ── Pinned NDK version (must match .cargo/config.toml) ──────────────────
    // Install via Android Studio → SDK Manager → SDK Tools → NDK (Side by side)
    // Or: sdkmanager "ndk;27.2.12479018"
    ndkVersion = "27.2.12479018"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.tor_stream"

        // minSdk 21 required for Rust cdylib on Android (Android 5.0+).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ── ABI filters — only ship Rust .so for supported architectures ────
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    buildTypes {
        release {
            // TODO: Replace with a real signing config before publishing.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false   // Proguard disabled until R8 rules are added
            isShrinkResources = false
        }
        debug {
            isDebuggable = true
            isShrinkResources = false
        }
    }

    // ── Tell Gradle where to find the Rust .so files ─────────────────────────
    // The build script (scripts/build_android.ps1) copies compiled .so files
    // from rust/target/<abi>/release/ into this directory.
    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.media3:media3-exoplayer:1.5.1")
    implementation("androidx.media3:media3-session:1.5.1")
    implementation("androidx.media3:media3-ui:1.5.1")
    implementation("androidx.media3:media3-datasource:1.5.1")
    implementation("androidx.media3:media3-common:1.5.1")
}

