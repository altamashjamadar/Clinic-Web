// Top-level build file
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    
    val kotlin_version = "1.9.24" // added the line
    dependencies {
        // Required for Kotlin + Android
        classpath("com.android.tools.build:gradle:8.5.0")  // Latest stable
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24")  // Latest Kotlin
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory (Flutter 3.22+)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}