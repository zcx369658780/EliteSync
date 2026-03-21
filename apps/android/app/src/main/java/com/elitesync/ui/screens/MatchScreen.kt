package com.elitesync.ui.screens

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
fun MatchScreen(vm: AppViewModel, onRetake: () -> Unit, onChat: () -> Unit, onLogout: () -> Unit) {
    val match by vm.currentMatch.collectAsState()
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val profile by vm.profile.collectAsState()
    val matchStateText by vm.matchStateText.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    LaunchedEffect(Unit) {
        vm.loadQuestionnaireProgress()
        vm.loadCurrentMatch()
    }

    GlassScrollPage(title = "每周匹配", status = status, error = error) {
        Text("状态: $matchStateText")
        Text("我的倾向: ${profile.summary.label}")
        Text(
            if (profile.summary.highlights.isEmpty()) {
                "完成答题后将显示你的画像倾向"
            } else {
                profile.summary.highlights.joinToString("；")
            }
        )
        Text(match?.let {
            val tags = if (it.explanation_tags.isEmpty()) it.highlights else it.explanation_tags.joinToString("；")
            val scoreLine = "分数(base/final/fair): ${it.base_score ?: "-"} / ${it.final_score ?: "-"} / ${it.fairness_adjusted_score ?: "-"}"
            val penaltyLine = if (it.penalty_factors.isEmpty()) {
                "惩罚因子: 无"
            } else {
                "惩罚因子: " + it.penalty_factors.entries.joinToString("；") { e ->
                    "${e.key}=${"%.2f".format(e.value)}"
                }
            }
            "匹配对象ID: ${it.partner_id}\n匹配理由: $tags\n$scoreLine\n$penaltyLine"
        } ?: "当前无可展示的匹配对象")
        StarrySecondaryButton(
            text = "开发联调：生成并发布匹配",
            onClick = { vm.devPrepareMatchForDemo() },
            enabled = questionnaireComplete
        )
        StarrySecondaryButton(text = "刷新匹配", onClick = { vm.loadCurrentMatch() })
        StarrySecondaryButton(text = "重新答题", onClick = onRetake)
        StarryPrimaryButton(text = "喜欢", onClick = { vm.confirmLike(true) })
        StarrySecondaryButton(text = "略过", onClick = { vm.confirmLike(false) })
        StarryPrimaryButton(text = "进入聊天", onClick = onChat)
        StarrySecondaryButton(text = "退出登录", onClick = onLogout)
    }
}
