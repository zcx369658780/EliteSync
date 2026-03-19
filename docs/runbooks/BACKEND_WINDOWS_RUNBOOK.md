# Backend Windows Runbook

## 1. 前置条件
- 路径：`D:\EliteSync`
- PHP：`C:\tools\php85\php.exe`
- 数据库：当前本地联调使用 SQLite（已在 `services/backend-laravel/.env` 配置）

## 2. 启动后端（推荐两终端）

### 终端 A：启动 Laravel HTTP API（8080）
```powershell
cd D:\EliteSync\services\backend-laravel
C:\tools\php85\php.exe artisan serve --host=0.0.0.0 --port=8080
```

### 终端 B：启动聊天 WebSocket 网关（8081）
```powershell
cd D:\EliteSync\services\backend-laravel
C:\tools\php85\php.exe artisan chat:ws --host=0.0.0.0 --port=8081
```

## 3. 一键启动方式（可选）
```powershell
cd D:\EliteSync
powershell -ExecutionPolicy Bypass -File .\scripts\start_laravel_realtime_local.ps1
```

## 4. 启动后快速验证

### 健康检查
```powershell
curl.exe http://127.0.0.1:8080/up
```

### 注册接口冒烟
```powershell
curl.exe -X POST "http://127.0.0.1:8080/api/v1/auth/register" ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"phone\":\"13800009999\",\"password\":\"123456\",\"name\":\"test\"}"
```

## 5. 关闭后端

### 方式 A：在启动终端按 `Ctrl + C`
- 终端 A 和终端 B 分别按一次。

### 方式 B：按端口结束进程（当终端已关闭但进程仍在）
```powershell
# 结束 8080 占用进程
$pid8080 = (Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty OwningProcess)
if ($pid8080) { Stop-Process -Id $pid8080 -Force }

# 结束 8081 占用进程
$pid8081 = (Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty OwningProcess)
if ($pid8081) { Stop-Process -Id $pid8081 -Force }
```

## 6. 常见问题

### 6.1 注册/登录返回 HTTP 500
- 查看日志：
```powershell
cd D:\EliteSync\services\backend-laravel
Get-Content .\storage\logs\laravel.log -Tail 120
```

### 6.2 匹配页 404（暂无匹配或未到 Drop）
- 用开发接口生成并发布匹配：
```powershell
curl.exe -X POST "http://127.0.0.1:8080/api/v1/admin/dev/run-matching" -H "Authorization: Bearer <token>"
curl.exe -X POST "http://127.0.0.1:8080/api/v1/admin/dev/release-drop" -H "Authorization: Bearer <token>"
```
