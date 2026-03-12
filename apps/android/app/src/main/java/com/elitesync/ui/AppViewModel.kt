package com.elitesync.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.elitesync.model.AnswerItem
import com.elitesync.model.MatchResp
import com.elitesync.model.Question
import com.elitesync.repo.AppRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AppViewModel : ViewModel() {
    private val repo = AppRepository()

    private val _token = MutableStateFlow("")
    val token: StateFlow<String> = _token

    private val _currentUserId = MutableStateFlow<Int?>(null)
    val currentUserId: StateFlow<Int?> = _currentUserId

    private val _questions = MutableStateFlow<List<Question>>(emptyList())
    val questions: StateFlow<List<Question>> = _questions

    private val _currentMatch = MutableStateFlow<MatchResp?>(null)
    val currentMatch: StateFlow<MatchResp?> = _currentMatch

    private val _messages = MutableStateFlow<List<String>>(emptyList())
    val messages: StateFlow<List<String>> = _messages

    private val _status = MutableStateFlow("就绪")
    val status: StateFlow<String> = _status

    private val _error = MutableStateFlow("")
    val error: StateFlow<String> = _error

    private fun setError(msg: String) {
        _error.value = msg
        _status.value = "失败"
    }

    fun clearError() {
        _error.value = ""
    }

    fun addIncomingMessage(msg: String) {
        _messages.value = _messages.value + msg
    }

    fun register(phone: String, password: String) = viewModelScope.launch {
        _status.value = "注册中..."
        runCatching { repo.register(phone, password) }
            .onSuccess {
                _token.value = it.access_token
                _currentUserId.value = it.user?.id
                _status.value = "注册成功"
                _error.value = ""
            }
            .onFailure { setError("注册失败: ${it.message}") }
    }

    fun login(phone: String, password: String) = viewModelScope.launch {
        _status.value = "登录中..."
        runCatching { repo.login(phone, password) }
            .onSuccess {
                _token.value = it.access_token
                _currentUserId.value = it.user?.id
                _status.value = "登录成功"
                _error.value = ""
            }
            .onFailure { setError("登录失败: ${it.message}") }
    }

    fun loadQuestions() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "加载问卷中..."
        runCatching { repo.questions(_token.value) }
            .onSuccess {
                _questions.value = it.items
                _status.value = "问卷加载完成(${it.total}题)"
                _error.value = ""
            }
            .onFailure { setError("拉取问卷失败: ${it.message}") }
    }

    fun saveAnswer(questionId: Int, answer: String, isDraft: Boolean) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "保存中..."
        runCatching { repo.saveAnswers(_token.value, listOf(AnswerItem(questionId, answer, isDraft))) }
            .onSuccess { _status.value = "答案已保存"; _error.value = "" }
            .onFailure { setError("保存失败: ${it.message}") }
    }

    fun loadCurrentMatch() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "查询匹配中..."
        runCatching { repo.currentMatch(_token.value) }
            .onSuccess {
                _currentMatch.value = it
                _status.value = "匹配结果已更新"
                _error.value = ""
            }
            .onFailure { setError("暂无匹配或未到Drop: ${it.message}") }
    }

    fun confirmLike(like: Boolean) = viewModelScope.launch {
        val m = _currentMatch.value ?: return@launch setError("暂无匹配可确认")
        _status.value = "提交意向中..."
        runCatching { repo.confirmMatch(_token.value, m.match_id, like) }
            .onSuccess { _status.value = if (like) "已选择喜欢" else "已选择略过"; _error.value = "" }
            .onFailure { setError("确认失败: ${it.message}") }
    }

    fun sendMessage(text: String) = viewModelScope.launch {
        val m = _currentMatch.value ?: return@launch setError("暂无匹配对象，无法发消息")
        if (_token.value.isBlank() || text.isBlank()) return@launch
        _status.value = "发送中..."
        runCatching { repo.sendMessage(_token.value, m.partner_id, text) }
            .onSuccess {
                _messages.value = _messages.value + "我: $text"
                _status.value = "发送成功"
                _error.value = ""
                refreshMessages()
            }
            .onFailure { setError("发送失败: ${it.message}") }
    }

    fun refreshMessages() = viewModelScope.launch {
        val m = _currentMatch.value ?: return@launch
        if (_token.value.isBlank()) return@launch
        runCatching { repo.loadMessages(_token.value, m.partner_id) }
            .onSuccess { resp ->
                _messages.value = resp.items.map { msg ->
                    if (msg.sender_id == _currentUserId.value) "我: ${msg.content}" else "对方: ${msg.content}"
                }
            }
            .onFailure { setError("拉取消息失败: ${it.message}") }
    }
}
