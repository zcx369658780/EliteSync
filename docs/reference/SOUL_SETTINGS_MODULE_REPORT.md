# Soul 设置模块拆解报告

## Session

- Date: 2026-05-01
- Device: emulator-5554
- Package: `cn.soulapp.android`
- Module: 设置 / 主页背景设置面
- Scope: 仅做低风险设置入口、主页背景、商业入口与权限边界探索

## 页面概览

Soul 的“设置”在当前样本中不是传统意义上的整页设置中心，而是从个人页右上角 `设置` 进入的底部抽屉 / 底部面板，核心标题为 `主页背景`。

这个面板主要围绕个人主页视觉装扮展开，包含：

- 主页背景设置
- 商业化装扮入口
- 图片背景
- 互动背景

从结构上看，它更像“个人主页视觉配置面”，而不是账号安全深区。

## 可见一级入口与功能文案

- `主页背景`
- `我的空间装扮`
- `立即开通`
- `图片背景`
  - 说明：`固定单张展示背景图`
  - 按钮：`去设置`
- `互动背景`
  - 说明：`旋转手机时背景图可切换`
  - 按钮：`去设置`

## 截图与层级证据

- 默认态 / 入口态截图：
  - [`SOUL_SETTINGS_001_PROFILE_DEFAULT.png`](/D:/EliteSync/docs/reference/soul_settings/assets/SOUL_SETTINGS_001_PROFILE_DEFAULT.png)
- 主页背景底抽屉截图：
  - [`SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET.png`](/D:/EliteSync/docs/reference/soul_settings/assets/SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET.png)
- 主页背景底抽屉 UI hierarchy：
  - [`SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET.xml`](/D:/EliteSync/docs/reference/soul_settings/assets/SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET.xml)
- 权限弹窗截图：
  - [`SOUL_SETTINGS_003_PERMISSION_DIALOG.png`](/D:/EliteSync/docs/reference/soul_settings/assets/SOUL_SETTINGS_003_PERMISSION_DIALOG.png)
- 返回个人页截图：
  - [`SOUL_SETTINGS_004_RETURN_PROFILE.png`](/D:/EliteSync/docs/reference/soul_settings/assets/SOUL_SETTINGS_004_RETURN_PROFILE.png)

## 低风险探索记录

### 1. 个人页进入设置面板

- 页面入口：个人页右上角 `设置` 图标
- 结果：打开 `主页背景` 底抽屉
- 截图编号：
  - `SOUL_SETTINGS_001_PROFILE_DEFAULT`
  - `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET`
- 参考价值：
  - EliteSync 的个人页设置入口如果要保留轻量感，可以考虑把常用视觉设置做成底抽屉，而不是强制跳转大页面

### 2. 主页背景底抽屉

- 页面名：`主页背景`
- 功能名：主页背景配置面板
- 页面入口：个人页右上角 `设置`
- 核心操作：
  - 查看主页背景
  - 查看商业装扮提示
  - 选择图片背景 / 互动背景
- 回读路径：
  - 在当前样本里，`BACK` 可回到个人页；更深层权限弹窗出现后也可回退至个人页
- 截图编号：
  - `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET`
- 参考价值：
  - 可参考 EliteSync 的“设置面板聚合方式”
  - 可参考 EliteSync 在设置入口中优先展示轻量、低风险的外观类配置

### 3. 商业化装扮入口

- 模块：设置
- 页面名：主页背景
- 功能名：我的空间装扮 / 立即开通
- 页面入口：`主页背景` 底抽屉顶部商业横幅
- 核心操作：
  - 查看权益
  - 了解背景修改次数
  - 进入开通页
- 回读路径：
  - 未进入
- 截图编号：
  - `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET`
- 对 EliteSync 的参考价值：
  - 商业入口和普通设置项要明显分层，避免和基础功能混在一起

### 4. 图片背景设置

