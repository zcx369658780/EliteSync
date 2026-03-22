package com.elitesync.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun GlassScrollPage(
    title: String,
    status: String? = null,
    error: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val scroll = rememberScrollState()
    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
            .padding(EliteSyncDimens.Space16)
            .verticalScroll(scroll),
        verticalArrangement = Arrangement.spacedBy(EliteSyncDimens.Space12)
    ) {
        Text(title, color = EliteSyncColors.TextPrimary)
        if (!error.isNullOrBlank()) {
            StarryStatusBanner(text = "错误：$error", tone = StatusTone.Error)
        } else if (!status.isNullOrBlank()) {
            StarryStatusBanner(text = "状态：$status", tone = StatusTone.Info)
        }
        content()
    }
}

