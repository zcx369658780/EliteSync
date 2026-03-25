package com.elitesync.ui

import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.elitesync.ui.components.EliteSyncBottomTabs
import com.elitesync.ui.components.StarryAppBackground
import com.elitesync.ui.components.NavTabSpec
import com.elitesync.ui.components.ProvideUiFeedbackSettings
import com.elitesync.ui.components.ProvideUiPerformanceSettings
import com.elitesync.ui.components.UiFeedbackSettings
import com.elitesync.ui.components.UiPerformanceSettings
import com.elitesync.ui.components.starryPanGesture
import com.elitesync.ui.screens.BaiduMapPickerScreen
import com.elitesync.ui.screens.BasicProfileScreen
import com.elitesync.ui.screens.AboutScreen
import com.elitesync.ui.screens.ChatScreen
import com.elitesync.ui.screens.ChangePasswordScreen
import com.elitesync.ui.screens.DiscoverScreen
import com.elitesync.ui.screens.MatchScreen
import com.elitesync.ui.screens.MeScreen
import com.elitesync.ui.screens.MeSettingsScreen
import com.elitesync.ui.screens.MessagesScreen
import com.elitesync.ui.screens.MbtiQuizScreen
import com.elitesync.ui.screens.OnboardingHubScreen
import com.elitesync.ui.screens.PreferencesScreen
import com.elitesync.ui.screens.ProfileInsightsScreen
import com.elitesync.ui.screens.QuestionnaireScreen
import com.elitesync.ui.screens.RecommendScreen
import com.elitesync.ui.screens.RegisterScreen
import com.elitesync.ws.ChatSocketManager

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
    val tabs = listOf(
        NavTabSpec("推荐", "main/recommend"),
        NavTabSpec("匹配", "main/match"),
        NavTabSpec("消息", "main/messages"),
        NavTabSpec("发现", "main/discover"),
        NavTabSpec("我的", "main/me")
    )

    val backStackEntry by nav.currentBackStackEntryAsState()
    val currentRoute = backStackEntry?.destination?.route
    val showMainTabs = tabs.any { it.route == currentRoute }

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
                EliteSyncBottomTabs(
                    tabs = tabs,
                    currentRoute = currentRoute,
                    onTabClick = { route ->
                        nav.navigate(route) {
                            launchSingleTop = true
                        }
                    }
                )
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
                    } else if (from >= 0 && to < 0) {
                        slideInVertically(animationSpec = tween(300)) { it / 3 } + fadeIn(animationSpec = tween(260))
                    } else if (from < 0 && to < 0) {
                        slideInVertically(animationSpec = tween(220)) { it / 7 } + fadeIn(animationSpec = tween(200))
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
                    } else if (from >= 0 && to < 0) {
                        slideOutVertically(animationSpec = tween(240)) { -it / 8 } + fadeOut(animationSpec = tween(220))
                    } else if (from < 0 && to < 0) {
                        slideOutVertically(animationSpec = tween(200)) { -it / 10 } + fadeOut(animationSpec = tween(180))
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
                    } else if (from < 0 && to >= 0) {
                        slideInVertically(animationSpec = tween(240)) { -it / 8 } + fadeIn(animationSpec = tween(220))
                    } else if (from < 0 && to < 0) {
                        slideInVertically(animationSpec = tween(200)) { -it / 10 } + fadeIn(animationSpec = tween(180))
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
                    } else if (from < 0 && to >= 0) {
                        slideOutVertically(animationSpec = tween(210)) { it / 4 } + fadeOut(animationSpec = tween(180))
                    } else if (from < 0 && to < 0) {
                        slideOutVertically(animationSpec = tween(190)) { it / 12 } + fadeOut(animationSpec = tween(170))
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
                        onAbout = { nav.navigate("main/me/about") },
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
                    MeSettingsScreen(
                        vm = vm,
                        onChangePassword = { nav.navigate("main/me/change-password") },
                        onBack = { nav.popBackStack() }
                    )
                }
                composable("main/me/change-password") {
                    ChangePasswordScreen(vm = vm, onBack = { nav.popBackStack() })
                }
                composable("main/me/about") {
                    AboutScreen(vm = vm, onBack = { nav.popBackStack() })
                }
                composable("profile/insights") {
                    ProfileInsightsScreen(
                        vm = vm,
                        onOpenMbtiQuiz = { nav.navigate("profile/mbti/quiz") }
                    )
                }
                composable("profile/mbti/quiz") {
                    MbtiQuizScreen(
                        vm = vm,
                        onBack = { nav.popBackStack() }
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
                composable("chat") {
                    ChatScreen(vm = vm, socket = socket)
                }
            }

        }
    }
    }
    }
}
