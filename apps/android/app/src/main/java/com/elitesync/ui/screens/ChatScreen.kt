package com.elitesync.ui.screens

import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryListItemCard
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarryTextField
import com.elitesync.ws.ChatSocketManager

@Composable
fun ChatScreen(vm: AppViewModel, socket: ChatSocketManager) {
    val messages by vm.messages.collectAsState()
    val userId by vm.currentUserId.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    var input by remember { mutableStateOf("") }
    val lifecycleOwner = LocalLifecycleOwner.current

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

    GlassScrollPage(title = "聊天", status = status, error = error) {
        StarrySectionCard(title = "会话") {
            LazyColumn(modifier = androidx.compose.ui.Modifier.height(320.dp)) {
                items(messages) { StarryListItemCard(text = it) }
            }
        }
        StarrySectionCard(title = "发送消息") {
            StarryTextField(value = input, onValueChange = { input = it }, label = "消息", singleLine = false)
            StarryPrimaryButton(text = "发送", onClick = {
                vm.sendMessage(input)
                input = ""
                socket.heartbeat()
                vm.refreshMessages()
            })
        }
    }
}
