package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryBackButton
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarryTextField
import androidx.compose.material3.Text

@Composable
fun ChangePasswordScreen(
    vm: AppViewModel,
    onBack: () -> Unit
) {
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    val loading = status.contains("修改密码中")

    var currentPassword by remember { mutableStateOf("") }
    var newPassword by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }

    GlassScrollPage(
        title = "修改密码",
        status = status,
        error = error
    ) {
        StarrySectionCard(title = "密码安全") {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("密码规则：至少8位，且必须包含字母和数字。")
                StarryTextField(
                    value = currentPassword,
                    onValueChange = { currentPassword = it },
                    label = "当前密码",
                    isPassword = true
                )
                StarryTextField(
                    value = newPassword,
                    onValueChange = { newPassword = it },
                    label = "新密码",
                    isPassword = true
                )
                StarryTextField(
                    value = confirmPassword,
                    onValueChange = { confirmPassword = it },
                    label = "确认新密码",
                    isPassword = true
                )
                StarryPrimaryButton(
                    text = "保存新密码",
                    onClick = {
                        vm.clearError()
                        vm.changePassword(
                            currentPassword = currentPassword,
                            newPassword = newPassword,
                            newPasswordConfirm = confirmPassword
                        )
                    },
                    loading = loading
                )
                StarryBackButton(
                    text = "返回设置",
                    onClick = onBack,
                    modifier = Modifier,
                    compact = true
                )
            }
        }
    }
}

