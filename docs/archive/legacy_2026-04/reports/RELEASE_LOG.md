# Release Log


## 2026-04-10 20:24:44 - 0.03.02
- VersionCode: 302
- DownloadURL: http://101.133.161.203/downloads/elitesync-0.03.02.apk
- SHA256: 7A695084D34FF9D92E1993940F1D6A2F53F0345C7B95F277F9C25F45C1602B0D
- Changelog: # EliteSync 0.03.02 更新日志

1) 完成 3.2 终验收尾与版本收口：补齐终验补证、归档材料与截图，核心链路正式归档。
2) 星盘主视觉改为 APP 端本地完整绘制，并优化默认缩放与展示比例，避免圆盘被裁切。
3) Android 宿主 bootstrap 已补齐 API / WS 基线注入，登录后不再依赖隐式回退地址，降低 `Request Timed out` 误报风险。

- PostCheck: SKIPPED


## 2026-04-09 20:16:12 - 0.03.01
- VersionCode: 301
- DownloadURL: http://101.133.161.203/downloads/elitesync-0.03.01.apk
- SHA256: 8C1524F63C9F2B969738240C40709BA0820CEF719B57C399637EBB22807CC395
- Changelog: # EliteSync 0.03.01 更新日志

1) 完成 3.0-3.1 首轮交付收口：优化首页关键路径、匹配解释、首聊引导与 telemetry，补齐账号分层、状态发布、管理员控制面与广场接入。
2) 补齐普通账号 A/B 可见性证明、管理员匹配触发与回查、测试账号重建与清理证据。
3) 更新版本号、版本检查、关于页历史、发布配置与 APK 文件名到 0.03.01 / 301，便于 Beta 发布与归档审计。

- PostCheck: SKIPPED

## 2026-04-10 21:38:46 - 0.03.02a
- VersionCode: 30201
- DownloadURL: http://101.133.161.203/downloads/elitesync-0.03.02a.apk
- SHA256: 5B697DE092B27DF11592C5C002E341D77DA822A33B93A1DED09D4B1EB8E18DC6
- Changelog: 完成 3.2a 版本收口：星盘主视觉改为 APP 端本地完整绘制，盘面元素开关细分到星体 / 虚点 / 相位 / 盘心，并支持恢复默认与预设档位切换；Android 宿主 bootstrap 已补齐 API / WS 基线注入，确保登录后不再依赖隐式回退地址；版本号、版本检查、关于页历史、发布配置与 APK 文件名同步到 0.03.02a / 30201。
- PostCheck: PASS
- Check Details:
  - [PASS] Version API: latest=0.03.02a(30201)
  - [PASS] Download URL: HTTP/1.1 200 OK
  - [PASS] Remote APK Retention: count=2, keep=2
  - [PASS] Remote APK SHA256: remote=5B697DE092B27DF11592C5C002E341D77DA822A33B93A1DED09D4B1EB8E18DC6
