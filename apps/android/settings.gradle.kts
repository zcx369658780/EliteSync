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
        maven(url = uri("https://storage.googleapis.com/download.flutter.io"))
    }
}

rootProject.name = "EliteSyncAndroid"
include(":app")
