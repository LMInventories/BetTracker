
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
    // (shared_preferences_android, flutter_local_notifications, etc.) may inherit the
    // installed JDK version (17 on CI) as their Java target. Force both to 11 to match.
    //
    // NOTE: options.release is blocked by AGP (prevents Android bootclasspath setup).
    //       Use sourceCompatibility/targetCompatibility on the task instead.
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }
    tasks.withType(JavaCompile::class.java).configureEach {
        sourceCompatibility = JavaVersion.VERSION_11.toString()
        targetCompatibility = JavaVersion.VERSION_11.toString()
    }
}
