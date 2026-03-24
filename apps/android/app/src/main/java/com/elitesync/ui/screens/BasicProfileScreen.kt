package com.elitesync.ui.screens

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.location.Address
import android.location.Geocoder
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.ui.platform.LocalContext
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.StarryBackButton
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryDateDropdownField
import com.elitesync.ui.components.StarryOptionCard
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton
import com.elitesync.ui.components.StarryTextField
import com.elitesync.ui.components.StarryDropdownField
import androidx.compose.material3.Text
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import java.util.Locale

@Composable
fun BasicProfileScreen(vm: AppViewModel, onBack: () -> Unit) {
    val context = LocalContext.current
    var nickname by remember { mutableStateOf("") }
    var gender by remember { mutableStateOf("") }
    var birthday by remember { mutableStateOf("") }
    var city by remember { mutableStateOf("") }
    var goal by remember { mutableStateOf("") }
    val currentBirthday by vm.currentUserBirthday.collectAsState()
    val currentZodiacAnimal by vm.currentUserZodiacAnimal.collectAsState()
    val currentGender by vm.currentUserGender.collectAsState()
    val currentName by vm.currentUserName.collectAsState()
    val currentCity by vm.currentUserCity.collectAsState()
    val currentGoal by vm.currentRelationshipGoal.collectAsState()
    val currentPlace by vm.currentPlace.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    var localLocating by remember { mutableStateOf(false) }
    val locating = localLocating || status.contains("定位解析中") || status.contains("定位中")

    val goalOptions = mapOf(
        "marriage" to "结婚",
        "dating" to "恋爱",
        "friendship" to "交友"
    )

    val locationLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestMultiplePermissions()
    ) { grantMap ->
        val granted = grantMap[Manifest.permission.ACCESS_FINE_LOCATION] == true ||
            grantMap[Manifest.permission.ACCESS_COARSE_LOCATION] == true
        if (granted) {
            localLocating = true
            requestCurrentLocation(context) { lat, lng ->
                if (lat != null && lng != null) {
                    resolveCityFromGps(context, lat, lng) { detected ->
                        localLocating = false
                        if (!detected.isNullOrBlank()) {
                            city = detected
                            vm.cityResolvedFromLocation(detected)
                        } else {
                            vm.cityUnresolvedFromLocation()
                        }
                    }
                } else {
                    localLocating = false
                    vm.locationUnavailable()
                }
            }
        } else {
            localLocating = false
            vm.locationUnavailable()
        }
    }

    LaunchedEffect(Unit) {
        vm.loadBasicProfile()
    }

    LaunchedEffect(currentName, currentBirthday, currentGender, currentCity, currentGoal) {
        if (nickname.isBlank()) nickname = currentName
        if (birthday.isBlank()) {
            birthday = currentBirthday
        }
        if (gender.isBlank()) {
            gender = currentGender
        }
        if (city.isBlank()) {
            city = if (currentCity.contains("未解析城市")) "" else currentCity
        }
        if (goal.isBlank()) goal = currentGoal
    }

    LaunchedEffect(currentPlace) {
        val place = currentPlace
        val c = listOf(
            place?.city.orEmpty(),
            place?.district.orEmpty()
        ).firstOrNull { it.isNotBlank() }.orEmpty()
        if (c.isNotBlank()) city = c
    }

    LaunchedEffect(status) {
        if (!status.contains("定位")) {
            localLocating = false
        }
    }

    GlassScrollPage(
        title = "基础资料",
        status = status,
        error = error
    ) {
        StarrySectionCard(title = "基本信息") {
            StarryTextField(value = nickname, onValueChange = { nickname = it }, label = "昵称")
            Text("性别（必选）", color = Color(0xFFE6EEFF))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                StarryOptionCard(
                    text = "男",
                    selected = gender == "male",
                    modifier = Modifier.weight(1f),
                    onClick = { gender = "male" }
                )
                StarryOptionCard(
                    text = "女",
                    selected = gender == "female",
                    modifier = Modifier.weight(1f),
                    onClick = { gender = "female" }
                )
            }
            StarryDateDropdownField(value = birthday, onValueChange = { birthday = it }, label = "生日（下拉选择）")
            if (birthday.isNotBlank()) {
                val zodiacText = currentZodiacAnimal.ifBlank { "自动计算中" }
                Text("属相：$zodiacText", color = Color(0xFFB9CCEE))
            }
        }
        StarrySectionCard(title = "城市与婚恋目标") {
            Text("城市信息（自动GPS定位）", color = Color(0xFFE6EEFF))
            StarrySecondaryButton(
                text = if (city.isBlank()) "自动获取城市" else "重新定位城市",
                loading = locating,
                feedbackText = "开始定位",
                onClick = {
                    if (city.contains("未解析城市")) city = ""
                    val granted = ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED ||
                        ContextCompat.checkSelfPermission(
                            context,
                            Manifest.permission.ACCESS_COARSE_LOCATION
                        ) == PackageManager.PERMISSION_GRANTED
                    if (granted) {
                        localLocating = true
                        requestCurrentLocation(context) { lat, lng ->
                            if (lat != null && lng != null) {
                                resolveCityFromGps(context, lat, lng) { detected ->
                                    localLocating = false
                                    if (!detected.isNullOrBlank()) {
                                        city = detected
                                        vm.cityResolvedFromLocation(detected)
                                    } else {
                                        vm.cityUnresolvedFromLocation()
                                    }
                                }
                            } else {
                                localLocating = false
                                vm.locationUnavailable()
                            }
                        }
                    } else {
                        locationLauncher.launch(
                            arrayOf(
                                Manifest.permission.ACCESS_FINE_LOCATION,
                                Manifest.permission.ACCESS_COARSE_LOCATION
                            )
                        )
                    }
                }
            )
            StarryTextField(
                value = city,
                onValueChange = { city = it },
                label = "城市（可手动填写）"
            )
            Text(if (city.isBlank()) "当前城市：未获取" else "当前城市：$city")
            currentPlace?.let {
                Text(
                    text = "定位结果：${it.name}（${it.city}${it.district}）",
                    color = Color(0xFFB9CCEE)
                )
            }

            StarryDropdownField(
                label = "婚恋目标",
                valueText = goalOptions[goal] ?: "请选择",
                options = goalOptions.values.toList(),
                onSelect = { label ->
                    goal = goalOptions.entries.firstOrNull { it.value == label }?.key ?: ""
                }
            )
        }
        StarrySectionCard {
            StarryPrimaryButton(
                text = "保存",
                feedbackText = "正在保存",
                onClick = {
                    vm.saveBasicProfile(
                        birthday = birthday,
                        name = nickname.ifBlank { null },
                        gender = gender,
                        city = city,
                        relationshipGoal = goal
                    )
                }
            )
            StarryBackButton(onClick = onBack)
        }
    }
}

