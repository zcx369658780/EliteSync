package com.elitesync.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable

import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.Stable
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.input.pointer.pointerInteropFilter
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.SystemClock
import java.time.LocalDate
import java.time.YearMonth

data class UiFeedbackSettings(
    val hapticEnabled: Boolean = false,
    val clickSoundEnabled: Boolean = false
)

private val GlobalStarPanTargetX = mutableStateOf(0f)
private val GlobalStarPanTargetY = mutableStateOf(0f)
private var GlobalTouchLastX = 0f
private var GlobalTouchLastY = 0f

fun addGlobalStarPan(dx: Float, dy: Float) {
    GlobalStarPanTargetX.value = (GlobalStarPanTargetX.value + dx * 0.06f).coerceIn(-18f, 18f)
    GlobalStarPanTargetY.value = (GlobalStarPanTargetY.value + dy * 0.05f).coerceIn(-12f, 12f)
}

private fun releaseGlobalStarPan() {
    GlobalStarPanTargetX.value *= 0.62f
    GlobalStarPanTargetY.value *= 0.62f
}

@Stable
@Composable
fun rememberAnimatedGlobalStarPan(): Pair<Float, Float> {
    val panX by animateFloatAsState(
        targetValue = GlobalStarPanTargetX.value,
        animationSpec = tween(durationMillis = 420),
        label = "sharedStarPanX"
    )
    val panY by animateFloatAsState(
        targetValue = GlobalStarPanTargetY.value,
        animationSpec = tween(durationMillis = 420),
        label = "sharedStarPanY"
    )
    return panX to panY
}

@OptIn(ExperimentalComposeUiApi::class)
fun Modifier.starryPanGesture(): Modifier = this.pointerInteropFilter {
    when (it.actionMasked) {
        android.view.MotionEvent.ACTION_DOWN -> {
            GlobalTouchLastX = it.x
            GlobalTouchLastY = it.y
        }
        android.view.MotionEvent.ACTION_MOVE -> {
            val dx = it.x - GlobalTouchLastX
            val dy = it.y - GlobalTouchLastY
            if (dx != 0f || dy != 0f) addGlobalStarPan(dx, dy)
            GlobalTouchLastX = it.x
            GlobalTouchLastY = it.y
        }
        android.view.MotionEvent.ACTION_UP,
        android.view.MotionEvent.ACTION_CANCEL -> releaseGlobalStarPan()
    }
    false
}

private object StarryClickSound {
    private val tone by lazy { ToneGenerator(AudioManager.STREAM_MUSIC, 48) }
    private var lastPlayAt = 0L

    fun play() {
        val now = SystemClock.elapsedRealtime()
        if (now - lastPlayAt < 75L) return
        lastPlayAt = now
        tone.startTone(ToneGenerator.TONE_PROP_ACK, 24)
    }
}

val LocalUiFeedbackSettings = staticCompositionLocalOf { UiFeedbackSettings() }
data class UiPerformanceSettings(
    val liteMode: Boolean = false
)
val LocalUiPerformanceSettings = staticCompositionLocalOf { UiPerformanceSettings() }

private object StarryTextColors {
    val Primary = Color(0xFFE6EEF8)
    val Secondary = Color(0xFFB7C4D8)
    val Weak = Color(0xFF8695AD)
    val Error = Color(0xFFFF7B86)
}

private data class BtnStateColors(
    val normal: Color,
    val pressed: Color,
    val disabled: Color,
    val content: Color,
    val contentDisabled: Color
)

