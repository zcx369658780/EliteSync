# Soul 首页模块拆解报告

## Session

- Date: 2026-05-01
- Device: emulator-5554
- Package: `cn.soulapp.android`
- Module: 首页 / 广场 Feed
- Scope: 仅做低风险首页与浅层浮层探索

## 页面概览

当前 Soul 首页为“广场”信息流形态，核心结构清晰，包含：

- 顶部分类 Tab：`关注 / 推荐 / 同城`
- 顶部功能区：`广场相机 / 搜索 / 音乐故事`
- 中间 Feed 卡片：头像、昵称、发布时间、关注、分享/举报、正文、图片、私聊、喜欢、评论
- 底部导航：`星球 / 广场 / 发布瞬间 / 聊天 / 自己`

低风险探索中，还触发到一个电台推荐浮层：

- 标题：`来跟我一起听随机电台吧`
- 主卡：`大城小事`
- 操作：播放 / 下一首 / 随机 / 喜欢 / 关闭 / `好的`
- 关闭后回到首页 Feed

## Page Record

| 模块 | 页面名 | 功能名 | 页面入口 | 核心操作 | 回读路径 | 截图编号 | 对 EliteSync 的参考价值 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 首页 | 首页（广场 Feed） | 顶部分类 Tab | App 启动后默认进入首页；顶部 `关注 / 推荐 / 同城` | 切换信息流分类 | 保持首页；必要时用返回键回到首页默认态 | `SOUL_HOME_001_HOME` | 主页信息架构可参考 EliteSync 首页 / 发现 / 同城的分栏组织 |
| 首页 | 首页（广场 Feed） | 顶部功能区 | 首页顶部左侧相机、右侧搜索与音乐故事入口 | 打开相机 / 搜索 / 音乐故事入口 | 返回首页 Feed | `SOUL_HOME_001_HOME` | 首页顶部工具区密度与入口分层可参考 EliteSync 首页快捷入口布局 |
| 首页 | 首页（广场 Feed） | 卡片互动入口 | Feed 卡片内的 `私聊 / 喜欢 / 评论 / 关注 / 分享或举报` | 私聊、关注、点赞、评论、查看更多操作 | 返回当前 Feed 卡片或上一条 Feed | `SOUL_HOME_001_HOME` | 可参考 EliteSync 信息流卡片的 CTA 摆放、互动按钮层级与间距 |
| 首页 | 首页（广场 Feed） | 底部导航 | 首页底部 `星球 / 广场 / 发布瞬间 / 聊天 / 自己` | 切换主功能区 | 用底部 Tab 返回任意主页面 | `SOUL_HOME_001_HOME` | 可参考 EliteSync 主导航的视觉重心、中心发布按钮和五段式导航 |
| 首页 | 首页（广场 Feed） | 随机电台推荐浮层 | 在首页顶部区域轻触后弹出的电台推荐卡 | 播放 / 下一首 / 随机 / 喜欢 / `好的` / 关闭 | 点击左上角关闭按钮回到首页；`BACK` 不一定直接关闭 | `SOUL_HOME_002_OVERLAY` / `SOUL_HOME_003_RETURN_HOME` | 可参考 EliteSync 的轻量引导浮层、媒体卡和临时推荐卡样式 |

## 可见一级入口

- 顶部分类：`关注 / 推荐 / 同城`
- 顶部功能：`广场相机 / 搜索 / 音乐故事`
- Feed 卡片互动：`私聊 / 喜欢 / 评论 / 关注 / 分享或举报`
- 底部主导航：`星球 / 广场 / 发布瞬间 / 聊天 / 自己`
- 低风险浮层：随机电台推荐卡

## 低风险分支探索记录

### 1. 首页默认态

- 首页默认停留在 `推荐` 信息流
- 可见卡片包含：
  - 用户头像 / 昵称 / 发布时间
  - `关注`
  - `分享或举报`
  - 内容正文
  - 图片内容
  - `私聊`
  - `喜欢`
  - `评论`

### 2. 首页顶部区域触发的随机电台浮层

- 触发后出现一张电台推荐浮层
- 浮层中可见：
  - `来跟我一起听随机电台吧`
  - `大城小事`
  - 播放 / 暂停
  - 下一首
  - 随机
  - 喜欢
  - `迷幻烟嗓`
  - `好的`
  - 左上角关闭按钮
- 返回路径：
  - 点击左上角关闭按钮可回到首页 Feed
  - `BACK` 在当前样本中不作为可靠关闭路径

## 截图与层级证据

- `D:\EliteSync\docs\reference\soul_home\assets\SOUL_HOME_001_HOME.png`
- `D:\EliteSync\docs\reference\soul_home\assets\SOUL_HOME_001_HOME.xml`
- `D:\EliteSync\docs\reference\soul_home\assets\SOUL_HOME_002_OVERLAY.png`
- `D:\EliteSync\docs\reference\soul_home\assets\SOUL_HOME_002_OVERLAY.xml`
- `D:\EliteSync\docs\reference\soul_home\assets\SOUL_HOME_003_RETURN_HOME.png`
- `D:\EliteSync\docs\reference\soul_home\assets\SOUL_HOME_003_RETURN_HOME.xml`

## 对 EliteSync 的参考价值

- 首页信息流分栏清晰，适合继续保持“主 Tab + 内容 Feed + 快捷入口”的结构。
- Feed 卡片上的 `私聊` 入口很轻量，适合作为 EliteSync 消息入口的布局参考。
- 底部中心发布按钮与五段式导航的结合，适合继续参考 EliteSync 的主导航节奏。
- 浮层媒体卡的样式可参考 EliteSync 的轻量推荐卡 / 临时引导卡设计。

## Notes

- Sensitive areas skipped:
  - 支付
  - 会员购买
  - 账号安全
  - 删除账号
  - 私信深区
- Unknowns / follow-ups:
  - 顶部 `关注` 轻触后出现随机电台浮层，是否为稳定交互仍需后续复测。
  - 本次只做了低风险首页探索，未深入私信或账号敏感页。
