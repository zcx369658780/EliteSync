package com.elitesync.ui.screens

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton

@Composable
fun MeSettingsScreen(
    vm: AppViewModel,
    onBack: () -> Unit
) {
    val hapticEnabled by vm.hapticEnabled.collectAsState()
    val clickSoundEnabled by vm.clickSoundEnabled.collectAsState()
    val liteMode by vm.litePerformanceMode.collectAsState()

    GlassScrollPage(title = "设置") {
        StarrySectionCard(title = "交互反馈") {
            StarrySecondaryButton(
                text = if (hapticEnabled) "触感反馈：已开启" else "触感反馈：已关闭",
                onClick = { vm.toggleHapticEnabled() }
            )
            StarrySecondaryButton(
                text = if (clickSoundEnabled) "点击音效：已开启" else "点击音效：已关闭",
                onClick = { vm.toggleClickSoundEnabled() }
            )
        }
        StarrySectionCard(title = "性能") {
            StarrySecondaryButton(
                text = if (liteMode) "快速性能模式：已开启" else "快速性能模式：已关闭",
                onClick = { vm.toggleLitePerformanceMode() }
            )
            Text("说明：开启后会降低星空背景动态层与纹理负载，适配低性能设备。")
            StarryPrimaryButton(text = "返回", onClick = onBack)
        }
    }
}
