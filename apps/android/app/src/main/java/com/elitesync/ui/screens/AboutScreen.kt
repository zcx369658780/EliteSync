package com.elitesync.ui.screens

import android.content.Intent
import android.content.ClipboardManager
import android.content.ClipData
import android.net.Uri
import android.widget.Toast
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.platform.LocalContext
import com.elitesync.BuildConfig
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.EliteSyncColors
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.RuleDocumentBlock
import com.elitesync.ui.components.StarryBackButton
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarryStatusBanner
import com.elitesync.ui.components.StatusTone
import java.io.BufferedReader
import java.io.InputStreamReader

@Composable
fun AboutScreen(
    vm: AppViewModel,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    val appUpdateInfo by vm.appUpdateInfo.collectAsState()
    val appUpdateCheckMessage by vm.appUpdateCheckMessage.collectAsState()
    val appUpdateLastCheckedAt by vm.appUpdateLastCheckedAt.collectAsState()
    LaunchedEffect(Unit) { vm.clearAppUpdateCheckMessage() }
    val changelogText = remember {
        runCatching {
            context.assets.open("changelog_v0.txt").use { input ->
                BufferedReader(InputStreamReader(input)).readText()
            }
        }.getOrElse { "更新历史加载失败，请检查 assets/changelog_v0.txt" }
    }

    GlassScrollPage(title = "关于") {
        Text(
            text = "当前版本号：${BuildConfig.VERSION_NAME}",
            color = EliteSyncColors.TextPrimary
        )
        Text(
            text = "运行环境：API ${BuildConfig.API_BASE_URL} | WS ${BuildConfig.WS_BASE_URL}",
            color = EliteSyncColors.TextSecondary
        )
        if (appUpdateLastCheckedAt.isNotBlank()) {
            Text(
                text = "上次检查更新时间：$appUpdateLastCheckedAt",
                color = EliteSyncColors.TextSecondary
            )
        }

        Text(
            text = "更新历史",
            color = EliteSyncColors.TextSecondary
        )
        RuleDocumentBlock(text = changelogText)

        Text(
            text = "资质",
            color = EliteSyncColors.TextSecondary
        )
        RuleDocumentBlock(
            text = "软件著作权：还未申请\nICP备案：还未申请\n增值电信业务许可：还未申请"
        )

        StarryPrimaryButton(
            text = "检查更新",
            feedbackText = "正在检查",
            onClick = { vm.checkAppUpdate(reportMessage = true) }
        )
        StarryPrimaryButton(
            text = "复制更新诊断信息",
            feedbackText = "已复制",
            onClick = {
                val cm = context.getSystemService(ClipboardManager::class.java)
                val text = vm.buildUpdateDiagnosticText()
                cm?.setPrimaryClip(ClipData.newPlainText("update_diagnostic", text))
                Toast.makeText(context, "更新诊断信息已复制", Toast.LENGTH_SHORT).show()
            }
        )
        if (appUpdateCheckMessage.isNotBlank()) {
            StarryStatusBanner(
                text = appUpdateCheckMessage,
                tone = if (appUpdateCheckMessage.startsWith("检查更新失败")) StatusTone.Error else StatusTone.Info
            )
        }
        StarryBackButton(onClick = onBack)
    }

    appUpdateInfo?.let { update ->
        AlertDialog(
            onDismissRequest = {
                if (!update.force_update) vm.dismissAppUpdatePrompt()
            },
            title = { Text(if (update.force_update) "发现新版本（必须更新）" else "发现新版本") },
            text = {
                Text(
                    buildString {
                        append("当前版本：${update.client_version_name}\n")
                        append("最新版本：${update.latest_version_name}\n")
                        if (update.changelog.isNotBlank()) {
                            append("\n更新内容：\n${update.changelog}")
                        }
                    }
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        runCatching {
                            context.startActivity(
                                Intent(Intent.ACTION_VIEW, Uri.parse(update.download_url))
                            )
                        }
                    }
                ) { Text("是（下载）") }
            },
            dismissButton = if (!update.force_update) {
                { TextButton(onClick = { vm.dismissAppUpdatePrompt() }) { Text("否") } }
            } else null
        )
    }
}
