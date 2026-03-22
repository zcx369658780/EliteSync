package com.elitesync

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Typography
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.elitesync.ui.AppNavHost
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.EliteSyncColors
import com.elitesync.ws.ChatSocketManager

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.Theme_EliteSync)
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val appDarkScheme = darkColorScheme(
                primary = EliteSyncColors.BrandPrimary,
                onPrimary = EliteSyncColors.TextPrimary,
                secondary = EliteSyncColors.Info,
                onSecondary = EliteSyncColors.TextPrimary,
                background = EliteSyncColors.BgBase,
                surface = EliteSyncColors.BgDepth,
                onSurface = EliteSyncColors.TextPrimary,
                onBackground = EliteSyncColors.TextPrimary
            )
            val appTypography = Typography(
                headlineLarge = TextStyle(
                    fontFamily = FontFamily.SansSerif,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 28.sp,
                    lineHeight = 34.sp
                ),
                headlineMedium = TextStyle(
                    fontFamily = FontFamily.SansSerif,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 22.sp,
                    lineHeight = 30.sp
                ),
                titleMedium = TextStyle(
                    fontFamily = FontFamily.SansSerif,
                    fontWeight = FontWeight.Medium,
                    fontSize = 18.sp,
                    lineHeight = 26.sp
                ),
                bodyLarge = TextStyle(
                    fontFamily = FontFamily.SansSerif,
                    fontWeight = FontWeight.Normal,
                    fontSize = 16.sp,
                    lineHeight = 24.sp
                ),
                bodyMedium = TextStyle(
                    fontFamily = FontFamily.SansSerif,
                    fontWeight = FontWeight.Normal,
                    fontSize = 14.sp,
                    lineHeight = 22.sp
                ),
                bodySmall = TextStyle(
                    fontFamily = FontFamily.SansSerif,
                    fontWeight = FontWeight.Normal,
                    fontSize = 13.sp,
                    lineHeight = 20.sp
                ),
                labelSmall = TextStyle(
                    fontFamily = FontFamily.SansSerif,
                    fontWeight = FontWeight.Medium,
                    fontSize = 11.sp,
                    lineHeight = 16.sp
                )
            )
            MaterialTheme(colorScheme = appDarkScheme, typography = appTypography) {
                Surface(modifier = Modifier.fillMaxSize().statusBarsPadding()) {
                    val vm: AppViewModel = viewModel()
                    val socket = remember {
                        ChatSocketManager { vm.addIncomingMessage(it) }
                    }
                    AppNavHost(vm = vm, socket = socket)
                }
            }
        }
    }
}
