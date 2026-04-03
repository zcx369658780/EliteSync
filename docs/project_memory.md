# 项目长期记忆

## 算法与接口总文件

项目内保留一份持续维护的总文件，用于记录：

- 全部算法信息
- 全部数据条目接口
- 用户字段与数据类型
- 关键 API 入口
- 兼容层与废弃项
- 与顾问对接所需的版本基线材料

每次版本更新后，必须优先更新这份总文件，再生成下一版规划或对外简报。

## 维护原则

- 只保留一份“当前版本总基线”文件作为主入口。
- 新版本规划必须以这份总基线为准。
- 历史版本只保留必要的归档，不再作为主对接材料。
- 若算法或数据接口发生变化，先更新总文件，再更新索引和版本规划。
- 百度地图配置已拆分为两套，不要再共用同一个 AK：
  - Android SDK AK：仅用于 Android `local.properties`
  - Web 服务 AK / SK：仅用于后端 `.env` 的地点搜索与地理编码签名
- 百度地图 Android 安全码当前固定为 `BB:BB:BF:79:60:8A:22:F4:E4:DA:86:5E:38:07:CC:EC:03:98:EB:7C;com.elitesync`，仅用于百度控制台与应用包名 / SHA1 绑定记录。
- 当前 Android 侧百度地图包体使用 `BaiduLBS_Android_4195.zip` 对应的 `8.0.0` SDK 物料；后续如继续升级百度 SDK，必须同步更新 `LICENSE_DEPENDENCY_STATUS.md` 和相关配置说明。
- `flutter_svg` 已接入 Flutter 运行时，用于渲染 Kerykeion 返回的星盘 SVG 预览；依赖授权状态见 `LICENSE_DEPENDENCY_STATUS.md`。
- Kerykeion 已进入后端星盘服务集成评估链路，当前状态在 `LICENSE_DEPENDENCY_STATUS.md` 中标记为 `AGPL_PENDING_REVIEW`；若继续扩大到生产默认依赖，必须先完成商用影响复核与依赖链审计。
- 玄学详情页的展示偏好使用本地持久化 key `astro_chart_preferences_v1`，仅影响 Flutter 渲染，不得回写 canonical 画像数据；如新增显示项开关，优先扩展该本地偏好而不是改服务端真值。

## 开发工作流长期记忆

- 任何非微小任务，默认必须先进入 plan-first 流程。
- plan-first 阶段必须并行启动四个只读 subagent：
  1. `dependency-mapper`
  2. `risk-reviewer`
  3. `test-planner`
  4. `architecture-guardian`
- 只有在上述评审完成后，主线程才能汇总计划并进入实现。
- 涉及数据库、地图定位、权限、迁移、配置、第三方 SDK、状态持久化的任务，必须先确认备份/回滚点与最小回归清单。
- 实施阶段默认只允许一个 `implementation-worker` 写入同一批改动。
- 修改完成后，必须并行启动：
  1. `acceptance-auditor`
  2. `regression-sentinel`
  3. `test-planner` 复核验收覆盖
  4. `architecture-guardian` 复核结构边界
- 任一验收 subagent 输出 `fail`，必须进入修复轮次，不能直接宣告完成。
- 需要创建 PR 时，必须先经过 Code Review，并获得用户明确同意后再发起 PR。

## 高风险模块永久保护

- 本地数据库 / 远端数据库 / 迁移 / 初始化
- 地图、定位、权限、坐标刷新、逆地理编码
- 路由跳转、按钮事件、状态管理、页面生命周期
- 配置文件、环境变量、第三方 SDK 接入点
- 自动备份、恢复、版本升级脚本
