package com.elitesync.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryBackButton
import com.elitesync.ui.components.StarryOptionCard
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard

@Composable
fun MbtiQuizScreen(vm: AppViewModel, onBack: () -> Unit) {
    val questions by vm.mbtiQuestions.collectAsState()
    val answers by vm.mbtiAnswers.collectAsState()
    val mbti by vm.insightsMbti.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    val loading = status.contains("加载MBTI题目")
    val submitting = status.contains("MBTI结果计算")

    LaunchedEffect(Unit) {
        vm.loadMbtiQuiz("lite3_v1")
        vm.loadMbtiResult()
    }

    GlassScrollPage(title = "MBTI快速测试（3题）", status = status, error = error) {
        StarrySectionCard(title = "说明") {
            Text("约30秒完成。每题二选一，结果将自动保存到服务端。")
            Text("已完成：${answers.size}/${questions.size}")
        }

        questions.forEachIndexed { idx, q ->
            val selected = answers[q.question_id]
            StarrySectionCard(title = "第${idx + 1}题") {
                androidx.compose.foundation.layout.Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(1.dp, Color(0x66A7BFEB), RoundedCornerShape(16.dp))
                        .background(Color(0x22142339), RoundedCornerShape(16.dp))
                        .padding(10.dp)
                ) {
                    Text(q.content, modifier = Modifier.padding(bottom = 8.dp))
                    StarryOptionCard(
                        text = "A. ${q.option_a_text}",
                        selected = selected == "A",
                        modifier = Modifier.padding(vertical = 3.dp),
                        onClick = { vm.chooseMbtiAnswer(q.question_id, "A") }
                    )
                    StarryOptionCard(
                        text = "B. ${q.option_b_text}",
                        selected = selected == "B",
                        modifier = Modifier.padding(vertical = 3.dp),
                        onClick = { vm.chooseMbtiAnswer(q.question_id, "B") }
                    )
                }
            }
        }

        StarryPrimaryButton(
            text = "提交MBTI结果",
            loading = submitting,
            feedbackText = "提交中",
            enabled = questions.isNotEmpty() && answers.size == questions.size,
            onClick = { vm.submitMbtiQuiz() }
        )
        if (mbti.isNotBlank()) {
            Text("MBTI结果：$mbti", modifier = Modifier.padding(top = 4.dp, bottom = 2.dp))
        }
        StarryBackButton(
            text = "返回扩展画像",
            loading = loading,
            onClick = onBack
        )
    }
}
