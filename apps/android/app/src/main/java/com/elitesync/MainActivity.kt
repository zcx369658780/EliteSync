package com.elitesync

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setIntent(intent)
        ensureBootstrapDefaults()
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        ensureBootstrapDefaults()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "elitesync/bootstrap")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBootstrap" -> {
                        val extras = intent?.extras
                        val fileBootstrap = readBootstrapFile()
                        result.success(
                            mapOf(
                                "debugAccessToken" to firstNonBlank(
                                    extras?.getString("elitesync_debug_access_token"),
                                    fileBootstrap["elitesync_debug_access_token"],
                                ),
                                "debugAccessTokenB64" to firstNonBlank(
                                    extras?.getString("elitesync_debug_access_token_b64"),
                                    fileBootstrap["elitesync_debug_access_token_b64"],
                                ),
                                "debugRefreshToken" to firstNonBlank(
                                    extras?.getString("elitesync_debug_refresh_token"),
                                    fileBootstrap["elitesync_debug_refresh_token"],
                                ),
                                "debugAutoLoginPhone" to firstNonBlank(
                                    extras?.getString("elitesync_debug_auto_login_phone"),
                                    fileBootstrap["elitesync_debug_auto_login_phone"],
                                ),
                                "debugAutoLoginPassword" to firstNonBlank(
                                    extras?.getString("elitesync_debug_auto_login_password"),
                                    fileBootstrap["elitesync_debug_auto_login_password"],
                                ),
                                "apiBaseUrl" to firstNonBlank(
                                    extras?.getString("elitesync_api_base_url"),
                                    fileBootstrap["elitesync_api_base_url"],
                                ),
                                "wsBaseUrl" to firstNonBlank(
                                    extras?.getString("elitesync_ws_base_url"),
                                    fileBootstrap["elitesync_ws_base_url"],
                                ),
                                "chatMock" to readBootstrapBool("elitesync_chat_mock").toString(),
                                "adminMock" to readBootstrapBool("elitesync_admin_mock").toString(),
                                "initialRoute" to firstNonBlank(
                                    extras?.getString("elitesync_initial_route"),
                                    fileBootstrap["elitesync_initial_route"],
                                ),
                                "appVersionName" to BuildConfig.VERSION_NAME,
                                "appVersionCode" to BuildConfig.VERSION_CODE.toString(),
                                "debugBuild" to BuildConfig.DEBUG.toString(),
                            ),
                        )
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun ensureBootstrapDefaults() {
        val currentIntent = intent ?: return
        if (currentIntent.getStringExtra("elitesync_api_base_url").isNullOrBlank()) {
            currentIntent.putExtra("elitesync_api_base_url", BuildConfig.API_BASE_URL)
        }
        if (currentIntent.getStringExtra("elitesync_ws_base_url").isNullOrBlank()) {
            currentIntent.putExtra("elitesync_ws_base_url", BuildConfig.WS_BASE_URL)
        }
    }

    private fun readBootstrapFile(): Map<String, String> {
        val bootstrapFile = File(filesDir, "elitesync_bootstrap.json")
        if (!bootstrapFile.exists()) return emptyMap()
        return runCatching {
            val json = JSONObject(bootstrapFile.readText())
            buildMap {
                json.keys().forEach { key ->
                    put(key, json.optString(key, ""))
                }
            }
        }.getOrDefault(emptyMap())
    }

    private fun firstNonBlank(first: String?, second: String?): String {
        val firstValue = first?.trim().orEmpty()
        if (firstValue.isNotEmpty()) return firstValue
        return second?.trim().orEmpty()
    }

    private fun readBootstrapBool(name: String): Boolean {
        val currentIntent = intent ?: return false
        if (currentIntent.hasExtra(name)) {
            val boolValue = currentIntent.getBooleanExtra(name, false)
            if (boolValue || currentIntent.extras?.getString(name).isNullOrBlank()) {
                return boolValue
            }
        }
        return currentIntent.extras?.getString(name)?.toBooleanStrictOrNull() ?: false
    }
}
