package com.elitesync

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
                                "debugRefreshToken" to (extras?.getString("elitesync_debug_refresh_token") ?: ""),
                                "debugAutoLoginPhone" to (extras?.getString("elitesync_debug_auto_login_phone") ?: ""),
                                "debugAutoLoginPassword" to (extras?.getString("elitesync_debug_auto_login_password") ?: ""),
                                "chatMock" to (extras?.get("elitesync_chat_mock")?.toString() ?: "false"),
                                "adminMock" to (extras?.get("elitesync_admin_mock")?.toString() ?: "false"),
                                "initialRoute" to (extras?.getString("elitesync_initial_route") ?: ""),
                                "debugBuild" to BuildConfig.DEBUG.toString(),
                            ),
                        )
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
