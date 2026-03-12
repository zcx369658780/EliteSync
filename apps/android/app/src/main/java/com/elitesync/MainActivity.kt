package com.elitesync

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.remember
import androidx.lifecycle.viewmodel.compose.viewModel
import com.elitesync.ui.AppNavHost
import com.elitesync.ui.AppViewModel
import com.elitesync.ws.ChatSocketManager

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val vm: AppViewModel = viewModel()
            val socket = remember {
                ChatSocketManager { vm.addIncomingMessage(it) }
            }
            AppNavHost(vm = vm, socket = socket)
        }
    }
}
