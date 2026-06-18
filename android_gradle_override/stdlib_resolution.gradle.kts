
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

    // KGP 2.x enforces strict Java/Kotlin JVM-target consistency. Plugin subprojects
    // (shared_preferences_android, workmanager, etc.) pick up the installed JDK version
    // for javac (17 on CI) while their Kotlin tasks may target a different version.
    // Force both to 11 so they match. No afterEvaluate — configureEach is lazy.
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }
    tasks.withType(JavaCompile::class.java).configureEach {
        options.release.set(11)
    }
}
