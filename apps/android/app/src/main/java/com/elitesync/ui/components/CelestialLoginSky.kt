package com.elitesync.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

@Composable
fun CelestialLoginSky(
    modifier: Modifier = Modifier,
    latitude: Double,
    longitude: Double
) {
    Box(modifier = modifier.fillMaxSize()) {
        RealtimeConstellationSky(
            modifier = Modifier.fillMaxSize(),
            latitude = latitude,
            longitude = longitude,
            preset = SkyPreset.LOGIN,
            lowPerformanceMode = false,
            panExternalX = 0f,
            panExternalY = 0f
        )

        // 轻微顶部压暗，避免状态栏附近过亮
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color(0x22020812),
                            Color.Transparent,
                            Color(0x33020610)
                        )
                    )
                )
        )

        // 极弱的中心聚焦，不要做成大圆罩
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            Color(0x120D1B38),
                            Color.Transparent
                        ),
                        center = Offset.Unspecified,
                        radius = 900f
                    )
                )
        )
    }
}