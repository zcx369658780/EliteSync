import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}
val baiduAkFromProp = (project.findProperty("BAIDU_MAP_AK") as String?)
    ?: localProps.getProperty("BAIDU_MAP_AK", "")
val baiduSecurityCodeFromProp = (project.findProperty("BAIDU_MAP_SECURITY_CODE") as String?)
    ?: localProps.getProperty("BAIDU_MAP_SECURITY_CODE", "")

val flutterModuleDir = rootProject.file("../flutter_elitesync_module")
val flutterModuleLocalProps = Properties().apply {
    val f = rootProject.file("../flutter_elitesync_module/.android/local.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}
val flutterSdkPath = flutterModuleLocalProps.getProperty("flutter.sdk")
    ?: localProps.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_HOME")
val flutterExecutable = when {
    !flutterSdkPath.isNullOrBlank() -> {
        val suffix = if (System.getProperty("os.name").lowercase().contains("windows")) "flutter.bat" else "flutter"
        File(flutterSdkPath, "bin/$suffix").absolutePath
    }
    System.getProperty("os.name").lowercase().contains("windows") -> "flutter.bat"
    else -> "flutter"
}

val flutterDartDefines = (
    providers.gradleProperty("flutterDartDefines").orNull
        ?: rootProject.findProperty("flutterDartDefines") as String?
        ?: project.findProperty("flutterDartDefines") as String?
    )
    ?.trim()
    .orEmpty()
val flutterDartDefineArgs = flutterDartDefines
    .split(Regex("[;,]"))
    .map { it.trim() }
    .filter { it.isNotEmpty() }
    .flatMap { listOf("--dart-define=$it") }

val syncFlutterAar by tasks.registering(Exec::class) {
    group = "build"
    description = "Build latest Flutter module AAR before Android preBuild"
    workingDir = flutterModuleDir
    commandLine(
        listOf(
            flutterExecutable,
            "build",
            "aar",
            "--no-debug",
            "--no-profile",
        ) + flutterDartDefineArgs
    )
    inputs.dir(File(flutterModuleDir, "lib"))
    inputs.file(File(flutterModuleDir, "pubspec.yaml"))
    inputs.property("flutterDartDefines", flutterDartDefines)
    outputs.dir(File(flutterModuleDir, "build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0"))
}

tasks.named("preBuild") {
    dependsOn(syncFlutterAar)
}

android {
    namespace = "com.elitesync"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.elitesync"
        minSdk = 26
        targetSdk = 34
        // Versioning rule: major.minor.patch (e.g. 0.01.01)
        // major: product major stage (0 before launch, 1+ after launch)
        // minor: 01=Alpha, 02-99=Beta
        // patch: current stage incremental version
        versionCode = 209
        versionName = "0.02.09"
        ndk {
            // Google Play 16KB page-size compliance: avoid x86_64 native libs from third-party SDKs.
            // Keep ARM ABIs for real-device testing and release publishing.
            abiFilters += listOf("arm64-v8a")
        }
        buildConfigField("String", "API_BASE_URL", "\"https://slowdate.top/\"")
        buildConfigField("String", "WS_BASE_URL", "\"wss://slowdate.top/\"")
        buildConfigField("String", "BAIDU_MAP_AK", "\"$baiduAkFromProp\"")
        buildConfigField("String", "BAIDU_MAP_SECURITY_CODE", "\"$baiduSecurityCodeFromProp\"")
        buildConfigField("boolean", "ENABLE_BAIDU_NATIVE_SDK", "false")
        manifestPlaceholders["BAIDU_MAP_AK"] = baiduAkFromProp

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        debug {
            buildConfigField("String", "API_BASE_URL", "\"http://101.133.161.203/\"")
            buildConfigField("String", "WS_BASE_URL", "\"ws://101.133.161.203:8081/\"")
            buildConfigField("String", "BAIDU_MAP_AK", "\"$baiduAkFromProp\"")
            buildConfigField("String", "BAIDU_MAP_SECURITY_CODE", "\"$baiduSecurityCodeFromProp\"")
            buildConfigField("boolean", "ENABLE_BAIDU_NATIVE_SDK", "false")
        }
        create("profile") {
            initWith(getByName("debug"))
            matchingFallbacks += listOf("debug")
        }
        release {
            isMinifyEnabled = false
            buildConfigField("String", "API_BASE_URL", "\"https://slowdate.top/\"")
            buildConfigField("String", "WS_BASE_URL", "\"wss://slowdate.top/\"")
            buildConfigField("String", "BAIDU_MAP_AK", "\"$baiduAkFromProp\"")
            buildConfigField("String", "BAIDU_MAP_SECURITY_CODE", "\"$baiduSecurityCodeFromProp\"")
            buildConfigField("boolean", "ENABLE_BAIDU_NATIVE_SDK", "false")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures { buildConfig = true }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("libs")
        }
    }

    packaging {
        jniLibs {
            excludes += setOf("**/libVkLayer_khronos_validation.so")
        }
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

kotlin {
    jvmToolchain(17)
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.3")
    // XML theme resources like Theme.Material3.DayNight.NoActionBar
    implementation("com.google.android.material:material:1.12.0")

    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    implementation(files("libs/BaiduLBS_Android.jar"))
    implementation("cn.6tail:lunar:1.7.7")
    implementation("com.google.android.gms:play-services-location:21.3.0")
    // Use release AAR for debug installs to reduce APK size and startup/runtime jank.
    debugImplementation("com.elitesync.flutter_elitesync_module:flutter_release:1.0")
    add("profileImplementation", "com.elitesync.flutter_elitesync_module:flutter_profile:1.0")
    releaseImplementation("com.elitesync.flutter_elitesync_module:flutter_release:1.0")
}

configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.browser:browser:1.8.0")
    }
}



