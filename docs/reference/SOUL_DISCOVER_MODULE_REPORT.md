# Soul 发现 / 广场 模块拆解报告

## Session

- Date: 2026-05-01
- Device: emulator-5554
- Package: `cn.soulapp.android`
- Module: 发现 / 广场 Feed / 同城 / 搜索 / 分享面
- Scope: 仅做低风险推荐流、同城、搜索与浅层分享 / moderation 探索

## 页面概览

当前 Soul 的发现模块不是单纯的内容流，而是一个复合的“推荐 / 同城 / 搜索 / 分享 / 互动”入口层。
当前可见结构大致分为：

- 顶部分类 Tab：`关注 / 推荐 / 同城`
- 顶部功能位：`广场相机 / 搜索 / 音乐故事`
- 中间 Feed 卡片：头像、昵称、发布时间、正文、图片、位置、`私聊`、`喜欢`、`评论`、`关注`、`分享或举报`
- 右下侧快捷入口：`小信封`
- 底部导航：`星球 / 广场 / 发布瞬间 / 聊天 / 自己`

其中，发现页的交互明显围绕“浏览内容 + 低风险互动 + 同城探索 + 搜索热点”展开。

## 可见一级入口

- 顶部分类：
  - `关注`
  - `推荐`
  - `同城`
- 顶部功能：
  - `广场相机`
  - `搜索`
  - `音乐故事`
- Feed 卡片互动：
  - `私聊`
  - `喜欢`
  - `评论`
  - `关注`
  - `分享或举报`
- 右下侧快捷入口：
  - `小信封`
- 底部主导航：
  - `星球`
  - `广场`
  - `发布瞬间`
  - `聊天`
  - `自己`

## 低风险探索记录

### 1. 推荐 Feed 默认态

- 截图：
  - [`SOUL_DISCOVER_000_CURRENT.png`](./soul_discover/assets/SOUL_DISCOVER_000_CURRENT.png)
  - [`SOUL_DISCOVER_001_RECOMMEND_FEED.png`](./soul_discover/assets/SOUL_DISCOVER_001_RECOMMEND_FEED.png)
- 层级：
  - [`SOUL_DISCOVER_001_RECOMMEND_FEED.xml`](./soul_discover/assets/SOUL_DISCOVER_001_RECOMMEND_FEED.xml)
- 观察到的内容：
  - 顶部 `关注 / 推荐 / 同城`
  - 左侧 `广场相机`
  - 右侧 `搜索` 与 `音乐故事`
  - Feed 卡片内容包含：
    - 头像 / 昵称 / 发布时间
    - 正文
    - `私聊`
    - `关注`
    - `喜欢`
    - `评论`
    - `分享或举报`
  - 右下侧快捷入口：
    - `小信封`
  - 底部导航：
    - `星球 / 广场 / 发布瞬间 / 聊天 / 自己`
- 回读路径：
  - 保持在 `推荐` tab，或通过底部导航返回 `广场`
- 参考价值：
  - 可参考 EliteSync 发现页的信息流分栏和导航节奏

### 2. 卡片分享 / moderation 面板

- 截图：
  - [`SOUL_DISCOVER_002_SHARE_SHEET.png`](./soul_discover/assets/SOUL_DISCOVER_002_SHARE_SHEET.png)
- 层级：
  - [`SOUL_DISCOVER_002_SHARE_SHEET.xml`](./soul_discover/assets/SOUL_DISCOVER_002_SHARE_SHEET.xml)
- 观察到的内容：
  - 标题：`分享至好友`
  - 分享目标：
    - `微信`
    - `朋友圈`
    - `QQ`
    - `QQ空间`
    - `微博`
    - `更多`
  - 互动 / moderation 动作：
    - `私聊`
    - `关注`
    - `不喜欢`
    - `举报`
    - `复制链接`
- 页面入口：
  - 推荐 Feed 第一张卡片的 `分享或举报`
- 核心操作：
  - 分享到外部平台
  - 低风险 moderation 操作
  - 链接复制
- 回读路径：
  - 关闭底部面板后回到推荐 Feed
  - `BACK` 也可回到 Feed
- 参考价值：
  - 可参考 EliteSync 的卡片分享面板与 moderation 动作分层

### 3. 同城 Tab / 本地推荐流

- 截图：
  - [`SOUL_DISCOVER_004_CITY_TAB.png`](./soul_discover/assets/SOUL_DISCOVER_004_CITY_TAB.png)
- 层级：
  - [`SOUL_DISCOVER_004_CITY_TAB.xml`](./soul_discover/assets/SOUL_DISCOVER_004_CITY_TAB.xml)
- 观察到的内容：
  - 顶部 `同城` 已选中
  - 提示条：`为您推荐了8个瞬间`
  - 位置引导卡：
    - `开启定位，解锁同城瞬间`
    - `发现同城的小美好`
    - `开启`
  - 同城卡片继续保留：
    - `私聊`
    - `关注`
    - `喜欢`
    - `评论`
    - `分享或举报`
- 页面入口：
  - 顶部分类 tab 的 `同城`
- 核心操作：
  - 浏览本地内容
  - 观察位置解锁提示
  - 通过定位进一步解锁同城流
- 回读路径：
  - 切回 `推荐` tab 即可返回推荐 Feed
- 参考价值：
  - 可参考 EliteSync 的同城 / 地域内容分层

### 4. 搜索页 / 热词与恋爱提示

