package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryListItemCard
import com.elitesync.ui.components.StarryPrimaryButton

@Composable
fun MessagesScreen(vm: AppViewModel, onOpenChat: () -> Unit) {
    val messages by vm.messages.collectAsState()
    val status by vm.status.collectAsState()

    LaunchedEffect(Unit) {
        vm.refreshMessages()
    }

    GlassScrollPage(title = "消息", status = status) {
        Text("当前会话（占位）")
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            messages.takeLast(20).forEach { msg ->
                StarryListItemCard(text = msg)
            }
        }
        StarryPrimaryButton(text = "进入聊天详情", onClick = onOpenChat)
    }
}
