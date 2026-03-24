package com.elitesync.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.EliteSyncColors
import com.elitesync.ui.components.EliteSyncDimens
import com.elitesync.ui.components.EliteSyncShapes
import com.elitesync.ui.components.StarryListItemCard
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarryStatusBanner
import com.elitesync.ui.components.StarryTextField
import com.elitesync.ui.components.StatusTone
import com.elitesync.ws.ChatSocketManager
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive

@Composable
fun ChatScreen(vm: AppViewModel, socket: ChatSocketManager) {
    val messages by vm.messages.collectAsState()
    val userId by vm.currentUserId.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    var input by remember { mutableStateOf("") }
    val listState = rememberLazyListState()
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

    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.lastIndex)
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
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .padding(EliteSyncDimens.Space16),
        verticalArrangement = Arrangement.spacedBy(EliteSyncDimens.Space12)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(50.dp)
                .background(
                    color = androidx.compose.ui.graphics.Color(0xAA0F192C),
                    shape = RoundedCornerShape(EliteSyncShapes.TabRadius)
                )
                .border(
                    width = 1.dp,
                    color = EliteSyncColors.BorderSubtle.copy(alpha = 0.8f),
                    shape = RoundedCornerShape(EliteSyncShapes.TabRadius)
                )
                .padding(horizontal = 6.dp, vertical = 5.dp)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        color = EliteSyncColors.SurfaceCardStrong.copy(alpha = 0.95f),
                        shape = RoundedCornerShape(12.dp)
                    )
            ) {
                Text(
                    text = "聊天",
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 6.dp),
                    color = EliteSyncColors.TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center
                )
            }
        }

        if (!error.isNullOrBlank()) {
            StarryStatusBanner(text = "错误：$error", tone = StatusTone.Error)
        } else if (status.isNotBlank()) {
            StarryStatusBanner(text = "状态：$status", tone = StatusTone.Info)
        }

        StarrySectionCard(
            title = "会话",
            modifier = Modifier.weight(1f)
        ) {
            LazyColumn(
                state = listState,
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
            ) {
                items(messages) { StarryListItemCard(text = it) }
            }
        }

        StarrySectionCard(title = "发送消息") {
            StarryTextField(
                value = input,
                onValueChange = { input = it },
                label = "消息",
                singleLine = false
            )
            StarryPrimaryButton(
                text = "发送",
                feedbackText = "发送中",
                onClick = {
                    vm.sendMessage(input)
                    input = ""
                    socket.heartbeat()
                    vm.refreshMessages()
                }
            )
        }
    }
}
