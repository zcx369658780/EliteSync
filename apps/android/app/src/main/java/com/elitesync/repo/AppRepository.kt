package com.elitesync.repo

import com.elitesync.BuildConfig
import com.elitesync.model.*
import com.baidu.mapapi.model.LatLng
import com.baidu.mapapi.search.core.SearchResult
import com.baidu.mapapi.search.geocode.GeoCodeResult
import com.baidu.mapapi.search.geocode.GeoCoder
import com.baidu.mapapi.search.geocode.OnGetGeoCoderResultListener
import com.baidu.mapapi.search.geocode.ReverseGeoCodeOption
import com.baidu.mapapi.search.geocode.ReverseGeoCodeResult
import com.baidu.mapapi.search.sug.OnGetSuggestionResultListener
import com.baidu.mapapi.search.sug.SuggestionResult
import com.baidu.mapapi.search.sug.SuggestionSearch
import com.baidu.mapapi.search.sug.SuggestionSearchOption
import com.elitesync.network.ApiClient
import com.elitesync.network.BaiduMapClient
import kotlinx.coroutines.suspendCancellableCoroutine
import android.util.Log
import kotlin.coroutines.resume

class AppRepository {
    private val api = ApiClient.service
    private val baidu = BaiduMapClient.service

    suspend fun checkAppVersion(versionName: String, versionCode: Int, platform: String = "android", channel: String = "stable") =
        api.checkAppVersion(platform = platform, versionName = versionName, versionCode = versionCode, channel = channel)

    suspend fun register(phone: String, password: String, birthday: String?, realnameVerified: Boolean) =
        api.register(RegisterReq(phone, password, birthday, realnameVerified))
    suspend fun changePassword(token: String, currentPassword: String, newPassword: String, newPasswordConfirmation: String) =
        api.changePassword(
            "Bearer $token",
            ChangePasswordReq(
                current_password = currentPassword,
                new_password = newPassword,
                new_password_confirmation = newPasswordConfirmation
            )
        )
    suspend fun saveBasicProfile(
        token: String,
        birthday: String?,
        name: String? = null,
        gender: String,
        city: String,
        relationshipGoal: String
    ) = api.saveBasicProfile(
        "Bearer $token",
        BasicProfileReq(
            birthday = birthday,
            name = name,
            gender = gender,
            city = city,
            relationship_goal = relationshipGoal
        )
    )
    suspend fun saveCity(token: String, city: String) =
        api.saveCity("Bearer $token", CityUpdateReq(city = city))
    suspend fun basicProfile(token: String) = api.basicProfile("Bearer $token")
    suspend fun login(phone: String, password: String) = api.login(LoginReq(phone, password))
    suspend fun questions(token: String) = api.questions("Bearer $token")
    suspend fun replaceQuestion(token: String, excludeIds: List<Int>) = api.replaceQuestion("Bearer $token", ReplaceQuestionReq(excludeIds))
    suspend fun saveAnswers(token: String, answers: List<AnswerItem>) = api.saveAnswers("Bearer $token", SubmitAnswersReq(answers))
    suspend fun resetQuestionnaire(token: String) = api.resetQuestionnaire("Bearer $token")
    suspend fun questionnaireProgress(token: String) = api.questionnaireProgress("Bearer $token")
    suspend fun questionnaireProfile(token: String) = api.questionnaireProfile("Bearer $token")
    suspend fun astroProfile(token: String) = api.astroProfile("Bearer $token")
    suspend fun saveAstroProfile(token: String, payload: AstroProfilePayload) = api.saveAstroProfile("Bearer $token", payload)
    suspend fun mbtiQuiz(token: String, version: String = "lite3_v1") = api.mbtiQuiz("Bearer $token", version)
    suspend fun submitMbti(token: String, version: String, answers: List<MbtiAnswerItem>) =
        api.submitMbti("Bearer $token", MbtiSubmitReq(version, answers))
    suspend fun mbtiResult(token: String) = api.mbtiResult("Bearer $token")
    suspend fun currentMatch(token: String) = api.currentMatch("Bearer $token")
    suspend fun confirmMatch(token: String, matchId: Int, like: Boolean) = api.confirmMatch("Bearer $token", MatchConfirmReq(matchId, like))
    suspend fun sendMessage(token: String, receiverId: Int, content: String) = api.sendMessage("Bearer $token", MessageReq(receiverId, content))
    suspend fun devRunMatching(token: String) = api.devRunMatching("Bearer $token")
    suspend fun devReleaseDrop(token: String) = api.devReleaseDrop("Bearer $token")
    suspend fun loadMessages(token: String, peerId: Int, afterId: Int = 0) = api.messages("Bearer $token", peerId, afterId)

