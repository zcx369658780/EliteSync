package com.elitesync.ui.screens

import android.content.Context
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel

private const val PREFS_AUTH = "elitesync_auth_prefs"
private const val KEY_LAST_PHONE = "last_phone"
private const val KEY_LAST_PASSWORD = "last_password"
private val PHONE_REGEX = Regex("^1[3-9]\\d{9}$")
private val PASSWORD_REGEX = Regex("^(?=.*[A-Za-z])(?=.*\\d).{8,}$")

@Composable
fun RegisterScreen(vm: AppViewModel, onNext: (String) -> Unit) {
    val context = LocalContext.current
    val prefs = remember { context.getSharedPreferences(PREFS_AUTH, Context.MODE_PRIVATE) }
    var phone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var localError by remember { mutableStateOf("") }
    val isLoggedIn by vm.isLoggedIn.collectAsState()
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val questionnaireProgressLoaded by vm.questionnaireProgressLoaded.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    val scrollState = rememberScrollState()

    LaunchedEffect(Unit) {
        phone = prefs.getString(KEY_LAST_PHONE, "").orEmpty()
        password = prefs.getString(KEY_LAST_PASSWORD, "").orEmpty()
    }

    LaunchedEffect(status) {
        if (status == "注册成功，请登录" || status == "登录成功") {
            prefs.edit()
                .putString(KEY_LAST_PHONE, phone)
                .putString(KEY_LAST_PASSWORD, password)
                .apply()
        }
    }

    LaunchedEffect(isLoggedIn, questionnaireProgressLoaded, questionnaireComplete) {
        if (isLoggedIn && questionnaireProgressLoaded) {
            onNext(if (questionnaireComplete) "match" else "questionnaire")
        }
    }

    fun validateInput(rawPhone: String, rawPassword: String): String {
        if (!PHONE_REGEX.matches(rawPhone)) {
            return "手机号格式错误，请输入11位中国大陆手机号（如 13800138000）"
        }
        if (!PASSWORD_REGEX.matches(rawPassword)) {
            return "密码格式错误：至少8位，且必须包含字母和数字"
        }
        return ""
    }

    fun doAuth(action: (String, String) -> Unit) {
        val normalizedPhone = phone.trim()
        val pwd = password.trim()
        localError = validateInput(normalizedPhone, pwd)
        if (localError.isNotBlank()) {
            vm.clearError()
            return
        }
        localError = ""
        phone = normalizedPhone
        password = pwd
        action(normalizedPhone, pwd)
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp).verticalScroll(scrollState),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("EliteSync 登录/注册")
        OutlinedTextField(value = phone, onValueChange = { phone = it }, label = { Text("手机号") })
        OutlinedTextField(value = password, onValueChange = { password = it }, label = { Text("密码") })
        Button(onClick = { doAuth(vm::register) }) { Text("注册") }
        Button(onClick = { doAuth(vm::login) }) { Text("登录") }
        Text("状态: $status")
        val displayError = if (localError.isNotBlank()) localError else error
        if (displayError.isNotBlank()) {
            Text("错误: $displayError", color = Color.Red)
        }
    }
}
