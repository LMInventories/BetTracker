// Appended to android/app/build.gradle.kts after flutter create scaffold.
// Multiple android{} blocks merge — later values override earlier ones.
//
// Fixes applied:
//   1. Core library desugaring — required by flutter_local_notifications 17+
//      to use java.time APIs on Android < 26.
//   2. SOURCE_COMPATIBILITY / jvmTarget bumped to 11 — workmanager and other
//      plugins declare Java 11 bytecode; mismatching jvmTarget causes the
//      "Compilation error. See log for more details" Kotlin build failure.
//   3. minSdk pinned to 21 — workmanager hard minimum; flutter.minSdkVersion
//      may default lower in some Flutter SDK versions.

android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    defaultConfig {
        minSdk = 21
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
