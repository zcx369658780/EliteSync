package com.elitesync.ui

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import java.net.URLEncoder

object MapIntentBridge {
    private const val BAIDU_PKG = "com.baidu.BaiduMap"

    fun openBaiduMapSearch(context: Context, query: String): Boolean {
        val q = URLEncoder.encode(query.ifBlank { "位置" }, "UTF-8")
        val uri = Uri.parse("baidumap://map/place/search?query=$q&region=全国&src=elitesync")
        return openBaiduMapUri(context, uri)
    }

    fun openBaiduMapAt(context: Context, lat: Double, lng: Double, title: String = "当前位置"): Boolean {
        val t = URLEncoder.encode(title, "UTF-8")
        val uri = Uri.parse("baidumap://map/marker?location=$lat,$lng&title=$t&content=$t&src=elitesync")
        return openBaiduMapUri(context, uri)
    }

    private fun openBaiduMapUri(context: Context, uri: Uri): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                setPackage(BAIDU_PKG)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }

    fun openBaiduWebSearch(context: Context, query: String): Boolean {
        val q = URLEncoder.encode(query.ifBlank { "位置" }, "UTF-8")
        val web = Uri.parse("https://map.baidu.com/search/$q")
        return try {
            context.startActivity(
                Intent(Intent.ACTION_VIEW, web).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
            true
        } catch (_: Exception) {
            false
        }
    }

    fun openBaiduSearchSmart(context: Context, query: String): Boolean {
        // 模拟器上百度地图APP经常因架构/服务兼容问题崩溃，优先走网页更稳定。
        return if (isLikelyEmulator()) {
            openBaiduWebSearch(context, query)
        } else {
            openBaiduMapSearch(context, query) || openBaiduWebSearch(context, query)
        }
    }

    private fun isLikelyEmulator(): Boolean {
        val fp = Build.FINGERPRINT ?: ""
        val model = Build.MODEL ?: ""
        val brand = Build.BRAND ?: ""
        val device = Build.DEVICE ?: ""
        val product = Build.PRODUCT ?: ""
        return fp.contains("generic", true) ||
            fp.contains("emulator", true) ||
            model.contains("Emulator", true) ||
            model.contains("Android SDK built for", true) ||
            brand.startsWith("generic", true) ||
            device.startsWith("generic", true) ||
            product.contains("sdk", true)
    }

    /**
     * 支持从“百度地图分享文本/链接”中提取坐标，常见格式:
     * 1) "...lat,lng..."
     * 2) "...location=lat,lng..."
     * 3) "...latlng:lat,lng..."
     */
    fun extractLatLng(text: String): Pair<Double, Double>? {
        val patterns = listOf(
            Regex("""location=([-+]?\d+(\.\d+)?),\s*([-+]?\d+(\.\d+)?)""", RegexOption.IGNORE_CASE),
            Regex("""latlng[:=]([-+]?\d+(\.\d+)?),\s*([-+]?\d+(\.\d+)?)""", RegexOption.IGNORE_CASE),
            Regex("""([-+]?\d{1,2}\.\d+),\s*([-+]?\d{1,3}\.\d+)""")
        )
        for (p in patterns) {
            val m = p.find(text) ?: continue
            val lat = m.groupValues[1].toDoubleOrNull() ?: continue
            val lng = m.groupValues[3].toDoubleOrNull() ?: continue
            if (lat in -90.0..90.0 && lng in -180.0..180.0) {
                return lat to lng
            }
        }
        return null
    }
}
