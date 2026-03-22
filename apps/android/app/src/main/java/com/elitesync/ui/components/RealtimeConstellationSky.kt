package com.elitesync.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import kotlinx.coroutines.delay
import kotlin.math.PI
import kotlin.math.asin
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin

private data class RealStarSpec(
    val id: String,
    val raHours: Double,
    val decDeg: Double,
    val mag: Float,
    val tint: Color = Color.White,
    val radiusBias: Float = 0f
)

private data class CatalogStar(
    val id: String?,
    val raRad: Double,
    val sinDec: Double,
    val cosDec: Double,
    val mag: Float,
    val layer: StarLayer,
    val tint: Color,
    val radiusBias: Float,
    val twinkle: TwinkleProfile
)

private data class ProjectedStar(
    val x: Float,
    val y: Float,
    val altitudeNorm: Float
)

private data class TwinkleProfile(
    val amplitude: Float,
    val speedHz: Float,
    val phase: Float,
    val driftAmplitude: Float,
    val driftSpeedHz: Float
)

private enum class StarLayer {
    DIM,
    NORMAL,
    BRIGHT
}

private data class ProjectionSpec(
    val centerX: Float,
    val centerY: Float,
    val radius: Float,
    val minAltitudeDeg: Float,
    val altitudeCurve: Float
)

enum class SkyPreset {
    LOGIN,
    APP
}

private val REAL_STARS = listOf(
    RealStarSpec("betelgeuse", 5.9195, 7.407, 0.50f, Color(0xFFFFD4B0), 0.35f),
    RealStarSpec("rigel", 5.2423, -8.201, 0.18f, Color(0xFFDDEBFF), 0.30f),
    RealStarSpec("bellatrix", 5.4189, 6.349, 1.64f, Color(0xFFEAF2FF), 0.18f),
    RealStarSpec("saiph", 5.7959, -9.669, 2.07f, Color(0xFFE5EEFF), 0.12f),
    RealStarSpec("mintaka", 5.5334, -0.299, 2.23f, Color(0xFFE7F0FF), 0.12f),
    RealStarSpec("alnilam", 5.6036, -1.201, 1.69f, Color(0xFFE7F0FF), 0.16f),
    RealStarSpec("alnitak", 5.6793, -1.943, 1.74f, Color(0xFFE8F0FF), 0.16f),
    RealStarSpec("sirius", 6.7525, -16.716, -1.46f, Color(0xFFE8F2FF), 0.50f),
    RealStarSpec("procyon", 7.6550, 5.225, 0.34f, Color(0xFFF8F8FF), 0.26f),
    RealStarSpec("aldebaran", 4.5987, 16.509, 0.87f, Color(0xFFFFD6A7), 0.30f),
    RealStarSpec("capella", 5.2782, 45.998, 0.08f, Color(0xFFFFE2B8), 0.32f),
    RealStarSpec("pollux", 7.7553, 28.026, 1.14f, Color(0xFFFFD9AF), 0.22f),
    RealStarSpec("castor", 7.5766, 31.888, 1.58f, Color(0xFFF1F5FF), 0.18f),
    RealStarSpec("regulus", 10.1395, 11.967, 1.36f, Color(0xFFEFF5FF), 0.18f),
    RealStarSpec("spica", 13.4199, -11.161, 0.97f, Color(0xFFD9E8FF), 0.22f),
    RealStarSpec("arcturus", 14.2610, 19.182, -0.05f, Color(0xFFFFC99A), 0.34f),
    RealStarSpec("denebola", 11.8177, 14.572, 2.14f, Color(0xFFF0F5FF), 0.10f),
    RealStarSpec("antares", 16.4901, -26.432, 1.06f, Color(0xFFFFB58A), 0.28f),
    RealStarSpec("shaula", 17.5601, -37.104, 1.62f, Color(0xFFE7F0FF), 0.16f),
    RealStarSpec("sargas", 17.6219, -42.997, 1.86f, Color(0xFFF4F4FF), 0.14f),
    RealStarSpec("vega", 18.6156, 38.783, 0.03f, Color(0xFFDDEBFF), 0.32f),
    RealStarSpec("deneb", 20.6905, 45.280, 1.25f, Color(0xFFE3EDFF), 0.22f),
    RealStarSpec("altair", 19.8464, 8.868, 0.77f, Color(0xFFF7F7FF), 0.26f),
    RealStarSpec("albireo", 19.5120, 27.959, 3.05f, Color(0xFFFFE3B8), 0.08f),
    RealStarSpec("fomalhaut", 22.9608, -29.622, 1.16f, Color(0xFFF6F8FF), 0.18f),
    RealStarSpec("markab", 23.0793, 15.205, 2.49f, Color(0xFFF1F5FF), 0.10f),
    RealStarSpec("scheat", 23.0629, 28.082, 2.42f, Color(0xFFFFF0D0), 0.10f),
    RealStarSpec("algenib", 0.2206, 15.183, 2.84f, Color(0xFFEFF5FF), 0.08f),
    RealStarSpec("alpheratz", 0.1398, 29.091, 2.06f, Color(0xFFE2EBFF), 0.12f),
    RealStarSpec("dubhe", 11.0621, 61.750, 1.79f, Color(0xFFFFE0B5), 0.14f),
    RealStarSpec("merak", 11.0307, 56.382, 2.37f, Color(0xFFF5F7FF), 0.10f),
    RealStarSpec("phecda", 11.8972, 53.694, 2.43f, Color(0xFFF2F6FF), 0.10f),
    RealStarSpec("megrez", 12.2570, 57.033, 3.31f, Color(0xFFF4F6FF), 0.08f),
    RealStarSpec("alioth", 12.9005, 55.960, 1.76f, Color(0xFFEAF1FF), 0.14f),
    RealStarSpec("mizar", 13.3987, 54.925, 2.23f, Color(0xFFE9F0FF), 0.10f),
    RealStarSpec("alkaid", 13.7923, 49.313, 1.85f, Color(0xFFDDEAFF), 0.14f),
    RealStarSpec("schedar", 0.6751, 56.537, 2.24f, Color(0xFFFFD7A8), 0.12f),
    RealStarSpec("caph", 0.1529, 59.150, 2.28f, Color(0xFFF3F6FF), 0.10f),
    RealStarSpec("gamma_cas", 0.9451, 60.717, 2.47f, Color(0xFFDCE8FF), 0.10f),
    RealStarSpec("ruchbah", 1.4303, 60.235, 2.68f, Color(0xFFF0F4FF), 0.08f)
)

