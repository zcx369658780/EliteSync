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

@Composable
fun StarryPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
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
        label = "primaryButtonScale"
    )
    val active = enabled && !loading
    val bg by animateColorAsState(
        targetValue = btnBgColor(StarryButtons.Primary, active, pressed),
        animationSpec = tween(220),
        label = "primaryButtonBg"
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
            .border(1.dp, Color(0x7ABBCDF2), RoundedCornerShape(EliteSyncShapes.ControlRadius))
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
                    color = StarryButtons.Primary.content,
                    strokeWidth = 2.dp
                )
                Text("处理中...", color = StarryButtons.Primary.content, fontWeight = FontWeight.SemiBold)
            }
        } else {
            Text(
                text,
                color = if (active) StarryButtons.Primary.content else StarryButtons.Primary.contentDisabled,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
fun StarrySecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false
) {
    val settings = LocalUiFeedbackSettings.current
    val haptic = LocalHapticFeedback.current
    val interactionSource = remember { MutableInteractionSource() }
    val pressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (pressed) 0.975f else 1f,
        animationSpec = tween(160),
        label = "secondaryButtonScale"
    )
    val active = enabled && !loading
    val bg by animateColorAsState(
        targetValue = btnBgColor(StarryButtons.Secondary, active, pressed),
        animationSpec = tween(220),
        label = "secondaryButtonBg"
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
            .border(1.dp, EliteSyncColors.BorderSubtle, RoundedCornerShape(EliteSyncShapes.ControlRadius))
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
        Text(
            if (loading) "处理中..." else text,
            color = if (active) StarryButtons.Secondary.content else StarryButtons.Secondary.contentDisabled,
            fontWeight = FontWeight.Medium
        )
    }
}
