# APP Versioning Spec

更新时间：2026-04-06

## 版本号格式

统一使用三段式：`major.minor.patch`  
示例：`0.01.01`

## 各段含义

1. `major`：大版本阶段
- 上线前固定为 `0`
- 正式上线后从 `1` 开始递增

2. `minor`：开发阶段
- `01`：Alpha 阶段
- `02` - `99`：Beta 阶段

3. `patch`：当前阶段内的迭代序号
- 同一 `major.minor` 下按发布顺序递增

## 当前版本

- 当前版本：`0.02.08`
- 含义：`开发阶段 (major=0)` + `Beta 预热阶段 (minor=02)` + `第 8 个版本 (patch=08)`

## Android 映射规则

Android `versionCode` 使用数值映射：

`versionCode = major * 10000 + minor * 100 + patch`

示例：
- `0.01.01` -> `101`
- `0.02.03` -> `203`
- `0.02.05` -> `205`
- `0.02.06` -> `206`
- `0.02.08` -> `208`
- `1.02.03` -> `10203`

## 后端更新检查接口

- `GET /api/v1/app/version/check`
- 参数：
  - `platform`: `android` / `ios`
  - `version_name`: 当前版本号（如 `0.01.01`）
  - `version_code`: 当前版本码（如 `101`）
  - `channel`: 可选，默认 `stable`
