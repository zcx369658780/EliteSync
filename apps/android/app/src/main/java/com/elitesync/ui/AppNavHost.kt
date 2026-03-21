package com.elitesync.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.clickable
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.animation.core.animateDpAsState
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.elitesync.ui.components.StarryAppBackground
import com.elitesync.ui.components.ProvideUiFeedbackSettings
import com.elitesync.ui.components.ProvideUiPerformanceSettings
import com.elitesync.ui.components.UiFeedbackSettings
import com.elitesync.ui.components.UiPerformanceSettings
import com.elitesync.ui.components.starryPanGesture
import com.elitesync.ui.screens.BaiduMapPickerScreen
import com.elitesync.ui.screens.BasicProfileScreen
import com.elitesync.ui.screens.ChatScreen
import com.elitesync.ui.screens.DiscoverScreen
import com.elitesync.ui.screens.MatchScreen
import com.elitesync.ui.screens.MeScreen
import com.elitesync.ui.screens.MeSettingsScreen
import com.elitesync.ui.screens.MessagesScreen
import com.elitesync.ui.screens.OnboardingHubScreen
import com.elitesync.ui.screens.PreferencesScreen
import com.elitesync.ui.screens.ProfileInsightsScreen
import com.elitesync.ui.screens.QuestionnaireScreen
import com.elitesync.ui.screens.RecommendScreen
import com.elitesync.ui.screens.RegisterScreen
import com.elitesync.ws.ChatSocketManager
import kotlinx.coroutines.delay

private data class MainTab(val label: String, val route: String)
private val MAIN_TAB_ORDER = mapOf(
    "main/recommend" to 0,
    "main/match" to 1,
    "main/messages" to 2,
    "main/discover" to 3,
    "main/me" to 4
)

private fun mainTabIndex(route: String?): Int = MAIN_TAB_ORDER[route] ?: -1

