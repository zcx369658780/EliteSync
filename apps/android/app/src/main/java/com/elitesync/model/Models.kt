package com.elitesync.model

data class RegisterReq(val phone: String, val password: String)
data class LoginReq(val phone: String, val password: String)
data class AuthUser(val id: Int, val phone: String? = null, val name: String? = null)
data class TokenResp(
    val access_token: String,
    val token_type: String? = null,
    val user: AuthUser? = null
)

data class QuestionOptionLabel(val zh: String? = null, val en: String? = null)
data class QuestionOptionItem(
    val option_id: String,
    val label: QuestionOptionLabel = QuestionOptionLabel(),
    val score: Double? = null
)

data class Question(
    val id: Int,
    val question_key: String? = null,
    val category: String? = null,
    val content: String,
    val question_type: String? = null,
    val acceptable_answer_logic: String? = null,
    val options: List<String> = emptyList(),
    val option_items: List<QuestionOptionItem> = emptyList(),
    val version: Int? = 1
)
data class QuestionsResp(
    val items: List<Question>,
    val total: Int,
    val bank_total: Int? = null,
    val required: Int? = null
)
data class QuestionnaireProgressResp(val answered: Int, val total: Int, val complete: Boolean)
data class ReplaceQuestionReq(val exclude_ids: List<Int>)

data class AnswerItem(
    val question_id: Int,
    val answer: String? = null,
    val is_draft: Boolean = false,
    val selected_answer: List<String>? = null,
    val acceptable_answers: List<String>? = null,
    val importance: Int? = null,
    val version: Int? = null
)
data class SubmitAnswersReq(val answers: List<AnswerItem>)
data class ProfileSummary(val label: String = "", val highlights: List<String> = emptyList())
data class ProfileResp(
    val answered: Int = 0,
    val total: Int = 0,
    val complete: Boolean = false,
    val vector: Map<String, Int> = emptyMap(),
    val summary: ProfileSummary = ProfileSummary()
)

data class MatchResp(
    val match_id: Int,
    val partner_id: Int,
    val highlights: String,
    val explanation_tags: List<String> = emptyList(),
    val base_score: Int? = null,
    val final_score: Int? = null,
    val fairness_adjusted_score: Int? = null,
    val penalty_factors: Map<String, Double> = emptyMap()
)
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
