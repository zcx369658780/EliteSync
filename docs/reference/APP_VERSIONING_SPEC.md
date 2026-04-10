# APP Versioning Spec

更新时间：2026-04-10

## 版本号格式

统一使用三段式并允许可选后缀：`major.minor.patch[suffix]`  
示例：`0.03.02a`

## 各段含义

1. `major`：大版本阶段
- 上线前固定为 `0`
- 正式上线后从 `1` 开始递增

2. `minor`：开发阶段
- `01`：Alpha 阶段
- `02` - `99`：Beta 阶段

3. `patch`：当前阶段内的迭代序号
- 同一 `major.minor` 下按发布顺序递增

4. `suffix`：可选后缀
- 用于同一 patch 的补丁 / 终验 / alpha 发布
- 当前默认按字母顺序比较，`a < b < c ...`

## 当前版本

- 当前版本：`0.03.02a`
- 含义：`开发阶段 (major=0)` + `Beta 预热阶段 (minor=03)` + `第 2 个版本 (patch=02)` + `alpha 后缀 a`

## Android 映射规则

Android `versionCode` 使用数值映射。

历史已发版本 `0.03.01` / `0.03.02` 仍保留旧 compact 编码 `301` / `302` 作为历史包记录。

从 `0.03.02a` 开始，发布工具改用扩展编码：

`versionCode = major * 1000000 + minor * 10000 + patch * 100 + suffixRank`

其中 `suffixRank` 规则：
- 无后缀：`0`
- `a`：`1`
- `b`：`2`
- 以此类推，支持多字母后缀按 26 进制累积

示例：
- `0.03.02a` -> `30201`
- `0.03.03` -> `30300`
- `1.02.03` -> `1020300`

## 后端更新检查接口

- `GET /api/v1/app/version/check`
- 参数：
  - `platform`: `android` / `ios`
  - `version_name`: 当前版本号（如 `0.03.02a`）
  - `version_code`: 当前版本码（如 `30201`）
  - `channel`: 可选，默认 `stable`