private object StarryButtons {
    val Primary = BtnStateColors(
        normal = Color(0xFF2A567D),
        pressed = Color(0xFF23496B),
        disabled = Color(0xFF1A2A3F),
        content = Color(0xFFEAF3FF),
        contentDisabled = Color(0xFF667892)
    )
    val Secondary = BtnStateColors(
        normal = Color(0xFF25364F),
        pressed = Color(0xFF1E2C40),
        disabled = Color(0xFF172233),
        content = Color(0xFFDDE8F7),
        contentDisabled = Color(0xFF60718A)
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
fun ProvideUiFeedbackSettings(
    settings: UiFeedbackSettings,
    content: @Composable () -> Unit
) {
    CompositionLocalProvider(LocalUiFeedbackSettings provides settings) {
        content()
    }
}

@Composable
fun ProvideUiPerformanceSettings(
    settings: UiPerformanceSettings,
    content: @Composable () -> Unit
) {
    CompositionLocalProvider(LocalUiPerformanceSettings provides settings) {
        content()
    }
}

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

        // 只保留一层很轻的上下压暗，别再叠星空图片和大蓝光
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

private fun btnBgColor(
    palette: BtnStateColors,
    active: Boolean,
    pressed: Boolean
): Color = when {
    !active -> palette.disabled
    pressed -> palette.pressed
    else -> palette.normal
}

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
    val glow by animateFloatAsState(
        targetValue = if (pressed) 0.42f else 0.16f,
        animationSpec = tween(220),
        label = "primaryButtonGlow"
    )
    val active = enabled && !loading
    val bg by animateColorAsState(
        targetValue = btnBgColor(StarryButtons.Primary, active, pressed),
        animationSpec = tween(220),
        label = "primaryButtonBg"
    )
    Box(
        modifier = modifier
            .wrapContentWidth()
            .heightIn(min = 44.dp)
            .clip(RoundedCornerShape(22.dp))
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
                alpha = if (active) 1f else 0.55f
            }
            .background(bg)
            .clickable(
                enabled = active,
                interactionSource = interactionSource,
                indication = null
            ) {
                if (settings.hapticEnabled) haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                if (settings.clickSoundEnabled) StarryClickSound.play()
                onClick()
            }
            .padding(horizontal = 20.dp, vertical = 12.dp)
    ) {
        if (loading) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                CircularProgressIndicator(
                    color = StarryButtons.Primary.content,
                    strokeWidth = 2.dp
                )
                Text("处理中...", color = StarryButtons.Primary.content)
            }
        } else {
            Text(
                text,
                color = if (active) StarryButtons.Primary.content else StarryButtons.Primary.contentDisabled
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
            .wrapContentWidth()
            .heightIn(min = 44.dp)
            .clip(RoundedCornerShape(20.dp))
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
                alpha = if (active) 1f else 0.55f
            }
            .background(bg)
            .clickable(
                enabled = active,
                interactionSource = interactionSource,
                indication = null
            ) {
                if (settings.hapticEnabled) haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                if (settings.clickSoundEnabled) StarryClickSound.play()
                onClick()
            }
            .padding(horizontal = 18.dp, vertical = 10.dp)
    ) {
        Text(
            if (loading) "处理中..." else text,
            color = if (active) StarryButtons.Secondary.content else StarryButtons.Secondary.contentDisabled
        )
    }
}

@Composable
fun StarryTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    singleLine: Boolean = true,
    isError: Boolean = false,
    errorMessage: String? = null,
    isPassword: Boolean = false
) {
    val passwordVisible = remember { mutableStateOf(false) }
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier.fillMaxWidth(),
        singleLine = singleLine,
        isError = isError,
        label = { Text(label, color = StarryTextColors.Secondary) },
        trailingIcon = if (isPassword) {
            {
                Text(
                    if (passwordVisible.value) "隐藏" else "显示",
                    color = StarryTextColors.Secondary,
                    modifier = Modifier.clickable { passwordVisible.value = !passwordVisible.value }
                )
            }
        } else null,
        supportingText = if (isError && !errorMessage.isNullOrBlank()) {
            { Text(errorMessage, color = StarryTextColors.Error) }
        } else null,
        visualTransformation = if (isPassword && !passwordVisible.value) PasswordVisualTransformation() else VisualTransformation.None,
        textStyle = TextStyle(color = StarryTextColors.Primary),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = Color(0xFF3D5B84),
            unfocusedBorderColor = Color(0xFF2A3957),
            errorBorderColor = StarryTextColors.Error,
            focusedContainerColor = Color(0xFF10192B),
            unfocusedContainerColor = Color(0xFF10192B),
            errorContainerColor = Color(0xFF10192B),
            focusedLabelColor = StarryTextColors.Primary,
            unfocusedLabelColor = StarryTextColors.Secondary,
            errorLabelColor = StarryTextColors.Error,
            cursorColor = StarryTextColors.Primary
        )
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StarryDropdownField(
    label: String,
    valueText: String,
    options: List<String>,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = valueText,
            onValueChange = {},
            readOnly = true,
            label = { Text(label, color = Color(0xFFAFC7F9)) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(),
            textStyle = TextStyle(color = StarryTextColors.Primary),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color(0xFF3D5B84),
                unfocusedBorderColor = Color(0xFF2A3957),
                focusedContainerColor = Color(0xFF10192B),
                unfocusedContainerColor = Color(0xFF10192B),
                focusedLabelColor = StarryTextColors.Primary,
                unfocusedLabelColor = StarryTextColors.Secondary,
                cursorColor = StarryTextColors.Primary
            )
        )
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { item ->
                DropdownMenuItem(
                    text = { Text(item) },
                    onClick = {
                        onSelect(item)
                        expanded = false
                    }
                )
            }
        }
    }
}

