# 4.6H LiveKit 连接层排障报告

更新时间：2026-04-23

## 1. 结论先行

本轮排障后，根因已经从“客户端页面绑定 / publish / subscribe”进一步缩小为 **云端 LiveKit 入口层配置问题**，更具体地说：

- **更像 7880 端口暴露 / 公网入口路径问题**
- **更像 LIVEKIT_URL / 协议与入口配置不匹配**
- **反向代理 / WebSocket upgrade 路径已补到可达**
- **LiveKit 容器本身在云端可正常启动并监听**
- **不是纯 UI 问题**
- **publish / subscribe 仍需要一轮新的干净设备侧验证，但当前已不再是最早那种“直连 :7880 timeout / reset”状态**

当前最关键的变化是：

1. 之前 Flutter 端拿到的 LiveKit 入口是 `http://101.133.161.203:7880`，真机/模拟器都在 `Room.connect()` 阶段失败。
2. 现在云端已经把 LiveKit 入口改成了 `http://101.133.161.203`，并由 nginx 把 `/rtc/` 反向代理到 `127.0.0.1:7880`。
3. 现在从外部访问 `http://101.133.161.203/rtc/validate?...` 已经能得到 `401 Unauthorized`，这说明请求已经进入 LiveKit 信令层，而不是像以前那样卡在直连 `:7880` 的超时 / reset 阶段。

因此，当前更合理的判断是：

> **云端 LiveKit 入口配置已修正，连接层阻断已从“直连 7880 不可用”转为“需要一轮重新启动后的设备侧验证，确认 Room.connect() 是否已稳定进入后续 publish / subscribe”。**

如果只做根因排序，当前优先级应为：

1. **以前的 7880 公网入口 / URL 配置错误**（已修正）
2. **反向代理与 WebSocket / validate 链路的入口不匹配**（已修正为 `/rtc/`）
3. **客户端旧连接态 / 旧 join-info 仍需干净重启验证**
4. **更底层的 publish / subscribe 问题**（当前证据不足，不能作为第一根因）

---

## 2. Flutter 实际入房参数

### 真机与模拟器在服务端拿到的 join-info

后端 `GET /api/v1/rtc/calls/{callId}/livekit` 仍然通过 `LiveKitTokenService::issueJoinInfo()` 生成 join-info。

从后端代码和最新返回值看，关键字段为：

- `enabled = true`
- `url = http://101.133.161.203`
- `room_name = 7_8`
- `identity = rtc-user-8`（用户 8）
- `participant_name = 华霜魂`
- `mode = voice`
- `expires_at` 为 JWT TTL 对应时间

另一个账号（用户 7 / `test1`）遵循同一生成规则：

- `identity = rtc-user-7`
- `room_name = 7_8`
- `participant_name = test1`
- `mode = voice`

### room.connect() 调用前最终值

Flutter 端 `RtcLiveKitService.ensureConnected()` 使用的是：

- `info.url`
- `info.token`

也就是说，本轮最重要的前置修复是 **服务端下发的 `url` 已从直连 `:7880` 改成 `http://101.133.161.203`**，客户端无需再把 `:7880` 当作公网入口。

### 设备侧日志中可见的入房前请求

在最新一轮设备日志里，可见：

- `RTC_INVITE_PROVIDER_OPEN callId=48`
- `GET http://101.133.161.203/api/v1/rtc/calls/48/livekit`
- `200 GET .../livekit`

这说明：

- 客户端已能拿到 join-info
- 服务端 RTC 接口链路是通的
- 阻断点不在 `GET /api/v1/rtc/calls/{callId}/livekit`

---

## 3. 服务端 join-info 生成逻辑

### 相关代码位置

- [`services/backend-laravel/app/Http/Controllers/Api/V1/RtcController.php`](D:/EliteSync/services/backend-laravel/app/Http/Controllers/Api/V1/RtcController.php)
- [`services/backend-laravel/app/Services/LiveKitTokenService.php`](D:/EliteSync/services/backend-laravel/app/Services/LiveKitTokenService.php)
- [`services/backend-laravel/config/livekit.php`](D:/EliteSync/services/backend-laravel/config/livekit.php)

