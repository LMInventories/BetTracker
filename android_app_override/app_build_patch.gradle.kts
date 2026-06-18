
// Appended to android/app/build.gradle.kts after flutter create scaffold.
// Multiple android{}/kotlin{} blocks merge — later values override earlier ones.
//
// Fixes applied:
//   1. Core library desugaring — required by flutter_local_notifications 17+
//      (uses java.time APIs not natively available on Android < 26).
//   2. Java 11 source/target — modern plugin bytecode targets Java 11; mismatching
//      sourceCompatibility causes Kotlin K2 compilation failures in subprojects.
//   3. minSdk 21 — workmanager hard minimum; flutter.minSdkVersion may default lower.
//
// NOTE: kotlinOptions is deprecated-as-error in Kotlin DSL — use kotlin{compilerOptions}.

android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    defaultConfig {
        minSdk = 21
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
