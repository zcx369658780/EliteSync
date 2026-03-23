package com.elitesync.network

import com.google.gson.JsonParser
import retrofit2.HttpException
import java.net.ConnectException
import java.net.SocketTimeoutException
import java.io.IOException
import java.net.UnknownHostException
import javax.net.ssl.SSLException

object NetworkErrorMapper {
    fun message(throwable: Throwable): String {
        if (throwable is UnknownHostException) {
            val detail = throwable.message?.takeIf { it.isNotBlank() } ?: "unknown host"
            return "域名解析失败: $detail"
        }

        if (throwable is SSLException) {
            return "SSL 连接失败，请检查设备时间或证书链"
        }

        if (throwable is SocketTimeoutException) {
            return "请求超时，请稍后重试"
        }

        if (throwable is ConnectException) {
            return "无法连接服务器，请稍后重试"
        }

        if (throwable is IOException) {
            return "网络不可用，请检查网络连接后重试"
        }

        if (throwable is HttpException) {
            val body = runCatching { throwable.response()?.errorBody()?.string() }.getOrNull()
            if (!body.isNullOrBlank()) {
                val parsed = runCatching { JsonParser.parseString(body).asJsonObject }.getOrNull()
                val explicitMsg = parsed
                    ?.getAsJsonObject("error")
                    ?.get("message")
                    ?.asString
                    ?: parsed?.get("message")?.asString

                if (!explicitMsg.isNullOrBlank()) {
                    return normalizeValidationMessage(explicitMsg)
                }

                val errorsObj = parsed?.getAsJsonObject("errors")
                if (errorsObj != null) {
                    val firstMessage = errorsObj.entrySet()
                        .firstNotNullOfOrNull { entry ->
                            entry.value?.asJsonArray?.firstOrNull()?.asString
                        }
                    if (!firstMessage.isNullOrBlank()) {
                        return normalizeValidationMessage(firstMessage)
                    }
                }
            }
            return mapHttpCode(throwable.code())
        }

        return throwable.message ?: throwable.javaClass.simpleName
    }

    private fun normalizeValidationMessage(raw: String): String {
        val msg = raw.trim()
        val lower = msg.lowercase()
        return when {
            lower.contains("password") &&
                (lower.contains("letter") || lower.contains("number") || lower.contains("least 8")) ->
                "密码格式错误：至少8位，且必须包含字母和数字"
            lower.contains("phone") && lower.contains("required") ->
                "手机号不能为空"
            lower.contains("phone") && (lower.contains("invalid") || lower.contains("format")) ->
                "手机号格式错误，请输入11位中国大陆手机号（如 13800138000）"
            lower.contains("route") && lower.contains("could not be found") ->
                "当前功能服务端暂未发布，请稍后重试"
            lower.contains("sqlstate") ->
                "服务暂时不可用，请稍后重试"
            else -> msg
        }
    }

    private fun mapHttpCode(code: Int): String {
        return when (code) {
            400 -> "请求参数错误，请检查填写内容"
            401 -> "登录状态已失效，请重新登录"
            403 -> "当前操作无权限"
            404 -> "服务端接口暂不可用"
            409 -> "数据冲突，请刷新后重试"
            422 -> "提交内容不符合要求，请检查后重试"
            429 -> "请求过于频繁，请稍后重试"
            500 -> "服务端处理异常，请稍后重试"
            502, 503, 504 -> "服务暂时不可用，请稍后重试"
            else -> "请求失败（HTTP $code）"
        }
    }
}