@SuppressLint("MissingPermission")
private fun getCurrentLocation(context: Context): Location? {
    val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return null
    val gps = runCatching { lm.getLastKnownLocation(LocationManager.GPS_PROVIDER) }.getOrNull()
    val net = runCatching { lm.getLastKnownLocation(LocationManager.NETWORK_PROVIDER) }.getOrNull()
    val passive = runCatching { lm.getLastKnownLocation(LocationManager.PASSIVE_PROVIDER) }.getOrNull()
    return listOfNotNull(gps, net, passive).maxByOrNull { it.time }
}

@SuppressLint("MissingPermission")
private fun requestCurrentLocation(context: Context, onResult: (Double?, Double?) -> Unit) {
    val fineGranted = ActivityCompat.checkSelfPermission(
        context,
        Manifest.permission.ACCESS_FINE_LOCATION
    ) == PackageManager.PERMISSION_GRANTED
    val coarseGranted = ActivityCompat.checkSelfPermission(
        context,
        Manifest.permission.ACCESS_COARSE_LOCATION
    ) == PackageManager.PERMISSION_GRANTED
    if (!fineGranted && !coarseGranted) {
        onResult(null, null)
        return
    }

    val fused = LocationServices.getFusedLocationProviderClient(context)
    // First try cached last location for fast UX.
    fused.lastLocation
        .addOnSuccessListener { last ->
            if (last != null) {
                Log.d("BasicProfileScreen", "lastLocation hit: ${last.latitude}, ${last.longitude}")
                onResult(last.latitude, last.longitude)
                return@addOnSuccessListener
            }
            val cts = CancellationTokenSource()
            fused.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, cts.token)
                .addOnSuccessListener { loc ->
                    if (loc != null) {
                        Log.d("BasicProfileScreen", "getCurrentLocation hit: ${loc.latitude}, ${loc.longitude}")
                        onResult(loc.latitude, loc.longitude)
                    } else {
                        Log.d("BasicProfileScreen", "getCurrentLocation null, fallback system")
                        requestSystemCurrentLocation(context, onResult)
                    }
                }
                .addOnFailureListener { e ->
                    Log.w("BasicProfileScreen", "getCurrentLocation failed: ${e.message}")
                    requestSystemCurrentLocation(context, onResult)
                }
        }
        .addOnFailureListener { e ->
            Log.w("BasicProfileScreen", "lastLocation failed: ${e.message}")
            requestSystemCurrentLocation(context, onResult)
        }
}

