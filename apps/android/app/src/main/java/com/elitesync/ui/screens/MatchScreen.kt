package com.elitesync.ui.screens

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.elitesync.model.MatchReasonModule
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.EliteSyncColors
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton
import com.elitesync.ui.components.StarryVerdictBadge

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
        StarrySectionCard(title = "匹配摘要") {
            Text("状态: $matchStateText")
            Text("我的倾向: ${profile.summary.label}")
            match?.let { StarryVerdictBadge(it.match_verdict) }
            Text(
                if (profile.summary.highlights.isEmpty()) {
                    "完成答题后将显示你的画像倾向"
                } else {
                    profile.summary.highlights.joinToString("；")
                }
            )
            val m = match
            if (m == null) {
                Text("当前无可展示的匹配对象")
            } else {
                Text("匹配对象ID: ${m.partner_id}")
                Text("综合说明: ${m.match_reasons?.summary ?: "暂无"}")
                Text("置信度: ${(((m.match_reasons?.confidence ?: 0.5) * 100).toInt())}%")
                m.match_reasons?.contract_version?.takeIf { it.isNotBlank() }?.let {
                    Text("解释版本: $it", color = EliteSyncColors.TextSecondary)
                }

                val core = m.core_scores
                if (core != null) {
                    Text("核心分(人格/MBTI/玄学/总分): ${core.personality ?: "-"} / ${core.mbti ?: "-"} / ${core.astro ?: "-"} / ${core.overall ?: "-"}")
                }
                Text("分数(base/final/fair): ${m.base_score ?: "-"} / ${m.final_score ?: "-"} / ${m.fairness_adjusted_score ?: "-"}")

                val modules = m.match_reasons?.modules.orEmpty()
                if (modules.isNotEmpty()) {
                    val sortedModules = modules.sortedByDescending { it.score ?: 0 }
                    Text("模块解释：", color = EliteSyncColors.TextSecondary)
                    sortedModules.forEach { module ->
                        ModuleLine(module)
                    }
                } else {
                    val tags = if (m.explanation_tags.isEmpty()) m.highlights else m.explanation_tags.joinToString("；")
                    Text("匹配理由: $tags")
                    if (!m.match_reasons?.mismatch.isNullOrEmpty()) {
                        m.match_reasons?.mismatch?.forEach { Text("关注点: $it", color = EliteSyncColors.Warning) }
                    }
                }

                val astro = m.astro_scores
                if (astro != null) {
                    Text("玄学分项(八字/属相/星座/星盘): ${astro.bazi ?: "-"} / ${astro.zodiac ?: "-"} / ${astro.constellation ?: "-"} / ${astro.natal_chart ?: "-"}")
                }
                val penaltyLine = if (m.penalty_factors.isEmpty()) {
                    "修正因子: 无"
                } else {
                    "修正因子:"
                }
                Text(penaltyLine)
                if (m.penalty_factors.isNotEmpty()) {
                    m.penalty_factors.entries.forEach { e ->
                        Text(
                            "  - ${humanizePenaltyFactorLine(e.key, e.value)}",
                            color = EliteSyncColors.TextSecondary
                        )
                    }
                }
            }
        }
        StarrySectionCard(title = "操作") {
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
}

@Composable
private fun ModuleLine(module: MatchReasonModule) {
    val score = (module.score ?: 0).coerceIn(0, 100)
    val scoreColor = scoreGradientColor(score)
    val weightPct = (((module.weight ?: 0.0) * 100).toInt()).coerceAtLeast(0)
    val confidencePct = (((module.confidence ?: 0.0) * 100).toInt()).coerceIn(0, 100)
    val verdictText = when (module.verdict) {
        "strong", "high" -> "高匹配"
        "medium" -> "中匹配"
        "weak", "low" -> "低匹配"
        else -> "待评估"
    }
    Column(verticalArrangement = Arrangement.spacedBy(com.elitesync.ui.components.EliteSyncDimens.Space4)) {
        Text(
            "${module.label.ifBlank { module.key }}：${module.score ?: "-"}分  $verdictText",
            color = scoreColor
        )
        Text(
            "  权重 ${weightPct}% · 置信度 ${confidencePct}%",
            color = EliteSyncColors.TextSecondary
        )
        val reasonShort = module.reason_short?.trim().orEmpty()
        val reasonDetail = module.reason_detail?.trim().orEmpty()
        val riskShort = module.risk_short?.trim().orEmpty()
        val riskDetail = module.risk_detail?.trim().orEmpty()

        if (reasonShort.isNotBlank()) {
            Text("  匹配点：$reasonShort", color = EliteSyncColors.TextSecondary)
        } else {
            module.highlights.firstOrNull()?.text?.takeIf { it.isNotBlank() }?.let {
                Text("  匹配点：$it", color = EliteSyncColors.TextSecondary)
            }
        }

        if (reasonDetail.isNotBlank()) {
            Text("  说明：$reasonDetail", color = EliteSyncColors.TextSecondary)
        } else {
            module.highlights.drop(1).firstOrNull()?.text?.takeIf { it.isNotBlank() }?.let {
                Text("  说明：$it", color = EliteSyncColors.TextSecondary)
            }
        }

        if (riskShort.isNotBlank()) {
            Text("  风险：$riskShort", color = EliteSyncColors.Warning)
        } else {
            module.risks.firstOrNull()?.text?.takeIf { it.isNotBlank() }?.let {
                Text("  风险：$it", color = EliteSyncColors.Warning)
            }
        }

        if (riskDetail.isNotBlank()) {
            Text("  风险说明：$riskDetail", color = EliteSyncColors.Warning)
        } else {
            module.risks.drop(1).firstOrNull()?.text?.takeIf { it.isNotBlank() }?.let {
                Text("  风险说明：$it", color = EliteSyncColors.Warning)
            }
        }

        if (module.evidence_tags.isNotEmpty()) {
            Text(
                "  证据标签：${humanizeEvidenceTags(module.evidence_tags)}",
                color = EliteSyncColors.TextSecondary
            )
        }
        if (module.degraded == true) {
            val reason = module.degrade_reason?.takeIf { it.isNotBlank() } ?: "数据不完整"
            Text("  当前为降级估算：$reason", color = EliteSyncColors.Warning)
        }
    }
}

private fun scoreGradientColor(score: Int): Color {
    val red = Color(0xFFFF4D4F)     // 50 and below -> red
    val amber = Color(0xFFFFB020)   // middle -> amber
    val green = Color(0xFF22C55E)   // 100 -> green
    val t = ((score - 50f) / 50f).coerceIn(0f, 1f)
    return if (t < 0.5f) {
        lerp(red, amber, t / 0.5f)
    } else {
        lerp(amber, green, (t - 0.5f) / 0.5f)
    }
}
