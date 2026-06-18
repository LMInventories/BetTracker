
// Kotlin DSL variant — appended to android/build.gradle.kts after flutter create scaffold.

// Kotlin 1.8+ merged kotlin-stdlib-jdk7/jdk8 into the main stdlib artifact.
// Force all configs to the same version to prevent duplicate-class errors.
allprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" &&
                requested.name in listOf("kotlin-stdlib-jdk8", "kotlin-stdlib-jdk7")) {
                useVersion("2.1.0")
            }
        }
    }

    // KGP 2.x enforces strict Java/Kotlin JVM-target consistency. The CI runner has
    // JDK 17 installed; AGP's toolchain integration makes plugin subprojects
    // (shared_preferences_android, workmanager, etc.) compile Java to JVM 17.
    // Forcing Kotlin to match (17) is the only reliable fix — overriding Java
    // via task.sourceCompatibility does not survive AGP's internal reconfiguration,
    // and options.release is explicitly blocked by AGP.
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
