package com.elitesync.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.clickable
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import java.time.LocalDate
import java.time.YearMonth
import androidx.compose.ui.graphics.Color

@Composable
fun StarryTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    singleLine: Boolean = true,
    isError: Boolean = false,
    errorMessage: String? = null,
    isPassword: Boolean = false
) {
    val passwordVisible = remember { mutableStateOf(false) }
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = EliteSyncDimens.InputHeight),
        singleLine = singleLine,
        isError = isError,
        label = { Text(label, color = StarryTextColors.Secondary) },
        trailingIcon = if (isPassword) {
            {
                Text(
                    if (passwordVisible.value) "隐藏" else "显示",
                    color = StarryTextColors.Secondary,
                    modifier = Modifier.clickable { passwordVisible.value = !passwordVisible.value }
                )
            }
        } else null,
        supportingText = if (isError && !errorMessage.isNullOrBlank()) {
            { Text(errorMessage, color = StarryTextColors.Error) }
        } else null,
        visualTransformation = if (isPassword && !passwordVisible.value) PasswordVisualTransformation() else VisualTransformation.None,
        textStyle = TextStyle(color = StarryTextColors.Primary),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = Color.Transparent,
            unfocusedBorderColor = Color.Transparent,
            errorBorderColor = StarryTextColors.Error,
            focusedContainerColor = Color.Transparent,
            unfocusedContainerColor = Color.Transparent,
            errorContainerColor = Color.Transparent,
            focusedLabelColor = StarryTextColors.Primary,
            unfocusedLabelColor = StarryTextColors.Secondary,
            errorLabelColor = StarryTextColors.Error,
            cursorColor = StarryTextColors.Primary
        )
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StarryDropdownField(
    label: String,
    valueText: String,
    options: List<String>,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = valueText,
            onValueChange = {},
            readOnly = true,
            label = { Text(label, color = StarryTextColors.Secondary) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(),
            textStyle = TextStyle(color = StarryTextColors.Primary),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.Transparent,
                unfocusedBorderColor = Color.Transparent,
                focusedContainerColor = Color.Transparent,
                unfocusedContainerColor = Color.Transparent,
                focusedLabelColor = StarryTextColors.Primary,
                unfocusedLabelColor = StarryTextColors.Secondary,
                cursorColor = StarryTextColors.Primary
            )
        )
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { item ->
                DropdownMenuItem(
                    text = { Text(item) },
                    onClick = {
                        onSelect(item)
                        expanded = false
                    }
                )
            }
        }
    }
}

@Composable
fun StarryDateDropdownField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    startYear: Int = 1950,
    endYear: Int = LocalDate.now().year
) {
    val parsed = remember(value) {
        runCatching { LocalDate.parse(value) }.getOrNull()
    }
    var year by remember(parsed, endYear) { mutableStateOf(parsed?.year ?: endYear) }
    var month by remember(parsed) { mutableStateOf(parsed?.monthValue ?: 1) }
    var day by remember(parsed) { mutableStateOf(parsed?.dayOfMonth ?: 1) }

    val maxDay = remember(year, month) { YearMonth.of(year, month).lengthOfMonth() }
    if (day > maxDay) day = maxDay

    fun emitDate() {
        onValueChange("%04d-%02d-%02d".format(year, month, day))
    }

    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Text(label, color = StarryTextColors.Secondary)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            StarryDropdownField(
                label = "年",
                valueText = year.toString(),
                options = (endYear downTo startYear).map { it.toString() },
                onSelect = {
                    year = it.toInt()
                    val limit = YearMonth.of(year, month).lengthOfMonth()
                    if (day > limit) day = limit
                    emitDate()
                },
                modifier = Modifier.weight(1.3f)
            )
            StarryDropdownField(
                label = "月",
                valueText = month.toString().padStart(2, '0'),
                options = (1..12).map { it.toString().padStart(2, '0') },
                onSelect = {
                    month = it.toInt()
                    val limit = YearMonth.of(year, month).lengthOfMonth()
                    if (day > limit) day = limit
                    emitDate()
                },
                modifier = Modifier.weight(1f)
            )
            StarryDropdownField(
                label = "日",
                valueText = day.toString().padStart(2, '0'),
                options = (1..maxDay).map { it.toString().padStart(2, '0') },
                onSelect = {
                    day = it.toInt()
                    emitDate()
                },
                modifier = Modifier.weight(1f)
            )
        }
    }
}
