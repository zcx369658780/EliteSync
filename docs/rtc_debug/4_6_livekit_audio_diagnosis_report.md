# 4.6 LiveKit 真语音诊断报告

更新时间：2026-04-23

## 1. 结论先行

当前证据更像是 **publish / subscribe 链路问题**，而不是单纯的页面 UI 问题或播放路由问题。

更具体地说：

- `RtcLiveKitService` 已经把 `room.connect()`、`startAudio()`、`setSpeakerOn(true)`、`setMicrophoneEnabled(true)` 接上了
- 页面也已经把 `remoteAudioTrack` 绑定到了频谱组件
- 但当前页面仍长期停留在“等待远端音轨…”
- 我抓到的 emulator 侧 logcat 里，没有出现可用于闭合真语音的关键 LiveKit 音轨事件：
  - `RTC_LIVEKIT_TRACK_SUBSCRIBED`
  - `RTC_LIVEKIT_AUDIO_PLAYBACK`
  - `RTC_LIVEKIT_REMOTE_AUDIO_REFRESH`

因此，最可能的故障点在：

1. 本地音频轨道没有真正 publish 成功，或没有形成可被对端订阅的音频 publication
2. 对端没有真正 subscribe 到音频 publication / `publication.track` 仍为空

相比之下，**页面绑定层**的概率较低，因为：

- `RtcLiveKitService` 是 `ChangeNotifier`
- `RtcCallPage` 正在 `watch` 该 service
- `RtcAudioSpectrumBar` 直接消费 `remoteAudioTrack`

如果 `remoteAudioTrack` 真有值，页面理论上应当能重建并从“等待远端音轨…”切换到波形态。

### 目前仍无法最终判断的原因

本轮环境里 **没有连接物理真机**，只看到一个模拟器设备：

- `emulator-5556`

因此，用户要求的两组验证：

- A. 真机发起 / 模拟器接听
- B. 模拟器发起 / 真机接听

**都无法在当前环境内完整完成**。  
这意味着：

- 可以判断“状态机已闭合、真语音未闭合”
- 不能最终区分“publish 侧失败”还是“subscribe 侧失败”

---

## 2. 环境与测试矩阵

### 运行环境

- Flutter：`Flutter 3.43.0-0.3.pre`
- Dart：`3.12.0`
- livekit_client：`2.7.0`
- Android Emulator：`sdk_gphone64_x86_64`
- Android 版本：`16`
- SDK Level：`36`

### 设备可用性

- 当前可见设备：`emulator-5556`
- 未检测到连接中的物理 Android 手机

### 测试矩阵

| 方向 | 状态 | 备注 |
|---|---|---|
| 真机发起 / 模拟器接听 | 未完成 | 当前环境没有物理真机 |
| 模拟器发起 / 真机接听 | 未完成 | 当前环境没有物理真机 |
| 模拟器内 RTC 状态机 | 已验证 | 呼叫状态可走到 created -> accepted -> connected -> ended |
| 模拟器侧 LiveKit 语音可视化 | 未闭合 | 页面仍停留在“等待远端音轨…” |

---

## 3. 双端身份与房间一致性检查

### 已确认的后端身份模型

后端 `LiveKitTokenService` 生成的 join-info：

- `identity = rtc-user-{userId}`
- `room = rtc_sessions.room_key`
- token 允许：
  - `roomJoin`
  - `canPublish`
  - `canSubscribe`

相关实现位置：

- [`services/backend-laravel/app/Services/LiveKitTokenService.php`](../../services/backend-laravel/app/Services/LiveKitTokenService.php)
- [`services/backend-laravel/app/Http/Controllers/Api/V1/RtcController.php`](../../services/backend-laravel/app/Http/Controllers/Api/V1/RtcController.php)

### 目前可以确认的点

- join-info 逻辑本身允许发布和订阅
- RTC 呼叫状态机和 room_key 由服务端统一管理
- 当前页面观察到的症状不是“未进房间”，而是“进房后没有远端音轨”

### 仍需双端真机证据才能彻底确认的点

- 两端是否真的使用不同 participant identity
- 两端是否真的加入了同一个 room
- 是否存在同 identity 重复登录导致的轨道覆盖 / 互踢

由于缺少物理真机，本轮无法把这些问题最终排除。

---

## 4. 本地 publish 结果

### 代码层已做的事情

`RtcLiveKitService.ensureConnected()` 中已经显式执行：

- `await room.connect(info.url, info.token)`
- `await room.startAudio()`
- `await room.setSpeakerOn(true)`
- `await room.localParticipant?.setMicrophoneEnabled(true)`

相关实现位置：

- [`apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart`](../../apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart)

### 当前证据不足之处

在本轮抓到的 logcat 中，没有看到可以证明 local publish 已成功的关键信号，例如：

- `RTC_LIVEKIT_TRACK_PUBLISHED`
- `RTC_LIVEKIT_TRACK_SUBSCRIBED`
- `RTC_LIVEKIT_AUDIO_PLAYBACK`

因此，**本地 publish 是否真的生成了可用 audio publication，当前还不能直接从日志闭合**。

### 初步判断

如果两端都完全没有波形、也没有远端轨道，那更像是：

- local microphone track 没有稳定 publish 出去
  或
- publish 出去了，但 subscriber 没拿到可用的 audio publication

这一步仍是本轮的首要怀疑对象。

---

## 5. 远端 subscribe 结果

