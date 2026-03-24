package com.elitesync.ui.screens

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import com.elitesync.ui.AppViewModel
import com.elitesync.ui.components.GlassScrollPage
import com.elitesync.ui.components.StarryListItemCard
import com.elitesync.ui.components.StarryPrimaryButton
import com.elitesync.ui.components.StarrySectionCard
import com.elitesync.ui.components.StarrySecondaryButton
import com.elitesync.ui.components.StarryTextField
import kotlinx.coroutines.launch
import kotlin.math.max
import kotlin.math.min

@Composable
fun ProfileInsightsScreen(vm: AppViewModel, onOpenMbtiQuiz: () -> Unit) {
    val birthday by vm.currentUserBirthday.collectAsState()
    val birthTime by vm.insightsBirthTime.collectAsState()
    val mbti by vm.insightsMbti.collectAsState()
    val birthQuery by vm.insightsBirthQuery.collectAsState()
    val astro by vm.insightsResult.collectAsState()
    val places by vm.placeResults.collectAsState()
    val birthPlace by vm.birthPlace.collectAsState()
    val status by vm.status.collectAsState()
    val error by vm.error.collectAsState()
    val searching = status.contains("地点搜索中")
    val computing = status.contains("画像计算")
    val scope = rememberCoroutineScope()
    var selectingPlace by remember { mutableStateOf(false) }
    val hideProgress = remember { Animatable(0f) }
    LaunchedEffect(Unit) {
        vm.loadMbtiResult()
    }
    GlassScrollPage(title = "扩展画像（算法版）", status = status, error = error) {
        StarrySectionCard(title = "输入参数") {
            Text("基于出生时间 + 出生地经纬度，计算星座 / 八字 / 基础星盘。")
            Text("生日（个人信息）：${if (birthday.isBlank()) "未填写，请到“我的-基础资料”补充" else birthday}")
            StarryTextField(value = birthTime, onValueChange = { vm.updateInsightsBirthTime(it) }, label = "出生时间（HH:mm）")
            StarryTextField(value = birthQuery, onValueChange = { vm.updateInsightsBirthQuery(it) }, label = "出生地搜索（城市/区县/地点）")
            StarrySecondaryButton(
                text = "搜索出生地",
                loading = searching,
                feedbackText = "正在搜索",
                onClick = { vm.searchPlaces(birthQuery) }
            )
            if (places.isNotEmpty()) {
                val visiblePlaces = places.take(10)
                val itemCount = visiblePlaces.size
                val step = if (itemCount <= 1) 1f else 0.45f / (itemCount - 1).toFloat()
                Column {
                    visiblePlaces.forEachIndexed { index, p ->
                        val fromBottom = itemCount - 1 - index
                        val start = fromBottom * step
                        val span = 0.55f
                        val localProgress = ((hideProgress.value - start) / span).coerceIn(0f, 1f)
                        val alpha = 1f - localProgress
                        val collapse = 1f - localProgress
                        StarryListItemCard(
                            text = "${p.name} ${p.city}${p.district}",
                            onClick = if (selectingPlace) null else {
                                {
                                    selectingPlace = true
                                    vm.setBirthPlace(p)
                                    scope.launch {
                                        hideProgress.snapTo(0f)
                                        hideProgress.animateTo(1f, animationSpec = tween(1000))
                                        vm.clearPlaceResults()
                                        hideProgress.snapTo(0f)
                                        selectingPlace = false
                                    }
                                }
                            },
                            modifier = Modifier
                                .graphicsLayer { this.alpha = alpha }
                                .height((56.dp + 4.dp) * max(0f, min(1f, collapse)))
                                .padding(vertical = 2.dp)
                        )
                    }
                }
            }
            Column {
                Text(
                    birthPlace?.let {
                        "已选出生地：${it.name} (${it.location.lat}, ${it.location.lng})"
                    } ?: "已选出生地：未选择"
                )
                StarrySecondaryButton(
                    text = "开始MBTI测试（3题）",
                    feedbackText = "进入测试",
                    onClick = onOpenMbtiQuiz
                )
                Text("当前MBTI：${if (mbti.isBlank()) "未测试" else mbti}")
                StarryPrimaryButton(
                    text = "计算星座/星盘/生辰八字",
                    loading = computing,
                    feedbackText = "开始计算",
                    onClick = { vm.computeAstroProfile() }
                )
            }
        }

        StarrySectionCard(title = "结果预览") {
        val a = astro
        if (a == null) {
            Text("- 星座：待计算")
            Text("- 生辰八字：待计算（依赖生日+时间+经纬度）")
            Text("- 星盘：待计算（太阳/月亮/上升）")
        } else {
            Text("- 太阳星座：${a.sunSign}")
            Text("- 月亮星座：${a.moonSign ?: "待计算"}")
            Text("- 上升星座：${a.ascSign ?: "待计算"}")
            Text("- 生辰八字：${a.bazi ?: "待计算"}")
            Text("- 真太阳时校正：${a.trueSolarTime ?: "未校正"}")
            Text("- 五行分析图谱")
            WuXingBars(a.wuXing)
            Text("- 大运（前8步）")
            a.daYun.forEach { d ->
                Text("  ${d.index}运 ${d.ganZhi} | ${d.startYear}-${d.endYear} | ${d.startAge}-${d.endAge}岁")
            }
            Text("- 流年（当前起10年）")
            a.liuNian.forEach { n ->
                Text("  ${n.year}年 ${n.ganZhi}（${n.age}岁）")
            }
            a.notes.forEach { n -> Text("提示：$n") }
        }
        Text("- MBTI：${if (mbti.isBlank()) "待填写" else mbti}")
        }
    }
}

@Composable
private fun WuXingBars(wuXing: Map<String, Int>) {
    val order = listOf("木", "火", "土", "金", "水")
    val max = (wuXing.values.maxOrNull() ?: 1).coerceAtLeast(1)
    val colorMap = mapOf(
        "木" to Color(0xFF5FB878),
        "火" to Color(0xFFFF6B6B),
        "土" to Color(0xFFB08B57),
        "金" to Color(0xFFD7C27A),
        "水" to Color(0xFF5AA9E6)
    )
    order.forEach { e ->
        val value = wuXing[e] ?: 0
        val ratio = value.toFloat() / max.toFloat()
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 2.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "$e $value",
                modifier = Modifier.width(56.dp)
            )
            Box(
                modifier = Modifier
                    .weight(1f)
                    .background(Color(0x332A2F4F))
                    .padding(1.dp)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(ratio)
                        .background(colorMap[e] ?: Color(0xFF8AA8FF))
                        .padding(vertical = 6.dp)
                )
            }
        }
    }
}