    suspend fun searchPlaces(query: String, region: String = "全国"): List<MapPlace> {
        if (query.isBlank()) return emptyList()

        val sdkResult = searchPlacesBySdk(query, region)
        if (sdkResult.isNotEmpty()) {
            Log.i("AppRepository", "searchPlaces sdk hit=${sdkResult.size} query=$query region=$region")
            return sdkResult
        }

        val ak = BuildConfig.BAIDU_MAP_AK
        if (ak.isBlank()) {
            Log.e("AppRepository", "searchPlaces aborted: BAIDU_MAP_AK blank")
            return emptyList()
        }
        val regionCandidates = buildList {
            val r = region.trim()
            if (r.isNotBlank()) add(r)
            add("中国")
            add("全国")
            add("北京")
            add("上海")
        }.distinct()

        val merged = linkedMapOf<String, MapPlace>()
        for (r in regionCandidates) {
            val resp = runCatching { baidu.suggestion(query = query, region = r, ak = ak) }.getOrNull() ?: continue
            if (resp.status != 0) {
                Log.w("AppRepository", "searchPlaces suggestion status=${resp.status} region=$r query=$query")
                continue
            }
            resp.result.forEach { item ->
                val lat = item.location?.lat ?: return@forEach
                val lng = item.location?.lng ?: return@forEach
                val place = MapPlace(
                    name = item.name.orEmpty(),
                    address = item.address.orEmpty(),
                    city = item.city.orEmpty(),
                    district = item.district.orEmpty(),
                    location = MapPoint(lat = lat, lng = lng)
                )
                val key = "${place.name}|${place.location.lat}|${place.location.lng}"
                merged.putIfAbsent(key, place)
            }
            if (merged.size >= 10) break
        }
        if (merged.isNotEmpty()) {
            Log.i("AppRepository", "searchPlaces http suggestion hit=${merged.size} query=$query region=$region")
            return merged.values.toList()
        }

        // Last fallback: convert address text into one geocode point, so user can still select it.
        for (r in regionCandidates) {
            val geo = runCatching { baidu.geocoding(address = query, city = r, ak = ak) }.getOrNull() ?: continue
            if (geo.status != 0) {
                Log.w("AppRepository", "searchPlaces geocoding status=${geo.status} city=$r query=$query")
                continue
            }
            val loc = geo.result?.location ?: continue
            val lat = loc.lat ?: continue
            val lng = loc.lng ?: continue
            Log.i("AppRepository", "searchPlaces geocoding fallback hit query=$query city=$r")
            return listOf(
                MapPlace(
                    name = query,
                    address = query,
                    city = if (r == "全国") "" else r,
                    district = "",
                    location = MapPoint(lat = lat, lng = lng)
                )
            )
        }
        Log.w("AppRepository", "searchPlaces empty query=$query region=$region")
        return emptyList()
    }

    suspend fun reverseGeocode(lat: Double, lng: Double): MapPlace? {
        val sdkResult = reverseGeocodeBySdk(lat, lng)
        if (sdkResult != null) return sdkResult

        val ak = BuildConfig.BAIDU_MAP_AK
        if (ak.isBlank()) return null
        val primary = reverseGeocodeByHttp(lat, lng, ak, "wgs84ll")
        if (primary != null) return primary
        val fallback = reverseGeocodeByHttp(lat, lng, ak, "gcj02ll")
        if (fallback != null) return fallback
        Log.w("AppRepository", "reverseGeocode empty for $lat,$lng on both coordtypes")
        return null
    }

