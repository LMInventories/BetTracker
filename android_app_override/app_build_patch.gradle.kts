
// Appended to android/app/build.gradle.kts after flutter create scaffold.
// Multiple android{}/kotlin{} blocks merge — later values override earlier ones.

android {
    compileOptions {
        // Match the CI JDK (17) so Java and Kotlin targets are consistent.
        // Core library desugaring handles java.time APIs on Android < 26 regardless
        // of the Java bytecode target version.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    defaultConfig {
        minSdk = 21
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
