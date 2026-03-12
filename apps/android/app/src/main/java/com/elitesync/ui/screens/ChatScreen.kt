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
import com.elitesync.ws.ChatSocketManager

@Composable
fun ChatScreen(vm: AppViewModel, socket: ChatSocketManager) {
    val messages by vm.messages.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    var input by remember { mutableStateOf("") }

    LaunchedEffect(Unit) {
        vm.refreshMessages()
    }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("聊天")
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(messages) { Text(it) }
        }
        OutlinedTextField(value = input, onValueChange = { input = it }, label = { Text("消息") })
        Button(onClick = {
            vm.sendMessage(input)
            input = ""
            socket.heartbeat()
            vm.refreshMessages()
        }) { Text("发送") }
        Text("状态: $status")
        if (error.isNotBlank()) Text("错误: $error", color = Color.Red)
    }
}
