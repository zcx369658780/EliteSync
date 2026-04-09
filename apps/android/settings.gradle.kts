pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    // Flutter module Gradle plugin adds transient repositories during module integration.
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        maven(url = uri("../flutter_elitesync_module/build/host/outputs/repo"))
        google()
        mavenCentral()
        val flutterStorageBaseUrl =
            System.getenv("FLUTTER_STORAGE_BASE_URL")
                ?.trim()
                ?.takeIf { it.isNotEmpty() }
                ?: "https://storage.googleapis.com"
        maven(url = uri("$flutterStorageBaseUrl/download.flutter.io"))
    }
}

rootProject.name = "EliteSyncAndroid"
include(":app")
