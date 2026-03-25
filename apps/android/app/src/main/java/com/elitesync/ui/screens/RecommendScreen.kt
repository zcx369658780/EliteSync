package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.ui.graphics.Color
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.elitesync.ui.components.EliteSyncColors
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton
import com.elitesync.ui.components.StarryVerdictBadge

@Composable
fun RecommendScreen(vm: AppViewModel, onQuestionnaire: () -> Unit, onGoMatch: () -> Unit) {
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val profile by vm.profile.collectAsState()
    val match by vm.currentMatch.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    LaunchedEffect(questionnaireComplete) {
        vm.loadQuestionnaireProgress()
        vm.loadQuestionnaireProfile()
        if (questionnaireComplete) {
            vm.loadCurrentMatch()
        }
    }

    GlassScrollPage(title = "推荐", status = status, error = error) {
        StarrySectionCard(title = "建档摘要") {
            Text(if (questionnaireComplete) "建档状态：已完成" else "建档状态：未完成")
            Text("我的倾向：${profile.summary.label}")
            Text(
                if (profile.summary.highlights.isEmpty()) {
                    "完成建档问卷后将显示匹配理由和推荐解释。"
                } else {
                    "画像摘要：${profile.summary.highlights.joinToString("；")}"
                }
            )
            match?.let { StarryVerdictBadge(it.match_verdict) }
            val brief = match?.let {
                val summary = it.match_reasons?.summary?.takeIf { s -> s.isNotBlank() } ?: it.highlights
                "当前匹配：$summary"
            } ?: if (questionnaireComplete) {
                "当前匹配：暂无可展示对象"
            } else {
                "当前匹配：完成建档后可查看"
            }
            Text(brief)
            val modules = match?.match_reasons?.modules.orEmpty()
            if (modules.isNotEmpty()) {
                val top = modules.sortedByDescending { it.score ?: 0 }.take(2)
                top.forEach { module ->
                    val score = module.score ?: 0
                    val line = module.reason_short?.takeIf { it.isNotBlank() }
                        ?: module.highlights.firstOrNull()?.text
                        ?: module.risk_short?.takeIf { it.isNotBlank() }
                        ?: module.risks.firstOrNull()?.text
                        ?: "暂无细节"
                    Text(
                        text = "${module.label.ifBlank { module.key }}（$score 分）：$line",
                        color = when {
                            score >= 85 -> Color(0xFF22C55E)
                            score >= 70 -> EliteSyncColors.TextPrimary
                            else -> EliteSyncColors.TextSecondary
                        }
                    )
                    if (module.evidence_tags.isNotEmpty()) {
                        Text(
                            text = "证据：${module.evidence_tags.joinToString(" | ")}",
                            color = EliteSyncColors.TextSecondary
                        )
                    }
                }
            }
        }
        StarrySectionCard(title = "下一步") {
            StarrySecondaryButton(
                text = if (questionnaireComplete) "重新建档/答题" else "开始建档/答题",
                onClick = onQuestionnaire
            )
            StarryPrimaryButton(text = "进入匹配", onClick = onGoMatch, enabled = questionnaireComplete)
        }
    }
}
