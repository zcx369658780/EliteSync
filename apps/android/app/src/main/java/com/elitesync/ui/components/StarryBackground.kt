package com.elitesync.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

@Composable
fun StarryAppBackground(
    modifier: Modifier = Modifier,
    latitude: Double = 34.7466,
    longitude: Double = 113.6254
) {
    val perf = LocalUiPerformanceSettings.current
    val (panX, panY) = rememberAnimatedGlobalStarPan()

    Box(modifier = modifier.fillMaxSize()) {
        RealtimeConstellationSky(
            modifier = Modifier.fillMaxSize(),
            latitude = latitude,
            longitude = longitude,
            preset = SkyPreset.APP,
            lowPerformanceMode = perf.liteMode,
            panExternalX = panX,
            panExternalY = panY
        )

        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        listOf(
                            Color(0x1802050D),
                            Color.Transparent,
                            Color(0x2602050D)
                        )
                    )
                )
        )
    }
}

