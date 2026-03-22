# Demo Persona Users

用于本地联调时快速生成 10 个“不同倾向”的测试账号。

## 前置

1. 已完成问卷题库迁移与播种：

```powershell
cd D:\EliteSync\services\backend-laravel
C:\tools\php85\php.exe artisan migrate:fresh --seed
```

## 生成测试账号

```powershell
cd D:\EliteSync\services\backend-laravel
C:\tools\php85\php.exe artisan db:seed --class=Database\\Seeders\\DemoPersonaUsersSeeder
```

## 账号列表

- `13900000001` ~ `13900000010`
- 密码统一：`secret123`

这些账号已自动写入 10 题答案，可直接用于匹配/聊天联调。

