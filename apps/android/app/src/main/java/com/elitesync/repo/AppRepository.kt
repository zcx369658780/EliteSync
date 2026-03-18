package com.elitesync.repo

import com.elitesync.model.*
import com.elitesync.network.ApiClient

class AppRepository {
    private val api = ApiClient.service

    suspend fun register(phone: String, password: String) = api.register(RegisterReq(phone, password))
    suspend fun login(phone: String, password: String) = api.login(LoginReq(phone, password))
    suspend fun questions(token: String) = api.questions("Bearer $token")
    suspend fun replaceQuestion(token: String, excludeIds: List<Int>) = api.replaceQuestion("Bearer $token", ReplaceQuestionReq(excludeIds))
    suspend fun saveAnswers(token: String, answers: List<AnswerItem>) = api.saveAnswers("Bearer $token", SubmitAnswersReq(answers))
    suspend fun resetQuestionnaire(token: String) = api.resetQuestionnaire("Bearer $token")
    suspend fun questionnaireProgress(token: String) = api.questionnaireProgress("Bearer $token")
    suspend fun questionnaireProfile(token: String) = api.questionnaireProfile("Bearer $token")
    suspend fun currentMatch(token: String) = api.currentMatch("Bearer $token")
    suspend fun confirmMatch(token: String, matchId: Int, like: Boolean) = api.confirmMatch("Bearer $token", MatchConfirmReq(matchId, like))
    suspend fun sendMessage(token: String, receiverId: Int, content: String) = api.sendMessage("Bearer $token", MessageReq(receiverId, content))
    suspend fun devRunMatching(token: String) = api.devRunMatching("Bearer $token")
    suspend fun devReleaseDrop(token: String) = api.devReleaseDrop("Bearer $token")
    suspend fun loadMessages(token: String, peerId: Int, afterId: Int = 0) = api.messages("Bearer $token", peerId, afterId)
}
