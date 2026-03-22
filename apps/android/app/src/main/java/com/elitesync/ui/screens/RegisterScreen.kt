package com.elitesync.ui.screens

import androidx.compose.foundation.layout.size
import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Spacer
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.elitesync.R
import com.elitesync.BuildConfig
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.RealtimeConstellationSky
import com.elitesync.ui.components.SkyPreset
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton
import com.elitesync.ui.components.StarryStatusBanner
import com.elitesync.ui.components.StarryTextField
import com.elitesync.ui.components.StatusTone
import com.elitesync.ui.components.rememberAnimatedGlobalStarPan
import com.elitesync.ui.components.starryPanGesture
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource

private const val PREFS_AUTH = "elitesync_auth_prefs"
private const val KEY_LAST_PHONE = "last_phone"
private const val KEY_LAST_PASSWORD = "last_password"
private const val KEY_LAST_SKY_LAT = "last_sky_lat"
private const val KEY_LAST_SKY_LNG = "last_sky_lng"
private val PHONE_REGEX = Regex("^1[3-9]\\d{9}$")
private val PASSWORD_REGEX = Regex("^(?=.*[A-Za-z])(?=.*\\d).{8,}$")

@Composable
fun RegisterScreen(vm: AppViewModel, onNext: (String) -> Unit) {
    val context = LocalContext.current
    val prefs = remember { context.getSharedPreferences(PREFS_AUTH, Context.MODE_PRIVATE) }
    var phone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var realnameVerified by remember { mutableStateOf(false) }
    var localError by remember { mutableStateOf("") }
    var showAuthPanel by remember { mutableStateOf(false) }
    var skyLat by remember { mutableStateOf(34.7466) }
    var skyLng by remember { mutableStateOf(113.6254) }
    var skyLocationText by remember { mutableStateOf("") }

    val isLoggedIn by vm.isLoggedIn.collectAsState()
    val questionnaireComplete by vm.questionnaireComplete.collectAsState()
    val questionnaireProgressLoaded by vm.questionnaireProgressLoaded.collectAsState()
    val liteMode by vm.litePerformanceMode.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    val appUpdateInfo by vm.appUpdateInfo.collectAsState()
    val scrollState = rememberScrollState()
    val (panX, panY) = rememberAnimatedGlobalStarPan()

    fun saveSkyLocation(lat: Double, lng: Double) {
        prefs.edit()
            .putString(KEY_LAST_SKY_LAT, lat.toString())
            .putString(KEY_LAST_SKY_LNG, lng.toString())
            .apply()
    }

    val locationLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            requestCurrentLocation(context) { lat, lng ->
                if (lat != null && lng != null) {
                    skyLat = lat
                    skyLng = lng
                    saveSkyLocation(lat, lng)
                    skyLocationText = ""
                } else {
                    skyLocationText = ""
                }
            }
        } else {
            skyLocationText = ""
        }
    }

    LaunchedEffect(Unit) {
        vm.checkAppUpdate()
        phone = prefs.getString(KEY_LAST_PHONE, "").orEmpty()
        password = prefs.getString(KEY_LAST_PASSWORD, "").orEmpty()
        val cachedLat = prefs.getString(KEY_LAST_SKY_LAT, null)?.toDoubleOrNull()
        val cachedLng = prefs.getString(KEY_LAST_SKY_LNG, null)?.toDoubleOrNull()

        if (cachedLat != null && cachedLng != null) {
            skyLat = cachedLat
            skyLng = cachedLng
            skyLocationText = ""
            return@LaunchedEffect
        }

        val granted = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            requestCurrentLocation(context) { lat, lng ->
                if (lat != null && lng != null) {
                    skyLat = lat
                    skyLng = lng
                    saveSkyLocation(lat, lng)
                    skyLocationText = ""
                } else {
                    skyLocationText = ""
                }
            }
        } else {
            locationLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        }
    }

    LaunchedEffect(status) {
        if (status == "注册成功，请登录" || status == "登录成功") {
            prefs.edit()
                .putString(KEY_LAST_PHONE, phone)
                .putString(KEY_LAST_PASSWORD, password)
                .apply()
        }
    }

    LaunchedEffect(isLoggedIn, questionnaireProgressLoaded, questionnaireComplete) {
        if (isLoggedIn && questionnaireProgressLoaded) {
            onNext(if (questionnaireComplete) "match" else "questionnaire")
        }
    }

    fun validateInput(rawPhone: String, rawPassword: String): String {
        if (!PHONE_REGEX.matches(rawPhone)) {
            return "手机号格式错误，请输入11位中国大陆手机号（如 13800138000）"
        }
        if (!PASSWORD_REGEX.matches(rawPassword)) {
            return "密码格式错误：至少8位，且必须包含字母和数字"
        }
        return ""
    }

    fun doRegister() {
        val normalizedPhone = phone.trim()
        val pwd = password.trim()
        localError = validateInput(normalizedPhone, pwd)
        if (localError.isNotBlank()) {
            vm.clearError()
            return
        }
        if (!realnameVerified) {
            localError = "请先通过实名认证（模拟）后再注册"
            vm.clearError()
            return
        }
        localError = ""
        phone = normalizedPhone
        password = pwd
        vm.register(normalizedPhone, pwd, null, true)
    }

    fun doLogin() {
        val normalizedPhone = phone.trim()
        val pwd = password.trim()
        localError = validateInput(normalizedPhone, pwd)
        if (localError.isNotBlank()) {
            vm.clearError()
            return
        }
        localError = ""
        phone = normalizedPhone
        password = pwd
        vm.login(normalizedPhone, pwd)
    }

    Box(modifier = Modifier.fillMaxSize().starryPanGesture()) {
        RealtimeConstellationSky(
            modifier = Modifier.fillMaxSize(),
            latitude = skyLat,
            longitude = skyLng,
            preset = SkyPreset.LOGIN,
            lowPerformanceMode = liteMode,
            panExternalX = panX,
            panExternalY = panY
        )

	Box(
		modifier = Modifier
			.fillMaxSize()
			.background(
				Brush.verticalGradient(
					listOf(
						Color(0x0802050D),
						Color(0x04060A14),
						Color(0x0C030710)
					)
				)
			)
	)

AnimatedVisibility(
    visible = !showAuthPanel,
    enter = fadeIn(),
    exit = fadeOut(),
    modifier = Modifier.fillMaxSize()
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .clickable { showAuthPanel = true },
        contentAlignment = Alignment.Center
    ) {
        // 中心净空/聚焦层：不是亮圈，而是帮助内容从背景里“浮出来”
        Box(
            modifier = Modifier
                .fillMaxWidth(0.86f)
                .fillMaxSize(0.46f)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            Color(0x120B1326),
                            Color(0x08070C18),
                            Color.Transparent
                        ),
                        radius = 520f
                    )
                )
        )

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter = painterResource(id = R.drawable.logo),
                    contentDescription = "慢约会 Logo",
                    contentScale = ContentScale.Fit,
                    modifier = Modifier.size(170.dp)
                )
            }
            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "慢约会",
                color = Color.White
            )
            Text(
                text = "在同一片星空下相遇",
                color = Color(0xFFC2D4FF)
            )
            Text(
                text = "点击进入",
                color = Color(0xFF93ACDE)
            )
        }
    }
}

        AnimatedVisibility(
            visible = showAuthPanel,
            enter = fadeIn() + slideInVertically(initialOffsetY = { it / 6 }),
            exit = fadeOut(),
            modifier = Modifier.fillMaxSize()
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
                    .verticalScroll(scrollState),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(6.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    val isRegisterLoading = status.contains("注册中")
                    val isLoginLoading = status.contains("登录中")
                    val phoneError = localError.contains("手机号格式错误")
                    val passwordError = localError.contains("密码格式错误")
                    Text("慢约会 登录/注册", color = Color.White)
                    Text("当前版本：${BuildConfig.VERSION_NAME}", color = Color(0xFFAAC2F2))
                    StarrySectionCard(title = "账号信息") {
                        StarryTextField(
                            value = phone,
                            onValueChange = { phone = it },
                            label = "手机号",
                            isError = phoneError,
                            errorMessage = if (phoneError) localError else null
                        )
                        StarryTextField(
                            value = password,
                            onValueChange = { password = it },
                            label = "密码",
                            isError = passwordError,
                            errorMessage = if (passwordError) localError else null,
                            isPassword = true
                        )
                        Text(
                            text = "账号规则：11位大陆手机号；密码至少8位且包含字母+数字。",
                            color = Color(0xFFAAC2F2)
                        )
                    }
                    StarrySectionCard(title = "认证与操作") {
                        StarrySecondaryButton(
                            text = if (realnameVerified) "实名认证（模拟）：已通过" else "实名认证（模拟）：点击通过",
                            onClick = {
                                realnameVerified = true
                                localError = ""
                            }
                        )
                        StarryPrimaryButton(text = "登录", onClick = { doLogin() }, loading = isLoginLoading)
                        StarrySecondaryButton(text = "注册", onClick = { doRegister() }, loading = isRegisterLoading)
                    }
                    val displayError = if (localError.isNotBlank()) localError else error
                    if (displayError.isNotBlank()) {
                        StarryStatusBanner(text = "错误：$displayError", tone = StatusTone.Error)
                    } else {
                        StarryStatusBanner(text = "状态：$status", tone = StatusTone.Info)
                    }
                }
            }
        }

        appUpdateInfo?.let { update ->
            AlertDialog(
                onDismissRequest = {
                    if (!update.force_update) vm.dismissAppUpdatePrompt()
                },
                title = { Text(if (update.force_update) "发现新版本（必须更新）" else "发现新版本") },
                text = {
                    Text(
                        buildString {
                            append("当前版本：${update.client_version_name}\n")
                            append("最新版本：${update.latest_version_name}\n")
                            if (update.changelog.isNotBlank()) {
                                append("\n更新内容：\n${update.changelog}")
                            }
                        }
                    )
                },
                confirmButton = {
                    TextButton(
                        onClick = {
                            runCatching {
                                context.startActivity(
                                    Intent(Intent.ACTION_VIEW, Uri.parse(update.download_url))
                                )
                            }
                        }
                    ) { Text("立即更新") }
                },
                dismissButton = if (!update.force_update) {
                    {
                        TextButton(onClick = { vm.dismissAppUpdatePrompt() }) { Text("稍后") }
                    }
                } else null
            )
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
