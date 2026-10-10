allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Fix for isar_flutter_libs "Namespace not specified" and "compileSdk 30" errors
subprojects {
    project.plugins.withId("com.android.library") {
        project.extensions.findByName("android")?.let { androidExt ->
            try {
                // Force compileSdk to 34 to satisfy AndroidX requirements
                val compileSdkMethod = androidExt.javaClass.getMethod("compileSdkVersion", Int::class.java)
                compileSdkMethod.invoke(androidExt, 34)
            } catch (e: Exception) {
                try {
                    val setCompileSdkMethod = androidExt.javaClass.getMethod("setCompileSdk", Int::class.java)
                    setCompileSdkMethod.invoke(androidExt, 34)
                } catch (e2: Exception) {}
            }

            try {
                val getNamespaceMethod = androidExt.javaClass.getMethod("getNamespace")
                val namespace = getNamespaceMethod.invoke(androidExt)
                if (namespace == null) {
                    val setNamespaceMethod = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespaceMethod.invoke(androidExt, "dev.isar.${project.name.replace("-", "_")}")
                }
            } catch (e: Exception) {
                // Ignore if methods don't exist
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
