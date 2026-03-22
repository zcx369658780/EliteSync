package com.elitesync.ui.screens

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton

@Composable
fun MeScreen(
    vm: AppViewModel,
    onBasicProfile: () -> Unit,
    onQuestionnaire: () -> Unit,
    onInsights: () -> Unit,
    onAbout: () -> Unit,
    onSettings: () -> Unit,
    onLogout: () -> Unit
) {
    val profile by vm.profile.collectAsState()

    GlassScrollPage(title = "我的") {
        StarrySectionCard(title = "个人摘要") {
            Text("个人画像：${profile.summary.label}")
        }
        StarrySectionCard(title = "资料与画像") {
            StarrySecondaryButton(text = "基础资料（生日）", onClick = onBasicProfile)
            StarrySecondaryButton(text = "编辑建档/问卷", onClick = onQuestionnaire)
            StarryPrimaryButton(text = "扩展画像（星座/八字/星盘/MBTI）", onClick = onInsights)
        }
        StarrySectionCard(title = "系统与服务") {
            StarrySecondaryButton(text = "设置", onClick = onSettings)
            StarrySecondaryButton(text = "关于", onClick = onAbout)
            StarrySecondaryButton(text = "会员中心（占位）", onClick = { })
            StarrySecondaryButton(text = "订单与支付（占位）", onClick = { })
        }
        StarrySectionCard(title = "账号") {
            StarrySecondaryButton(text = "退出登录", onClick = onLogout)
        }
    }
}