@Composable
fun AppNavHost(vm: AppViewModel, socket: ChatSocketManager) {
    val nav = rememberNavController()
    val uid by vm.currentUserId.collectAsState()
    val hapticEnabled by vm.hapticEnabled.collectAsState()
    val clickSoundEnabled by vm.clickSoundEnabled.collectAsState()
    val litePerformanceMode by vm.litePerformanceMode.collectAsState()
    val currentPlace by vm.currentPlace.collectAsState()
    val birthPlace by vm.birthPlace.collectAsState()
    val tabs = listOf(
        MainTab("推荐", "main/recommend"),
        MainTab("匹配", "main/match"),
        MainTab("消息", "main/messages"),
        MainTab("发现", "main/discover"),
        MainTab("我的", "main/me")
    )

    val backStackEntry by nav.currentBackStackEntryAsState()
    val currentRoute = backStackEntry?.destination?.route
    val showMainTabs = tabs.any { it.route == currentRoute }

    var routePulseVisible by remember { mutableStateOf(false) }
    LaunchedEffect(currentRoute) {
        if (currentRoute != null) {
            routePulseVisible = true
            delay(190)
            routePulseVisible = false
        }
    }
    val pulseAlpha by animateFloatAsState(
        targetValue = if (routePulseVisible) 0.24f else 0f,
        animationSpec = tween(240),
        label = "routePulseAlpha"
    )

    ProvideUiPerformanceSettings(
        settings = UiPerformanceSettings(
            liteMode = litePerformanceMode
        )
    ) {
    ProvideUiFeedbackSettings(
        settings = UiFeedbackSettings(
            hapticEnabled = hapticEnabled,
            clickSoundEnabled = clickSoundEnabled
        )
    ) {
    Scaffold(
        containerColor = Color.Transparent,
        bottomBar = {
            if (showMainTabs) {
                BoxWithConstraints(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 10.dp)
                        .height(58.dp)
                        .clip(RoundedCornerShape(18.dp))
                        .background(Color(0xAA101B32))
                ) {
                    val selectedIndex = tabs.indexOfFirst { it.route == currentRoute }.coerceAtLeast(0)
                    val tabWidth = maxWidth / tabs.size
                    val indicatorOffset by animateDpAsState(
                        targetValue = tabWidth * selectedIndex,
                        animationSpec = tween(240),
                        label = "navIndicatorOffset"
                    )

                    Box(
                        modifier = Modifier
                            .padding(6.dp)
                            .fillMaxHeight()
                            .fillMaxWidth(1f / tabs.size)
                            .graphicsLayer {
                                translationX = indicatorOffset.toPx()
                            }
                            .clip(RoundedCornerShape(12.dp))
                            .background(
                                Brush.horizontalGradient(
                                    listOf(Color(0x664EA5FF), Color(0x554BD0C9), Color(0x664EA5FF))
                                )
                            )
                    )

                    Row(modifier = Modifier.fillMaxSize()) {
                        tabs.forEach { tab ->
                            val selected = currentRoute == tab.route
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxSize()
                                    .clickable {
                                        nav.navigate(tab.route) { launchSingleTop = true }
                                    },
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = tab.label,
                                    color = if (selected) Color.White else Color(0xFF93A9D8),
                                    textAlign = TextAlign.Center
                                )
                            }
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        Box(modifier = Modifier.fillMaxSize().starryPanGesture()) {
            if (currentRoute != "register") {
                StarryAppBackground()
            }
            NavHost(
                navController = nav,
                startDestination = "register",
                modifier = Modifier.padding(innerPadding),
                enterTransition = {
                    val from = mainTabIndex(initialState.destination.route)
                    val to = mainTabIndex(targetState.destination.route)
                    if (from >= 0 && to >= 0) {
                        if (to > from) {
                            slideInHorizontally(animationSpec = tween(240)) { it / 3 } + fadeIn(animationSpec = tween(220))
                        } else {
                            slideInHorizontally(animationSpec = tween(240)) { -it / 3 } + fadeIn(animationSpec = tween(220))
                        }
                    } else {
                        fadeIn(animationSpec = tween(260)) + scaleIn(initialScale = 0.985f, animationSpec = tween(260))
                    }
                },
                exitTransition = {
                    val from = mainTabIndex(initialState.destination.route)
                    val to = mainTabIndex(targetState.destination.route)
                    if (from >= 0 && to >= 0) {
                        if (to > from) {
                            slideOutHorizontally(animationSpec = tween(220)) { -it / 5 } + fadeOut(animationSpec = tween(200))
                        } else {
                            slideOutHorizontally(animationSpec = tween(220)) { it / 5 } + fadeOut(animationSpec = tween(200))
                        }
                    } else {
                        fadeOut(animationSpec = tween(180))
                    }
                },
                popEnterTransition = {
                    val from = mainTabIndex(initialState.destination.route)
                    val to = mainTabIndex(targetState.destination.route)
                    if (from >= 0 && to >= 0) {
                        if (to > from) {
                            slideInHorizontally(animationSpec = tween(220)) { it / 4 } + fadeIn(animationSpec = tween(200))
                        } else {
                            slideInHorizontally(animationSpec = tween(220)) { -it / 4 } + fadeIn(animationSpec = tween(200))
                        }
                    } else {
                        fadeIn(animationSpec = tween(220)) + scaleIn(initialScale = 0.99f, animationSpec = tween(220))
                    }
                },
                popExitTransition = {
                    val from = mainTabIndex(initialState.destination.route)
                    val to = mainTabIndex(targetState.destination.route)
                    if (from >= 0 && to >= 0) {
                        if (to > from) {
                            slideOutHorizontally(animationSpec = tween(210)) { -it / 6 } + fadeOut(animationSpec = tween(180))
                        } else {
                            slideOutHorizontally(animationSpec = tween(210)) { it / 6 } + fadeOut(animationSpec = tween(180))
                        }
                    } else {
                        fadeOut(animationSpec = tween(180)) + scaleOut(targetScale = 1.01f, animationSpec = tween(180))
                    }
                }
            ) {
                composable("register") {
                    RegisterScreen(vm = vm, onNext = { route ->
                        nav.navigate(
                            when (route) {
                                "match" -> "main/recommend"
                                "questionnaire" -> "onboarding/hub"
                                else -> "main/recommend"
                            }
                        ) { popUpTo("register") { inclusive = false } }
                    })
                }
                composable("onboarding/hub") {
                    OnboardingHubScreen(
                        vm = vm,
                        onBasicProfile = { nav.navigate("onboarding/basic") },
                        onPreferences = { nav.navigate("onboarding/preferences") },
                        onQuestionnaire = { nav.navigate("onboarding/questionnaire") },
                        onFinish = { nav.navigate("main/recommend") }
                    )
                }
                composable("onboarding/basic") {
                    BasicProfileScreen(vm = vm, onBack = { nav.popBackStack() })
                }
                composable("onboarding/preferences") {
                    PreferencesScreen(onBack = { nav.popBackStack() })
                }
                composable("onboarding/questionnaire") {
                    QuestionnaireScreen(vm = vm, onNext = { nav.navigate("onboarding/hub") })
                }
                composable("main/recommend") {
                    RecommendScreen(
                        vm = vm,
                        onQuestionnaire = { nav.navigate("onboarding/hub") },
                        onGoMatch = { nav.navigate("main/match") }
                    )
                }
                composable("main/match") {
                    MatchScreen(
                        vm = vm,
                        onRetake = {
                            vm.resetQuestionnaire()
                            nav.navigate("onboarding/hub")
                        },
                        onChat = {
                            socket.connect(uid ?: 1)
                            nav.navigate("chat")
                        },
                        onLogout = {
                            socket.close()
                            vm.logout()
                            nav.navigate("register") {
                                popUpTo("register") { inclusive = true }
                            }
                        }
                    )
                }
                composable("main/messages") {
                    MessagesScreen(
                        vm = vm,
                        onOpenChat = {
                            socket.connect(uid ?: 1)
                            nav.navigate("chat")
                        }
                    )
                }
                composable("main/discover") {
                    DiscoverScreen(
                        vm = vm,
                        onOpenMapPicker = { nav.navigate("map/pick/current") }
                    )
                }
                composable("main/me") {
                    MeScreen(
                        vm = vm,
                        onBasicProfile = { nav.navigate("onboarding/basic") },
                        onQuestionnaire = { nav.navigate("onboarding/hub") },
                        onInsights = { nav.navigate("profile/insights") },
                        onSettings = { nav.navigate("main/me/settings") },
                        onLogout = {
                            socket.close()
                            vm.logout()
                            nav.navigate("register") {
                                popUpTo("register") { inclusive = true }
                            }
                        }
                    )
                }
                composable("main/me/settings") {
                    MeSettingsScreen(vm = vm, onBack = { nav.popBackStack() })
                }
                composable("profile/insights") {
                    ProfileInsightsScreen(
                        vm = vm,
                        onOpenMapPicker = { nav.navigate("map/pick/birth") }
                    )
                }
                composable("map/pick/current") {
                    BaiduMapPickerScreen(
                        title = "百度地图选点",
                        initialLat = currentPlace?.location?.lat,
                        initialLng = currentPlace?.location?.lng,
                        onBack = { nav.popBackStack() },
                        onConfirm = { lat, lng ->
                            vm.reverseGeocodeCurrent(lat, lng)
                            nav.popBackStack()
                        }
                    )
                }
                composable("map/pick/birth") {
                    BaiduMapPickerScreen(
                        title = "选择出生地",
                        initialLat = birthPlace?.location?.lat,
                        initialLng = birthPlace?.location?.lng,
                        onBack = { nav.popBackStack() },
                        onConfirm = { lat, lng ->
                            vm.reverseGeocodeBirth(lat, lng)
                            nav.popBackStack()
                        }
                    )
                }
                composable("chat") {
                    ChatScreen(vm = vm, socket = socket)
                }
            }

            if (pulseAlpha > 0f && currentRoute != "register") {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .graphicsLayer(alpha = pulseAlpha)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(Color(0x66BFD8FF), Color.Transparent),
                                radius = 780f
                            )
                        )
                )
            }
        }
    }
    }
    }
}
