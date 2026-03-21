package com.elitesync.ui.screens

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarryTextField

@Composable
fun PreferencesScreen(onBack: () -> Unit) {
    var ageRange by remember { mutableStateOf("") }
    var cityRange by remember { mutableStateOf("") }
    var education by remember { mutableStateOf("") }
    var job by remember { mutableStateOf("") }
    var income by remember { mutableStateOf("") }

    GlassScrollPage(title = "择偶偏好（占位）") {
        StarryTextField(value = ageRange, onValueChange = { ageRange = it }, label = "年龄范围（如 24-32）")
        StarryTextField(value = cityRange, onValueChange = { cityRange = it }, label = "城市/距离")
        StarryTextField(value = education, onValueChange = { education = it }, label = "学历偏好")
        StarryTextField(value = job, onValueChange = { job = it }, label = "职业偏好")
        StarryTextField(value = income, onValueChange = { income = it }, label = "收入偏好")
        StarryPrimaryButton(text = "保存并返回（占位）", onClick = onBack)
    }
}
