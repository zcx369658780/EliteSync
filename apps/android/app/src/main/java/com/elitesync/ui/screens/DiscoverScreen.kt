package com.elitesync.ui.screens

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Build
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.platform.LocalContext
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryListItemCard
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySecondaryButton
import com.elitesync.ui.components.StarryTextField

@Composable
fun DiscoverScreen(vm: AppViewModel, onOpenMapPicker: () -> Unit) {
    val context = LocalContext.current
    var query by remember { mutableStateOf("") }
    val places by vm.placeResults.collectAsState()
    val currentPlace by vm.currentPlace.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    val locating = status.contains("定位解析中") || status.contains("定位中")
    val searching = status.contains("地点搜索中")

    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            requestCurrentLocation(context) { lat, lng ->
                if (lat != null && lng != null) {
                    vm.reverseGeocodeCurrent(lat, lng)
                } else {
                    vm.locationUnavailable()
                }
            }
        }
    }

    GlassScrollPage(title = "发现", status = status, error = error) {
        Text("同城/附近能力（列表模式，地图接口已接入）")
        StarryPrimaryButton(text = "获取当前位置", loading = locating, onClick = {
            val granted = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            if (granted) {
                requestCurrentLocation(context) { lat, lng ->
                    if (lat != null && lng != null) {
                        vm.reverseGeocodeCurrent(lat, lng)
                    } else {
                        vm.locationUnavailable()
                    }
                }
            } else {
                launcher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
            }
        })
        Text(
            currentPlace?.let {
                "当前位置：${it.name} (${it.location.lat}, ${it.location.lng})"
            } ?: "当前位置：未获取"
        )
        StarryTextField(value = query, onValueChange = { query = it }, label = "搜索地点（用于同城/附近）")
        StarrySecondaryButton(text = "搜索地点", loading = searching, onClick = { vm.searchPlaces(query) })
        StarrySecondaryButton(text = "打开内置百度地图选点", onClick = onOpenMapPicker)
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            places.take(20).forEach { p ->
                StarryListItemCard(text = "${p.name} ${p.city}${p.district} (${p.location.lat}, ${p.location.lng})")
            }
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
        if (loc != null) {
            onResult(loc.latitude, loc.longitude)
        } else {
            requestSystemCurrentLocation(context, onResult)
        }
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
                        if (netLoc != null) {
                            onResult(netLoc.latitude, netLoc.longitude)
                        } else {
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
