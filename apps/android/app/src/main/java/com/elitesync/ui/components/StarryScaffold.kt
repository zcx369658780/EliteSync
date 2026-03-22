package com.elitesync.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp

internal object StarryTextColors {
    val Primary = EliteSyncColors.TextPrimary
    val Secondary = EliteSyncColors.TextSecondary
    val Weak = EliteSyncColors.TextTertiary
    val Error = EliteSyncColors.Error
}

internal data class BtnStateColors(
    val normal: Color,
    val pressed: Color,
    val disabled: Color,
    val content: Color,
    val contentDisabled: Color
)

internal object StarryButtons {
    val Primary = BtnStateColors(
        normal = Color(0xFF5F84C5),
        pressed = Color(0xFF4E74B2),
        disabled = Color(0xFF31435F),
        content = EliteSyncColors.TextPrimary,
        contentDisabled = EliteSyncColors.TextTertiary
    )
    val Secondary = BtnStateColors(
        normal = Color(0xFF24344E),
        pressed = Color(0xFF1F2D44),
        disabled = Color(0xFF172235),
        content = EliteSyncColors.TextPrimary,
        contentDisabled = EliteSyncColors.TextTertiary
    )
    val Option = BtnStateColors(
        normal = Color(0xFF1F2F45),
        pressed = Color(0xFF192639),
        disabled = Color(0xFF141F2F),
        content = Color(0xFFD4E1F3),
        contentDisabled = Color(0xFF5B6B84)
    )
    val ListItem = BtnStateColors(
        normal = Color(0xFF162235),
        pressed = Color(0xFF1B2A42),
        disabled = Color(0xFF111A29),
        content = Color(0xFFC9D8EC),
        contentDisabled = Color(0xFF55657E)
    )
}

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = modifier.padding(vertical = 2.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
        content = content
    )
}

@Composable
fun GlassSection(
    title: String,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    GlassCard(modifier = modifier.fillMaxWidth()) {
        Text(title, color = StarryTextColors.Secondary)
        content()
    }
}

internal fun btnBgColor(
    palette: BtnStateColors,
    active: Boolean,
    pressed: Boolean
): Color = when {
    !active -> palette.disabled
    pressed -> palette.pressed
    else -> palette.normal
}

@Composable
fun StarryListItemCard(
    text: String,
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null
) {
    val settings = LocalUiFeedbackSettings.current
    val haptic = LocalHapticFeedback.current
    val interactionSource = remember { MutableInteractionSource() }
    val clickableModifier = if (onClick != null) {
        modifier.clickable(
            interactionSource = interactionSource,
            indication = null
        ) {
            if (settings.hapticEnabled) haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
            if (settings.clickSoundEnabled) StarryClickSound.play()
            onClick()
        }
    } else modifier
    Box(
        modifier = clickableModifier
            .fillMaxWidth()
            .heightIn(min = 56.dp)
            .clip(RoundedCornerShape(EliteSyncShapes.ListItemRadius))
            .padding(horizontal = EliteSyncDimens.Space4, vertical = 8.dp)
    ) {
        Text(text = text, color = EliteSyncColors.TextSecondary)
    }
}

@Composable
fun StarryOptionCard(
    text: String,
    selected: Boolean,
    pickOrder: Int? = null,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val settings = LocalUiFeedbackSettings.current
    val haptic = LocalHapticFeedback.current
    val interactionSource = remember { MutableInteractionSource() }
    val pressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (pressed) 0.98f else 1f,
        animationSpec = tween(160),
        label = "optionScale"
    )
    val bg by animateColorAsState(
        targetValue = btnBgColor(StarryButtons.Option, true, pressed || selected),
        animationSpec = tween(200),
        label = "optionBg"
    )
    val badge = when (pickOrder) {
        0 -> "①"
        1 -> "②"
        else -> if (selected) "✓" else ""
    }
    Box(
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = 44.dp)
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clip(RoundedCornerShape(14.dp))
            .background(bg)
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                if (settings.hapticEnabled) haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                if (settings.clickSoundEnabled) StarryClickSound.play()
                onClick()
            }
            .padding(horizontal = 12.dp, vertical = 12.dp)
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Box(modifier = Modifier.width(20.dp)) {
                if (badge.isNotBlank()) {
                    Text(
                        text = badge,
                        color = if (selected) StarryButtons.Option.content else StarryTextColors.Secondary
                    )
                }
            }
            Text(
                text = text,
                color = if (selected) StarryButtons.Option.content else StarryTextColors.Primary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}
