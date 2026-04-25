pluginManagement {
    resolutionStrategy {
        eachPlugin {
            when (requested.id.id) {
                "com.android.application", "com.android.library" ->
                    useModule("com.android.tools.build:gradle:${requested.version}")
                "org.jetbrains.kotlin.android" ->
                    useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:${requested.version}")
            }
        }
    }
    repositories {
        maven(url = uri("file:///D:/EliteSync/gradle-local-m2")) {
            metadataSources {
                mavenPom()
                artifact()
            }
        }
        maven(url = "https://maven.aliyun.com/repository/gradle-plugin")
        maven(url = "https://maven.aliyun.com/repository/google")
        maven(url = "https://maven.aliyun.com/repository/public")
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    // Flutter module Gradle plugin adds transient repositories during module integration.
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        maven(url = uri("file:///D:/EliteSync/gradle-local-m2")) {
            metadataSources {
                mavenPom()
                artifact()
            }
        }
        maven(url = uri("../flutter_elitesync_module/build/host/outputs/repo"))
        maven(url = "https://maven.aliyun.com/repository/google")
        maven(url = "https://maven.aliyun.com/repository/public")
        maven(url = "https://maven.aliyun.com/repository/releases")
        google()
        mavenCentral()

        // Required for com.github.* dependencies such as audioswitch.
        maven(url = "https://jitpack.io")

        val flutterStorageBaseUrl =
            System.getenv("FLUTTER_STORAGE_BASE_URL")
                ?.trim()
                ?.takeIf { it.isNotEmpty() }
                ?: "https://storage.flutter-io.cn"
        maven(url = uri("$flutterStorageBaseUrl/download.flutter.io"))
    }
}
rootProject.name = "EliteSyncAndroid"
include(":app")
