package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel

@Composable
fun MatchScreen(vm: AppViewModel, onRetake: () -> Unit, onChat: () -> Unit, onLogout: () -> Unit) {
    val match by vm.currentMatch.collectAsState()
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val profile by vm.profile.collectAsState()
    val matchStateText by vm.matchStateText.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    val scrollState = rememberScrollState()

    LaunchedEffect(Unit) {
        vm.loadQuestionnaireProgress()
        vm.loadCurrentMatch()
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp).verticalScroll(scrollState),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text("每周匹配")
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
        Button(
            onClick = { vm.devPrepareMatchForDemo() },
            enabled = questionnaireComplete
        ) { Text("开发联调：生成并发布匹配") }
        Button(onClick = { vm.loadCurrentMatch() }) { Text("刷新匹配") }
        Button(onClick = onRetake) { Text("重新答题") }
        Button(onClick = { vm.confirmLike(true) }) { Text("喜欢") }
        Button(onClick = { vm.confirmLike(false) }) { Text("略过") }
        Button(onClick = onChat) { Text("进入聊天") }
        Button(onClick = onLogout) { Text("退出登录") }
        Text("状态: $status")
        if (error.isNotBlank()) Text("错误: $error", color = Color.Red)
    }
}
