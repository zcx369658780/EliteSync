package com.elitesync.network

import com.google.gson.JsonParser
import retrofit2.HttpException
import java.io.IOException
import java.net.UnknownHostException
import javax.net.ssl.SSLException

object NetworkErrorMapper {
    fun message(throwable: Throwable): String {
        if (throwable is UnknownHostException) {
            return "域名解析失败，请检查设备 DNS/网络设置"
        }

        if (throwable is SSLException) {
            return "SSL 连接失败，请检查设备时间或证书链"
        }

        if (throwable is IOException) {
            return "网络不可用，请检查服务是否启动"
        }

        if (throwable is HttpException) {
            val body = runCatching { throwable.response()?.errorBody()?.string() }.getOrNull()
            if (!body.isNullOrBlank()) {
                val parsed = runCatching { JsonParser.parseString(body).asJsonObject }.getOrNull()
                val msg = parsed
                    ?.getAsJsonObject("error")
                    ?.get("message")
                    ?.asString
                    ?: parsed?.get("message")?.asString
                if (!msg.isNullOrBlank()) {
                    return msg
                }
            }
            return "HTTP ${throwable.code()}"
        }

        return throwable.message ?: throwable.javaClass.simpleName
    }
}
