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
            "BaiduMapSDK_base_v8_0_0",
            "BaiduMapSDK_map_v8_0_0"
        )
    }

    override fun onCreate() {
        super.onCreate()
        if (!BuildConfig.ENABLE_BAIDU_NATIVE_SDK) {
            Log.i(TAG, "Baidu native SDK bootstrap disabled for current Flutter host build")
            return
        }
        REQUIRED_LIBS.forEach { lib ->
            runCatching { System.loadLibrary(lib) }
                .onFailure { Log.w(TAG, "loadLibrary failed: $lib -> ${it.message}") }
        }
        val ak = BuildConfig.BAIDU_MAP_AK
        if (ak.isNotBlank()) {
            runCatching {
                val m = SDKInitializer::class.java.getDeclaredMethod("setApiKey", String::class.java)
                m.isAccessible = true
                m.invoke(null, ak)
                Log.i(TAG, "SDKInitializer.setApiKey invoked by reflection")
            }.onFailure {
                Log.w(TAG, "setApiKey reflection unavailable: ${it.message}")
            }
        } else {
            Log.e(TAG, "BAIDU_MAP_AK is blank in BuildConfig")
        }
        SDKInitializer.setAgreePrivacy(this, true)
        SDKInitializer.initialize(this)
        SDKInitializer.setCoordType(CoordType.BD09LL)
    }
}