@Composable
fun StarryDateDropdownField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    startYear: Int = 1950,
    endYear: Int = LocalDate.now().year
) {
    val parsed = remember(value) {
        runCatching { LocalDate.parse(value) }.getOrNull()
    }
    var year by remember(parsed, endYear) { mutableStateOf(parsed?.year ?: endYear) }
    var month by remember(parsed) { mutableStateOf(parsed?.monthValue ?: 1) }
    var day by remember(parsed) { mutableStateOf(parsed?.dayOfMonth ?: 1) }

    val maxDay = remember(year, month) { YearMonth.of(year, month).lengthOfMonth() }
    if (day > maxDay) day = maxDay

    fun emitDate() {
        onValueChange("%04d-%02d-%02d".format(year, month, day))
    }

    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Text(label, color = StarryTextColors.Secondary)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            StarryDropdownField(
                label = "年",
                valueText = year.toString(),
                options = (endYear downTo startYear).map { it.toString() },
                onSelect = {
                    year = it.toInt()
                    val limit = YearMonth.of(year, month).lengthOfMonth()
                    if (day > limit) day = limit
                    emitDate()
                },
                modifier = Modifier.weight(1.3f)
            )
            StarryDropdownField(
                label = "月",
                valueText = month.toString().padStart(2, '0'),
                options = (1..12).map { it.toString().padStart(2, '0') },
                onSelect = {
                    month = it.toInt()
                    val limit = YearMonth.of(year, month).lengthOfMonth()
                    if (day > limit) day = limit
                    emitDate()
                },
                modifier = Modifier.weight(1f)
            )
            StarryDropdownField(
                label = "日",
                valueText = day.toString().padStart(2, '0'),
                options = (1..maxDay).map { it.toString().padStart(2, '0') },
                onSelect = {
                    day = it.toInt()
                    emitDate()
                },
                modifier = Modifier.weight(1f)
            )
        }
    }
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
    val pressed by interactionSource.collectIsPressedAsState()
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
            .heightIn(min = 44.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(
                animateColorAsState(
                    targetValue = btnBgColor(StarryButtons.ListItem, true, pressed),
                    animationSpec = tween(200),
                    label = "listItemBg"
                ).value
            )
            .padding(horizontal = 12.dp, vertical = 10.dp)
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

@Composable
fun GlassScrollPage(
    title: String,
    status: String? = null,
    error: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val scroll = rememberScrollState()
    Box(modifier = modifier.fillMaxSize().starryPanGesture()) {
        StarryAppBackground()
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(16.dp)
                .verticalScroll(scroll)
        ) {
            Text(title, color = Color.White)
            content()
            if (status != null) {
            Text("状态: $status", color = StarryTextColors.Primary)
            }
            if (!error.isNullOrBlank()) {
                Text("错误: $error", color = StarryTextColors.Error)
            }
        }
    }
}
