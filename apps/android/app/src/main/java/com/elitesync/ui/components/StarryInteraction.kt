package com.elitesync.ui.components

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.SystemClock
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInteropFilter

data class UiFeedbackSettings(
    val hapticEnabled: Boolean = false,
    val clickSoundEnabled: Boolean = false
)

data class UiPerformanceSettings(
    val liteMode: Boolean = false
)

val LocalUiFeedbackSettings = staticCompositionLocalOf { UiFeedbackSettings() }
val LocalUiPerformanceSettings = staticCompositionLocalOf { UiPerformanceSettings() }

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

internal object StarryClickSound {
    private val tone by lazy { ToneGenerator(AudioManager.STREAM_MUSIC, 48) }
    private var lastPlayAt = 0L

    fun play() {
        val now = SystemClock.elapsedRealtime()
        if (now - lastPlayAt < 75L) return
        lastPlayAt = now
        tone.startTone(ToneGenerator.TONE_PROP_ACK, 24)
    }
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

