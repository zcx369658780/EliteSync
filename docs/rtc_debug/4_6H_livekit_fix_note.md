# 4.6H LiveKit 连接层最小修复说明

更新时间：2026-04-23

## 修复目标

修复范围只限定在 **云端 LiveKit 连接入口**，不是 RTC UI，也不是 publish / subscribe 主链重写。

目标是把：

- `Room.connect()` 之前的 validate / signaling 入口打通

从而避免客户端直接碰 `:7880` 导致的 timeout / reset。

---

## 实际修复内容

### 1. backend `.env`

将 LiveKit 公网入口改为：

- 旧：`http://101.133.161.203:7880`
- 新：`http://101.133.161.203`

对应环境变量：

- `LIVEKIT_URL=http://101.133.161.203`

### 2. nginx 反代

新增：

- `/rtc/` -> `http://127.0.0.1:7880`

并保留：

- `Upgrade`
- `Connection`
- `Host`
- `X-Forwarded-*`
- 长超时

### 3. 验证

已经验证：

- `http://127.0.0.1/rtc/validate?...` 返回 `401 Unauthorized`
- `http://101.133.161.203/rtc/validate?...` 返回 `401 Unauthorized`

这意味着：

- 公网入口已修到 LiveKit
- validate 不再卡在直连 `:7880` 的外网失败

---

## 修复前症状

修复前，真机与模拟器在 `Room.connect()` 阶段分别出现：

- `Connection timed out`
- `Connection reset by peer`

失败目标集中在：

- `http://101.133.161.203:7880/rtc/validate?...`

---

## 修复后当前状态

修复后，云端入口已经可以响应 validate，说明：

- LiveKit 连接层入口已修复到可达
- 但设备侧仍需要一轮干净重启后重新验证 `Room.connect()` 是否已稳定进入成功态

---

## 不在本轮内的事

- 不改 RTC UI
- 不重写 4.6 架构
- 不换新 RTC 库
- 不扩视频 / 多人 / 直播
