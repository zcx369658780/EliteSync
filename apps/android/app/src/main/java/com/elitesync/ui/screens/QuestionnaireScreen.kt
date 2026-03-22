package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryOptionCard
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton

@Composable
fun QuestionnaireScreen(vm: AppViewModel, onNext: () -> Unit) {
    val questions by vm.questions.collectAsState()
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val questionnaireRequired by vm.questionnaireRequired.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    var currentIndex by remember { mutableStateOf(0) }
    val selectedMap = remember { mutableStateMapOf<Int, List<String>>() } // ordered: first is more important
    val submittedIds = remember { mutableStateListOf<Int>() }
    val seenQuestionIds = remember { mutableStateListOf<Int>() }

    LaunchedEffect(Unit) { vm.loadQuestions() }
    LaunchedEffect(questions) {
        questions.forEach {
            if (!seenQuestionIds.contains(it.id)) {
                seenQuestionIds.add(it.id)
            }
        }
        if (currentIndex > questions.lastIndex) {
            currentIndex = questions.lastIndex.coerceAtLeast(0)
        }
    }

    val currentQuestion = questions.getOrNull(currentIndex)
    val allAnsweredLocal = submittedIds.size >= questionnaireRequired
    val progressTarget = (submittedIds.size.toFloat() / questionnaireRequired.coerceAtLeast(1)).coerceIn(0f, 1f)
    val progress by animateFloatAsState(
        targetValue = progressTarget,
        animationSpec = tween(260),
        label = "questionProgress"
    )
    val submitAndGoNext: (Int, List<String>, Int) -> Unit = { questionId, selected, version ->
        if (selected.isNotEmpty()) {
            vm.saveAnswerV2(
                questionId = questionId,
                selectedAnswer = selected.first(),
                acceptableAnswers = selected.take(2),
                importance = 2,
                version = version
            )
            if (!submittedIds.contains(questionId)) {
                submittedIds.add(questionId)
            }
            if (currentIndex < questions.lastIndex) {
                currentIndex++
            }
        }
    }

    GlassScrollPage(title = "问卷（单击大按钮即可作答）", status = status, error = error) {
        StarrySectionCard(title = "进度") {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                StarrySecondaryButton(
                    text = "◀ 上一题",
                    onClick = { if (currentIndex > 0) currentIndex-- },
                    enabled = currentIndex > 0,
                    modifier = Modifier.fillMaxWidth(0.30f)
                )
                Text("进度: ${submittedIds.size}/$questionnaireRequired")
                StarrySecondaryButton(
                    text = "下一题 ▶",
                    onClick = { if (currentIndex < questions.lastIndex) currentIndex++ },
                    enabled = currentIndex < questions.lastIndex,
                    modifier = Modifier.fillMaxWidth(0.30f)
                )
            }
            LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier.fillMaxWidth(),
                color = Color(0xFF7FA9FF),
                trackColor = Color(0x55334B71)
            )
            Text("完成度：${(progress * 100).toInt()}%")
        }

        StarrySectionCard(title = "当前题目") {
            if (currentQuestion != null) {
                Text("${currentIndex + 1}. ${currentQuestion.content}")
                val options = currentQuestion.option_items
                val maxPick = if (currentQuestion.question_type == "multi_choice") 2 else 1
                val selected = selectedMap[currentQuestion.id].orEmpty()
                val remainingPickForMulti = if (currentQuestion.question_type == "multi_choice") {
                    (2 - selected.size).coerceAtLeast(0)
                } else 0
                options.forEachIndexed { idx, option ->
                    val optionCode = optionCode(idx)
                    val label = option.label.zh ?: option.option_id
                    val selectedIndex = selected.indexOf(option.option_id)
                    StarryOptionCard(
                        text = "$optionCode. $label",
                        selected = selectedIndex >= 0,
                        pickOrder = if (selectedIndex >= 0) selectedIndex else null,
                        onClick = {
                            val now = selectedMap[currentQuestion.id].orEmpty().toMutableList()
                            if (now.contains(option.option_id)) {
                                now.remove(option.option_id)
                            } else if (maxPick == 1) {
                                now.clear()
                                now.add(option.option_id)
                            } else {
                                if (now.size < 2) {
                                    now.add(option.option_id)
                                }
                            }
                            selectedMap[currentQuestion.id] = now
                            if (currentQuestion.question_type != "multi_choice" && now.size == 1) {
                                submitAndGoNext(currentQuestion.id, now, currentQuestion.version ?: 1)
                            } else if (currentQuestion.question_type == "multi_choice" && now.size >= 2) {
                                submitAndGoNext(currentQuestion.id, now, currentQuestion.version ?: 1)
                            }
                        }
                    )
                }
                Text(
                    if (currentQuestion.question_type == "multi_choice") {
                        "提示：多选题最多选两项，先选最重要(①)，再选次重要(②)；选到第二项后会自动进入下一题。"
                    } else {
                        "提示：单选题选择一项后会自动进入下一题；可用“上一题”返回修改。"
                    }
                )
                if (currentQuestion.question_type == "multi_choice" && remainingPickForMulti == 1) {
                    Text("还需再选 1 项", color = Color(0xFFD32F2F))
                }
                StarrySecondaryButton(
                    text = "换一题（未做过）",
                    modifier = Modifier.fillMaxWidth(),
                    onClick = {
                        val exclude = (seenQuestionIds.toSet() + selectedMap.keys + currentQuestion.id).toList()
                        vm.replaceQuestion(currentQuestion.id, exclude)
                    },
                    loading = status.contains("换题中")
                )
            } else {
                Text("题目加载中或已完成全部作答")
            }
        }
        StarrySectionCard(title = "完成") {
            Text(if (questionnaireComplete) "问卷状态: 已完成" else "问卷状态: 未完成")
            StarryPrimaryButton(text = "进入匹配", onClick = onNext, enabled = questionnaireComplete || allAnsweredLocal)
        }
    }
}

private fun optionCode(index: Int): String {
    return if (index in 0..25) {
        ('A'.code + index).toChar().toString()
    } else {
        "O${index + 1}"
    }
}
