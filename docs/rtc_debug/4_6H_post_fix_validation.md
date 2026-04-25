# 4.6H LiveKit 连接层修复后验证

更新时间：2026-04-23

## 已通过的验证

### 1. 云端 validate 路径可达

验证命令：

```powershell
curl.exe --noproxy '*' -I "http://101.133.161.203/rtc/validate?room=7_8&identity=rtc-user-8&access_token=demo"
```

结果：

- `HTTP/1.1 401 Unauthorized`

解释：

- 请求已经进入 LiveKit 入口
- 不再是旧的 `:7880` 外网直连失败

### 2. 服务器本机代理可达

验证命令：

```bash
curl -s -I 'http://127.0.0.1/rtc/validate?access_token=demo'
```

结果：

- `HTTP/1.1 401 Unauthorized`

解释：

- nginx `/rtc/` 代理已经把请求转到了 LiveKit

### 3. join-info 入口已更新

后端当前返回：

- `url = http://101.133.161.203`

说明：

- 客户端不再拿到旧的 `:7880` 直连入口

---

## 仍需补的设备侧验证

本轮还缺一条“干净重启后的新设备日志”来最终确认：

- `Room.connect()` 是否已经稳定成功
- 是否能进入后续 `TrackPublished / TrackSubscribed`

也就是说，当前已经确认：

- 云端连接入口已通

但还不能把“真语音已经完全闭合”当成最终结论。

---

## 当前建议

建议下一轮只做：

- 干净重启应用
- 重新发起真机 / 模拟器双向通话
- 只观察：
  - `Room.connect()`
  - `TrackPublished`
  - `TrackSubscribed`
  - `AudioPlayback`
  - `remoteAudioTrack`

不要继续扩 UI，也不要继续换 RTC 库。
