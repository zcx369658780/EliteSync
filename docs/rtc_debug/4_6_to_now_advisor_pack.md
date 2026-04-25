# EliteSync 4.6 RTC 真语音开发总包
更新时间：2026-04-24

## 1. 当前状态

当前 4.6 线已经推进到“状态机完成、LiveKit 接入完成、连接层基本闭合，但真实音频仍未打通”的阶段。

已经成立的部分：

- 1v1 语音优先 RTC 主链已跑通
- 呼叫 / 接听 / 连接 / 挂断 / 结果页已成立
- LiveKit join-info 已接入
- 云端 LiveKit 入口 / `/rtc/validate` 代理链已修正
- 真机 + 模拟器双端都能建立通话状态
- 后端能看到 heartbeat
- 后端也能看到音频帧进入诊断链

仍未闭合的部分：

- 真机端没有音频帧
- 模拟器端有音频帧，但没有波形 / 没有可听声音
- 音频输出链路仍未闭合
- 当前更像是 playback / routing / native audio path 问题，而不是单纯状态机问题

当前建议归档口径：

- `pass with observations`
- 中文口径：`状态机通过，真语音仍未闭合`

---

## 2. 4.6 开发脉络

### 4.6A：RTC 最小闭环起步

目标：

- 建立 1v1 语音优先 RTC 的最小状态机
- 先把呼叫、接听、结束这些状态闭合

主要内容：

- 后端 RTC 会话骨架
- Flutter RTC 页面壳层
- join-info 接口
- 通话结果页 / 来电页 / 通话页基础结构

关键产物：

- `docs/version_plans/4.6A_EXECUTION_NOTE.md`
- `docs/version_plans/4.6A_ACCEPTANCE_SUMMARY.md`
- `docs/version_plans/4.6A_HANDOFF_NOTE.md`

### 4.6B / 4.6C / 4.6D：通话壳层完善

目标：

- 来电页、结果页、权限页、恢复页补齐
- 把通话状态机前后端链路跑顺

主要内容：

- 来电唤起
- 接听 / 拒绝 / 挂断
- 权限引导
- 通话终态回流

关键产物：

- `docs/version_plans/4.6B_ACCEPTANCE_SUMMARY.md`
- `docs/version_plans/4.6C_ACCEPTANCE_SUMMARY.md`
- `docs/version_plans/4.6D_ACCEPTANCE_SUMMARY.md`

### 4.6F：LiveKit 真语音接入

目标：

- 把 RTC 状态机接到 LiveKit 真语音媒体层

主要内容：

- LiveKit 自托管接入
- `Room.connect()`
- join-info / token / room / identity
- heartbeat
- 音轨订阅、频谱诊断
- speaker / microphone 路由

关键产物：

- `docs/version_plans/4.6F_EXECUTION_NOTE.md`
- `docs/version_plans/4.6F_ACCEPTANCE_SUMMARY.md`
- `docs/version_plans/4.6F_LIVEKIT_LIVE_TEST_RUNBOOK.md`

### 4.6G：真机补充诊断

目标：

- 用真机 + 模拟器双向验证 publish / subscribe / playback / route 的问题位置

主要结论：

- 不是纯 UI
- 不是纯状态机
- 问题从“publish / subscribe 大致可疑”进一步缩小为 LiveKit 信令 / 连接层 / 音频输出链路

关键产物：

- `docs/rtc_debug/4_6G_true_device_audio_diagnosis_report.md`
- `docs/rtc_debug/4_6G_true_device_audio_raw_logs.md`
- `docs/rtc_debug/4_6G_phone_logcat_excerpt.md`
- `docs/rtc_debug/4_6G_emulator_logcat_excerpt.md`

### 4.6H：云端连接层排障

目标：

- 修正 LiveKit 公网入口 / validate 路径 / nginx 代理 / 协议入口

主要结论：

- 从直连 `:7880` 改为 `/rtc/` 代理入口
- `http://101.133.161.203/rtc/validate?...` 已能返回 `401`
- 云端入口层已修正，但音频链仍未闭合

