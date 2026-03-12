package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
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
fun MatchScreen(vm: AppViewModel, onChat: () -> Unit) {
    val match by vm.currentMatch.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()

    LaunchedEffect(Unit) { vm.loadCurrentMatch() }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text("每周匹配")
        Text(match?.let { "匹配对象: ${it.partner_id}\n亮点: ${it.highlights}" } ?: "当前还未到 Drop 时刻或暂无匹配")
        Button(onClick = { vm.confirmLike(true) }) { Text("喜欢") }
        Button(onClick = { vm.confirmLike(false) }) { Text("略过") }
        Button(onClick = onChat) { Text("进入聊天") }
        Text("状态: $status")
        if (error.isNotBlank()) Text("错误: $error", color = Color.Red)
    }
}
