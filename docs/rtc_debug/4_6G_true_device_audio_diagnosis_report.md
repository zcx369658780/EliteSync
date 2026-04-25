# 4.6G 真机补充诊断报告

更新时间：2026-04-23

## 1. 结论先行

这轮补充诊断后，问题已经从“publish / subscribe 大致可疑”进一步缩小为：

- **更像 LiveKit signaling / validate 连接层问题**
- 其次才可能是 **LiveKit 服务端端口 / 代理 / 容器可达性问题**
- **不是纯 UI 绑定问题**
- **不是单独的播放路由问题**
- **publish / subscribe 目前并没有进入可完整观察的阶段**

关键证据是：

1. 真机和模拟器都能成功请求后端：
   - `POST /api/v1/rtc/calls/{callId}/connect`
   - `GET /api/v1/rtc/calls/{callId}/livekit`
2. 但在真正进入 LiveKit 房间时，`room.connect()` 失败：
   - 真机：`SocketException: Connection timed out`
   - 模拟器：`SocketException: Connection reset by peer`
3. 两端都失败在同一条 LiveKit validate 链路：
   - `http://101.133.161.203:7880/rtc/validate?...`
4. 因为 `Room.connect()` 没有完成，所以：
   - 本地 microphone audio publication 无法被完整确认
   - remote participant / publication / TrackSubscribed 也无法进入稳定观察阶段
   - `remoteAudioTrack` 仍然停留在空值，频谱页保持“等待远端音轨…”

因此，当前最合理的结论是：

> 当前阻断点不在页面绑定，而在 LiveKit signaling / validate 连接阶段。  
> 也就是说，真语音链路根本还没稳定完成“入房”，因此 publish / subscribe 证据不足，不能把根因继续主要归到 UI 或波形组件。

---

## 2. 环境与测试矩阵

### 环境

- Flutter：`3.43.0-0.3.pre`
- Dart：`3.12.0`
- `livekit_client`：`^2.7.0`
- Android 真机：`25060RK16C`
- Android 版本：`16`
- SDK：`36`
- Android 模拟器：`sdk_gphone64_x86_64`
- Android 版本：`16`
- SDK：`36`

### 设备可用性

`adb devices -l` 结果表明两台设备都在线：

- 真机 serial：`TG9L8HOBKFMJZTZX`
- 模拟器 serial：`emulator-5556`

### 双向测试矩阵

| 方向 | 结果 | 备注 |
|---|---|---|
| 真机发起 -> 模拟器接听 | 未闭合音频 | 两端都进入通话态，但 `Room.connect()` 在 LiveKit validate 失败 |
| 模拟器发起 -> 真机接听 | 未闭合音频 | 两端都进入通话态，但 `Room.connect()` 在 LiveKit validate 失败 |

两种方向都观察到同一类失败，因此这不是单方向设备差异可以解释的现象。

---

## 3. 真机 adb 可用性

### adb 识别情况

已成功识别到真机：

- `TG9L8HOBKFMJZTZX`

同时也识别到模拟器：

- `emulator-5556`

### 抓日志结果

本轮真机 adb 抓日志成功，且能拿到 EliteSync 进程级日志。

### 真机信息

- 型号：`25060RK16C`
- Android 版本：`16`
- SDK：`36`

### 结论

真机 adb 已可用，本轮诊断可信度高于之前只靠模拟器的版本。

---

## 4. 双端 identity / room 一致性

### 已确认的后端规则

后端 join-info 的身份规则仍然是：

- `identity = rtc-user-{userId}`
- `room = rtc_sessions.room_key`
- token 允许：
  - `roomJoin`
  - `canPublish`
  - `canSubscribe`

### 本轮可确认的点

- 两端拿到的后端 `call_id` / `livekit` 接口都成功返回 `200`
- 两端进入的是同一套 RTC 呼叫流程
- 没有看到同 identity 冲突导致的显式报错

### 仍欠缺的点

因为 `Room.connect()` 失败，LiveKit 房间侧没有真正建立成功，所以本轮无法在 LiveKit 侧最终确认：

- 两端 participant 是否都已稳定入房
- remoteParticipants 是否都可见
- identity 是否在房间内完全一致且无冲突

但从现有证据看，**identity / room 不像是主根因**；更大的问题是连接还没进入稳定房间态。

---

## 5. 本地 publish 结果

### 真机侧

日志中可见：

- `room.connect()` 前的后端接口请求成功
- `org.webrtc.Logging: NativeLibrary: Loading native library: jingle_peerconnection_so`
- `AudioSystem` / `AudioEffect` 已初始化

但在这之后，`Room.connect()` 报错：

- `ClientException with SocketException: Connection timed out`

因此本轮**无法确认本地 microphone audio publication 是否真正完成**。

### 模拟器侧

日志中可见：

- `room.connect()` 前的后端接口请求成功
- `org.webrtc.Logging: NativeLibrary: Loading native library: jingle_peerconnection_so`
- `AudioSystem` 已初始化

