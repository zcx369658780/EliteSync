package com.elitesync.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
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
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

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
    loading: Boolean = false,
    compact: Boolean = false,
    fillWidth: Boolean = true,
    feedbackText: String? = null
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
    var showFeedbackBubble by remember { mutableStateOf(false) }
    LaunchedEffect(showFeedbackBubble) {
        if (showFeedbackBubble) {
            delay(1000)
            showFeedbackBubble = false
        }
    }
    Box(
        modifier = if (fillWidth) modifier.fillMaxWidth() else modifier
    ) {
        AnimatedVisibility(
            visible = showFeedbackBubble && !feedbackText.isNullOrBlank(),
            enter = fadeIn(animationSpec = tween(120)) + scaleIn(initialScale = 0.92f, animationSpec = tween(120)),
            exit = fadeOut(animationSpec = tween(200)) + scaleOut(targetScale = 0.96f, animationSpec = tween(200)),
            modifier = Modifier
                .align(Alignment.TopCenter)
                .offset(y = (-36).dp)
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(10.dp))
                    .background(Color(0xF0172238))
                    .border(1.dp, Color(0xFF455A89), RoundedCornerShape(10.dp))
                    .padding(horizontal = 10.dp, vertical = 6.dp)
            ) {
                Text(
                    text = feedbackText.orEmpty(),
                    color = Color(0xFFD7E5FF),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = if (compact) 38.dp else EliteSyncDimens.ButtonHeight)
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
                    if (!feedbackText.isNullOrBlank()) {
                        showFeedbackBubble = true
                    }
                }
                .padding(
                    horizontal = if (compact) EliteSyncDimens.Space8 else EliteSyncDimens.Space16,
                    vertical = if (compact) EliteSyncDimens.Space8 else EliteSyncDimens.Space12
                )
        ) {
        if (loading) {
            Row {
                CircularProgressIndicator(
                    color = palette.content,
                    strokeWidth = 2.dp
                )
                Text(
                    "处理中...",
                    color = palette.content,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = if (compact) 12.sp else 14.sp
                )
            }
        } else {
            Text(
                text,
                color = if (active) palette.content else palette.contentDisabled,
                fontWeight = FontWeight.SemiBold,
                fontSize = if (compact) 13.sp else 16.sp
            )
        }
        }
    }
}

@Composable
fun StarryPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    compact: Boolean = false,
    fillWidth: Boolean = true,
    feedbackText: String? = null
) {
    StarryActionButton(
        text = text,
        onClick = onClick,
        modifier = modifier,
        enabled = enabled,
        loading = loading,
        compact = compact,
        fillWidth = fillWidth,
        feedbackText = feedbackText,
        level = StarryButtonLevel.L2Primary
    )
}

@Composable
fun StarrySecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    compact: Boolean = false,
    fillWidth: Boolean = true,
    feedbackText: String? = null
) {
    StarryActionButton(
        text = text,
        onClick = onClick,
        modifier = modifier,
        enabled = enabled,
        loading = loading,
        compact = compact,
        fillWidth = fillWidth,
        feedbackText = feedbackText,
        level = StarryButtonLevel.L3Secondary
    )
}

@Composable
fun StarryBackButton(
    text: String = "返回",
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    compact: Boolean = false,
    fillWidth: Boolean = true,
    feedbackText: String? = null
) {
    StarryActionButton(
        text = text,
        onClick = onClick,
        modifier = modifier,
        enabled = enabled,
        loading = loading,
        compact = compact,
        fillWidth = fillWidth,
        feedbackText = feedbackText,
        level = StarryButtonLevel.L1Back
    )
}
