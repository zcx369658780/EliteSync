# 4.6A LiveKit 连接层排障报告

更新时间：2026-04-23

## 1. 结论先行

当前更像是：

- `Room.connect()` 的 fresh 复验仍未完成
- 设备侧前台 / 解锁状态干扰了复验
- 客户端没有稳定进入可观察的 `TrackPublished / TrackSubscribed / AudioPlayback` 阶段

目前**没有新的证据**表明根因已经转移到 `publish` 或 `subscribe` 深层音频链。
本轮抓到的最新证据更支持以下判断：

- 云端 LiveKit 入口已从旧的公网直连 `:7880` 收缩到公网根 host + `/rtc/` 反代
- `POST /api/v1/rtc/calls` 与 `GET /api/v1/rtc/calls/{callId}/livekit` 已可正常返回
- 但真机 / 模拟器的 fresh connect 复验仍未形成稳定、可重复、可前台观察的闭环

因此当前 4.6A 的状态应继续写作：

> `conditional pass`
> 中文口径：连接层最小修复已落地，但 fresh connect 复验仍待完成

## 2. 设备与测试矩阵

### 设备

- 真机：
  - serial：`TG9L8HOBKFMJZTZX`
- 模拟器：
  - serial：`emulator-5556`

### 账号

- `17094346566` / `test1` / user id `7`
- `13772423130` / `华霜魂` / user id `8`

### 运行时

- Flutter 版本：以当前仓库已安装版本为准
- livekit_client 版本：以 `pubspec.lock` 中当前锁定版本为准

### 双向矩阵

| 方向 | 当前结果 | 说明 |
|---|---|---|
| 真机 -> 模拟器 | 未完成 fresh connect 复验 | 设备前台/解锁状态未能稳定确认 |
| 模拟器 -> 真机 | 未完成 fresh connect 复验 | 真机屏幕仍无法稳定进入可交互前台 |

## 3. 真机 adb 可用性

### 可用性结论

- `adb devices` 可识别真机 serial：`TG9L8HOBKFMJZTZX`
- `adb devices` 同时可识别模拟器 serial：`emulator-5556`
- 但物理手机的屏幕状态未能通过 adb 强制切到可见前台
- `adb shell input keyevent` 在真机侧返回 `SecurityException: Injecting input events requires ... INJECT_EVENTS permission`

### 尝试过的最小动作

- `adb -s TG9L8HOBKFMJZTZX shell am start -n com.elitesync/.MainActivity`
- `adb -s TG9L8HOBKFMJZTZX shell wm dismiss-keyguard`

结论：

- activity 确实被投递到运行中的顶层实例
- 但截屏仍为黑屏，说明真机仍未进入可稳定观测的 UI 前台

## 4. 双端 identity / room 一致性

### 当前呼叫

- `call_id = 55`
- `call_key = b02cab1f-dc86-49ab-b5d6-b30f06bebc7b`
- `room_key = 7_8`
- `mode = voice`
- `status = calling`

### 账号 / identity

- 发起方：`user 7` / `rtc-user-7`
- 接收方：`user 8` / `rtc-user-8`

### 结论

- 两端 identity 仍然是唯一的
- room 一致
- 当前没有 evidence 指向 identity 冲突

## 5. 本地 publish 结果

### 当前可确认

- 目前没有抓到一轮 fresh connect 后的有效 `local audio publication` 证据
- 因为没有稳定完成可见的前台接听 / 入房复验

### 当前不能确认

- `setMicrophoneEnabled(true)` 后是否真的生成了稳定的 `localParticipant.audioTrackPublications`
- `publication.track` 是否非空
- 真正的 publish 是否在最新一轮完全成立

### 倾向判断

- 当前不支持把根因判成纯 publish 失败
- publish 更像是“还没进入足够干净、可重复的验证阶段”

## 6. 远端 subscribe 结果

### 当前可确认

- 当前最新一轮没有拿到稳定的 `TrackSubscribed` / `remoteAudioTrack` 非空证据
- 在最新 logcat 摘要中，没有出现可用于确认音频阶段闭环的 Flutter 侧 LiveKit 日志

### 当前不能确认

- `TrackSubscribedEvent` 是否稳定触发
- `publication.subscribed` 是否稳定为 true
- `publication.track` 是否非空

### 倾向判断

- 当前也不能判死为纯 subscribe 失败
- 更像是 fresh connect 复验未完成导致 publish / subscribe 无法进入稳定观察阶段

## 7. 页面绑定结果

### 当前可确认

- 目前没有拿到 `remoteAudioTrack` 稳定变成非空的证据
- 音频频谱仍然无法进入波形状态

### 当前不能确认

- 绑定失败
- 播放路由失败
- 还是根本没有进入 remote track 产生阶段

### 结论

- 目前页面绑定层不是首要怀疑对象
- 现阶段仍需先把 fresh connect 的设备侧复验补完整

## 8. 根因排序

按当前最新证据，最可能的根因排序为：

1. **设备侧 fresh connect 复验不完整**
   - 真机屏幕仍无法稳定进入可见前台
   - 无法对接听页 / 通话页做稳定现场验证

2. **publish / subscribe 链路尚未进入可观察闭环**
   - 没有 fresh connect 后的有效 track/track subscription 证据

3. **页面绑定与播放层仍缺少最终证据**
   - `remoteAudioTrack` 未见稳定非空
   - 频谱无法进入波形

## 9. 最小修复建议

只建议以下最小动作，不建议扩 UI 或重写 RTC 架构：

1. 先让真机进入稳定可见前台
2. 再做一轮干净重启后的双向 fresh connect
3. 在 fresh connect 成功后，继续观察 `TrackPublished / TrackSubscribed / remoteAudioTrack`
4. 若仍无音频，再把问题收窄到 publish / subscribe / playback 的其中一层

## 10. 是否建议进入 4.6A 修复回合

- **建议**：继续保留 `4.6A` 作为连接层修正版
- **不建议**：当前不要把 4.6A 升级成已完全通过
- **还需补什么**：
  - 真机可见前台
  - fresh connect 复验
  - publish / subscribe / playback 的最小证据链