但在这之后，`Room.connect()` 报错：

- `ClientException: Connection reset by peer`

因此本轮**同样无法确认本地 microphone audio publication 是否真正完成**。

### 结论

当前更合理的判断是：

- 不是“publish 已确认成功但对端没订阅到”
- 而是 **publish 还没进入可稳定验证的阶段**

也就是说，publish / subscribe 目前都被更早的 signaling 层失败挡住了。

---

## 6. 远端 subscribe 结果

### 真机侧

本轮没有看到以下关键事件：

- `TrackSubscribed`
- `TrackUnsubscribed`
- `TrackPublished`
- `AudioPlayback`
- `RTC_LIVEKIT_TRACK_SUBSCRIBED`
- `RTC_LIVEKIT_AUDIO_PLAYBACK`

### 模拟器侧

同样没有看到以下关键事件：

- `TrackSubscribed`
- `TrackUnsubscribed`
- `TrackPublished`
- `AudioPlayback`
- `RTC_LIVEKIT_TRACK_SUBSCRIBED`
- `RTC_LIVEKIT_AUDIO_PLAYBACK`

### 结论

远端 subscribe 结果目前**无法成立**，原因不是 UI，而是 `Room.connect()` 本身失败，导致：

- 远端 participant / publication 观察不到
- `publication.subscribed` 观察不到
- `publication.track` 也无法进入稳定非空状态

---

## 7. 页面绑定结果

### 已确认的绑定链

代码层上，页面绑定链已经存在：

- `RtcLiveKitService` 是 `ChangeNotifier`
- `RtcCallPage` 监听该 service
- `RtcAudioSpectrumBar` 消费 `remoteAudioTrack`

### 这轮日志说明了什么

当前频谱页长期停在：

- `等待远端音轨…`

结合日志可知，这不是因为页面没有 rebuild，而是因为：

- `Room.connect()` 失败
- `remoteAudioTrack` 没有机会进入稳定非空状态
- 频谱卡片拿到的仍是空值

### 结论

页面绑定层不是第一根因。  
它更像是**被上游 LiveKit signaling 失败“饿死”了数据**。

---

## 8. 根因排序

### Top 1：LiveKit signaling / validate 连接失败

证据最强：

- 两端都在同一条 `http://101.133.161.203:7880/rtc/validate?...` 上失败
- 真机是 `Connection timed out`
- 模拟器是 `Connection reset by peer`
- 失败点都出现在 `SignalClient.connect -> Engine.connect -> Room.connect`

### Top 2：云端 LiveKit 服务 / 端口 / 代理链路不稳定

可能性高：

- 既然两端都失败，问题更像服务端可达性或代理配置
- 包括但不限于：
  - `7880` 端口暴露
  - 反向代理 / 容器网络
  - WebSocket / HTTP validate 路由
  - LiveKit 进程状态不稳定

### Top 3：设备侧网络环境差异或协议兼容问题

次要可能：

- 真机与模拟器的网络栈不同
- 但两端表现不同却同样失败，仍更像共同的服务端链路问题

### 相对不太像的方向

- UI 绑定问题
- `remoteAudioTrack` 赋值逻辑本身的问题
- 单纯的播放路由问题

因为这些问题都发生在 `Room.connect()` 成功之后，而当前还没进到那一步。

---

## 9. 最小修复建议

只给最小修复方向，不重设计 RTC 架构：

1. **优先检查云端 LiveKit 服务本身**
   - 重点看 `7880` 的对外可达性
   - 重点看 `validate` 链路是否稳定
   - 重点看 LiveKit 容器 / 代理日志

2. **验证从 PC / 手机直接访问 validate 链路**
   - 临时用 `curl` 或浏览器从不同网络侧测试
   - 确认不是某一类设备被路由挡住

3. **确认当前 `LIVEKIT_URL` 与实际部署协议一致**
   - 当前日志显示请求打到 `http://101.133.161.203:7880/rtc/validate`
   - 需要确认这条链路是 LiveKit 当前预期入口，而不是代理残留或协议错配

4. **在 Flutter 侧保留现有诊断日志**
   - 不扩 UI
   - 只保留 `Room.connect` / `TrackSubscribed` / `AudioPlayback` 的诊断输出

---

## 10. 是否建议进入 4.6G 修复回合

建议进入，但仅限于：

- 修复 LiveKit signaling / validate 连接可达性
- 修复云端 LiveKit 服务 / 代理 / 端口配置
- 修复后再做一次双向真机 + 模拟器联测

不建议现在直接：

- 重写 RTC 架构
- 继续做 UI 扩展
- 继续把问题归因到波形组件或页面绑定

如果下一轮还要修，应该叫做 **4.6G 最小修复回合**，范围只围绕：

- 让 `Room.connect()` 先稳定成功
- 然后再重新观察 publish / subscribe / track binding / playback