private val CONSTELLATION_LINES = listOf(
    listOf(
        "betelgeuse" to "bellatrix",
        "bellatrix" to "mintaka",
        "mintaka" to "alnilam",
        "alnilam" to "alnitak",
        "alnitak" to "saiph",
        "saiph" to "rigel"
    ),
    listOf(
        "aldebaran" to "capella",
        "aldebaran" to "betelgeuse"
    ),
    listOf(
        "castor" to "pollux",
        "pollux" to "procyon"
    ),
    listOf(
        "regulus" to "denebola",
        "regulus" to "spica"
    ),
    listOf(
        "antares" to "sargas",
        "sargas" to "shaula"
    ),
    listOf(
        "vega" to "deneb",
        "deneb" to "altair",
        "altair" to "vega"
    ),
    listOf(
        "markab" to "scheat",
        "scheat" to "alpheratz",
        "alpheratz" to "algenib",
        "algenib" to "markab"
    ),
    listOf(
        "dubhe" to "merak",
        "merak" to "phecda",
        "phecda" to "megrez",
        "megrez" to "alioth",
        "alioth" to "mizar",
        "mizar" to "alkaid"
    ),
    listOf(
        "caph" to "schedar",
        "schedar" to "gamma_cas",
        "gamma_cas" to "ruchbah"
    )
)

