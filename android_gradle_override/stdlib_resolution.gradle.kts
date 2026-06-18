
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

    // KGP 2.x (K2 compiler) enforces strict JVM-target consistency across subprojects.
    // tasks.withType(...).configureEach is lazy — no afterEvaluate needed, and safe
    // to call even after subprojects are already configured (avoids the
    // "Cannot run afterEvaluate when project is already evaluated" error).
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }
}
