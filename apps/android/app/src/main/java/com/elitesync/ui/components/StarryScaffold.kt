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
    val borderNormal: Color,
    val borderPressed: Color,
    val borderDisabled: Color,
    val content: Color,
    val contentDisabled: Color
)

internal object StarryButtons {
    val Back = BtnStateColors(
        normal = Color(0xFF121A2E),
        pressed = Color(0xFF1A2440),
        disabled = Color(0xFF0F1526),
        borderNormal = Color(0xFF2A3554),
        borderPressed = Color(0xFF3A4A72),
        borderDisabled = Color(0xFF1D2740),
        content = Color(0xFFC9D6FF),
        contentDisabled = Color(0xFF5B678A)
    )
    val Primary = BtnStateColors(
        normal = Color(0xFF4DA3FF),
        pressed = Color(0xFF2F7DDB),
        disabled = Color(0xFF1B2438),
        borderNormal = Color.Transparent,
        borderPressed = Color.Transparent,
        borderDisabled = Color.Transparent,
        content = Color(0xFF061326),
        contentDisabled = Color(0xFF5C6A86)
    )
    val Secondary = BtnStateColors(
        normal = Color(0xFF141D33),
        pressed = Color(0xFF1D2945),
        disabled = Color(0xFF10182B),
        borderNormal = Color(0xFF3C4E78),
        borderPressed = Color(0xFF5871A8),
        borderDisabled = Color(0xFF273552),
        content = Color(0xFFAFC4FF),
        contentDisabled = Color(0xFF5A6787)
    )
    val Option = BtnStateColors(
        normal = Color(0xFF0E1528),
        pressed = Color(0xFF17223A),
        disabled = Color(0xFF0B1120),
        borderNormal = Color(0xFF1F2B47),
        borderPressed = Color(0xFF32456F),
        borderDisabled = Color(0xFF18233B),
        content = Color(0xFF9FB0D6),
        contentDisabled = Color(0xFF4F5C7C)
    )
    val ListItem = BtnStateColors(
        normal = Color(0xFF0E1528),
        pressed = Color(0xFF17223A),
        disabled = Color(0xFF0B1120),
        borderNormal = Color(0xFF1F2B47),
        borderPressed = Color(0xFF32456F),
        borderDisabled = Color(0xFF18233B),
        content = Color(0xFF9FB0D6),
        contentDisabled = Color(0xFF4F5C7C)
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

internal fun btnBorderColor(
    palette: BtnStateColors,
    active: Boolean,
    pressed: Boolean
): Color = when {
    !active -> palette.borderDisabled
    pressed -> palette.borderPressed
    else -> palette.borderNormal
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
            .border(
                width = 1.dp,
                color = StarryButtons.ListItem.borderNormal,
                shape = RoundedCornerShape(EliteSyncShapes.ListItemRadius)
            )
            .background(StarryButtons.ListItem.normal)
            .padding(horizontal = EliteSyncDimens.Space12, vertical = 12.dp)
    ) {
        Text(text = text, color = StarryButtons.ListItem.content)
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
            .border(
                width = 1.dp,
                color = if (selected) StarryButtons.Option.borderPressed else StarryButtons.Option.borderNormal,
                shape = RoundedCornerShape(14.dp)
            )
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