### 当前环境变量

云端 backend `.env` 现值：

- `LIVEKIT_ENABLED=true`
- `LIVEKIT_URL=http://101.133.161.203`
- `LIVEKIT_API_KEY=devkey`
- `LIVEKIT_API_SECRET=secret`
- `LIVEKIT_TOKEN_TTL_SECONDS=600`

### 生成逻辑

`LiveKitTokenService::issueJoinInfo()` 逻辑为：

1. 从 `config('livekit')` 读取：
   - enabled
   - url
   - api_key
   - api_secret
   - ttl_seconds
2. 用 `rtc-user-{userId}` 作为 identity
3. 用 `session->room_key` 作为房间名
4. 用 JWT 签出 LiveKit token
5. 返回给 Flutter：
   - `url`
   - `token`
   - `room_name`
   - `identity`
   - `participant_name`
   - `mode`
   - `expires_at`

### 本轮关键变化

本轮不是重写 token 逻辑，而是**修正 url 的公网入口口径**：

- 旧口径：`http://101.133.161.203:7880`
- 新口径：`http://101.133.161.203`

这个改变的意义是：

- 客户端不再把 LiveKit 服务直连到外网 7880
- 而是通过 nginx 的 `/rtc/` 入口进入 LiveKit

---

## 4. 云端端口与监听检查

### 监听情况

云端 `ss -lntp` 已确认：

- `0.0.0.0:80` 由 nginx 监听
- `*:7880` 由 `livekit-server` 监听
- `*:7881` 由 `livekit-server` 监听

说明：

- LiveKit 容器本机监听是正常的
- nginx 80 端口是公网稳定入口
- 7880 虽然在机器上监听，但不应再作为客户端公网直连入口依赖

### 容器情况

`docker ps` / `docker inspect` 显示：

- LiveKit 容器使用 `host` 网络模式
- 没有传统 Docker `PortBindings`

这意味着：

- 端口暴露不是 Docker 端口映射问题
- 更关键的是公网入口路径和代理配置是否正确

### 服务器本机测试结果

服务器本机：

- `curl http://127.0.0.1/rtc/validate?...` 返回 `401 Unauthorized`
- 说明 `/rtc/` 代理链路可达，并且确实进入了 LiveKit 逻辑

### 外部测试结果

开发机外部：

- `curl.exe --noproxy '*' -I "http://101.133.161.203/rtc/validate?room=7_8&identity=rtc-user-8&access_token=demo"`
  - 返回 `HTTP/1.1 401 Unauthorized`

这一步很关键，因为它证明：

- 公网访问已经不再卡在直连 `:7880` 的超时 / reset
- 外部请求已经能打到 LiveKit 的 validate 路径

---

## 5. 代理与协议检查

### 当前 nginx 代理

云端 nginx 配置里已新增：

```nginx
location ^~ /rtc/ {
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
    proxy_pass http://127.0.0.1:7880;
}
```

### 协议结论

本轮修复前后最重要的协议变化是：

- 旧的公网直连入口：`http://101.133.161.203:7880`
  - 之前在真机上超时
  - 之前在模拟器上 reset
- 新的公网入口：`http://101.133.161.203`
  - 通过 nginx `/rtc/` 转到 LiveKit
  - `/rtc/validate` 已可达

因此，当前更像是：

- **入口路径错误 / 入口暴露方式错误**
- 而不是单纯的 Flutter 侧 room.connect 写法错误

### 仍需注意

本轮还不能完全下结论说 `Room.connect()` 已 100% 稳定，因为：

- 设备侧最新日志仍需要一轮“干净重启后”的新验证
- 目前已有的 device log 里，能确定的是 **旧的直连 :7880 路径曾导致失败**
- 还需要确认 **新 `/rtc/` 入口是否已让 app 端稳定进入后续 publish / subscribe**

---

## 6. 服务端日志证据

### LiveKit 容器日志可见

云端 LiveKit 日志显示：

- 服务启动为 development mode
- API key / secret 以 `devkey / secret` 运行
- `portHttp = 7880`
- `bindAddresses = ["0.0.0.0"]`
- `rtc.portTCP = 7881`
- `rtc.portUDP = {Start: 7882, End: 0}`

