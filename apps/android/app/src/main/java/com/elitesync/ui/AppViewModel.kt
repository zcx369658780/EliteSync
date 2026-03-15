package com.elitesync.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.elitesync.model.AnswerItem
import com.elitesync.model.MatchResp
import com.elitesync.model.ProfileResp
import com.elitesync.model.Question
import com.elitesync.network.NetworkErrorMapper
import com.elitesync.repo.AppRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import java.time.OffsetDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter

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
    private val _questionnaireRequired = MutableStateFlow(10)
    val questionnaireRequired: StateFlow<Int> = _questionnaireRequired
    private val _profile = MutableStateFlow(ProfileResp())
    val profile: StateFlow<ProfileResp> = _profile

    private val _currentMatch = MutableStateFlow<MatchResp?>(null)
    val currentMatch: StateFlow<MatchResp?> = _currentMatch
    private val _matchStateText = MutableStateFlow("请先完成问卷")
    val matchStateText: StateFlow<String> = _matchStateText

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
        _questionnaireRequired.value = 10
        _profile.value = ProfileResp()
        _currentMatch.value = null
        _matchStateText.value = "请先完成问卷"
        _messages.value = emptyList()
        _error.value = ""
    }

    fun logout() {
        resetSessionState()
        _status.value = "已退出登录"
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
                _questionnaireRequired.value = it.required ?: 10
                _status.value = "问卷加载完成(${it.total}题)"
                _error.value = ""
                loadQuestionnaireProgress()
            }
            .onFailure { setError("拉取问卷失败: ${err(it)}") }
    }

    fun loadQuestionnaireProgress() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch
        runCatching { repo.questionnaireProgress(_token.value) }
            .onSuccess {
                _questionnaireComplete.value = it.complete
                if (!it.complete) {
                    _matchStateText.value = "问卷未完成"
                }
                loadQuestionnaireProfile()
            }
    }

    fun loadQuestionnaireProfile() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch
        runCatching { repo.questionnaireProfile(_token.value) }
            .onSuccess { _profile.value = it }
    }

    fun saveAnswer(questionId: Int, answer: String, isDraft: Boolean) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "保存中..."
        runCatching { repo.saveAnswers(_token.value, listOf(AnswerItem(question_id = questionId, answer = answer, is_draft = isDraft))) }
            .onSuccess {
                _status.value = "答案已保存"
                _error.value = ""
                loadQuestionnaireProgress()
            }
            .onFailure { setError("保存失败: ${err(it)}") }
    }

    fun saveAnswerV2(
        questionId: Int,
        selectedAnswer: String,
        acceptableAnswers: List<String>,
        importance: Int,
        version: Int = 1
    ) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "保存中..."
        val payload = AnswerItem(
            question_id = questionId,
            selected_answer = listOf(selectedAnswer),
            acceptable_answers = acceptableAnswers.distinct(),
            importance = importance.coerceIn(0, 3),
            version = version,
            is_draft = false,
            answer = selectedAnswer
        )
        runCatching { repo.saveAnswers(_token.value, listOf(payload)) }
            .onSuccess {
                _status.value = "答案已保存"
                _error.value = ""
                loadQuestionnaireProgress()
            }
            .onFailure { setError("保存失败: ${err(it)}") }
    }

    fun replaceQuestion(currentQuestionId: Int, excludeIds: List<Int>) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "换题中..."
        runCatching { repo.replaceQuestion(_token.value, excludeIds) }
            .onSuccess { next ->
                val updated = _questions.value.toMutableList()
                val idx = updated.indexOfFirst { it.id == currentQuestionId }
                if (idx >= 0) {
                    updated[idx] = next
                    _questions.value = updated
                    _status.value = "已换题"
                    _error.value = ""
                } else {
                    setError("当前题目已变化，请重试")
                }
            }
            .onFailure { setError("换题失败: ${err(it)}") }
    }

    fun saveAllAnswers(answer: String, isDraft: Boolean = false) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        if (_questions.value.isEmpty()) return@launch setError("暂无题目可保存")
        _status.value = "保存全部答案中..."
        val payload = _questions.value.map { q -> AnswerItem(question_id = q.id, answer = answer, is_draft = isDraft) }
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
        if (!_questionnaireComplete.value) {
            _currentMatch.value = null
            _matchStateText.value = "问卷未完成"
            return@launch
        }
        _status.value = "查询匹配中..."
        runCatching { repo.currentMatch(_token.value) }
            .onSuccess {
                _currentMatch.value = it
                _matchStateText.value = "已匹配"
                _status.value = "匹配结果已更新"
                _error.value = ""
            }
            .onFailure {
                _currentMatch.value = null
                val msg = err(it)
                _matchStateText.value = when {
                    msg.contains("questionnaire incomplete", ignoreCase = true) -> "问卷未完成"
                    msg.contains("drop not available", ignoreCase = true) -> "等待本周Drop发布"
                    msg.contains("no match", ignoreCase = true) -> "本轮暂无匹配对象"
                    else -> "匹配状态未知"
                }
                setError("暂无匹配或未到Drop: $msg")
            }
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
                val now = DateTimeFormatter.ofPattern("HH:mm").format(java.time.LocalDateTime.now())
                _messages.value = _messages.value + "我 [$now]: $text"
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
                    formatChatLine(
                        isMine = msg.sender_id == _currentUserId.value,
                        content = msg.content,
                        createdAt = msg.created_at,
                        isRead = msg.is_read
                    )
                }
            }
            .onFailure { setError("拉取消息失败: ${err(it)}") }
    }

    private fun formatChatLine(isMine: Boolean, content: String, createdAt: String?, isRead: Boolean): String {
        val who = if (isMine) "我" else "对方"
        val time = formatTime(createdAt)
        val readTag = if (isMine) if (isRead) " [已读]" else " [未读]" else ""
        return "$who [$time]$readTag: $content"
    }

    private fun formatTime(createdAt: String?): String {
        if (createdAt.isNullOrBlank()) return "--:--"
        return runCatching {
            val odt = OffsetDateTime.parse(createdAt)
            odt.atZoneSameInstant(ZoneId.systemDefault()).format(DateTimeFormatter.ofPattern("HH:mm"))
        }.getOrElse {
            if (createdAt.length >= 16) createdAt.substring(11, 16) else createdAt
        }
    }
}
