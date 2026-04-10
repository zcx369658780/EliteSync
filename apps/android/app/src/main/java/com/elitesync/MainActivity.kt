package com.elitesync

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
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
                        result.success(
                            mapOf(
                                "debugAccessToken" to (extras?.getString("elitesync_debug_access_token") ?: ""),
                                "debugAccessTokenB64" to (extras?.getString("elitesync_debug_access_token_b64") ?: ""),
                                "debugRefreshToken" to (extras?.getString("elitesync_debug_refresh_token") ?: ""),
                                "debugAutoLoginPhone" to (extras?.getString("elitesync_debug_auto_login_phone") ?: ""),
                                "debugAutoLoginPassword" to (extras?.getString("elitesync_debug_auto_login_password") ?: ""),
                                "apiBaseUrl" to (extras?.getString("elitesync_api_base_url") ?: ""),
                                "wsBaseUrl" to (extras?.getString("elitesync_ws_base_url") ?: ""),
                                "chatMock" to readBootstrapBool("elitesync_chat_mock").toString(),
                                "adminMock" to readBootstrapBool("elitesync_admin_mock").toString(),
                                "initialRoute" to (extras?.getString("elitesync_initial_route") ?: ""),
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
