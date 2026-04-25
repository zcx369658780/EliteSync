# APP Versioning Spec

更新时间：2026-04-18

## 版本号格式

统一使用三段式并允许可选后缀：`major.minor.patch[suffix]`  
示例：`0.04.06`

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

- 当前版本：`0.04.06`
- 含义：`开发阶段 (major=0)` + `Beta 预热阶段 (minor=04)` + `第 6 个版本 (patch=06)`

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
- `0.03.09` -> `30900`
- `0.04.06` -> `40600`
- `0.04.02` -> `40200`
- `0.03.03` -> `30300`
- `1.02.03` -> `1020300`

## 后端更新检查接口

- `GET /api/v1/app/version/check`
- 参数：
  - `platform`: `android` / `ios`
  - `version_name`: 当前版本号（如 `0.04.06`）
  - `version_code`: 当前版本码（如 `40600`）
  - `channel`: 可选，默认 `stable`

## 版本展示与发版绑定规则

以下规则作为当前项目的版本号操作约束：

1. **Android 宿主版本是版本中心与更新检查的主来源**
   - `apps/android/app/build.gradle.kts` 中的 `versionName` / `versionCode` 是当前产品版本的主来源。
   - 版本中心页、`/api/v1/app/version/check`、发版脚本的 `--VersionName` / `--VersionCode` 必须与宿主版本保持一致。

2. **Flutter 模块版本只做辅助展示**
   - `PackageInfo.fromPlatform()` 读到的是 Flutter 模块版本，只用于版本中心辅助展示。
   - 模块版本不能覆盖 Android 宿主版本，更不能被当成产品真值。

3. **更新历史与发版元数据必须同步**
   - `apps/android/app/src/main/assets/changelog_v0.txt`
   - `apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`
   - `docs/CHANGELOG.md`
   - `docs/devlogs/RELEASE_LOG.md`
   - `scripts/release_android_update_aliyun.ps1`
   以上内容在正式发版时应同步更新，避免版本号、下载包、更新历史、版本检查彼此脱节。

4. **发版脚本是阿里云发布的唯一推荐入口**
   - 正式发布优先使用 `scripts/release_android_update_aliyun.ps1`。
   - 该脚本负责把宿主版本、更新历史、后端版本检查、APK 文件名和 release log 一起收口。

5. **若截图 / 设备仍显示旧版本，优先刷新安装包**
   - 如果模拟器或真机版本中心仍显示旧版本，先确认设备上安装的是最新宿主 APK。
   - 不要为了“让截图好看”去改版本中心文案去迎合旧包，应该重新安装当前发布包后再采集证据。

6. **检查更新必须回归验证**
   - 发版后至少确认：
     - `GET /api/v1/app/version/check`
     - `GET /api/v1/app/health`
     - 下载地址 HTTP 200
     - 版本中心显示宿主版本、构建号、Flutter 模块版本和服务状态一致
