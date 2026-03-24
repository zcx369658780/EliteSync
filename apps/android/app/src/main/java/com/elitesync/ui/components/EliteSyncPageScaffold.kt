package com.elitesync.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun GlassScrollPage(
    title: String,
    status: String? = null,
    error: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val scroll = rememberScrollState()
    var reveal by remember(title) { mutableStateOf(false) }
    LaunchedEffect(title) {
        reveal = false
        reveal = true
    }
    val contentAlpha by animateFloatAsState(
        targetValue = if (reveal) 1f else 0f,
        animationSpec = tween(500),
        label = "pageContentAlpha"
    )
    val contentOffsetY by animateFloatAsState(
        targetValue = if (reveal) 0f else 22f,
        animationSpec = tween(500),
        label = "pageContentOffsetY"
    )
    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
            .padding(EliteSyncDimens.Space16)
            .verticalScroll(scroll),
        verticalArrangement = Arrangement.spacedBy(EliteSyncDimens.Space12)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(50.dp)
                .background(
                    color = androidx.compose.ui.graphics.Color(0xAA0F192C),
                    shape = RoundedCornerShape(EliteSyncShapes.TabRadius)
                )
                .border(
                    width = 1.dp,
                    color = EliteSyncColors.BorderSubtle.copy(alpha = 0.8f),
                    shape = RoundedCornerShape(EliteSyncShapes.TabRadius)
                )
                .padding(horizontal = 6.dp, vertical = 5.dp)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        color = EliteSyncColors.SurfaceCardStrong.copy(alpha = 0.95f),
                        shape = RoundedCornerShape(12.dp)
                    )
            ) {
                Text(
                    text = title,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 6.dp),
                    color = EliteSyncColors.TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center
                )
            }
        }
        if (!error.isNullOrBlank()) {
            StarryStatusBanner(text = "错误：$error", tone = StatusTone.Error)
        } else if (!status.isNullOrBlank()) {
            StarryStatusBanner(text = "状态：$status", tone = StatusTone.Info)
        }
        Column(
            modifier = Modifier.graphicsLayer {
                alpha = contentAlpha
                translationY = contentOffsetY
            },
            verticalArrangement = Arrangement.spacedBy(EliteSyncDimens.Space12)
        ) {
            content()
        }
    }
}

