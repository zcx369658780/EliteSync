package com.elitesync.ui.screens

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySecondaryButton

@Composable
fun MeScreen(
    vm: AppViewModel,
    onBasicProfile: () -> Unit,
    onQuestionnaire: () -> Unit,
    onInsights: () -> Unit,
    onSettings: () -> Unit,
    onLogout: () -> Unit
) {
    val profile by vm.profile.collectAsState()

    GlassScrollPage(title = "我的") {
        Text("个人画像：${profile.summary.label}")
        Text("认证中心（占位）")
        Text("- 实名认证：未提交")
        Text("- 学历认证：未提交")
        Text("- 资产认证：未提交")
        Text("- 无犯罪证明：未提交")
        StarrySecondaryButton(text = "基础资料（生日）", onClick = onBasicProfile)
        StarrySecondaryButton(text = "编辑建档/问卷", onClick = onQuestionnaire)
        StarryPrimaryButton(text = "扩展画像（星座/八字/星盘/MBTI）", onClick = onInsights)
        StarrySecondaryButton(text = "设置", onClick = onSettings)
        StarrySecondaryButton(text = "会员中心（占位）", onClick = { })
        StarrySecondaryButton(text = "订单与支付（占位）", onClick = { })
        StarrySecondaryButton(text = "退出登录", onClick = onLogout)
    }
}
