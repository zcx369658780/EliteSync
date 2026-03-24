package com.elitesync.model

data class RegisterReq(
    val phone: String,
    val password: String,
    val birthday: String? = null,
    val realname_verified: Boolean
)
data class LoginReq(val phone: String, val password: String)
data class AuthUser(
    val id: Int,
    val phone: String? = null,
    val name: String? = null,
    val birthday: String? = null,
    val zodiac_animal: String? = null,
    val gender: String? = null,
    val city: String? = null,
    val relationship_goal: String? = null,
    val realname_verified: Boolean? = null
)
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
    val core_scores: MatchCoreScores? = null,
    val astro_scores: MatchAstroScores? = null,
    val match_verdict: String? = null,
    val match_reasons: MatchReasons? = null,
    val penalty_factors: Map<String, Double> = emptyMap()
)
data class MatchConfirmReq(val match_id: Int, val like: Boolean)

data class MatchAstroScores(
    val bazi: Int? = null,
    val zodiac: Int? = null,
    val constellation: Int? = null,
    val natal_chart: Int? = null
)

data class MatchReasons(
    val summary: String? = null,
    val match: List<String> = emptyList(),
    val mismatch: List<String> = emptyList(),
    val confidence: Double? = null,
    val modules: List<MatchReasonModule> = emptyList()
)

data class MatchCoreScores(
    val personality: Int? = null,
    val mbti: Int? = null,
    val astro: Int? = null,
    val overall: Int? = null
)

data class MatchReasonModule(
    val key: String = "",
    val label: String = "",
    val score: Int? = null,
    val weight: Double? = null,
    val confidence: Double? = null,
    val verdict: String? = null,
    val reason_short: String? = null,
    val reason_detail: String? = null,
    val risk_short: String? = null,
    val risk_detail: String? = null,
    val evidence_tags: List<String> = emptyList(),
    val evidence: Map<String, Any?> = emptyMap(),
    val highlights: List<MatchReasonItem> = emptyList(),
    val risks: List<MatchReasonItem> = emptyList(),
    val degraded: Boolean? = null,
    val degrade_reason: String? = null
)

data class MatchReasonItem(
    val text: String = "",
    val evidence_tags: List<String> = emptyList(),
    val evidence: Map<String, Any?> = emptyMap()
)

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

data class MapPoint(val lat: Double, val lng: Double)
data class MapPlace(
    val name: String,
    val address: String,
    val city: String,
    val district: String,
    val location: MapPoint
)

data class DaYunItem(
    val index: Int,
    val gan_zhi: String,
    val start_year: Int,
    val end_year: Int,
    val start_age: Int,
    val end_age: Int
)

data class LiuNianItem(
    val year: Int,
    val age: Int,
    val gan_zhi: String
)

data class AstroProfilePayload(
    val birth_time: String,
    val birth_place: String? = null,
    val birth_lat: Double? = null,
    val birth_lng: Double? = null,
    val sun_sign: String,
    val moon_sign: String? = null,
    val asc_sign: String? = null,
    val bazi: String? = null,
    val true_solar_time: String? = null,
    val da_yun: List<DaYunItem> = emptyList(),
    val liu_nian: List<LiuNianItem> = emptyList(),
    val wu_xing: Map<String, Int> = emptyMap(),
    val notes: List<String> = emptyList()
)

data class AstroProfileRecord(
    val birth_time: String,
    val birth_place: String? = null,
    val birth_lat: Double? = null,
    val birth_lng: Double? = null,
    val sun_sign: String,
    val moon_sign: String? = null,
    val asc_sign: String? = null,
    val bazi: String? = null,
    val true_solar_time: String? = null,
    val da_yun: List<DaYunItem> = emptyList(),
    val liu_nian: List<LiuNianItem> = emptyList(),
    val wu_xing: Map<String, Int> = emptyMap(),
    val notes: List<String> = emptyList(),
    val computed_at: String? = null
)

data class AstroProfileResp(
    val exists: Boolean = false,
    val profile: AstroProfileRecord? = null
)

data class BasicProfileReq(
    val birthday: String? = null,
    val name: String? = null,
    val gender: String,
    val city: String,
    val relationship_goal: String
)

data class CityUpdateReq(
    val city: String
)

data class BasicProfileResp(
    val id: Int,
    val name: String? = null,
    val phone: String? = null,
    val birthday: String? = null,
    val zodiac_animal: String? = null,
    val gender: String? = null,
    val city: String? = null,
    val relationship_goal: String? = null,
    val realname_verified: Boolean? = null
)

data class AppVersionCheckResp(
    val platform: String = "android",
    val channel: String = "stable",
    val client_version_name: String = "",
    val client_version_code: Int = 0,
    val latest_version_name: String = "",
    val latest_version_code: Int = 0,
    val min_supported_version_name: String = "",
    val has_update: Boolean = false,
    val force_update: Boolean = false,
    val download_url: String = "",
    val changelog: String = "",
    val sha256: String = ""
)

data class MbtiQuizQuestion(
    val question_id: Int,
    val content: String,
    val option_a_text: String,
    val option_b_text: String
)

data class MbtiQuizResp(
    val version_code: String,
    val total: Int,
    val items: List<MbtiQuizQuestion>
)

data class MbtiAnswerItem(
    val question_id: Int,
    val option: String
)

data class MbtiSubmitReq(
    val version_code: String,
    val answers: List<MbtiAnswerItem>
)

data class MbtiSubmitResp(
    val ok: Boolean = false,
    val result: String = "",
    val letters: Map<String, String> = emptyMap(),
    val scores: Map<String, Int> = emptyMap(),
    val confidence: Map<String, Double> = emptyMap()
)

data class MbtiResultResp(
    val exists: Boolean = false,
    val result: String? = null,
    val updated_at: String? = null,
    val scores: Map<String, Int>? = null,
    val confidence: Map<String, Double>? = null
)
