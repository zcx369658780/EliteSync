package com.elitesync.ui.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

enum class StatusTone { Info, Success, Warning, Error }

@Composable
fun StarryStatusBanner(
    text: String,
    tone: StatusTone = StatusTone.Info,
    modifier: Modifier = Modifier
) {
    val fg = when (tone) {
        StatusTone.Info -> EliteSyncColors.TextPrimary
        StatusTone.Success -> EliteSyncColors.TextPrimary
        StatusTone.Warning -> EliteSyncColors.TextPrimary
        StatusTone.Error -> EliteSyncColors.Error
    }
    Text(
        text = text,
        color = fg,
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = EliteSyncDimens.Space4, vertical = EliteSyncDimens.Space4)
    )
}
