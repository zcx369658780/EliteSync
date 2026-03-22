package com.elitesync.ui.components

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

data class NavTabSpec(
    val label: String,
    val route: String
)

@Composable
fun EliteSyncBottomTabs(
    tabs: List<NavTabSpec>,
    currentRoute: String?,
    onTabClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 12.dp, vertical = 10.dp)
            .height(58.dp)
            .clip(RoundedCornerShape(EliteSyncShapes.TabRadius))
            .background(Color(0xAA0F192C))
    ) {
        val selectedIndex = tabs.indexOfFirst { it.route == currentRoute }.coerceAtLeast(0)
        val tabWidth = maxWidth / tabs.size
        val indicatorOffset = animateDpAsState(
            targetValue = tabWidth * selectedIndex,
            animationSpec = tween(240),
            label = "navIndicatorOffset"
        )

        Box(
            modifier = Modifier
                .padding(6.dp)
                .fillMaxHeight()
                .fillMaxWidth(1f / tabs.size)
                .graphicsLayer {
                    translationX = indicatorOffset.value.toPx()
                }
                .clip(RoundedCornerShape(12.dp))
                .background(EliteSyncColors.SurfaceCardStrong.copy(alpha = 0.95f))
        )

        Row(modifier = Modifier.fillMaxSize()) {
            tabs.forEach { tab ->
                val selected = currentRoute == tab.route
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxSize()
                        .clickable { onTabClick(tab.route) },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = tab.label,
                        color = if (selected) EliteSyncColors.TextPrimary else EliteSyncColors.TextTertiary,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}
