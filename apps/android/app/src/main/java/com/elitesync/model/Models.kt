package com.elitesync.model

data class RegisterReq(val phone: String, val password: String)
data class LoginReq(val phone: String, val password: String)
data class AuthUser(val id: Int, val phone: String? = null, val name: String? = null)
data class TokenResp(
    val access_token: String,
    val token_type: String? = null,
    val user: AuthUser? = null
)

data class Question(
    val id: Int,
    val question_key: String? = null,
    val content: String,
    val question_type: String? = null,
    val options: List<String> = emptyList()
)
data class QuestionsResp(val items: List<Question>, val total: Int)
data class QuestionnaireProgressResp(val answered: Int, val total: Int, val complete: Boolean)

data class AnswerItem(val question_id: Int, val answer: String, val is_draft: Boolean)
data class SubmitAnswersReq(val answers: List<AnswerItem>)

data class MatchResp(val match_id: Int, val partner_id: Int, val highlights: String)
data class MatchConfirmReq(val match_id: Int, val like: Boolean)

data class MessageReq(val receiver_id: Int, val content: String)
data class SimpleResp(val ok: Boolean? = null, val id: Int? = null)
data class ChatMessage(
    val id: Int,
    val sender_id: Int,
    val receiver_id: Int,
    val content: String,
    val is_read: Boolean = false,
    val created_at: String? = null
)
data class MessagesResp(val items: List<ChatMessage>, val total: Int)
