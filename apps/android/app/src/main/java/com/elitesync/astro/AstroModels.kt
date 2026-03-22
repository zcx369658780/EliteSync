package com.elitesync.astro

data class DaYunResult(
    val index: Int,
    val ganZhi: String,
    val startYear: Int,
    val endYear: Int,
    val startAge: Int,
    val endAge: Int
)

data class LiuNianResult(
    val year: Int,
    val age: Int,
    val ganZhi: String
)

data class AstroProfileResult(
    val sunSign: String,
    val moonSign: String?,
    val ascSign: String?,
    val bazi: String?,
    val trueSolarTime: String?,
    val daYun: List<DaYunResult> = emptyList(),
    val liuNian: List<LiuNianResult> = emptyList(),
    val wuXing: Map<String, Int> = emptyMap(),
    val notes: List<String> = emptyList()
)