- 模块：设置
- 页面名：图片背景
- 功能名：固定单张展示背景图
- 页面入口：`主页背景` 底抽屉中的 `图片背景 / 去设置`
- 核心操作：
  - 进入单张背景配置
  - 预期是选择或设置一张主页背景图
- 回读路径：
  - 被系统相机/媒体权限弹窗阻断，未继续深入
- 截图编号：
  - `SOUL_SETTINGS_003_PERMISSION_DIALOG`
- 对 EliteSync 的参考价值：
  - 外观类配置如果依赖系统权限，最好单独做权限提示与降级路径，避免阻塞用户继续浏览其他设置项

### 5. 互动背景设置

- 模块：设置
- 页面名：互动背景
- 功能名：旋转手机时背景图可切换
- 页面入口：`主页背景` 底抽屉中的 `互动背景 / 去设置`
- 核心操作：
  - 配置旋转态背景切换
- 回读路径：
  - 未稳定进入；当前被权限弹窗打断
- 截图编号：
  - `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET`
  - `SOUL_SETTINGS_003_PERMISSION_DIALOG`
- 对 EliteSync 的参考价值：
  - 适合参考为“设备状态联动视觉效果”的低风险扩展点，但不应和账号安全、支付入口耦合

## 页面与功能表

| 模块 | 页面名 | 功能名 | 页面入口 | 核心操作 | 回读路径 | 截图编号 | 对 EliteSync 的参考价值 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 设置 | 主页背景 | 设置面板入口 | 个人页右上角 `设置` | 打开主页背景底抽屉 | `BACK` 回个人页 | `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET` | 适合参考 EliteSync 的轻量设置抽屉形态 |
| 设置 | 主页背景 | 商业化装扮入口 | `我的空间装扮` / `立即开通` | 查看权益、进入开通页 | 未进入 | `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET` | 适合参考商业入口与基础设置的分层 |
| 设置 | 图片背景 | 主页背景图设置 | `图片背景 / 去设置` | 配置单张背景图 | 被权限弹窗阻断 | `SOUL_SETTINGS_003_PERMISSION_DIALOG` | 适合参考外观配置与系统权限的前置提示 |
| 设置 | 互动背景 | 旋转态背景设置 | `互动背景 / 去设置` | 旋转时切换背景图 | 未稳定进入 | `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET` | 适合参考设备状态联动视觉配置 |
| 设置 | 系统权限弹窗 | 相机 / 媒体权限申请 | 点击 `图片背景 / 去设置` 后出现 | 选择允许 / 拒绝权限 | `BACK` 返回个人页 | `SOUL_SETTINGS_003_PERMISSION_DIALOG` | 适合参考设置深层前的权限边界提示 |

## 结构化结论

- 当前 Soul 设置模块在可见层面，重点是 `主页背景` 与个人主页视觉装扮。
- 商业化入口和基础设置项共存，但通过横幅与按钮文案做了明显分层。
- `图片背景`、`互动背景` 是当前最有价值的低风险观察点。
- 继续往下会触发相机/媒体权限，因此本轮已经构成一个明确 blocker，不应盲点推进。

## 对 EliteSync 的参考价值

- 可以参考 Soul 的设置入口采用“底抽屉 / 轻量设置面板”的结构，而不是一上来强跳大页。
- 视觉设置与商业开通需要分层，避免普通设置页被会员入口打断。
- 如果某些设置依赖系统权限，必须在 UX 上提前提示并提供返回路径。
- 设置面板中的低风险外观项适合优先承接到 EliteSync 的个人主页视觉配置。

## Notes

- Sensitive areas skipped:
  - 支付
  - 会员购买确认
  - 账号删除
  - 手机号绑定
  - 账号安全深区
  - 主动给陌生人发消息
- Blocker:
  - `图片背景 / 去设置` 触发系统相机 / 媒体权限弹窗
  - 未授予权限，保持低风险边界
- Related blocker report:
  - [`SOUL_SETTINGS_BLOCKER_REPORT.md`](/D:/EliteSync/docs/reference/SOUL_SETTINGS_BLOCKER_REPORT.md)