private fun resolveCityFromGps(
    context: Context,
    lat: Double,
    lng: Double,
    onResult: (String?) -> Unit
) {
    if (!Geocoder.isPresent()) {
        onResult(null)
        return
    }
    val geocoder = Geocoder(context, Locale.SIMPLIFIED_CHINESE)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        geocoder.getFromLocation(lat, lng, 1, object : Geocoder.GeocodeListener {
            override fun onGeocode(addresses: MutableList<Address>) {
                val city = extractCityFromAddresses(addresses)
                onResult(city)
            }

            override fun onError(errorMessage: String?) {
                Log.w("BasicProfileScreen", "Geocoder error: $errorMessage")
                onResult(null)
            }
        })
    } else {
        Thread {
            val city = runCatching {
                geocoder.getFromLocation(lat, lng, 1)?.let { extractCityFromAddresses(it) }
            }.getOrNull()
            Handler(Looper.getMainLooper()).post { onResult(city) }
        }.start()
    }
}

private fun extractCityFromAddresses(addresses: List<Address>): String? {
    val first = addresses.firstOrNull() ?: return null
    val candidates = listOfNotNull(
        first.locality,
        first.subAdminArea,
        first.adminArea,
        first.featureName,
        first.getAddressLine(0)
    ).map { it.trim() }.filter { it.isNotBlank() }

    for (raw in candidates) {
        val parsed = parseCityName(raw)
        if (!parsed.isNullOrBlank()) return parsed
    }
    return null
}

private fun parseCityName(raw: String): String? {
    val direct = Regex("([\\u4e00-\\u9fa5]{2,12}(市|自治州|地区|盟))").find(raw)?.groupValues?.get(1)
    if (!direct.isNullOrBlank()) return direct
    // Last resort: take first few chars as requested.
    val cleaned = raw.replace("中国", "").replace("中华人民共和国", "").trim()
    if (cleaned.isBlank()) return null
    return cleaned.take(4)
}

@SuppressLint("MissingPermission")
private fun requestSystemCurrentLocation(context: Context, onResult: (Double?, Double?) -> Unit) {
    val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
    if (lm == null) {
        onResult(null, null)
        return
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        val executor = ContextCompat.getMainExecutor(context)
        runCatching {
            lm.getCurrentLocation(LocationManager.GPS_PROVIDER, null, executor) { gpsLoc ->
                if (gpsLoc != null) {
                    onResult(gpsLoc.latitude, gpsLoc.longitude)
                } else {
                    lm.getCurrentLocation(LocationManager.NETWORK_PROVIDER, null, executor) { netLoc ->
                        if (netLoc != null) onResult(netLoc.latitude, netLoc.longitude)
                        else {
                            val fallback = getCurrentLocation(context)
                            onResult(fallback?.latitude, fallback?.longitude)
                        }
                    }
                }
            }
        }.onFailure {
            val fallback = getCurrentLocation(context)
            onResult(fallback?.latitude, fallback?.longitude)
        }
    } else {
        val fallback = getCurrentLocation(context)
        onResult(fallback?.latitude, fallback?.longitude)
    }
}
