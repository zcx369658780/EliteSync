package com.elitesync.astro

import com.nlf.calendar.Solar
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.tan

object AstroCalculator {
    private val zodiac = listOf("白羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座", "天秤座", "天蝎座", "射手座", "摩羯座", "水瓶座", "双鱼座")
    private val wuXingOrder = listOf("木", "火", "土", "金", "水")
    private val dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")
    private val stemToWuXing = mapOf(
        "甲" to "木", "乙" to "木",
        "丙" to "火", "丁" to "火",
        "戊" to "土", "己" to "土",
        "庚" to "金", "辛" to "金",
        "壬" to "水", "癸" to "水"
    )

    fun calculate(
        birthday: String,
        birthTime: String,
        gender: String,
        birthLat: Double?,
        birthLng: Double?,
        zoneId: ZoneId = ZoneId.systemDefault()
    ): AstroProfileResult? {
        val date = runCatching { LocalDate.parse(birthday) }.getOrNull() ?: return null
        val time = runCatching { LocalTime.parse(birthTime) }.getOrNull() ?: return null
        val local = LocalDateTime.of(date, time)
        val instant = local.atZone(zoneId).toInstant()
        val notes = mutableListOf<String>()

        val sunLon = sunLongitude(instant)
        val sunSign = signOf(sunLon)

        val moonLon = moonLongitudeApprox(instant)
        val moonSign = signOf(moonLon)

        val ascSign = if (birthLat != null && birthLng != null) {
            signOf(ascendantLongitude(instant, birthLat, birthLng))
        } else {
            notes += "未提供出生地经纬度，无法计算上升星座。"
            null
        }

        if (birthLng != null) {
            // True solar time correction for China baseline 120E.
            val correctionMinutes = ((birthLng - 120.0) * 4.0).toInt()
            val corrected = local.plusMinutes(correctionMinutes.toLong())
            val solar = Solar.fromYmdHms(
                corrected.year,
                corrected.monthValue,
                corrected.dayOfMonth,
                corrected.hour,
                corrected.minute,
                corrected.second
            )
            val eight = solar.lunar.eightChar
            val baziText = "${eight.year} ${eight.month} ${eight.day} ${eight.time}"
            val daYunList = buildDaYun(eight, gender)
            val liuNianList = buildLiuNian(eight, gender)
            val wuXingMap = buildWuXing(eight)
            return AstroProfileResult(
                sunSign = sunSign,
                moonSign = moonSign,
                ascSign = ascSign,
                bazi = baziText,
                trueSolarTime = corrected.format(dtf),
                daYun = daYunList,
                liuNian = liuNianList,
                wuXing = wuXingMap,
                notes = notes
            )
        } else {
            notes += "未提供出生地经度，八字按标准时区时间计算可能有偏差。"
            val solar = Solar.fromYmdHms(
                local.year,
                local.monthValue,
                local.dayOfMonth,
                local.hour,
                local.minute,
                local.second
            )
            val eight = solar.lunar.eightChar
            val baziText = "${eight.year} ${eight.month} ${eight.day} ${eight.time}"
            val daYunList = buildDaYun(eight, gender)
            val liuNianList = buildLiuNian(eight, gender)
            val wuXingMap = buildWuXing(eight)
            return AstroProfileResult(
                sunSign = sunSign,
                moonSign = moonSign,
                ascSign = ascSign,
                bazi = baziText,
                trueSolarTime = null,
                daYun = daYunList,
                liuNian = liuNianList,
                wuXing = wuXingMap,
                notes = notes
            )
        }
    }

    private fun buildDaYun(eight: com.nlf.calendar.EightChar, gender: String): List<DaYunResult> {
        val yun = eight.getYun(if (gender == "female") 0 else 1)
        return yun.getDaYun(8)
            .filter { it.index > 0 }
            .map {
                DaYunResult(
                    index = it.index,
                    ganZhi = it.ganZhi,
                    startYear = it.startYear,
                    endYear = it.endYear,
                    startAge = it.startAge,
                    endAge = it.endAge
                )
            }
    }

    private fun buildLiuNian(eight: com.nlf.calendar.EightChar, gender: String): List<LiuNianResult> {
        val yun = eight.getYun(if (gender == "female") 0 else 1)
        val daYunRaw = yun.getDaYun(8).filter { it.index > 0 }
        if (daYunRaw.isEmpty()) return emptyList()
        val year = LocalDate.now().year
        val hit = daYunRaw.firstOrNull { year in it.startYear..it.endYear } ?: daYunRaw.first()
        return hit.getLiuNian(10).map {
            LiuNianResult(
                year = it.year,
                age = it.age,
                ganZhi = it.ganZhi
            )
        }
    }