@Composable
fun RealtimeConstellationSky(
    modifier: Modifier = Modifier,
    latitude: Double,
    longitude: Double,
    preset: SkyPreset = SkyPreset.APP,
    lowPerformanceMode: Boolean = false,
    panExternalX: Float = 0f,
    panExternalY: Float = 0f
) {
    val nowEpoch by produceState(initialValue = System.currentTimeMillis()) {
        if (lowPerformanceMode) {
            while (true) {
                value = System.currentTimeMillis()
                delay(66L)
            }
        } else {
            while (true) {
                withFrameNanos { frame ->
                    value = frame / 1_000_000L
                }
            }
        }
    }

    val realCatalog = remember { REAL_STARS.mapIndexed(::toCatalogStar) }
	val proceduralCatalog = remember(preset, lowPerformanceMode) {
		val count = when {
			preset == SkyPreset.LOGIN && lowPerformanceMode -> 520
			preset == SkyPreset.LOGIN -> 1400
			lowPerformanceMode -> 420
			else -> 980
		}
		buildProceduralCatalog(count)
	}

    Canvas(modifier = modifier.fillMaxSize()) {
        runCatching {
            val projection = projectionSpec(
                width = size.width,
                height = size.height,
                preset = preset,
                lowPerformanceMode = lowPerformanceMode,
                panX = panExternalX,
                panY = panExternalY
            )
            val latRad = latitude.toRad()
            val sinLat = sin(latRad)
            val cosLat = cos(latRad)
            val lstRad = localSiderealTimeRadians(nowEpoch, longitude)
            val epochSec = nowEpoch / 1000f
            val anchors = HashMap<String, ProjectedStar>(realCatalog.size)

            drawRect(
                brush = androidx.compose.ui.graphics.Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF000208),
                        Color(0xFF01040B),
                        Color(0xFF020813),
                        Color(0xFF030A16),
                        Color(0xFF040D1A)
                    )
                ),
                size = size
            )

            drawRect(
                brush = androidx.compose.ui.graphics.Brush.radialGradient(
                    colors = listOf(
                        Color(0x080E2342),
                        Color.Transparent,
                        Color(0xB0000104)
                    ),
                    center = Offset(size.width * 0.5f, size.height * 0.56f),
                    radius = max(size.width, size.height) * 0.98f
                ),
                size = size
            )

            realCatalog.forEach { star ->
                val projected = projectStar(
                    star = star,
                    lstRad = lstRad,
                    sinLat = sinLat,
                    cosLat = cosLat,
                    spec = projection
                ) ?: return@forEach
                val id = star.id ?: return@forEach
                anchors[id] = projected
            }

            fun drawLayer(layer: StarLayer, glow: Boolean = false) {
                proceduralCatalog.forEach { star ->
                    if (star.layer != layer) return@forEach
                    val projected = projectStar(
                        star = star,
                        lstRad = lstRad,
                        sinLat = sinLat,
                        cosLat = cosLat,
                        spec = projection
                    ) ?: return@forEach
                    drawProjectedStar(
                        star = star,
                        projected = projected,
                        epochSec = epochSec,
                        preset = preset,
                        lowPerformanceMode = lowPerformanceMode,
                        forceGlow = glow
                    )
                }
                realCatalog.forEach { star ->
                    if (star.layer != layer) return@forEach
                    val projected = anchors[star.id] ?: return@forEach
                    drawProjectedStar(
                        star = star,
                        projected = projected,
                        epochSec = epochSec,
                        preset = preset,
                        lowPerformanceMode = lowPerformanceMode,
                        forceGlow = glow
                    )
                }
            }

            drawLayer(StarLayer.DIM)
            drawLayer(StarLayer.NORMAL)
            drawLayer(StarLayer.BRIGHT, glow = true)

            // 先关闭星座线，避免背景再次变成“星图控件感”
// if (preset == SkyPreset.APP) {
//     drawConstellationHints(anchors, lowPerformanceMode)
// }
        }.onFailure {
            drawRect(
                brush = androidx.compose.ui.graphics.Brush.verticalGradient(
                    colors = listOf(Color(0xFF040814), Color(0xFF0D1732))
                ),
                size = size
            )
        }
    }
}

