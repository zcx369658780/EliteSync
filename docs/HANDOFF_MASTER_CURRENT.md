# EliteSync Current Handoff Master

更新时间：2026-05-07

用途：这是当前恢复后的主交接入口。它只做“交接恢复 + 信息追回 + 单文件收口”，不代表继续扩大 5.5 范围，也不代表进入 commit / push 流程。

## 1. 当前审计快照

- Branch: `feature/5.0-alpha-readiness-20260501`
- HEAD: `8cdc29c37d5c53a433fe985c5fb1f6dc2cab6d6a`
- 当前工作树：未清洁，有 20 个 tracked 文件改动与 1 个新增文件。
- 当前 diff 主题集中在：
  - 5.4 Admin Dashboard runtime / tests
  - 5.4 handoff / current entry docs
  - `0.05.04 / 50400` release / version metadata sync
  - backend version checks and release config
  - matching marker config remains observation / pending confirmation
  - `docs/version_plans/0.05.04_UPDATE_BRIEF.md`

## 2. 当前版本线口径

- 当前最新已完成并验收版本：`5.4`
- 当前 5.4 主交接入口：`docs/version_plans/5.4_HANDOFF_MASTER.md`
- 当前发布链同步口径：`0.05.04 / 50400`
- 当前发布证据状态：0.05.04 APK 存在、下载 URL、SHA256、version API 与 Version Center 0.05.04 补证已完成。
- 5.4 状态：`pass with observations`
- 5.5 状态：只作为下一条主线恢复到文档口径，主题为“真实小样本反馈吸收版”。当前工作树未追回到明确的 5.5 实现文件、5.5 计划文件或 5.5 主交接文件；不要把 5.5 当作已实现。
- 5.4 已按用户前提完成开发、code review、GitHub 提交，并通过 PR merge regression。当前本地 HEAD 已包含 5.4 相关提交。
- 已追回的正式项目状态：`5.4` 已完成 code review、已提交 GitHub、已通过 PR merge regression；这不是 observation，也不需要在后续会话重新判定 5.4 是否完成。
- 已追回的正式项目状态：`0.05.04 / 50400` 已在 GitHub regression 通过后发布到阿里云；这不是 observation。

## 3. 5.4 已完成内容

5.4 是“测试运营准备与云端治理增强版”，已完成：

- Admin Dashboard 只读运营准备入口
- release baseline / cloud database / observability rows
- Health / Version、Notification、Media、RTC / LiveKit、Queue / Logs 观测入口
- Smoke / Regression Matrix
- 5.4 Runbook Library
- backup / restore / migration readiness
- synthetic / smoke 账号治理提示
- 19 张截图与 19 份 XML 证据，索引在 `docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md`
- 5.4 回归清单：`docs/version_plans/5.4_REGRESSION_CHECKLIST.md`

5.4 不应重开，不应扩成完整运营平台、云端执行平台、后台重构或 RTC / 数据库重写。

5.4 的 GitHub 合并事实已作为正式项目状态承接：code review 已完成，GitHub 提交已完成，PR merge regression 已通过。

## 4. 发布链与证据边界

- `0.05.04 / 50400` 已成为当前发布链同步口径。
- `0.05.04 / 50400` 已在 GitHub regression 通过后发布到阿里云，当前应按已发布版本承接。
- 本次同步覆盖 Android host versionName / versionCode、Flutter module pubspec version、app 内更新历史、Laravel version check 默认值与测试断言、`0.05.04_UPDATE_BRIEF.md`。
- 旧 5.4 UI / Version Center 证据仍主要来自 release-chain sync 前的 `0.04.09 / 40900` 包。
- 0.05.04 发布证据已补齐：
  - 本地 APK：`apps/android/app/build/outputs/apk/debug/app-debug.apk`
  - 阿里云 APK：`/opt/elitesync/services/backend-laravel/public/downloads/elitesync-0.05.04.apk`
  - 下载 URL：`http://101.133.161.203/downloads/elitesync-0.05.04.apk`，返回 `HTTP/1.1 200 OK`
  - 本地 / 远程 SHA256：`C53633477E60A804E57DCB7094BDAA1C3863334234A8A4BB34C007BAA264335B`
  - version API：`latest_version_name=0.05.04`、`latest_version_code=50400`，download URL 与 SHA256 匹配
  - Version Center 0.05.04 补证：`docs/version_plans/assets/5.4/screenshots/version_center_0_05_04_release_evidence.png` 与 `docs/version_plans/assets/5.4/xml/version_center_0_05_04_release_evidence.xml`

不要把 0.05.04 发布证据闭环误写成 Cloud DB、backup、restore、migration、queue/logs 或 RTC success 已通过。

## 5. GitHub 推送信息

- 当前 Git remote:
  - `origin git@github.com:zcx369658780/EliteSync.git`
- GitHub push 配置文件位置：
  - `C:\Users\zcxve\.codex\memories\secrets\elitesync_github_push.env`
- 相关说明：
  - `docs/reference/GITHUB_PUSH_NETWORK_MODE.md`
  - `scripts/publish_to_github.ps1`
- 已追回的 HTTPS + proxy 工作模式：
  - `HTTP_PROXY=http://127.0.0.1:7890`
  - `HTTPS_PROXY=http://127.0.0.1:7890`

注意：`scripts/publish_to_github.ps1` 内部会执行 `git add -A`、commit、push。它只应在用户明确要求整仓发布并接受该行为时使用；当前仓库规则默认禁止 `git add .` / `git add -A`，日常提交应按单主题逐文件 stage。

## 6. 阿里云 SSH 与发布方法

