
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

    // KGP 2.x (K2 compiler) enforces strict JVM-target consistency. CI runner has JDK 17;
    // plugin subprojects inherit that as their Java target. Match Kotlin to 17.
    //
    // languageVersion = KOTLIN_1_9: K2 compat mode — treats many K2 behavioral changes
    // (smart-cast changes, companion-access changes, etc.) as warnings rather than errors.
    // Required for plugins like workmanager 0.5.x that predate K2 and contain code the
    // K2 compiler rejects under default KOTLIN_2_0 language semantics.
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            languageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_9)
            apiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_9)
        }
    }
}
