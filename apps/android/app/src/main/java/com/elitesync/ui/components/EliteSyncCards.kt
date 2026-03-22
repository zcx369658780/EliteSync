package com.elitesync.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun StarrySectionCard(
    title: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(androidx.compose.ui.graphics.Color.Transparent, RoundedCornerShape(EliteSyncShapes.CardRadius))
            .padding(vertical = EliteSyncDimens.Space4),
        verticalArrangement = Arrangement.spacedBy(EliteSyncDimens.Space12)
    ) {
        if (!title.isNullOrBlank()) {
            Text(title, color = EliteSyncColors.TextSecondary)
        }
        content()
    }
}