    private suspend fun reverseGeocodeByHttp(
        lat: Double,
        lng: Double,
        ak: String,
        coordType: String
    ): MapPlace? {
        val resp = baidu.reverseGeocoding(location = "$lat,$lng", coordType = coordType, ak = ak)
        if ((resp.status ?: -1) != 0) {
            Log.w("AppRepository", "reverseGeocodeByHttp status=${resp.status} coordType=$coordType")
            return null
        }
        val r = resp.result ?: return null
        val city = r.addressComponent?.city.orEmpty()
        val district = r.addressComponent?.district.orEmpty()
        val title = r.sematic_description?.takeIf { it.isNotBlank() }
            ?: r.formatted_address.orEmpty()
        return MapPlace(
            name = title.ifBlank { "定位结果" },
            address = r.formatted_address.orEmpty(),
            city = city,
            district = district,
            location = MapPoint(lat = lat, lng = lng)
        )
    }

    private suspend fun searchPlacesBySdk(query: String, region: String): List<MapPlace> {
        if (query.isBlank()) return emptyList()

        val candidates = buildList {
            val r = region.trim()
            if (r.isNotBlank()) add(r)
            add("全国")
            add("中国")
            add("北京")
        }.distinct()

        for (city in candidates) {
            val one = requestSuggestionOnce(query, city)
            if (one.isNotEmpty()) return one
        }
        return emptyList()
    }

    private suspend fun requestSuggestionOnce(query: String, city: String): List<MapPlace> =
        suspendCancellableCoroutine { cont ->
            val search = SuggestionSearch.newInstance()
            var done = false
            fun finish(value: List<MapPlace>) {
                if (!done) {
                    done = true
                    runCatching { search.destroy() }
                    cont.resume(value)
                }
            }

            search.setOnGetSuggestionResultListener(object : OnGetSuggestionResultListener {
                override fun onGetSuggestionResult(result: SuggestionResult?) {
                    if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {
                        finish(emptyList())
                        return
                    }
                    val mapped = result.allSuggestions.orEmpty().mapNotNull { s ->
                        val loc = s.pt ?: return@mapNotNull null
                        MapPlace(
                            name = s.key.orEmpty(),
                            address = s.address.orEmpty(),
                            city = s.city.orEmpty(),
                            district = s.district.orEmpty(),
                            location = MapPoint(lat = loc.latitude, lng = loc.longitude)
                        )
                    }
                    finish(mapped)
                }
            })
            val ok = search.requestSuggestion(
                SuggestionSearchOption()
                    .keyword(query)
                    .city(city)
                    .citylimit(false)
            )
            if (!ok) finish(emptyList())

            cont.invokeOnCancellation {
                runCatching { search.destroy() }
            }
        }

    private suspend fun reverseGeocodeBySdk(lat: Double, lng: Double): MapPlace? =
        suspendCancellableCoroutine { cont ->
            val coder = GeoCoder.newInstance()
            var done = false
            fun finish(value: MapPlace?) {
                if (!done) {
                    done = true
                    runCatching { coder.destroy() }
                    cont.resume(value)
                }
            }

            coder.setOnGetGeoCodeResultListener(object : OnGetGeoCoderResultListener {
                override fun onGetGeoCodeResult(result: GeoCodeResult?) = Unit

                override fun onGetReverseGeoCodeResult(result: ReverseGeoCodeResult?) {
                    if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR || result.location == null) {
                        finish(null)
                        return
                    }
                    val loc = result.location
                    finish(
                        MapPlace(
                            name = result.sematicDescription.orEmpty().ifBlank { result.address.orEmpty() },
                            address = result.address.orEmpty(),
                            city = result.addressDetail?.city.orEmpty(),
                            district = result.addressDetail?.district.orEmpty(),
                            location = MapPoint(lat = loc.latitude, lng = loc.longitude)
                        )
                    )
                }
            })
            val ok = coder.reverseGeoCode(
                ReverseGeoCodeOption().location(LatLng(lat, lng))
            )
            if (!ok) finish(null)

            cont.invokeOnCancellation {
                runCatching { coder.destroy() }
            }
        }
}
