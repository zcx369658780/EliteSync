package com.elitesync.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

enum class StarryButtonLevel {
    L1Back,
    L2Primary,
    L3Secondary
}

@Composable
private fun StarryActionButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    level: StarryButtonLevel = StarryButtonLevel.L3Secondary,
    enabled: Boolean = true,
    loading: Boolean = false
) {
    val settings = LocalUiFeedbackSettings.current
    val haptic = LocalHapticFeedback.current
    val interactionSource = remember { MutableInteractionSource() }
    val pressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (pressed) 0.97f else 1f,
        animationSpec = tween(160),
        label = "actionButtonScale"
    )
    val active = enabled && !loading
    val palette = when (level) {
        StarryButtonLevel.L1Back -> StarryButtons.Back
        StarryButtonLevel.L2Primary -> StarryButtons.Primary
        StarryButtonLevel.L3Secondary -> StarryButtons.Secondary
    }
    val bg by animateColorAsState(
        targetValue = btnBgColor(palette, active, pressed),
        animationSpec = tween(220),
        label = "actionButtonBg"
    )
    val border by animateColorAsState(
        targetValue = btnBorderColor(palette, active, pressed),
        animationSpec = tween(220),
        label = "actionButtonBorder"
    )
    Box(
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = EliteSyncDimens.ButtonHeight)
            .clip(RoundedCornerShape(EliteSyncShapes.ControlRadius))
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
                alpha = if (active) 1f else 0.55f
            }
            .background(bg)
            .border(1.dp, border, RoundedCornerShape(EliteSyncShapes.ControlRadius))
            .clickable(
                enabled = active,
                interactionSource = interactionSource,
                indication = null
            ) {
                if (settings.hapticEnabled) haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                if (settings.clickSoundEnabled) StarryClickSound.play()
                onClick()
            }
            .padding(horizontal = EliteSyncDimens.Space16, vertical = EliteSyncDimens.Space12)
    ) {
        if (loading) {
            Row {
                CircularProgressIndicator(
                    color = palette.content,
                    strokeWidth = 2.dp
                )
                Text("处理中...", color = palette.content, fontWeight = FontWeight.SemiBold)
            }
        } else {
            Text(
                text,
                color = if (active) palette.content else palette.contentDisabled,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
fun StarryPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false
) {
    StarryActionButton(
        text = text,
        onClick = onClick,
        modifier = modifier,
        enabled = enabled,
        loading = loading,
        level = StarryButtonLevel.L2Primary
    )
}

@Composable
fun StarrySecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false
) {
    StarryActionButton(
        text = text,
        onClick = onClick,
        modifier = modifier,
        enabled = enabled,
        loading = loading,
        level = StarryButtonLevel.L3Secondary
    )
}

@Composable
fun StarryBackButton(
    text: String = "返回",
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false
) {
    StarryActionButton(
        text = text,
        onClick = onClick,
        modifier = modifier,
        enabled = enabled,
        loading = loading,
        level = StarryButtonLevel.L1Back
    )
}
