# EliteSync Android (P0 客户端实现)

当前目录已升级为**可导入 Android Studio 的 Compose 工程骨架**，用于联调 P0 后端能力：

## 已实现页面与链路
- 错误兜底：网络异常不再直接闪退，页面显示状态与错误提示
- 注册/登录页：调用 `/api/v1/auth/register`、`/api/v1/auth/login`
- 问卷页：拉取题目 `/api/v1/questionnaire/questions`，提交答案 `/api/v1/questionnaire/answers`
- 匹配页：查询 `/api/v1/matches/current`，确认意向 `/api/v1/matches/confirm`
- 聊天页：发送 `/api/v1/messages`，并通过 WebSocket `ws://10.0.2.2:8081/api/v1/messages/ws/{userId}` 实时接收

## 运行方式
1. 先启动后端 HTTP（默认 8080）和聊天网关（默认 8081）。
2. Android Studio 打开 `apps/android` 目录。
3. 等待 Gradle Sync 完成后运行 `app`。
4. 模拟器使用 `10.0.2.2:8080` 访问 API，`10.0.2.2:8081` 访问 WS 网关。

## 目录说明
- `app/src/main/java/com/elitesync/network`: Retrofit API 定义
- `app/src/main/java/com/elitesync/repo`: 仓储层
- `app/src/main/java/com/elitesync/ui`: ViewModel + 导航
- `app/src/main/java/com/elitesync/ui/screens`: 4 个核心页面
- `app/src/main/java/com/elitesync/ws`: WebSocket 连接管理

> 说明：当前为 P0 联调版本，重点是打通主流程，UI/状态管理与本地缓存会在下一阶段优化。

## 构建版本约束（重要）
- Android Gradle Plugin: `8.9.1`
- Kotlin Android Plugin: `1.9.24`
- JDK / Gradle JDK: **17**（建议 Temurin 17.0.10+）
- Gradle 运行 JDK 不要使用 25（否则会出现 `Unsupported class file major version 69`）

如果 Android Studio 报 `jvmTarget: String` 相关错误，项目已迁移到 Kotlin `compilerOptions` DSL。


## 依赖预下载（解决主题资源缺失）

若遇到 `Theme.Material3.DayNight.NoActionBar not found`，请先执行：

```powershell
.\scripts\android_sync_deps_windows.ps1
```

或 CMD：

```bat
scripts\android_sync_deps_windows.bat
```

这会主动下载 Android 依赖并执行一次 `assembleDebug` 资源校验。
