package com.elitesync.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.elitesync.ui.screens.ChatScreen
import com.elitesync.ui.screens.MatchScreen
import com.elitesync.ui.screens.QuestionnaireScreen
import com.elitesync.ui.screens.RegisterScreen
import com.elitesync.ws.ChatSocketManager

@Composable
fun AppNavHost(vm: AppViewModel, socket: ChatSocketManager) {
    val nav = rememberNavController()
    val uid by vm.currentUserId.collectAsState()

    NavHost(navController = nav, startDestination = "register") {
        composable("register") {
            RegisterScreen(vm = vm, onNext = { nav.navigate("questionnaire") })
        }
        composable("questionnaire") {
            QuestionnaireScreen(vm = vm, onNext = { nav.navigate("match") })
        }
        composable("match") {
            MatchScreen(
                vm = vm,
                onChat = {
                    socket.connect(uid ?: 1)
                    nav.navigate("chat")
                }
            )
        }
        composable("chat") {
            ChatScreen(vm = vm, socket = socket)
        }
    }
}
