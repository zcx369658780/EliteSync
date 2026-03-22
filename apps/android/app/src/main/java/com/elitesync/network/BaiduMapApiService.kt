package com.elitesync.network

import retrofit2.http.GET
import retrofit2.http.Query

data class BaiduLocationDto(
    val lat: Double? = null,
    val lng: Double? = null
)

data class BaiduSuggestionItemDto(
    val name: String? = null,
    val city: String? = null,
    val district: String? = null,
    val address: String? = null,
    val location: BaiduLocationDto? = null
)

data class BaiduSuggestionResp(
    val status: Int? = null,
    val result: List<BaiduSuggestionItemDto> = emptyList()
)

data class BaiduReverseResultDto(
    val formatted_address: String? = null,
    val sematic_description: String? = null,
    val addressComponent: BaiduAddressComponentDto? = null
)

data class BaiduAddressComponentDto(
    val city: String? = null,
    val district: String? = null
)

data class BaiduReverseResp(
    val status: Int? = null,
    val result: BaiduReverseResultDto? = null
)

interface BaiduMapApiService {
    @GET("/place/v2/suggestion")
    suspend fun suggestion(
        @Query("query") query: String,
        @Query("region") region: String = "全国",
        @Query("city_limit") cityLimit: Boolean = false,
        @Query("output") output: String = "json",
        @Query("ak") ak: String
    ): BaiduSuggestionResp

    @GET("/reverse_geocoding/v3")
    suspend fun reverseGeocoding(
        @Query("location") location: String,
        @Query("coordtype") coordType: String = "wgs84ll",
        @Query("output") output: String = "json",
        @Query("ak") ak: String
    ): BaiduReverseResp
}

