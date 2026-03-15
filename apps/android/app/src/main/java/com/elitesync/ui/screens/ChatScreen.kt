package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.verticalScroll
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import com.elitesync.ui.AppViewModel
import com.elitesync.ws.ChatSocketManager

@Composable
fun ChatScreen(vm: AppViewModel, socket: ChatSocketManager) {
    val messages by vm.messages.collectAsState()
    val userId by vm.currentUserId.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    var input by remember { mutableStateOf("") }
    val lifecycleOwner = LocalLifecycleOwner.current
    val scrollState = rememberScrollState()

    LaunchedEffect(Unit) {
        userId?.let { socket.connect(it) }
        vm.refreshMessages()
    }

    LaunchedEffect(userId) {
        while (isActive) {
            vm.refreshMessages()
            delay(2000)
        }
    }

    DisposableEffect(lifecycleOwner, userId) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                userId?.let { socket.connect(it) }
                vm.refreshMessages()
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp).verticalScroll(scrollState),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text("聊天")
        LazyColumn(modifier = Modifier.height(320.dp)) {
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
