package com.elitesync.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.baidu.mapapi.map.BaiduMap
import com.baidu.mapapi.map.DotOptions
import com.baidu.mapapi.map.MapStatusUpdateFactory
import com.baidu.mapapi.map.MapView
import com.baidu.mapapi.model.LatLng
import com.elitesync.ui.components.StarryBackButton
import com.elitesync.ui.components.StarryPrimaryButton

@Composable
fun BaiduMapPickerScreen(
    title: String,
    initialLat: Double? = null,
    initialLng: Double? = null,
    onBack: () -> Unit,
    onConfirm: (lat: Double, lng: Double) -> Unit
) {
    var selected by remember { mutableStateOf<LatLng?>(null) }
    var mapViewRef by remember { mutableStateOf<MapView?>(null) }
    val lifecycleOwner = LocalLifecycleOwner.current
    val scrollState = rememberScrollState()

    DisposableEffect(lifecycleOwner, mapViewRef) {
        val observer = LifecycleEventObserver { _, event ->
            val mv = mapViewRef ?: return@LifecycleEventObserver
            when (event) {
                Lifecycle.Event.ON_RESUME -> mv.onResume()
                Lifecycle.Event.ON_PAUSE -> mv.onPause()
                Lifecycle.Event.ON_DESTROY -> mv.onDestroy()
                else -> Unit
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(horizontal = 16.dp, vertical = 12.dp)
            .imePadding()
            .navigationBarsPadding(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(title)
        Text("点击地图选择位置，点击确认后回填经纬度。")
        AndroidView(
            modifier = Modifier
                .fillMaxWidth()
                .height(420.dp),
            factory = { context ->
                MapView(context).apply {
                    mapViewRef = this
                    val map = this.map
                    map.uiSettings.isCompassEnabled = true
                    val center = if (initialLat != null && initialLng != null) {
                        LatLng(initialLat, initialLng)
                    } else {
                        LatLng(39.915, 116.404)
                    }
                    val zoom = if (initialLat != null && initialLng != null) 14f else 11f
                    map.setMapStatus(MapStatusUpdateFactory.newLatLngZoom(center, zoom))
                    map.setOnMapClickListener(object : BaiduMap.OnMapClickListener {
                        override fun onMapClick(point: LatLng) {
                            selected = point
                            map.clear()
                            map.addOverlay(
                                DotOptions()
                                    .center(point)
                                    .radius(14)
                                    .color(0xCC1E88E5.toInt())
                            )
                        }

                        override fun onMapPoiClick(mapPoi: com.baidu.mapapi.map.MapPoi) {
                            selected = mapPoi.position
                            map.clear()
                            map.addOverlay(
                                DotOptions()
                                    .center(mapPoi.position)
                                    .radius(14)
                                    .color(0xCC1E88E5.toInt())
                            )
                        }
                    })
                }
            }
        )
        Text(
            selected?.let { "已选：${it.latitude}, ${it.longitude}" } ?: "已选：无"
        )
        StarryBackButton(
            text = "返回",
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 6.dp),
            onClick = onBack
        )
        StarryPrimaryButton(
            text = "确认使用该位置",
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp),
            enabled = selected != null,
            onClick = {
                val point = selected ?: return@StarryPrimaryButton
                onConfirm(point.latitude, point.longitude)
            }
        )
    }
}