private fun toCatalogStar(index: Int, spec: RealStarSpec): CatalogStar {
    val decRad = spec.decDeg.toRad()
    return CatalogStar(
        id = spec.id,
        raRad = spec.raHours * 15.0.toRad(),
        sinDec = sin(decRad),
        cosDec = cos(decRad),
        mag = spec.mag,
        layer = classifyLayerByMagnitude(spec.mag, preferBright = false),
        tint = spec.tint,
        radiusBias = spec.radiusBias,
        twinkle = buildTwinkleProfile(
            index.toLong() * 17L + 11L,
            classifyLayerByMagnitude(spec.mag, preferBright = false)
        )
    )
}

private fun buildProceduralCatalog(count: Int): List<CatalogStar> {
    val stars = ArrayList<CatalogStar>(count)
    var i = 0

    while (stars.size < count && i < count * 8) {
        val index = i + 1
        val seed = 10_007L + index * 131L

        val x = halton(index, 2)
        val y = halton(index, 3)
        val z = halton(index, 5)

        val patchA = 0.5 + 0.5 * sin((x * 2.0 * PI * 1.25) + z * PI * 0.65)
        val patchB = 0.5 + 0.5 * cos((y * 2.0 * PI * 1.45) - x * PI * 0.55)
        val density = (0.16 + 0.34 * patchA * patchB).toFloat()

        if (seededUnit(seed + 211L) > density) {
            i++
            continue
        }

        val raHours = x * 24.0
        val sinDec = -1.0 + 2.0 * y
        val decRad = asin(sinDec)

        val faintBias = seededUnit(seed + 19L).toDouble().pow(0.82)
        val mag = (3.4 + faintBias * 2.0).toFloat() // 3.4 ~ 5.4，再提升整体可见度

        val layer = when {
            mag < 4.8f && seededUnit(seed + 29L) > 0.62f -> StarLayer.NORMAL
            mag < 4.35f && seededUnit(seed + 31L) > 0.82f -> StarLayer.BRIGHT
            else -> StarLayer.DIM
        }

        stars += CatalogStar(
            id = null,
            raRad = raHours * 15.0.toRad(),
            sinDec = sinDec,
            cosDec = cos(decRad),
            mag = mag,
            layer = layer,
            tint = proceduralStarTint(seed, layer),
            radiusBias = if (layer == StarLayer.BRIGHT && seededUnit(seed + 71L) > 0.88f) 0.06f else 0f,
            twinkle = buildTwinkleProfile(seed, layer)
        )
        i++
    }

    return stars
}

private fun buildTwinkleProfile(seed: Long, layer: StarLayer): TwinkleProfile {
    val baseAmp = when (layer) {
        StarLayer.DIM -> 0.002f + 0.004f * seededUnit(seed + 1L)
        StarLayer.NORMAL -> 0.045f + 0.070f * seededUnit(seed + 1L)
        StarLayer.BRIGHT -> 0.16f + 0.22f * seededUnit(seed + 1L)
    }

    val speed = when (layer) {
        StarLayer.DIM -> 0.020f + 0.015f * seededUnit(seed + 2L)
        StarLayer.NORMAL -> 0.080f + 0.070f * seededUnit(seed + 2L)
        StarLayer.BRIGHT -> 0.14f + 0.12f * seededUnit(seed + 2L)
    }

    val driftAmp = baseAmp * (0.30f + 0.55f * seededUnit(seed + 3L))
    val driftSpeed = 0.020f + 0.030f * seededUnit(seed + 4L)

    return TwinkleProfile(
        amplitude = baseAmp,
        speedHz = speed,
        phase = (2f * PI.toFloat()) * seededUnit(seed + 5L),
        driftAmplitude = driftAmp,
        driftSpeedHz = driftSpeed
    )
}