关键产物：

- `docs/rtc_debug/4_6H_livekit_connectivity_report.md`
- `docs/rtc_debug/4_6H_livekit_fix_note.md`
- `docs/rtc_debug/4_6H_post_fix_validation.md`

---

## 3. 当前算法说明

### 3.1 状态机

当前 RTC 主链由后端状态机驱动：

- `rtc_sessions`
- `rtc_session_events`
- 状态：`created -> calling -> ringing -> accepted -> connecting -> in_call -> ended / failed`

状态机负责：

- 呼叫发起
- 接听 / 拒绝
- 挂断
- 终态回收
- heartbeat 过期收口

### 3.2 LiveKit 媒体层

Flutter 在状态进入 `connecting / in_call` 后会：

- 请求 `/api/v1/rtc/calls/{callId}/livekit`
- 读取 `url / token / room / identity`
- 调用 `room.connect()`
- 调用 `room.startAudio()`
- 调用 `room.setSpeakerOn(true)`
- 调用 `localParticipant.setMicrophoneEnabled(true)`

### 3.3 音轨诊断层

当前页面上有诊断用音频频谱条：

- 有远端音轨时，尝试显示 PCM 波形
- 无远端音轨时，显示“等待远端音轨…”

该组件只用于诊断，不参与业务状态机。

---

## 4. 当前问题定义

当前真实问题不是“能不能建立通话”，而是：

- heartbeat 已经能看到
- 音频帧也已经能看到
- 但**仍然听不到声音**

两端现象已经分化为：

- **模拟器**：能看到音轨帧，但没有波形、没有声音
- **真机**：连音频帧都没有

说明问题更像：

- 真机 / 模拟器路径差异
- remote audio track 的稳定绑定问题
- Android 音频输出路由问题
- LiveKit 媒体播放链路问题

而不是单纯的状态机或页面 UI 问题。

---

## 5. 证据与截图

### 当前现场截图

以下截图是当前已经抓到的真实设备状态：

- `docs/rtc_debug/assets/4.6_current/phone_messages_current.png`
- `docs/rtc_debug/assets/4.6_current/emulator_call_ended_current.png`

### 历史诊断截图

之前已归档的音频诊断截图：

- `docs/version_plans/assets/4.6F/4_6F_audio_waiting_call_page.png`

### 日志类证据

当前关键日志文件：

- `docs/rtc_debug/phone_full_logcat.txt`
- `docs/rtc_debug/emulator_full_logcat.txt`
- `docs/rtc_debug/phone_rtc_excerpt.txt`
- `docs/rtc_debug/emulator_rtc_excerpt.txt`

### 关键后端日志文件

- `docs/rtc_debug/4_6H_livekit_connectivity_raw_notes.md`
- `docs/rtc_debug/4_6G_true_device_audio_raw_logs.md`

---

## 6. 这条线已经确认的事情

1. `Room.connect()` 不再卡在最早那种直连 `:7880` 的入口错误上。
2. 云端 LiveKit `/rtc/validate` 链路已经可达。
3. heartbeat 机制已运行。
4. 真机和模拟器都已能走到通话页面。
5. 音轨帧 / 诊断链已能在模拟器侧观察到一部分。
6. 但**音频播放仍未闭合**。

---

## 7. 给顾问的判断建议

如果要给出当前版本的判断，我建议写成：

> `4.6` 已完成 RTC 状态机与 LiveKit 接入骨架，连接层也已修正到可达，但真实音频输出仍未闭合。  
> 当前版本更适合判为 `pass with observations`，观察项集中在音频播放 / 路由 / 设备差异上。

---

## 8. 下一步建议

不要再扩：

- 不要继续扩 UI
- 不要重写 RTC 架构
- 不要盲换 RTC 库
- 不要把这轮继续扩成多人 / 视频 / 社区 / 在线状态平台

如果后续继续修，优先级应是：

1. 音频播放链路
2. Android 音频路由
3. 真机 / 模拟器差异
4. 远端音轨绑定与播放状态日志

