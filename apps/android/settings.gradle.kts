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
        google()
        mavenCentral()
        maven(url = uri("../flutter_elitesync_module/build/host/outputs/repo"))
        maven(url = uri("https://storage.googleapis.com/download.flutter.io"))
        maven(url = "https://maven.baidubce.com/repository/maven/")
    }
}

rootProject.name = "EliteSyncAndroid"
include(":app")
