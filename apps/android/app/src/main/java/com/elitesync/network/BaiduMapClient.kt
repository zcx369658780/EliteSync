package com.elitesync.network

import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object BaiduMapClient {
    private const val BASE_URL = "https://api.map.baidu.com/"

    val service: BaiduMapApiService by lazy {
        val client = OkHttpClient.Builder()
            .dns(DomainDns)
            .build()
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(BaiduMapApiService::class.java)
    }
}