- 截图：
  - [`SOUL_DISCOVER_005_SEARCH_PAGE.png`](./soul_discover/assets/SOUL_DISCOVER_005_SEARCH_PAGE.png)
- 层级：
  - [`SOUL_DISCOVER_005_SEARCH_PAGE.xml`](./soul_discover/assets/SOUL_DISCOVER_005_SEARCH_PAGE.xml)
- 观察到的内容：
  - 搜索框：`搜索`
  - 右侧按钮：`搜索`
  - 提示卡：
    - `测测今日的恋爱幸运数字`
    - `问问其他`
  - 热搜区标题：`热SOUL`
  - 热词示例：
    - `五一劳动节快乐`
    - `五月的天 刚诞生的夏天`
    - `其他水果统统让道！荔枝季来了`
    - `强扭的瓜不甜但是解渴`
    - `Soul星神仙画手申请出战！`
    - `蓝花楹最佳观赏期💜`
    - `带上256G的胃见面吧`
- 页面入口：
  - 顶部右侧 `搜索`
- 核心操作：
  - 搜索内容 / 用户 / 话题
  - 查看热搜词
  - 从恋爱提示卡进入话题或提示探索
- 回读路径：
  - 顶部返回箭头或 `BACK` 返回 Feed
- 参考价值：
  - 可参考 EliteSync 的内容搜索、热词推荐、提示卡结构

## Page Record

| 模块 | 页面名 | 功能名 | 页面入口 | 核心操作 | 回读路径 | 截图编号 | 对 EliteSync 的参考价值 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 发现 | 推荐 Feed 默认态 | 顶部分类 Tab | 底部 `广场` 默认页，顶部 `关注 / 推荐 / 同城` | 切换推荐流分类 | 保持 `推荐` tab，或底部导航回广场 | `SOUL_DISCOVER_001_RECOMMEND_FEED` | 可参考 EliteSync 发现页的信息流分栏和导航节奏 |
| 发现 | 推荐 Feed 默认态 | 顶部功能位 | 首页顶部 `广场相机 / 搜索 / 音乐故事` | 打开相机、搜索、音乐故事入口 | 回到 Feed 默认态 | `SOUL_DISCOVER_001_RECOMMEND_FEED` | 可参考 EliteSync 顶栏快捷入口的密度与视觉权重 |
| 发现 | 推荐 Feed 默认态 | 卡片互动入口 | Feed 卡片内 `私聊 / 关注 / 喜欢 / 评论 / 分享或举报` | 低风险互动、关注、点赞、评论、分享 / 举报 | 返回当前卡片或上一条卡片 | `SOUL_DISCOVER_001_RECOMMEND_FEED` | 可参考 EliteSync 动态卡 CTA 摆放与互动层级 |
| 发现 | 分享至好友 | 分享 / moderation 面板 | Feed 卡片 `分享或举报` | 分享到外部平台，执行 `私聊 / 关注 / 不喜欢 / 举报 / 复制链接` | 关闭面板或 `BACK` 返回 Feed | `SOUL_DISCOVER_002_SHARE_SHEET` / `SOUL_DISCOVER_003_RETURN_FEED` | 可参考 EliteSync 的分享面板和轻量治理动作分层 |
| 发现 | 同城 Tab | 本地内容流与定位解锁 | 顶部 `同城` tab | 浏览本地内容，观察 `开启定位，解锁同城瞬间` | 切回 `推荐` tab 返回 Feed | `SOUL_DISCOVER_004_CITY_TAB` | 可参考 EliteSync 的同城内容分层与按需权限提示 |
| 发现 | 搜索页 | 热词 / 提示卡 | 顶部右侧 `搜索` | 搜索内容、查看热词、进入恋爱提示卡 | 顶部返回或 `BACK` 返回 Feed | `SOUL_DISCOVER_005_SEARCH_PAGE` | 可参考 EliteSync 的搜索页、热词榜与提示卡结构 |

## Notes

- Sensitive areas skipped:
  - 支付
  - 会员购买
  - 账号安全深区
  - 删除账号
  - 主动给陌生人发送真实内容
- Second-level branches explored:
  - 推荐 Feed 的 `分享或举报`
  - 同城 tab 的位置解锁提示
  - 搜索页的热词 / 恋爱提示卡
- Unknowns / follow-ups:
  - `音乐故事` 的内部页面仍未深入
  - `小信封` 右下快捷入口的真实语义后续可再验证
  - `开启定位` 是否会显著改变同城内容流，后续可在用户授权前提下继续观察

## Evidence

- Screenshot file(s):
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_000_CURRENT.png`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_001_RECOMMEND_FEED.png`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_002_SHARE_SHEET.png`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_003_RETURN_FEED.png`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_004_CITY_TAB.png`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_005_SEARCH_PAGE.png`
- UI hierarchy file(s):
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_000_CURRENT.xml`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_001_RECOMMEND_FEED.xml`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_002_SHARE_SHEET.xml`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_003_RETURN_FEED.xml`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_004_CITY_TAB.xml`
  - `D:\EliteSync\docs\reference\soul_discover\assets\SOUL_DISCOVER_005_SEARCH_PAGE.xml`
- Back-navigation evidence:
  - `SOUL_DISCOVER_003_RETURN_FEED` 作为分享面板返回 Feed 的证据
  - `SOUL_DISCOVER_004_CITY_TAB` 通过切换 tab 回到推荐流
  - `SOUL_DISCOVER_005_SEARCH_PAGE` 通过返回箭头 / `BACK` 回到发现页

