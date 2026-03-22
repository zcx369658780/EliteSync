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
fun OnboardingHubScreen(
    vm: AppViewModel,
    onBasicProfile: () -> Unit,
    onPreferences: () -> Unit,
    onQuestionnaire: () -> Unit,
    onFinish: () -> Unit
) {
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val onboardingComplete by vm.onboardingComplete.collectAsState()

    GlassScrollPage(title = "新用户建档") {
        StarrySectionCard(title = "建档状态") {
            Text(if (onboardingComplete) "状态：建档已完成" else "状态：建档进行中")
            Text("建议顺序：基础资料 -> 择偶偏好 -> 问卷画像")
        }
        StarrySectionCard(title = "建档流程") {
            StarrySecondaryButton(text = "1) 基础资料（占位）", onClick = onBasicProfile)
            StarrySecondaryButton(text = "2) 择偶偏好（占位）", onClick = onPreferences)
            StarrySecondaryButton(text = "3) 问卷画像", onClick = onQuestionnaire)
            StarryPrimaryButton(
                text = "完成建档，进入推荐",
                onClick = {
                    vm.markOnboardingComplete()
                    onFinish()
                },
                enabled = questionnaireComplete
            )
            if (!questionnaireComplete) {
                Text("提示：请先完成问卷画像后再完成建档。")
            }
        }
    }
}
