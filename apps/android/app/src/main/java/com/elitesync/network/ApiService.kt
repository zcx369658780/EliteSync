package com.elitesync.network

import com.elitesync.model.*
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST

interface ApiService {
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

    @GET("/api/v1/questionnaire/progress")
    suspend fun questionnaireProgress(@Header("Authorization") bearer: String): QuestionnaireProgressResp

    @GET("/api/v1/questionnaire/profile")
    suspend fun questionnaireProfile(@Header("Authorization") bearer: String): ProfileResp

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
