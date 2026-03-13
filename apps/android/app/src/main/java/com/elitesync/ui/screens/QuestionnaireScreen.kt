package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
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
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    var answer by remember { mutableStateOf("A") }

    LaunchedEffect(Unit) { vm.loadQuestions() }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("问卷（后端拉取）")
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(questions.take(10)) { q ->
                Text("${q.id}. ${q.content}")
                Text("选项: ${q.options.joinToString()}")
            }
        }
        OutlinedTextField(value = answer, onValueChange = { answer = it }, label = { Text("答案示例") })
        Button(onClick = { vm.saveAllAnswers(answer, false) }) { Text("保存全部答案") }
        Text(if (questionnaireComplete) "问卷状态: 已完成" else "问卷状态: 未完成")
        Button(onClick = onNext, enabled = questionnaireComplete) { Text("进入匹配") }
        Text("状态: $status")
        if (error.isNotBlank()) Text("错误: $error", color = Color.Red)
    }
}