    private fun buildWuXing(eight: com.nlf.calendar.EightChar): Map<String, Int> {
        val score = linkedMapOf(
            "木" to 0.0,
            "火" to 0.0,
            "土" to 0.0,
            "金" to 0.0,
            "水" to 0.0
        )

        listOf(
            eight.yearWuXing,
            eight.monthWuXing,
            eight.dayWuXing,
            eight.timeWuXing
        ).forEach { pair ->
            pair.forEach { ch ->
                val e = ch.toString()
                if (score.containsKey(e)) {
                    score[e] = (score[e] ?: 0.0) + 1.0
                }
            }
        }

        val hideGan = buildList {
            addAll(eight.yearHideGan)
            addAll(eight.monthHideGan)
            addAll(eight.dayHideGan)
            addAll(eight.timeHideGan)
        }
        hideGan.forEach { gan ->
            val e = stemToWuXing[gan] ?: return@forEach
            score[e] = (score[e] ?: 0.0) + 0.5
        }

        return wuXingOrder.associateWith { element ->
            ((score[element] ?: 0.0) * 10.0).toInt()
        }
    }

    private fun signOf(lambdaDeg: Double): String {
        val idx = floor(norm360(lambdaDeg) / 30.0).toInt().coerceIn(0, 11)
        return zodiac[idx]
    }

    private fun sunLongitude(instant: Instant): Double {
        val d = julianDay(instant) - 2451543.5
        val w = 282.9404 + 4.70935e-5 * d
        val e = 0.016709 - 1.151e-9 * d
        val m = norm360(356.0470 + 0.9856002585 * d)
        val mRad = Math.toRadians(m)
        val eAnom = m + Math.toDegrees(e * sin(mRad) * (1.0 + e * cos(mRad)))
        val eRad = Math.toRadians(eAnom)
        val xv = cos(eRad) - e
        val yv = sqrt(1.0 - e * e) * sin(eRad)
        val v = Math.toDegrees(atan2(yv, xv))
        return norm360(v + w)
    }

    private fun moonLongitudeApprox(instant: Instant): Double {
        val d = julianDay(instant) - 2451543.5
        val n = norm360(125.1228 - 0.0529538083 * d)
        val i = 5.1454
        val w = norm360(318.0634 + 0.1643573223 * d)
        val a = 60.2666
        val e = 0.0549
        val m = norm360(115.3654 + 13.0649929509 * d)
        val e0 = m + Math.toDegrees(e * sin(Math.toRadians(m)) * (1.0 + e * cos(Math.toRadians(m))))
        val xv = a * (cos(Math.toRadians(e0)) - e)
        val yv = a * (sqrt(1 - e * e) * sin(Math.toRadians(e0)))
        val v = Math.toDegrees(atan2(yv, xv))
        val r = sqrt(xv * xv + yv * yv)

        val xh = r * (cos(Math.toRadians(n)) * cos(Math.toRadians(v + w)) - sin(Math.toRadians(n)) * sin(Math.toRadians(v + w)) * cos(Math.toRadians(i)))
        val yh = r * (sin(Math.toRadians(n)) * cos(Math.toRadians(v + w)) + cos(Math.toRadians(n)) * sin(Math.toRadians(v + w)) * cos(Math.toRadians(i)))

        var lon = Math.toDegrees(atan2(yh, xh))
        // First-order perturbation to reduce sign-boundary errors.
        val sunLon = sunLongitude(instant)
        val dArg = norm360(lon - sunLon)
        lon += -1.274 * sin(Math.toRadians(m - 2 * dArg))
        lon += 0.658 * sin(Math.toRadians(2 * dArg))
        lon += -0.186 * sin(Math.toRadians(norm360(356.0470 + 0.9856002585 * d)))
        return norm360(lon)
    }

    private fun ascendantLongitude(instant: Instant, latDeg: Double, lonDeg: Double): Double {
        val jd = julianDay(instant)
        val t = (jd - 2451545.0) / 36525.0
        val gmst = norm360(
            280.46061837 +
                360.98564736629 * (jd - 2451545.0) +
                0.000387933 * t * t -
                t * t * t / 38710000.0
        )
        val lst = norm360(gmst + lonDeg)
        val eps = Math.toRadians(23.439291 - 0.0130042 * t)
        val phi = Math.toRadians(latDeg.coerceIn(-66.0, 66.0))
        val theta = Math.toRadians(lst)
        val raw = Math.toDegrees(
            atan2(
                -cos(theta),
                sin(theta) * cos(eps) - tan(phi) * sin(eps)
            )
        )
        return norm360(raw)
    }

    private fun julianDay(instant: Instant): Double {
        return instant.toEpochMilli() / 86400000.0 + 2440587.5
    }

    private fun norm360(x: Double): Double {
        var r = x % 360.0
        if (r < 0) r += 360.0
        return r
    }
}
