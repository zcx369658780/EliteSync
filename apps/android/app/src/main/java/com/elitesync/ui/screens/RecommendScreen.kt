package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySecondaryButton

@Composable
fun RecommendScreen(vm: AppViewModel, onQuestionnaire: () -> Unit, onGoMatch: () -> Unit) {
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val profile by vm.profile.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    LaunchedEffect(Unit) {
        vm.loadQuestionnaireProgress()
        vm.loadQuestionnaireProfile()
    }

    GlassScrollPage(title = "推荐", status = status, error = error) {
        Text(if (questionnaireComplete) "建档状态：已完成" else "建档状态：未完成")
        Text("我的倾向：${profile.summary.label}")
        Text(
            if (profile.summary.highlights.isEmpty()) {
                "完成建档问卷后将显示匹配理由和推荐解释。"
            } else {
                "画像摘要：${profile.summary.highlights.joinToString("；")}"
            }
        )
        StarrySecondaryButton(
            text = if (questionnaireComplete) "重新建档/答题" else "开始建档/答题",
            onClick = onQuestionnaire
        )
        StarryPrimaryButton(text = "进入匹配", onClick = onGoMatch, enabled = questionnaireComplete)
    }
}