- ServerHost: `101.133.161.203`
- User: `root`
- RemoteRoot: `/opt/elitesync`
- 默认 SSH 私钥：
  - `C:\Users\zcxve\.ssh\CodexKey.pem`
  - 脚本默认写法：`$env:USERPROFILE\.ssh\CodexKey.pem`
- 后端远程路径：
  - `/opt/elitesync/services/backend-laravel`
- APK 远程下载目录：
  - `/opt/elitesync/services/backend-laravel/public/downloads/`
- 当前下载 URL 口径：
  - `http://101.133.161.203/downloads/elitesync-0.05.04.apk`

推荐 PowerShell SSH 调用模板：

```powershell
$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem"
$remote = @'
set -euo pipefail
cd /opt/elitesync/services/backend-laravel
php artisan about
'@
$sshArgs = @(
  '-o','BatchMode=yes',
  '-o','StrictHostKeyChecking=no',
  '-i',$KeyPath,
  'root@101.133.161.203',
  $remote
)
& $env:WINDIR\System32\OpenSSH\ssh.exe @sshArgs
```

该模板只用于用户明确要求远端检查或执行时；不要在交接恢复阶段主动连云端。

## 7. 常用脚本与用途

- `scripts/release_android_update_aliyun.ps1`
  - 用途：更新 Android version、追加 changelog、构建 debug APK、上传阿里云、更新 Laravel `.env` 和 release metadata、清理旧 APK、执行 post-release self check、追加 `docs/devlogs/RELEASE_LOG.md`。
  - 只应在用户明确要求发版 / 上传 APK 到阿里云时运行。
- `scripts/publish_to_github.ps1`
  - 用途：从外部 env 读取 GitHub push 配置，设置 remote，执行 `git add -A`、commit、push。
  - 当前默认不推荐直接运行，除非用户明确接受整仓 add / commit / push。
- `scripts/deploy_aliyun_backend.ps1`
  - 用途：上传 Laravel backend、可选备份、composer install、migrate、cache、restart nginx / php-fpm / websocket 服务。
  - 会触碰云端服务与迁移，必须用户明确要求。
- `scripts/db_backup_aliyun_mysql.ps1`
  - 用途：在云端导出 MySQL 备份并下载 manifest / sql.gz / sha256 到本地 `backups/aliyun_mysql`。
  - 涉及云端 DB 读取，运行前需确认。
- `scripts/db_restore_aliyun_mysql.ps1`
  - 用途：把备份恢复到目标数据库，默认 `elitesync_restore`。
  - 高风险脚本，只能在用户明确指定备份和目标库时运行。
- `scripts/release_gate_alpha.ps1`
  - 用途：Android compile、backend smoke、astro regression、可选 calibration cycle，并写入 `docs/devlogs/RELEASE_GATE_LOG.md`。
- `scripts/regression_alpha_baseline.ps1`
  - 用途：组合 backend tests 与 release gate，写入 `docs/devlogs/REGRESSION_BASELINE_LOG.md`。
- `scripts/smoke_backend_alpha.ps1`
  - 用途：对 `http://101.133.161.203` 或指定 BaseUrl 执行后端 smoke，可用 `-SkipAuthChecks` 做公开链路检查。
- `scripts/fast_deploy_flutter_android_debug.ps1`
  - 用途：构建 Flutter AAR / Android debug APK，安装到指定 emulator/device 并启动 app。
- `scripts/apply_calibration_mode.ps1`、`scripts/apply_match_tuning_profile.ps1`、`scripts/run_astro_calibration_cycle.ps1`
  - 用途：匹配 / 玄学校准相关，只应在校准任务明确时运行。

## 8. 保护面与 blocker 规则

当前不能误动：

- Laravel backend contract
- 数据库 schema / migrations / production data
- profile/basic、profile/astro/summary、profile/astro/chart 真值链
- 出生地、坐标、八字、紫微、星盘等 canonical 服务端真源
- RTC / LiveKit contract 与通话状态机
- notification payload contract
- media_assets / message_attachments / chat_messages 稳定链路
- Android host release version 真值与 `/api/v1/app/version/check` 一致性
- UI protected surfaces：主导航、首页、消息页、聊天页、通知中心、匹配页、资料页、问卷页、版本中心、现代 UI spacing / card / background

遇到跨层不确定点，先写 blocker / observation，不要盲修。尤其不要把本地前端工作误写成云端已执行，不要伪造 smoke / regression / version-chain 已通过。

## 9. 下一步最安全顺序

1. 先确认是否要继续 5.5，还是先收口当前 dirty 工作树。
2. 如果要交付当前 5.4 / 0.05.04 工作，先按固定提交流程分桶，不使用 `git add .`。
3. `0.05.04 / 50400` 已正式发布到阿里云，且本轮已补齐 version-chain / Version Center / download / release / SHA256 留痕。
4. 如果要开始 5.5，先写 5.5 计划与 scope freeze，再做只读 dependency / risk / test / architecture 审计。
5. 5.5 第一轮只能吸收真实小样本反馈，不应预先脑补大功能包，也不应重开 5.0-5.4 主链。

## 10. 当前仍是 observation

- Cloud DB read-only audit 需要真实批准环境与凭据路径。
- backup existence 需要真实备份证据。
- restore drill 需要非生产恢复环境演练。
- migration-level checks 需要真实只读环境或后端证据。
- queue / logs 需要当前日志源。
- RTC success evidence 未声明通过，当前只保留 RTC 权限面证据。
- `services/backend-laravel/config/matching.php` 的 matching algo marker 同步仍是待确认 observation，不属于当前 `0.05.04 / 50400` 正式发布链同步口径。
- 旧 `0.04.09 / 40900` 截图仍只作为历史 5.4 功能 / 保护面证据，不作为 0.05.04 release-chain 证据。
