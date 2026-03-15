package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel

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
    val scrollState = rememberScrollState()

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

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp).verticalScroll(scrollState),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text("问卷（单击大按钮即可作答）")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Button(
                onClick = { if (currentIndex > 0) currentIndex-- },
                enabled = currentIndex > 0
            ) { Text("◀ 上一题") }
            Text("进度: ${submittedIds.size}/$questionnaireRequired")
            Button(
                onClick = { if (currentIndex < questions.lastIndex) currentIndex++ },
                enabled = currentIndex < questions.lastIndex
            ) { Text("下一题 ▶") }
        }

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
                Button(
                    modifier = Modifier.fillMaxWidth().height(56.dp),
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
                ) {
                    val pickTag = when (selectedIndex) {
                        0 -> "① "
                        1 -> "② "
                        else -> ""
                    }
                    Text((if (selectedIndex >= 0) "✓ " else "") + pickTag + "$optionCode. $label")
                }
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
            Button(
                modifier = Modifier.fillMaxWidth(),
                onClick = {
                    val exclude = (seenQuestionIds.toSet() + selectedMap.keys + currentQuestion.id).toList()
                    vm.replaceQuestion(currentQuestion.id, exclude)
                }
            ) { Text("换一题（未做过）") }
        } else {
            Text("题目加载中或已完成全部作答")
        }

        Text(if (questionnaireComplete) "问卷状态: 已完成" else "问卷状态: 未完成")
        Button(onClick = onNext, enabled = questionnaireComplete || allAnsweredLocal) { Text("进入匹配") }
        Text("状态: $status")
        if (error.isNotBlank()) Text("错误: $error", color = Color.Red)
    }
}

private fun optionCode(index: Int): String {
    return if (index in 0..25) {
        ('A'.code + index).toChar().toString()
    } else {
        "O${index + 1}"
    }
}
