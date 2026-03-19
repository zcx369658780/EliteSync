package com.elitesync.ws

import com.elitesync.BuildConfig
import com.elitesync.network.DomainDns
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import org.json.JSONObject

class ChatSocketManager(
    private val onText: (String) -> Unit
) {
    private val client = OkHttpClient.Builder()
        .dns(DomainDns)
        .build()
    private var socket: WebSocket? = null
    private val wsBaseUrl: String = BuildConfig.WS_BASE_URL.ifBlank { "wss://slowdate.top/" }

    fun connect(userId: Int) {
        socket?.close(1000, "reconnect")
        val wsUrl = wsBaseUrl.trimEnd('/') + "/api/v1/messages/ws/$userId"
        val req = Request.Builder().url(wsUrl).build()
        socket = client.newWebSocket(req, object : WebSocketListener() {
            override fun onMessage(webSocket: WebSocket, text: String) {
                val content = runCatching {
                    val payload = JSONObject(text)
                    if (payload.optString("type") == "message") {
                        payload.optString("content")
                    } else {
                        ""
                    }
                }.getOrDefault("")

                if (content.isNotBlank()) {
                    onText("对方: $content")
                }
            }
        })
    }

    fun heartbeat() {
        socket?.send("ping")
    }

    fun close() {
        socket?.close(1000, "bye")
    }
}
