package com.elitesync.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

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

fun verdictLabel(verdict: String?): String = when (verdict?.lowercase()) {
    "high" -> "高匹配"
    "medium" -> "中匹配"
    "low" -> "低匹配"
    else -> "待评估"
}

@Composable
fun StarryVerdictBadge(
    verdict: String?,
    modifier: Modifier = Modifier
) {
    val (bg, border) = when (verdict?.lowercase()) {
        "high" -> EliteSyncColors.Success.copy(alpha = 0.24f) to EliteSyncColors.Success.copy(alpha = 0.70f)
        "medium" -> EliteSyncColors.Warning.copy(alpha = 0.22f) to EliteSyncColors.Warning.copy(alpha = 0.68f)
        "low" -> EliteSyncColors.Info.copy(alpha = 0.20f) to EliteSyncColors.Info.copy(alpha = 0.62f)
        else -> EliteSyncColors.BrandSecondary.copy(alpha = 0.72f) to EliteSyncColors.BorderSubtle.copy(alpha = 0.8f)
    }

    Box(
        modifier = modifier
            .background(bg, RoundedCornerShape(999.dp))
            .border(1.dp, border, RoundedCornerShape(999.dp))
            .padding(horizontal = 10.dp, vertical = 4.dp)
    ) {
        Text(
            text = verdictLabel(verdict),
            color = Color(0xFFEAF2FF),
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium
        )
    }
}
