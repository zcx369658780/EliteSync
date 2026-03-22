package com.elitesync

import android.app.Application
import android.util.Log
import com.baidu.mapapi.CoordType
import com.baidu.mapapi.SDKInitializer

class EliteSyncApp : Application() {
    companion object {
        private const val TAG = "EliteSyncApp"

        // For local jar/so integration, explicitly load Baidu native libs first.
        // This avoids JNI method lookup races during SDK bootstrap.
        private val REQUIRED_LIBS = listOf(
            "c++_shared",
            "tiny_magic",
            "locSDK8b",
            "BaiduMapSDK_base_v7_6_7",
            "BaiduMapSDK_map_v7_6_7"
        )
    }

    override fun onCreate() {
        super.onCreate()
        REQUIRED_LIBS.forEach { lib ->
            runCatching { System.loadLibrary(lib) }
                .onFailure { Log.w(TAG, "loadLibrary failed: $lib -> ${it.message}") }
        }
        SDKInitializer.setAgreePrivacy(this, true)
        SDKInitializer.initialize(this)
        SDKInitializer.setCoordType(CoordType.BD09LL)
    }
}
