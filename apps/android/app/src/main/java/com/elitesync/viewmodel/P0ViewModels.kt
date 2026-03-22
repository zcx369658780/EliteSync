package com.elitesync.viewmodel

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class AuthViewModel : ViewModel() {
    private val _token = MutableStateFlow("")
    val token: StateFlow<String> = _token
    fun onLoginSuccess(accessToken: String) { _token.value = accessToken }
    fun logout() { _token.value = "" }
}

class QuestionnaireViewModel : ViewModel() {
    private val _draftCount = MutableStateFlow(0)
    val draftCount: StateFlow<Int> = _draftCount
    fun saveDraft() { _draftCount.value += 1 }
}
