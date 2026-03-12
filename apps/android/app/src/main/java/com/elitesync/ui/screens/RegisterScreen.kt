package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel

@Composable
fun RegisterScreen(vm: AppViewModel, onNext: () -> Unit) {
    var phone by remember { mutableStateOf("13800000001") }
    var password by remember { mutableStateOf("123456") }
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("EliteSync 登录/注册")
        OutlinedTextField(value = phone, onValueChange = { phone = it }, label = { Text("手机号") })
        OutlinedTextField(value = password, onValueChange = { password = it }, label = { Text("密码") })
        Button(onClick = { vm.register(phone, password) }) { Text("注册") }
        Button(onClick = { vm.login(phone, password) }) { Text("登录") }
        Button(onClick = onNext) { Text("进入问卷") }
        Text("状态: $status")
        if (error.isNotBlank()) {
            Text("错误: $error", color = Color.Red)
        }
    }
}