### 代码层的订阅路径

`RtcLiveKitService` 当前的订阅逻辑是：

- 监听 `TrackSubscribedEvent`
- 监听 `ParticipantConnectedEvent` / `TrackPublishedEvent` / `ParticipantStateUpdatedEvent`
- 通过 `_refreshRemoteAudioTrack(room)` 扫描：
  - `room.remoteParticipants.values`
  - `participant.audioTrackPublications`
  - `publication.subscribed == true`
  - `publication.track != null`

相关实现位置：

- [`apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart`](../../apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart)

### 当前现象

- 频谱组件仍显示“等待远端音轨…”
- emulator 侧 logcat 中未捕获到：
  - `RTC_LIVEKIT_TRACK_SUBSCRIBED`
  - `RTC_LIVEKIT_TRACK_SUBSCRIBE_FAILED`
  - `RTC_LIVEKIT_REMOTE_AUDIO_REFRESH`

### 初步判断

这说明远端订阅链至少有一段没有闭合：

- 要么远端 participant 根本没看到音频 publication
- 要么 publication 看到了，但 `subscribed == true` / `track != null` 没到位
- 要么 `TrackSubscribedEvent` 根本没触发

当前证据更偏向 **subscribe 侧没有真正闭合**，但因为缺少真机双端日志，publish 和 subscribe 还不能完全拆开。

---

## 6. 页面绑定结果

### 绑定链路

`RtcCallPage` 现在是这样消费音轨的：

- `final liveKitService = ref.watch(rtcLiveKitServiceProvider);`
- 将 `liveKitService.remoteAudioTrack` 传给 `RtcAudioSpectrumBar`

相关实现位置：

- [`apps/flutter_elitesync_module/lib/features/rtc/presentation/pages/rtc_call_page.dart`](../../apps/flutter_elitesync_module/lib/features/rtc/presentation/pages/rtc_call_page.dart)
- [`apps/flutter_elitesync_module/lib/features/rtc/presentation/widgets/rtc_audio_spectrum_bar.dart`](../../apps/flutter_elitesync_module/lib/features/rtc/presentation/widgets/rtc_audio_spectrum_bar.dart)
- [`apps/flutter_elitesync_module/lib/features/rtc/presentation/providers/rtc_providers.dart`](../../apps/flutter_elitesync_module/lib/features/rtc/presentation/providers/rtc_providers.dart)

### 绑定层的判断

因为 service 已经是 `ChangeNotifierProvider`，并且页面在 `watch` 它，**只要 `_remoteAudioTrack` 真正被赋值，页面应当自动 rebuild**。

所以：

- 页面绑定层不像是主要卡点
- 更可能是上游音轨一直没有变成非空

### 当前页面状态

`RtcAudioSpectrumBar` 的文案仍然停在：

- `等待远端音轨…`

这意味着：

- 不是“拿到了 track 但没显示”
- 而是“track 根本没到页面这一层”更符合现象

---

## 7. 最可能的根因排序

### Top 1：publish 侧没有产生可被对端订阅的有效音频轨道

理由：

- 没看到 `TrackPublished` / `TrackSubscribed` / `AudioPlayback` 关键日志
- 双端都没有波形
- 页面一直卡在等待远端音轨
- `setMicrophoneEnabled(true)` 被调用了，但没有进一步的音轨闭环证据

### Top 2：subscribe 侧没有把 remote audio publication 绑定成 `remoteAudioTrack`

理由：

- service 的扫描逻辑依赖 `publication.subscribed && publication.track != null`
- 当前没有任何满足这条链路的日志
- 页面状态说明 UI 绑定到的源一直是 null

### Top 3：音频播放路由 / 设备输入输出链路有问题

理由：

- 即使加入房间、状态机正常，也可能因为设备音频输出路由 / 麦克风采样 / 模拟器音频能力导致“看似通话正常但没有声音”

### Top 4：模拟器能力限制或环境差异

理由：

- 当前只有 emulator 证据，没有物理真机
- 音频输入 / 输出在模拟器上的行为比真机更不稳定

---

## 8. 最小修复建议

只建议做最小诊断修复，不建议重构 RTC 架构。

### 建议 1：把 local publish 与 remote subscribe 的调试日志补全

继续补最小 instrumentation，记录：

- `localParticipant.audioTrackPublications` 数量
- 每条 publication 的 `sid / source / muted / enabled / track`
- `room.remoteParticipants` 的 participant identity
- 每条 remote publication 的 `subscribed / track / kind / source`

### 建议 2：在两端分别确认 track 是否真的非空

只需确认：

- 本端是否真的 publish 出了 audio publication
- 对端是否真的收到了 remote audio publication

如果本端没有 publication：

- 优先查 microphone capture / permission / device audio

如果本端有 publication、对端没有：

- 优先查 subscribe / room / identity / token / route 绑定

### 建议 3：如果模拟器不稳定，改用“真机 + 真机”或“真机 + 模拟器”再确认

当前最稳妥的结论是：

- RTC 状态机已可用
- 真语音链路未闭合
- 现在缺少真机双向证据，无法最终判死 publish 还是 subscribe

---

## 附：本轮可确认的状态

- 呼叫状态机：已通
- LiveKit join-info：已通
- 语音入口 / 来电页 / 通话页：已通
- 真语音 publish / subscribe / playback：未闭合
- 页面频谱：仍停在等待远端音轨
- 双向真机诊断：未完成

