package com.elitesync.network

import com.elitesync.model.*
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Query

interface ApiService {
    @GET("/api/v1/app/version/check")
    suspend fun checkAppVersion(
        @Query("platform") platform: String,
        @Query("version_name") versionName: String,
        @Query("version_code") versionCode: Int,
        @Query("channel") channel: String = "stable"
    ): AppVersionCheckResp

    @POST("/api/v1/auth/register")
    suspend fun register(@Body req: RegisterReq): TokenResp

    @POST("/api/v1/auth/login")
    suspend fun login(@Body req: LoginReq): TokenResp

    @GET("/api/v1/questionnaire/questions")
    suspend fun questions(@Header("Authorization") bearer: String): QuestionsResp

    @POST("/api/v1/questionnaire/questions/replace")
    suspend fun replaceQuestion(@Header("Authorization") bearer: String, @Body req: ReplaceQuestionReq): Question

    @POST("/api/v1/questionnaire/answers")
    suspend fun saveAnswers(@Header("Authorization") bearer: String, @Body req: SubmitAnswersReq): SimpleResp

    @POST("/api/v1/questionnaire/reset")
    suspend fun resetQuestionnaire(@Header("Authorization") bearer: String): SimpleResp

    @GET("/api/v1/questionnaire/progress")
    suspend fun questionnaireProgress(@Header("Authorization") bearer: String): QuestionnaireProgressResp

    @GET("/api/v1/questionnaire/profile")
    suspend fun questionnaireProfile(@Header("Authorization") bearer: String): ProfileResp

    @GET("/api/v1/profile/basic")
    suspend fun basicProfile(@Header("Authorization") bearer: String): BasicProfileResp

    @POST("/api/v1/profile/basic")
    suspend fun saveBasicProfile(@Header("Authorization") bearer: String, @Body req: BasicProfileReq): SimpleResp

    @POST("/api/v1/profile/city")
    suspend fun saveCity(@Header("Authorization") bearer: String, @Body req: CityUpdateReq): SimpleResp

    @GET("/api/v1/profile/astro")
    suspend fun astroProfile(@Header("Authorization") bearer: String): AstroProfileResp

    @POST("/api/v1/profile/astro")
    suspend fun saveAstroProfile(@Header("Authorization") bearer: String, @Body req: AstroProfilePayload): SimpleResp

    @GET("/api/v1/profile/mbti/quiz")
    suspend fun mbtiQuiz(
        @Header("Authorization") bearer: String,
        @Query("version") version: String = "lite3_v1"
    ): MbtiQuizResp

    @POST("/api/v1/profile/mbti/submit")
    suspend fun submitMbti(
        @Header("Authorization") bearer: String,
        @Body req: MbtiSubmitReq
    ): MbtiSubmitResp

    @GET("/api/v1/profile/mbti/result")
    suspend fun mbtiResult(@Header("Authorization") bearer: String): MbtiResultResp

    @GET("/api/v1/matches/current")
    suspend fun currentMatch(@Header("Authorization") bearer: String): MatchResp

    @POST("/api/v1/matches/confirm")
    suspend fun confirmMatch(@Header("Authorization") bearer: String, @Body req: MatchConfirmReq): Map<String, Boolean>

    @POST("/api/v1/messages")
    suspend fun sendMessage(@Header("Authorization") bearer: String, @Body req: MessageReq): SimpleResp

    @POST("/api/v1/admin/dev/run-matching")
    suspend fun devRunMatching(@Header("Authorization") bearer: String): SimpleResp

    @POST("/api/v1/admin/dev/release-drop")
    suspend fun devReleaseDrop(@Header("Authorization") bearer: String): SimpleResp

    @GET("/api/v1/messages")
    suspend fun messages(
        @Header("Authorization") bearer: String,
        @retrofit2.http.Query("peer_id") peerId: Int,
        @retrofit2.http.Query("after_id") afterId: Int = 0
    ): MessagesResp
}
