package com.elitesync.ui.screens

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Build
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

@Composable
fun BasicProfileScreen(vm: AppViewModel, onBack: () -> Unit) {
    val context = LocalContext.current
    var nickname by remember { mutableStateOf("") }
    var gender by remember { mutableStateOf("") }
    var birthday by remember { mutableStateOf("") }
    var city by remember { mutableStateOf("") }
    var goal by remember { mutableStateOf("") }
    val currentBirthday by vm.currentUserBirthday.collectAsState()
    val currentGender by vm.currentUserGender.collectAsState()
    val currentName by vm.currentUserName.collectAsState()
    val currentCity by vm.currentUserCity.collectAsState()
    val currentGoal by vm.currentRelationshipGoal.collectAsState()
    val currentPlace by vm.currentPlace.collectAsState()
    val status by vm.status.collectAsState()
    val locating = status.contains("定位解析中") || status.contains("定位中")

    val goalOptions = mapOf(
        "marriage" to "结婚",
        "dating" to "恋爱",
        "friendship" to "交友"
    )

    val locationLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            requestCurrentLocation(context) { lat, lng ->
                if (lat != null && lng != null) vm.reverseGeocodeCurrent(lat, lng)
                else vm.locationUnavailable()
            }
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
        if (city.isBlank()) city = currentCity
        if (goal.isBlank()) goal = currentGoal
    }

    LaunchedEffect(currentPlace) {
        val c = currentPlace?.city.orEmpty()
        if (c.isNotBlank()) city = c
    }

    GlassScrollPage(title = "基础资料") {
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
        }
        StarrySectionCard(title = "城市与婚恋目标") {
            Text("城市（自动GPS定位）", color = Color(0xFFE6EEFF))
            StarrySecondaryButton(
                text = if (city.isBlank()) "自动获取城市" else "重新定位城市",
                loading = locating,
                onClick = {
                    val granted = ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
                    if (granted) {
                        requestCurrentLocation(context) { lat, lng ->
                            if (lat != null && lng != null) vm.reverseGeocodeCurrent(lat, lng)
                            else vm.locationUnavailable()
                        }
                    } else {
                        locationLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
                    }
                }
            )
            Text(if (city.isBlank()) "当前城市：未获取" else "当前城市：$city")

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
            StarrySecondaryButton(text = "返回", onClick = onBack)
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
    val cts = CancellationTokenSource()
    fused.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, cts.token).addOnSuccessListener { loc ->
        if (loc != null) onResult(loc.latitude, loc.longitude)
        else requestSystemCurrentLocation(context, onResult)
    }.addOnFailureListener {
        requestSystemCurrentLocation(context, onResult)
    }
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