### 日志没有说明的问题

日志本身没有显示“LiveKit 没有启动”或“容器挂掉”。

所以这次不是：

- 容器没起来
- 服务没监听
- 进程没有绑定端口

而更像：

- 公网入口最初走错了
- 客户端需要走 nginx `/rtc/` 入口，而不是直接碰 `:7880`

### 目前对错误类型的解释

最早的设备日志表现为：

- 真机：`Connection timed out`
- 模拟器：`Connection reset by peer`

这与“外部直连 7880 的入口不通”高度一致。

本轮修复后，公网 `/rtc/validate` 已经可达，说明问题已经从“入口根本不通”前进到了“需要重新跑一次设备侧确认 Room.connect 是否稳定成功”的阶段。

---

## 7. 根因排序

### Top 1

**更像 7880 端口暴露 / 公网入口路径配置问题**

理由：

- 设备早期直接打 `:7880` 时超时 / reset
- 云端本机 7880 正常监听，但外部直连不稳定
- nginx `/rtc/` 代理后，validate 路径可达

### Top 2

**更像 LIVEKIT_URL / 协议入口配置错误**

理由：

- 旧 join-info 入口过于依赖 `http://101.133.161.203:7880`
- 新 join-info 已改成 `http://101.133.161.203`
- 这说明客户端应以 nginx 公网入口为准，而不是直接碰 raw 端口

### Top 3

**更像客户端需要一次干净重启后的新验证**

理由：

- 本轮已修复云端入口
- 但设备侧最新一轮是否完全吃到新 join-info、是否已经稳定进入 `Room.connect()` 成功态，还需一轮新日志确认

### 次级可能

**更像 residual WebSocket / upgrade 问题**

目前概率已经低于“入口 / URL 配置问题”，但如果下一轮设备侧仍失败，就要重点盯：

- websocket upgrade 是否真正被带到 LiveKit
- 客户端拿到的最终 URL 是否仍被改写为错误地址
- 是否有旧进程 / 旧缓存仍在使用旧 join-info

---

## 8. 最小修复动作

本轮已经做的最小修复是：

1. 云端 backend `.env` 的 `LIVEKIT_URL` 改为：
   - `http://101.133.161.203`
2. 云端 nginx 新增：
   - `/rtc/` -> `http://127.0.0.1:7880`
3. 云端 validate 路径已验证可达：
   - `http://101.133.161.203/rtc/validate?...`

这已经是足够小的修复，不需要重写 RTC 架构，也不需要继续扩大 UI。

### 不建议继续做的事

- 不要为了这个问题去重写 4.6 UI
- 不要换新的 RTC 大库
- 不要改成多人 / 直播 / 推送平台式重构
- 不要改数据库 schema

---

## 9. 修复后验证结果

### 已确认通过的内容

- 云端 LiveKit 仍然在线
- 80 端口 nginx 可达
- `/rtc/validate` 可达并返回 `401 Unauthorized`
- backend join-info 返回的新入口是 `http://101.133.161.203`
- `GET /api/v1/rtc/calls/{callId}/livekit` 可正常返回 200

### 仍需确认的内容

仍需要一轮**干净重启后的设备侧新验证**，重点看：

- `Room.connect()` 是否稳定成功
- 是否还会出现 `Connection timed out / reset by peer`
- 是否开始出现：
  - `TrackPublished`
  - `TrackSubscribed`
  - `AudioPlayback`
  - `remoteAudioTrack` 非空

### 当前阶段结论

本轮已经把“入口层不可达”的问题修到了“入口层可达”。

也就是说：

- 以前是 **连 validate 都走不通**
- 现在是 **validate 已打通，下一层才是 publish / subscribe**

---

## 10. 是否建议进入 4.6A 修复版计划

**建议进入。**

但建议的范围必须非常小，只针对：

- `Room.connect()` 的稳定性复验
- 设备侧新日志确认
- 若仍失败，再看 publish / subscribe

建议的修复版命名可以是：

- `4.6H` 继续收口版
- 或 `4.6I` 真语音二次验证版

不要把它扩成新的 RTC 大版本。
