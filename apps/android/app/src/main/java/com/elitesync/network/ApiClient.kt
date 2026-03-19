package com.elitesync.network

import com.elitesync.BuildConfig
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApiClient {
    private const val FALLBACK_BASE_URL = "http://101.133.161.203/"
    private val baseUrl: String = BuildConfig.API_BASE_URL.ifBlank { FALLBACK_BASE_URL }

    val service: ApiService by lazy {
        val client = OkHttpClient.Builder().build()
        Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }
}
