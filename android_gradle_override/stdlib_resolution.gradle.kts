
// Kotlin DSL variant — appended when flutter create generates android/build.gradle.kts.

// Kotlin 1.8+ merged kotlin-stdlib-jdk7 and kotlin-stdlib-jdk8 into the main
// stdlib artifact. If any dependency still pulls in an old separate jdk7/jdk8
// artifact at a different version, Gradle raises a duplicate-class error.
allprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" &&
                requested.name in listOf("kotlin-stdlib-jdk8", "kotlin-stdlib-jdk7")) {
                useVersion("2.1.0")
            }
        }
    }
}

// Kotlin 2.x (K2 compiler) enforces a strict "inconsistent JVM-target" check.
// Plugin subprojects (workmanager, shared_preferences_android, etc.) may declare
// jvmTarget = "1.8" in their own build files while the toolchain expects "11".
// This override runs after each subproject is configured and wins over its own setting.
allprojects {
    afterEvaluate {
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class).configureEach {
            kotlinOptions.jvmTarget = "11"
        }
    }
}
