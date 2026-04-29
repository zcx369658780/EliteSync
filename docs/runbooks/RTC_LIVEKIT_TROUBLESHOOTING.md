# RTC / LiveKit Troubleshooting Runbook

更新时间：2026-04-28

## 适用场景

当 RTC 通话出现以下任一现象时使用：

- 来电不弹；
- `Room.connect()` 超时；
- 通话能进但没有声音；
- `TrackSubscribed` 有，但波形不动；
- `heartbeat_timeout` 过早触发；
- 手机 / 模拟器双端表现不一致。

## 排查顺序

### 1. 先确认当前 call 的真值链

先看后端：

- `GET /api/v1/rtc/calls/{callId}`
- `GET /api/v1/rtc/calls/{callId}/livekit`

确认字段：

- `status`
- `mode`
- `call_key`
- `room_key`
- `initiator_user_id`
- `peer_user_id`
- `events`
- `initiator_last_seen_at`
- `peer_last_seen_at`
- `failure_code`
- `failure_message`

如果这里就 404 / 401 / 403，先修后端真值链，不要盯前端。

### 2. 看后端日志

重点关注：

- `rtc_call_created`
- `rtc_call_heartbeat`
- `rtc_livekit_join_info_requested`
- `heartbeat_timeout`

判断：

- join-info 是否真的发出；
- heartbeat 是否持续；
- call 是否被早退收口。

### 3. 看 Flutter / LiveKit 日志

重点看：

- `RTC_LIVEKIT_ROOM_CONNECT_START`
- `RTC_LIVEKIT_ROOM_CONNECT_OK`
- `RTC_LIVEKIT_ROOM_CONNECT_FAIL`
- `RTC_LIVEKIT_TRACK_SUBSCRIBED`
- `RTC_LIVEKIT_AUDIO_PLAYBACK_*`
- `RTC_LIVEKIT_REMOTE_AUDIO_STATS`
- `RTC_LIVEKIT_PEER_CONNECTION`

判断：

- 是卡在 connect；
- 还是 connect 成功但订阅失败；
- 还是订阅成功但播放链没闭合。

### 4. 分四层定位

#### A. Backend 层

看：

- `rtc_sessions`
- `rtc_session_events`
- `notifications`

问题通常是：

- call 真值未创建；
- session 状态不对；
- heartbeat 没有更新；
- call 被 `heartbeat_timeout` 收口。

#### B. Signaling / Room 层

看：

- `room.connect()` 是否成功；
- `RTC_LIVEKIT_PEER_CONNECTION` 中 connection / ice / signaling 状态；
- `RTC_LIVEKIT_ROOM_CONNECT_FAIL` 的错误信息。

问题通常是：

- LiveKit URL 不对；
- 域名 / 协议 / 证书不匹配；
- UDP / TURN 未通；
- 服务器安全组没放行。

#### C. Subscribe / Track 层

看：

- `RTC_LIVEKIT_TRACK_SUBSCRIBED`
- `RTC_LIVEKIT_REMOTE_PARTICIPANT`
- `RTC_LIVEKIT_REMOTE_AUDIO_REFRESH`

问题通常是：

- 没有 audio publication；
- 订阅时机丢失；
- track 被刷新逻辑覆盖；
- 手机 / 模拟器一端没真正拿到远端音轨。

#### D. Playback / Route 层

看：

- `RTC_LIVEKIT_AUDIO_ROUTE`
- `RTC_LIVEKIT_AUDIO_PLAYBACK_START`
- `RTC_LIVEKIT_AUDIO_PLAYBACK_READY`
- `RTC_LIVEKIT_AUDIO_FRAME`
- `RTC_LIVEKIT_REMOTE_AUDIO_STATS`

问题通常是：

- 帧来了但都是静音；
- `startAudio()` 未真正生效；
- 扬声器路由失败；
- 设备音频焦点 / 模拟器权限问题。

## 经验判断

### 如果 `TrackSubscribed` 没出现

优先查：

- join-info 是否正确；
- room.connect 是否稳定；
- 远端是否真的 publish 了音轨。

### 如果 `TrackSubscribed` 有，但 `AUDIO_FRAME` 一直是 0

优先查：

- 远端是否是静音帧；
- 本地 route / playback 是否没闭合；
- `room.startAudio()` / `setSpeakerOn()` 调用顺序。

### 如果双端一边正常一边不正常

优先查：

- 设备麦克风权限；
- 模拟器网络；
- 是否某一端的 `remoteAudioTrack` 被刷新逻辑误清空；
- `PeerConnection` 是否一直停在 `Checking`。

### 如果通话会在几十秒后自动断掉

优先查：

- heartbeat timer 是否启动；
- 前端是否继续发 heartbeat；
- 后端是否把 `heartbeat_timeout` 提前触发。

## 可执行最小步骤

1. 记下 `call_id`；
2. 查 `/api/v1/rtc/calls/{callId}` 和 `/livekit`；
3. 查后端 `rtc_call_*` 日志；
4. 查 Flutter `RTC_LIVEKIT_*` 日志；
5. 只在明确卡在媒体路径时，再查 UDP / TURN / 安全组；
6. 不要先重写 UI，也不要 repo 级回滚。

## 需要保留的边界

- UI protected surfaces 不动；
- 不用截图代替日志；
- 不把通知或消息的 UI 文案降噪误改为 RTC 主链；
- 不在没有 blocker report 的情况下做大范围恢复。

## 结论

这个 runbook 的目的，是在 RTC 问题再次出现时，先把它缩到 backend / signaling / subscribe / playback 里的某一层，再决定最小修复，而不是直接猜测或整仓恢复。
