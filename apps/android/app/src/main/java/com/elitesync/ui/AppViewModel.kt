package com.elitesync.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.elitesync.model.AnswerItem
import com.elitesync.model.MatchResp
import com.elitesync.model.Question
import com.elitesync.network.NetworkErrorMapper
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
    private val _isLoggedIn = MutableStateFlow(false)
    val isLoggedIn: StateFlow<Boolean> = _isLoggedIn

    private val _questions = MutableStateFlow<List<Question>>(emptyList())
    val questions: StateFlow<List<Question>> = _questions
    private val _questionnaireComplete = MutableStateFlow(false)
    val questionnaireComplete: StateFlow<Boolean> = _questionnaireComplete

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

    private fun err(e: Throwable): String = NetworkErrorMapper.message(e)

    fun clearError() {
        _error.value = ""
    }

    fun addIncomingMessage(msg: String) {
        _messages.value = _messages.value + msg
    }

    private fun resetSessionState() {
        _token.value = ""
        _currentUserId.value = null
        _isLoggedIn.value = false
        _questions.value = emptyList()
        _questionnaireComplete.value = false
        _currentMatch.value = null
        _messages.value = emptyList()
        _error.value = ""
    }

    fun register(phone: String, password: String) = viewModelScope.launch {
        _status.value = "注册中..."
        runCatching { repo.register(phone, password) }
            .onSuccess {
                resetSessionState()
                _status.value = "注册成功，请登录"
                _error.value = ""
            }
            .onFailure { setError("注册失败: ${err(it)}") }
    }

    fun login(phone: String, password: String) = viewModelScope.launch {
        _status.value = "登录中..."
        runCatching { repo.login(phone, password) }
            .onSuccess {
                resetSessionState()
                _token.value = it.access_token
                _currentUserId.value = it.user?.id
                _isLoggedIn.value = true
                _status.value = "登录成功"
                _error.value = ""
            }
            .onFailure { setError("登录失败: ${err(it)}") }
    }

    fun loadQuestions() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "加载问卷中..."
        runCatching { repo.questions(_token.value) }
            .onSuccess {
                _questions.value = it.items
                _status.value = "问卷加载完成(${it.total}题)"
                _error.value = ""
                loadQuestionnaireProgress()
            }
            .onFailure { setError("拉取问卷失败: ${err(it)}") }
    }

    fun loadQuestionnaireProgress() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch
        runCatching { repo.questionnaireProgress(_token.value) }
            .onSuccess { _questionnaireComplete.value = it.complete }
    }

    fun saveAnswer(questionId: Int, answer: String, isDraft: Boolean) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "保存中..."
        runCatching { repo.saveAnswers(_token.value, listOf(AnswerItem(questionId, answer, isDraft))) }
            .onSuccess {
                _status.value = "答案已保存"
                _error.value = ""
                loadQuestionnaireProgress()
            }
            .onFailure { setError("保存失败: ${err(it)}") }
    }

    fun saveAllAnswers(answer: String, isDraft: Boolean = false) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        if (_questions.value.isEmpty()) return@launch setError("暂无题目可保存")
        _status.value = "保存全部答案中..."
        val payload = _questions.value.map { q -> AnswerItem(q.id, answer, isDraft) }
        runCatching { repo.saveAnswers(_token.value, payload) }
            .onSuccess {
                _status.value = "全部答案已保存"
                _error.value = ""
                loadQuestionnaireProgress()
            }
            .onFailure { setError("保存失败: ${err(it)}") }
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
            .onFailure { setError("暂无匹配或未到Drop: ${err(it)}") }
    }

    fun confirmLike(like: Boolean) = viewModelScope.launch {
        val m = _currentMatch.value ?: return@launch setError("暂无匹配可确认")
        _status.value = "提交意向中..."
        runCatching { repo.confirmMatch(_token.value, m.match_id, like) }
            .onSuccess { _status.value = if (like) "已选择喜欢" else "已选择略过"; _error.value = "" }
            .onFailure { setError("确认失败: ${err(it)}") }
    }

    fun devPrepareMatchForDemo() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        if (!_questionnaireComplete.value) return@launch setError("请先完成问卷后再生成开发态匹配")
        _status.value = "生成开发态匹配中..."
        runCatching {
            repo.devRunMatching(_token.value)
            repo.devReleaseDrop(_token.value)
        }.onSuccess {
            _status.value = "开发态匹配已准备，正在刷新..."
            _error.value = ""
            loadCurrentMatch()
        }.onFailure {
            setError("开发态匹配准备失败: ${err(it)}")
        }
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
            .onFailure { setError("发送失败: ${err(it)}") }
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
            .onFailure { setError("拉取消息失败: ${err(it)}") }
    }
}