private fun projectStar(
    star: CatalogStar,
    lstRad: Double,
    sinLat: Double,
    cosLat: Double,
    spec: ProjectionSpec
): ProjectedStar? {
    val hourAngle = normalizeRadians(lstRad - star.raRad)
    val cosHa = cos(hourAngle)
    val sinAlt = star.sinDec * sinLat + star.cosDec * cosLat * cosHa
    val minAltSin = sin(spec.minAltitudeDeg.toDouble().toRad())
    if (sinAlt <= minAltSin) return null

    val altRad = asin(sinAlt)
    val azRad = atan2(
        -sin(hourAngle) * star.cosDec,
        star.sinDec * cosLat - star.cosDec * sinLat * cosHa
    )
    val azNorm = if (azRad < 0.0) azRad + 2.0 * PI else azRad
    val altDeg = altRad.toDeg().toFloat()
    val altitudeNorm = ((altDeg - spec.minAltitudeDeg) / (90f - spec.minAltitudeDeg)).coerceIn(0f, 1f)
    val distanceNorm = (1f - altitudeNorm).pow(spec.altitudeCurve)

    val x = spec.centerX + spec.radius * distanceNorm * sin(azNorm).toFloat()
    val y = spec.centerY - spec.radius * distanceNorm * cos(azNorm).toFloat()
    if (x < -12f || x > spec.centerX * 2f + 12f || y < -12f || y > spec.centerY * 1.8f + 24f) return null

    return ProjectedStar(x = x, y = y, altitudeNorm = altitudeNorm)
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawProjectedStar(
    star: CatalogStar,
    projected: ProjectedStar,
    epochSec: Float,
    preset: SkyPreset,
    lowPerformanceMode: Boolean,
    forceGlow: Boolean = false
) {
    val baseBrightness = magnitudeToBrightness(star.mag)
    val twinkle = twinkleAlpha(epochSec, star.twinkle, baseBrightness)

    val presetAlphaGain = if (preset == SkyPreset.LOGIN) 1.42f else 1.30f
    val presetRadiusGain = if (preset == SkyPreset.LOGIN) 1.07f else 1.03f

    val altitudeBoost = 0.86f + 0.30f * projected.altitudeNorm
    val contentSuppression = contentRegionFactor(
        x = projected.x,
        y = projected.y,
        preset = preset,
        layer = star.layer
    )

    val baseAlpha = (baseBrightness * altitudeBoost * presetAlphaGain * contentSuppression)
        .coerceIn(0.05f, 1.0f)

    val bodyPulseStrength = when (star.layer) {
        StarLayer.DIM -> 0.10f
        StarLayer.NORMAL -> 0.90f
        StarLayer.BRIGHT -> 1.50f
    }

    val bodyAlpha = (baseAlpha * (1f + (twinkle - 1f) * bodyPulseStrength)).coerceIn(
            when (star.layer) {
                StarLayer.DIM -> 0.05f
                StarLayer.NORMAL -> 0.10f
                StarLayer.BRIGHT -> 0.14f
            },
        when (star.layer) {
            StarLayer.DIM -> 0.40f
            StarLayer.NORMAL -> 0.98f
            StarLayer.BRIGHT -> 1.0f
        }
    )

    val baseRadius = magnitudeToRadius(
        mag = star.mag,
        layer = star.layer,
        radiusBias = star.radiusBias,
        altitudeNorm = projected.altitudeNorm,
        lowPerformanceMode = lowPerformanceMode
    ) * presetRadiusGain

    val radius = when (star.layer) {
        StarLayer.DIM -> baseRadius
        StarLayer.NORMAL -> baseRadius * (1f + (twinkle - 1f) * 0.01f).coerceIn(0.99f, 1.01f)
        StarLayer.BRIGHT -> baseRadius * (1f + (twinkle - 1f) * 0.02f).coerceIn(0.98f, 1.02f)
    }

    val canGlow = !lowPerformanceMode && (
        forceGlow || (star.layer == StarLayer.BRIGHT && star.mag <= 2.8f)
    )

    if (canGlow) {
        val glowAlpha = (bodyAlpha * 0.16f).coerceIn(0.03f, 0.24f)
        drawCircle(
            color = star.tint,
            radius = radius * (1.65f + 0.55f * baseBrightness),
            center = Offset(projected.x, projected.y),
            alpha = glowAlpha
        )
    }

    drawCircle(
        color = star.tint,
        radius = radius,
        center = Offset(projected.x, projected.y),
        alpha = bodyAlpha
    )
}

private fun projectionSpec(
    width: Float,
    height: Float,
    preset: SkyPreset,
    lowPerformanceMode: Boolean,
    panX: Float,
    panY: Float
): ProjectionSpec {
    val loginPreset = preset == SkyPreset.LOGIN
    return ProjectionSpec(
        centerX = width * 0.5f + panX,
        centerY = height * (if (loginPreset) 0.70f else 0.74f) + panY,
        radius = min(width, height) * when {
            loginPreset && lowPerformanceMode -> 0.98f
            loginPreset -> 1.14f
            lowPerformanceMode -> 0.82f
            else -> 0.95f
        },
        minAltitudeDeg = when {
            loginPreset && lowPerformanceMode -> 2f
            loginPreset -> -6f
            lowPerformanceMode -> 8f
            else -> 2f
        },
        altitudeCurve = when {
            loginPreset -> 0.54f
            lowPerformanceMode -> 0.70f
            else -> 0.62f
        }
    )
}

private fun magnitudeToBrightness(mag: Float): Float {
    val flux = 10.0.pow(-0.4 * mag.toDouble())
    val minFlux = 10.0.pow(-0.4 * 6.3)
    val maxFlux = 10.0.pow(-0.4 * -1.46)
    val normalized = ((flux - minFlux) / (maxFlux - minFlux))
        .toFloat()
        .coerceIn(0f, 1f)

    return 0.36f + normalized.pow(0.60f) * 1.24f
}

private fun magnitudeToRadius(
    mag: Float,
    layer: StarLayer,
    radiusBias: Float,
    altitudeNorm: Float,
    lowPerformanceMode: Boolean
): Float {
    val base = when (layer) {
        StarLayer.DIM -> if (lowPerformanceMode) 0.92f else 1.08f
        StarLayer.NORMAL -> if (lowPerformanceMode) 1.22f else 1.42f
        StarLayer.BRIGHT -> if (lowPerformanceMode) 1.74f else 2.04f
    }

    val brightness = magnitudeToBrightness(mag)
    val boost = when (layer) {
        StarLayer.DIM -> 0.24f
        StarLayer.NORMAL -> 0.54f
        StarLayer.BRIGHT -> 0.92f
    }

    return base + brightness * boost + altitudeNorm * 0.14f + radiusBias
}

private fun twinkleAlpha(epochSec: Float, profile: TwinkleProfile, baseBrightness: Float): Float {
    val primary = sin((epochSec * profile.speedHz + profile.phase) * (2f * PI.toFloat()))
    val drift = sin((epochSec * profile.driftSpeedHz + profile.phase * 0.37f) * (2f * PI.toFloat()))
    val wobble = profile.amplitude * primary + profile.driftAmplitude * drift
    val gain = 1.00f + baseBrightness * 0.95f
    return (1f + wobble * gain).coerceIn(0.42f, 1.75f)
}

private fun localSiderealTimeRadians(epochMillis: Long, longitude: Double): Double {
    val jd = epochMillis / 86_400_000.0 + 2440587.5
    val d = jd - 2451545.0
    val gmst = 280.46061837 + 360.98564736629 * d
    return normalizeDegrees(gmst + longitude).toRad()
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.contentRegionFactor(
    x: Float,
    y: Float,
    preset: SkyPreset,
    layer: StarLayer
): Float {
    val cx = size.width * 0.5f
    val cy = if (preset == SkyPreset.LOGIN) size.height * 0.56f else size.height * 0.60f
    val rx = size.width * if (preset == SkyPreset.LOGIN) 0.30f else 0.26f
    val ry = size.height * if (preset == SkyPreset.LOGIN) 0.23f else 0.18f

    val dx = (x - cx) / rx
    val dy = (y - cy) / ry
    val d = dx * dx + dy * dy

    if (d >= 1f) return 1f

    val minFactor = when (layer) {
        StarLayer.DIM -> if (preset == SkyPreset.LOGIN) 0.80f else 0.84f
        StarLayer.NORMAL -> if (preset == SkyPreset.LOGIN) 0.94f else 0.96f
        StarLayer.BRIGHT -> if (preset == SkyPreset.LOGIN) 0.98f else 0.99f
    }

    return lerp(minFactor, 1f, d)
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawConstellationHints(
    anchors: Map<String, ProjectedStar>,
    lowPerformanceMode: Boolean
) {
    CONSTELLATION_LINES.take(2).forEach { lines ->
        lines.forEach { (a, b) ->
            val start = anchors[a]
            val end = anchors[b]
            if (start != null && end != null) {
                drawLine(
                    color = Color(0xFF7F9DC8),
                    start = Offset(start.x, start.y),
                    end = Offset(end.x, end.y),
                    strokeWidth = if (lowPerformanceMode) 0.55f else 0.72f,
                    alpha = 0.08f + 0.08f * min(start.altitudeNorm, end.altitudeNorm)
                )
            }
        }
    }
}

private fun halton(index: Int, base: Int): Double {
    var i = index
    var f = 1.0
    var r = 0.0
    while (i > 0) {
        f /= base.toDouble()
        r += f * (i % base)
        i /= base
    }
    return r
}

private fun seededUnit(seed: Long): Float {
    val mixed = splitMix64(seed)
    val positive = mixed ushr 11
    return (positive.toDouble() / (1L shl 53).toDouble()).toFloat()
}

private fun splitMix64(value: Long): Long {
    var z = value - 7046029254386353131L
    z = (z xor (z ushr 30)) * -4658895280553007687L
    z = (z xor (z ushr 27)) * -7723592293110705685L
    return z xor (z ushr 31)
}

private fun classifyLayerByMagnitude(mag: Float, preferBright: Boolean = false): StarLayer {
    return when {
        preferBright || mag <= 1.2f -> StarLayer.BRIGHT
        mag <= 3.0f -> StarLayer.NORMAL
        else -> StarLayer.DIM
    }
}

private fun pickProceduralLayer(seed: Long): StarLayer {
    val p = seededUnit(seed + 97L)
    return when {
        p < 0.71f -> StarLayer.DIM
        p < 0.93f -> StarLayer.NORMAL
        else -> StarLayer.BRIGHT
    }
}

private fun proceduralStarTint(seed: Long, layer: StarLayer): Color {
    val p = seededUnit(seed + 43L)
    val warmChance = when (layer) {
        StarLayer.DIM -> 0.03f
        StarLayer.NORMAL -> 0.06f
        StarLayer.BRIGHT -> 0.10f
    }
    return when {
        p < warmChance -> lerpColor(Color(0xFFF7F8FF), Color(0xFFFFF0D9), seededUnit(seed + 59L))
        p < warmChance + 0.18f -> lerpColor(Color(0xFFE8F1FF), Color(0xFFDCEAFF), seededUnit(seed + 73L))
        else -> lerpColor(Color(0xFFF1F6FF), Color(0xFFEAF2FF), seededUnit(seed + 61L))
    }
}

private fun lerpColor(a: Color, b: Color, t: Float): Color {
    val p = t.coerceIn(0f, 1f)
    return Color(
        red = lerp(a.red, b.red, p),
        green = lerp(a.green, b.green, p),
        blue = lerp(a.blue, b.blue, p),
        alpha = lerp(a.alpha, b.alpha, p)
    )
}

private fun lerp(a: Float, b: Float, t: Float): Float = a + (b - a) * t

private fun normalizeDegrees(value: Double): Double {
    var v = value % 360.0
    if (v < 0) v += 360.0
    return v
}

private fun normalizeRadians(value: Double): Double {
    var v = value % (2.0 * PI)
    if (v < -PI) v += 2.0 * PI
    if (v > PI) v -= 2.0 * PI
    return v
}

private fun Double.toRad(): Double = this * PI / 180.0
private fun Double.toDeg(): Double = this * 180.0 / PI
