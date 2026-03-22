# EliteSync P0 本地安装与运行说明

> 本文档面向**无安卓开发经验**的同学，目标是让你能把当前 P0 代码拉下来后快速跑起来并调试。

---

## 1. 代码内容概览

当前仓库已包含两部分：

1. **后端 API（可运行）**：`services/api/`
   - 技术栈：FastAPI + SQLAlchemy + SQLite + APScheduler
   - 已实现：注册登录/JWT、问卷、匹配、聊天、后台接口等 P0 基础能力

2. **Android 客户端（骨架）**：`apps/android/`
   - 当前是 P0 架构起步代码（模型 + ViewModel + 说明）
   - **注意**：该目录目前还不是完整可编译的 Android Studio 工程（后续迭代会补齐 Gradle 与页面）

---

## 2. 环境准备

建议环境：

- OS：Linux / macOS / Windows（WSL 也可）
- Python：`3.10+`
- Git：最新版
- （可选）Docker / Docker Compose

先确认版本：

```bash
python --version
git --version
```

---

## 3. 下载代码

如果你还没克隆仓库：

```bash
git clone https://github.com/zcx369658780/EliteSync.git
cd EliteSync
```

如果你已经有仓库，拉取最新 `work` 分支：

```bash
git fetch origin
git checkout work
git pull
```

---

## 3.1 一键环境配置脚本（推荐）

仓库已提供一键脚本：

- Windows 环境安装：`scripts/setup_env_windows.ps1`
- Windows 启动服务（PowerShell）：`scripts/start_windows.ps1`
- Windows 启动服务（CMD/双击）：`scripts/start_windows.bat`（自动写入 `logs/`）
- Linux/macOS 环境安装：`scripts/setup_env_unix.sh`

### Windows 一键安装 + 运行

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup_env_windows.ps1 -PythonVersion 3.11 -RunTests
.\scripts\start_windows.ps1
.\scripts\start_windows.ps1 -BindHost 0.0.0.0 -Port 8000
```

> 注意：你之前的报错是把 `Set-ExecutionPolicy` 和脚本路径写在同一条命令里导致的。它们必须分成两行执行。

或者使用 CMD / 双击方式启动（自动生成日志文件）：

```bat
scripts\start_windows.bat
```

日志会写入仓库根目录 `logs/`，文件名示例：`api_20260310_213000.log`。

## 4. 启动后端（推荐本地 Python 方式）

### 4.1 进入后端目录

```bash
cd services/api
```

### 4.2 安装依赖

```bash
python -m pip install -r requirements.txt
```

### 4.3 启动服务

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

启动成功后，访问：

- 健康检查：`http://127.0.0.1:8000/health`
- Swagger 文档：`http://127.0.0.1:8000/docs`

---

## 5. 后端快速验证（最小流程）

另开一个终端，执行：

### 5.0 这些后端验收代码在哪里运行？

你可以在两处运行 B 类后端验收：

1. **Swagger UI（推荐新手）**：打开 `http://127.0.0.1:8000/docs`，直接点接口并填写参数。
2. **终端命令行**：在 PowerShell / CMD 用 `curl` 调接口（本章示例即为命令行方式）。

为了测试匹配链路，新增了两个开发验收接口（Swagger 可直接调用）：

- `POST /api/v1/admin/dev/run-matching`：手动执行本周匹配
- `POST /api/v1/admin/dev/release-drop`：手动释放本周 Drop 可见性

### 5.1 注册

```bash
curl -X POST 'http://127.0.0.1:8000/api/v1/auth/register' \
  -H 'Content-Type: application/json' \
  -d '{"phone":"13800000001","password":"123456"}'
```

拿到返回中的 `access_token` 后，继续：

### 5.2 拉取问卷题目

```bash
curl 'http://127.0.0.1:8000/api/v1/questions' \
  -H 'Authorization: Bearer <你的access_token>'
```

### 5.3 提交答案（草稿/正式均支持）

```bash
curl -X POST 'http://127.0.0.1:8000/api/v1/questions/answers' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <你的access_token>' \
  -d '{"answers":[{"question_id":1,"answer":"A","is_draft":false}]}'
```

### 5.4 查看进度

```bash
curl 'http://127.0.0.1:8000/api/v1/questions/answers/progress' \
  -H 'Authorization: Bearer <你的access_token>'
```

---

## 6. 运行测试

在 `services/api` 目录：

```bash
PYTHONPATH=. pytest -q
```

如果看到 `1 passed` 即表示当前已有自动化链路通过。

---

## 7. 使用 Docker 运行（可选）

当前仓库提供了基础 compose 文件（`infra/docker-compose.yml`），你可以：

```bash
cd infra
docker compose up --build
```

默认会启动 API 服务到 `8000` 端口。

---

## 8. Android 代码如何查看

Android 目录已提供可导入 Android Studio 的 P0 工程骨架：

1. 启动后端（8000 端口）。
2. 用 Android Studio 打开 `apps/android`。
3. 等待 Gradle Sync 后直接运行 `app`。
4. 客户端默认调用 `10.0.2.2:8000`（模拟器访问本机后端地址）。

核心实现文件：
- `apps/android/app/src/main/java/com/elitesync/MainActivity.kt`
- `apps/android/app/src/main/java/com/elitesync/ui/AppNavHost.kt`
- `apps/android/app/src/main/java/com/elitesync/ui/screens/*`
- `apps/android/app/src/main/java/com/elitesync/network/*`
- `apps/android/app/src/main/java/com/elitesync/ws/ChatSocketManager.kt`

---


### Android 主题资源报错快速修复
若 Android Studio 报错：`Theme.Material3.DayNight.NoActionBar not found`，请在仓库根目录执行：

```powershell
.\scripts\android_sync_deps_windows.ps1
```

该脚本会执行 `--refresh-dependencies` 主动下载依赖并触发 `assembleDebug` 校验。

## 9. 常见问题
### Android Studio 版本与 JDK 建议
- Gradle JDK 请选择 **JDK 17**（不要选 25）
- Android 构建脚本已固定插件版本：
  - AGP `8.5.2`
  - Kotlin `1.9.24`
- 如果看到 `Unsupported class file major version 69`，说明 Gradle 正在用 Java 25 运行，请改回 JDK 17。


### Q1：启动后 `questions` 是空的？
A：服务启动时会自动 seed 66 题；若中途清库，请重启服务。

### Q2：为什么 Android 现在不能直接编译？
A：本次 P0 先交付“后端可跑 + 客户端骨架”，完整可编译工程在下一迭代补齐。

### Q3：如何查看所有接口？
A：启动后打开 `http://127.0.0.1:8000/docs`（Swagger UI）。

---

## 10. 建议调试顺序（给新手）

1. 先把后端跑通（`/health` 正常）
2. 在 Swagger 里依次跑：注册 → 登录 → 问题拉取 → 答案提交 → 进度查询
3. 再看匹配、聊天、后台接口
4. 最后再开始接 Android 页面

这样最容易定位问题，学习曲线也最平滑。
