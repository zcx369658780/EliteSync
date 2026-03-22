package com.elitesync.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.elitesync.astro.AstroCalculator
import com.elitesync.astro.AstroProfileResult
import com.elitesync.model.AstroProfilePayload
import com.elitesync.model.AstroProfileRecord
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
    private val _currentUserName = MutableStateFlow("")
    val currentUserName: StateFlow<String> = _currentUserName
    private val _currentUserBirthday = MutableStateFlow("")
    val currentUserBirthday: StateFlow<String> = _currentUserBirthday
    private val _currentUserGender = MutableStateFlow("")
    val currentUserGender: StateFlow<String> = _currentUserGender
    private val _currentUserCity = MutableStateFlow("")
    val currentUserCity: StateFlow<String> = _currentUserCity
    private val _currentRelationshipGoal = MutableStateFlow("")
    val currentRelationshipGoal: StateFlow<String> = _currentRelationshipGoal
    private val _currentUserRealnameVerified = MutableStateFlow(false)
    val currentUserRealnameVerified: StateFlow<Boolean> = _currentUserRealnameVerified
    private val _isLoggedIn = MutableStateFlow(false)
    val isLoggedIn: StateFlow<Boolean> = _isLoggedIn

    private val _questions = MutableStateFlow<List<Question>>(emptyList())
    val questions: StateFlow<List<Question>> = _questions
    private val _questionnaireComplete = MutableStateFlow(false)
    val questionnaireComplete: StateFlow<Boolean> = _questionnaireComplete
    private val _questionnaireProgressLoaded = MutableStateFlow(false)
    val questionnaireProgressLoaded: StateFlow<Boolean> = _questionnaireProgressLoaded
    private val _questionnaireRequired = MutableStateFlow(10)
    val questionnaireRequired: StateFlow<Int> = _questionnaireRequired
    private val _profile = MutableStateFlow(ProfileResp())
    val profile: StateFlow<ProfileResp> = _profile
    private val _onboardingComplete = MutableStateFlow(false)
    val onboardingComplete: StateFlow<Boolean> = _onboardingComplete

    private val _currentMatch = MutableStateFlow<MatchResp?>(null)
    val currentMatch: StateFlow<MatchResp?> = _currentMatch
    private val _matchStateText = MutableStateFlow("请先完成问卷")
    val matchStateText: StateFlow<String> = _matchStateText

    private val _messages = MutableStateFlow<List<String>>(emptyList())
    val messages: StateFlow<List<String>> = _messages
    private val _placeResults = MutableStateFlow<List<com.elitesync.model.MapPlace>>(emptyList())
    val placeResults: StateFlow<List<com.elitesync.model.MapPlace>> = _placeResults
    private val _currentPlace = MutableStateFlow<com.elitesync.model.MapPlace?>(null)
    val currentPlace: StateFlow<com.elitesync.model.MapPlace?> = _currentPlace
    private val _birthPlace = MutableStateFlow<com.elitesync.model.MapPlace?>(null)
    val birthPlace: StateFlow<com.elitesync.model.MapPlace?> = _birthPlace
    private val _insightsBirthTime = MutableStateFlow("")
    val insightsBirthTime: StateFlow<String> = _insightsBirthTime
    private val _insightsMbti = MutableStateFlow("")
    val insightsMbti: StateFlow<String> = _insightsMbti
    private val _insightsBirthQuery = MutableStateFlow("")
    val insightsBirthQuery: StateFlow<String> = _insightsBirthQuery
    private val _insightsResult = MutableStateFlow<AstroProfileResult?>(null)
    val insightsResult: StateFlow<AstroProfileResult?> = _insightsResult

    private val _status = MutableStateFlow("就绪")
    val status: StateFlow<String> = _status

    private val _error = MutableStateFlow("")
    val error: StateFlow<String> = _error
    private val _hapticEnabled = MutableStateFlow(false)
    val hapticEnabled: StateFlow<Boolean> = _hapticEnabled
    private val _clickSoundEnabled = MutableStateFlow(true)
    val clickSoundEnabled: StateFlow<Boolean> = _clickSoundEnabled
    private val _litePerformanceMode = MutableStateFlow(false)
    val litePerformanceMode: StateFlow<Boolean> = _litePerformanceMode

    private fun setError(msg: String) {
        _error.value = msg
        _status.value = "失败"
    }

    private fun err(e: Throwable): String = NetworkErrorMapper.message(e)

    fun clearError() {
        _error.value = ""
    }

    fun toggleHapticEnabled() {
        _hapticEnabled.value = !_hapticEnabled.value
    }

    fun toggleClickSoundEnabled() {
        _clickSoundEnabled.value = !_clickSoundEnabled.value
    }

    fun toggleLitePerformanceMode() {
        _litePerformanceMode.value = !_litePerformanceMode.value
    }

    fun locationUnavailable() {
        _status.value = "未获取到设备定位"
        _error.value = "未获取到设备定位，请确认已开启定位服务；模拟器请先在 Extended Controls 设置经纬度。"
    }

    fun addIncomingMessage(msg: String) {
        _messages.value = _messages.value + msg
    }

    private fun resetSessionState() {
        _token.value = ""
        _currentUserId.value = null
        _currentUserName.value = ""
        _currentUserBirthday.value = ""
        _currentUserGender.value = ""
        _currentUserCity.value = ""
        _currentRelationshipGoal.value = ""
        _currentUserRealnameVerified.value = false
        _isLoggedIn.value = false
        _questions.value = emptyList()
        _questionnaireComplete.value = false
        _questionnaireProgressLoaded.value = false
        _questionnaireRequired.value = 10
        _profile.value = ProfileResp()
        _onboardingComplete.value = false
        _currentMatch.value = null
        _matchStateText.value = "请先完成问卷"
        _messages.value = emptyList()
        _placeResults.value = emptyList()
        _currentPlace.value = null
        _birthPlace.value = null
        _insightsBirthTime.value = ""
        _insightsMbti.value = ""
        _insightsBirthQuery.value = ""
        _insightsResult.value = null
        _error.value = ""
    }

    fun logout() {
        resetSessionState()
        _status.value = "已退出登录"
    }

    fun markOnboardingComplete() {
        _onboardingComplete.value = true
    }

    fun register(phone: String, password: String, birthday: String?, realnameVerified: Boolean) = viewModelScope.launch {
        _status.value = "注册中..."
        runCatching { repo.register(phone, password, birthday, realnameVerified) }
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
                _currentUserName.value = it.user?.name.orEmpty()
                _currentUserBirthday.value = it.user?.birthday.orEmpty()
                _currentUserGender.value = it.user?.gender.orEmpty()
                _currentUserCity.value = it.user?.city.orEmpty()
                _currentRelationshipGoal.value = it.user?.relationship_goal.orEmpty()
                _currentUserRealnameVerified.value = it.user?.realname_verified == true
                _isLoggedIn.value = true
                _status.value = "登录成功"
                _error.value = ""
                loadBasicProfile()
                loadAstroProfileCache()
                loadQuestionnaireProgress()
            }
            .onFailure { setError("登录失败: ${err(it)}") }
    }

    fun loadBasicProfile() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch
        runCatching { repo.basicProfile(_token.value) }
            .onSuccess {
                _currentUserName.value = it.name.orEmpty()
                _currentUserBirthday.value = it.birthday.orEmpty()
                _currentUserGender.value = it.gender.orEmpty()
                _currentUserCity.value = it.city.orEmpty()
                _currentRelationshipGoal.value = it.relationship_goal.orEmpty()
            }
    }

    fun saveBasicProfile(
        birthday: String,
        name: String? = null,
        gender: String,
        city: String,
        relationshipGoal: String
    ) = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        if (gender != "male" && gender != "female") return@launch setError("请选择性别（男/女）")
        if (city.isBlank()) return@launch setError("请先获取城市定位")
        if (relationshipGoal !in setOf("marriage", "dating", "friendship")) return@launch setError("请选择婚恋目标")
        _status.value = "保存基础资料中..."
        runCatching {
            repo.saveBasicProfile(
                token = _token.value,
                birthday = birthday.trim().ifBlank { null },
                name = name,
                gender = gender,
                city = city,
                relationshipGoal = relationshipGoal
            )
        }
            .onSuccess {
                _currentUserName.value = name.orEmpty()
                _currentUserBirthday.value = birthday.trim()
                _currentUserGender.value = gender
                _currentUserCity.value = city
                _currentRelationshipGoal.value = relationshipGoal
                _status.value = "基础资料已保存"
                _error.value = ""
            }
            .onFailure {
                val mapped = err(it)
                if (mapped.contains("route", ignoreCase = true) &&
                    mapped.contains("profile/basic", ignoreCase = true)
                ) {
                    _currentUserName.value = name.orEmpty()
                    _currentUserBirthday.value = birthday.trim()
                    _currentUserGender.value = gender
                    _currentUserCity.value = city
                    _currentRelationshipGoal.value = relationshipGoal
                    _status.value = "基础资料已本地更新（服务端待升级）"
                    _error.value = ""
                } else {
                    setError("保存基础资料失败: $mapped")
                }
            }
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
                _questionnaireProgressLoaded.value = true
                if (!it.complete) {
                    _matchStateText.value = "问卷未完成"
                }
                loadQuestionnaireProfile()
            }
            .onFailure {
                _questionnaireProgressLoaded.value = true
            }
    }

    fun resetQuestionnaire() = viewModelScope.launch {
        if (_token.value.isBlank()) return@launch setError("请先登录")
        _status.value = "重置问卷中..."
        runCatching { repo.resetQuestionnaire(_token.value) }
            .onSuccess {
                _questionnaireComplete.value = false
                _questionnaireProgressLoaded.value = true
                _questions.value = emptyList()
                _status.value = "问卷已重置"
                _error.value = ""
            }
            .onFailure { setError("重置失败: ${err(it)}") }
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

    fun searchPlaces(query: String, region: String = "全国") = viewModelScope.launch {
        if (query.isBlank()) {
            _placeResults.value = emptyList()
            return@launch
        }
        _status.value = "地点搜索中..."
        runCatching { repo.searchPlaces(query, region) }
            .onSuccess {
                _placeResults.value = it
                _status.value = "搜索完成(${it.size})"
                _error.value = ""
            }
            .onFailure { setError("地点搜索失败: ${err(it)}") }
    }

    fun reverseGeocodeCurrent(lat: Double, lng: Double) = viewModelScope.launch {
        _status.value = "定位解析中..."
        runCatching { repo.reverseGeocode(lat, lng) }
            .onSuccess {
                _currentPlace.value = it
                _status.value = if (it != null) "定位成功" else "定位解析无结果"
                _error.value = ""
            }
            .onFailure { setError("定位解析失败: ${err(it)}") }
    }

    fun reverseGeocodeBirth(lat: Double, lng: Double) = viewModelScope.launch {
        _status.value = "出生地解析中..."
        runCatching { repo.reverseGeocode(lat, lng) }
            .onSuccess {
                _birthPlace.value = it
                _status.value = if (it != null) "出生地已更新" else "出生地解析无结果"
                _error.value = ""
            }
            .onFailure { setError("出生地解析失败: ${err(it)}") }
    }

    fun setBirthPlace(place: com.elitesync.model.MapPlace) {
        _birthPlace.value = place
        _status.value = "已选择出生地"
    }

    fun updateInsightsBirthTime(v: String) {
        _insightsBirthTime.value = v
    }

    fun updateInsightsMbti(v: String) {
        _insightsMbti.value = v.uppercase()
    }

    fun updateInsightsBirthQuery(v: String) {
        _insightsBirthQuery.value = v
    }

    fun loadAstroProfileCache() = viewModelScope.launch {
        val token = _token.value
        if (token.isBlank()) return@launch
        runCatching { repo.astroProfile(token) }
            .onSuccess { resp ->
                val cached = resp.profile ?: return@onSuccess
                if (!resp.exists) return@onSuccess
                _insightsBirthTime.value = cached.birth_time
                _insightsBirthQuery.value = cached.birth_place.orEmpty()
                if (cached.birth_lat != null && cached.birth_lng != null) {
                    _birthPlace.value = com.elitesync.model.MapPlace(
                        name = cached.birth_place ?: "已保存出生地",
                        address = cached.birth_place ?: "",
                        city = "",
                        district = "",
                        location = com.elitesync.model.MapPoint(cached.birth_lat, cached.birth_lng)
                    )
                }
                _insightsResult.value = cached.toAstroResult()
            }
    }

    fun computeAstroProfile() = viewModelScope.launch {
        val birthday = _currentUserBirthday.value.trim()
        val gender = _currentUserGender.value.trim()
        val token = _token.value
        var birthTime = _insightsBirthTime.value.trim()
        var place = _birthPlace.value

        if (token.isNotBlank()) {
            _status.value = "读取画像缓存中..."
            runCatching { repo.astroProfile(token) }
                .onSuccess { resp ->
                    val cached = resp.profile
                    if (resp.exists && cached != null) {
                        if (birthTime.isBlank()) {
                            birthTime = cached.birth_time
                            _insightsBirthTime.value = cached.birth_time
                        }
                        if (place == null && cached.birth_lat != null && cached.birth_lng != null) {
                            place = com.elitesync.model.MapPlace(
                                name = cached.birth_place ?: "已保存出生地",
                                address = cached.birth_place ?: "",
                                city = "",
                                district = "",
                                location = com.elitesync.model.MapPoint(cached.birth_lat, cached.birth_lng)
                            )
                            _birthPlace.value = place
                        }
                    }
                    if (resp.exists && cached != null && canUseCachedAstro(cached, birthTime, place)) {
                        _insightsResult.value = cached.toAstroResult()
                        _status.value = "画像读取完成(缓存)"
                        _error.value = ""
                        return@launch
                    }
                }
        }

        if (birthday.isBlank() || birthTime.isBlank()) {
            _status.value = "画像计算失败"
            _error.value = "请先完善生日与出生时间（HH:mm）。"
            return@launch
        }
        if (gender != "male" && gender != "female") {
            _status.value = "画像计算失败"
            _error.value = "请先到“基础资料”选择性别（男/女）。"
            return@launch
        }

        val result = AstroCalculator.calculate(
            birthday = birthday,
            birthTime = birthTime,
            gender = gender,
            birthLat = place?.location?.lat,
            birthLng = place?.location?.lng
        )

        _insightsResult.value = result
        if (result == null) {
            _status.value = "画像计算失败"
            _error.value = "请检查生日（注册信息）与出生时间（HH:mm）是否填写正确。"
            return@launch
        }

        if (token.isBlank()) {
            _status.value = "画像计算完成"
            _error.value = ""
            return@launch
        }

        _status.value = "画像计算完成，保存中..."
        val payload = AstroProfilePayload(
            birth_time = birthTime,
            birth_place = place?.name,
            birth_lat = place?.location?.lat,
            birth_lng = place?.location?.lng,
            sun_sign = result.sunSign,
            moon_sign = result.moonSign,
            asc_sign = result.ascSign,
            bazi = result.bazi,
            true_solar_time = result.trueSolarTime,
            da_yun = result.daYun.map {
                com.elitesync.model.DaYunItem(
                    index = it.index,
                    gan_zhi = it.ganZhi,
                    start_year = it.startYear,
                    end_year = it.endYear,
                    start_age = it.startAge,
                    end_age = it.endAge
                )
            },
            liu_nian = result.liuNian.map {
                com.elitesync.model.LiuNianItem(
                    year = it.year,
                    age = it.age,
                    gan_zhi = it.ganZhi
                )
            },
            wu_xing = result.wuXing,
            notes = result.notes
        )
        runCatching { repo.saveAstroProfile(token, payload) }
            .onSuccess {
                _status.value = "画像计算完成（已保存）"
                _error.value = ""
            }
            .onFailure {
                _status.value = "画像计算完成（保存失败）"
                _error.value = "画像结果已在本地生成，但服务端保存失败：${err(it)}"
            }
    }

    private fun canUseCachedAstro(
        cached: AstroProfileRecord,
        birthTime: String,
        place: com.elitesync.model.MapPlace?
    ): Boolean {
        if (cached.birth_time != birthTime) return false
        if (place == null) return true
        val latOk = cached.birth_lat != null && kotlin.math.abs(cached.birth_lat - place.location.lat) < 1e-4
        val lngOk = cached.birth_lng != null && kotlin.math.abs(cached.birth_lng - place.location.lng) < 1e-4
        return latOk && lngOk
    }

    private fun AstroProfileRecord.toAstroResult(): AstroProfileResult {
        return AstroProfileResult(
            sunSign = sun_sign,
            moonSign = moon_sign,
            ascSign = asc_sign,
            bazi = bazi,
            trueSolarTime = true_solar_time,
            daYun = da_yun.map {
                com.elitesync.astro.DaYunResult(
                    index = it.index,
                    ganZhi = it.gan_zhi,
                    startYear = it.start_year,
                    endYear = it.end_year,
                    startAge = it.start_age,
                    endAge = it.end_age
                )
            },
            liuNian = liu_nian.map {
                com.elitesync.astro.LiuNianResult(
                    year = it.year,
                    age = it.age,
                    ganZhi = it.gan_zhi
                )
            },
            wuXing = wu_xing,
            notes = notes
        )
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
