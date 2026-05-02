# Soul 聊天模块拆解报告

## Session

- Date: 2026-05-01
- Device: emulator-5554
- Package: `cn.soulapp.android`
- Module: 聊天 / 聊天列表 / 奇遇铃对话
- Scope: 仅做低风险聊天列表、系统通知、奇遇铃与浅层会话探索

## 页面概览

当前 Soul 的聊天模块不是单一 IM 列表，而是一个混合了：

- 通讯录 / 聊天 双 Tab
- 搜索
- 会话列表
- 商业化/活动入口
- 系统通知
- 奇遇铃待聊列表
- 具体会话页
- 底部主导航

的复合入口层。

其中最有价值的低风险结构包括：

- 聊天列表顶部的 `通讯录 / 聊天` 分栏
- 会话卡片上的未读点、时间、摘要、活动标题
- `奇遇铃-稍后再聊` 的低风险候聊/回聊列表
- 具体聊天页中的 `关注`、`查看主页`、`聊天设置`
- 输入栏中的语音、文本、AI 回复、表情、更多入口

## 可见一级入口

- 顶部页签：
  - `通讯录`
  - `聊天`
- 顶部功能：
  - `+`
  - 搜索框：`搜索备注、昵称或者聊天记录`
  - 右侧排序 / 筛选按钮
- 聊天列表会话入口：
  - `宇宙哔哔机特权`
  - `有趣的灵魂正在等你`
  - `奇遇铃-稍后再聊`
  - `系统通知`
  - `Soul空间站`
- 底部主导航：
  - `星球`
  - `广场`
  - `发布瞬间`
  - `聊天`
  - `自己`

## 低风险探索记录

### 1. 聊天列表默认态

- 截图：
  - [`SOUL_CHAT_001_LIST_DEFAULT.png`](./soul_chat/assets/SOUL_CHAT_001_LIST_DEFAULT.png)
- 层级：
  - [`SOUL_CHAT_001_LIST_DEFAULT.xml`](./soul_chat/assets/SOUL_CHAT_001_LIST_DEFAULT.xml)
- 观察到的结构：
  - 顶部 `通讯录 / 聊天`
  - 搜索框
  - 右侧排序 / 筛选按钮
  - 多个会话卡片
  - 底部导航
- 会话卡结构：
  - 左侧头像 / 图标
  - 主标题
  - 副标题 / 摘要
  - 右侧时间
  - 未读红点
- 回读路径：
  - `BACK` 或底部导航可回到此页

### 2. 奇遇铃-稍后再聊列表

- 截图：
  - [`SOUL_CHAT_002_QIYU_LIST.png`](./soul_chat/assets/SOUL_CHAT_002_QIYU_LIST.png)
- 层级：
  - 低风险列表页，无需额外弹窗
- 观察到的结构：
  - 标题：`奇遇铃-稍后再聊`
  - 说明：`仅保留最近3天你直接关闭的用户哦`
  - 用户卡：
    - `jingjing`
    - `微塔女孩`
  - 关系 / 推荐标签：
    - `处女座的他，今天和你最搭`
    - `你们距离很近哦`
  - AI 灵感回复区：
    - `你好 / 可以认识一下么`
    - `哈喽哈喽 / 小姐姐好呀`
    - 描述：`经典问候，安全不出错`
  - 输入栏：
    - 语音按钮
    - 文本输入框
    - AI 回复按钮
    - 表情按钮
    - 更多按钮
- 入口：
  - 从聊天列表点击 `奇遇铃-稍后再聊`
- 回读路径：
  - `BACK` 返回聊天列表
- 参考价值：
  - 非常适合 EliteSync 的首聊引导、冰破建议、推荐回复和轻量关系推进设计

### 3. jingjing 具体会话页

- 截图：
  - [`SOUL_CHAT_003_QIYU_CONVERSATION.png`](./soul_chat/assets/SOUL_CHAT_003_QIYU_CONVERSATION.png)
- 层级：
  - [`SOUL_CHAT_003_QIYU_CONVERSATION.xml`](./soul_chat/assets/SOUL_CHAT_003_QIYU_CONVERSATION.xml)
- 观察到的结构：
  - 顶部：
    - 返回
    - 会话标题 `jingjing`
    - `关注`
    - `聊天设置`
  - 关系推进区：
    - `关注后可邀请通话`
    - `展开`
  - 对方主页 / 资料卡：
    - `匹配度 94%`
    - `Ta忧郁骑士星球`
    - `查看主页`
    - `Ta的认证：ISFJ`
    - `Ta的引力签：无聊很闷的一个人`
    - `你们的共同点：河南`
  - 灵感回复区：
    - `灵感回复可提升回复率哦`
    - `你好 / 可以认识一下么`
    - `哈喽哈喽 / 小姐姐好呀`
  - 输入区：
    - 语音按钮
    - 文本输入框 `文明聊天，友善交友~`
    - AI 按钮
    - 表情按钮
    - 更多按钮
- 入口：
  - 从 `奇遇铃-稍后再聊` 点击 `jingjing`
- 核心操作：
  - 查看对方资料卡
  - 关注
  - 展开更多关系 / 画像信息
  - 查看主页
  - 观察推荐回复和输入区结构
- 回读路径：
  - 顶部 `返回` 或 `BACK` 返回 `奇遇铃-稍后再聊` 列表
- 参考价值：
  - 可直接参考 EliteSync 聊天页的关系推进按钮布局、对方资料卡密度、冰破建议与输入栏组件组合

### 4. 系统通知页

- 截图：
  - [`SOUL_CHAT_004_SYSTEM_NOTICE.png`](./soul_chat/assets/SOUL_CHAT_004_SYSTEM_NOTICE.png)
- 观察到的结构：
  - `系统通知`
  - `Soul防骗贴士`
  - `展开`
- 入口：
  - 从聊天列表点击 `系统通知`
- 回读路径：
  - `BACK` 返回聊天列表
- 参考价值：
  - 可参考 EliteSync 的系统通知卡片和安全提示样式

### 5. 随机互动玩法 blocker

- 截图：
  - [`SOUL_CHAT_005_RANDOM_INTERACTION_BLOCKER.png`](./soul_chat/assets/SOUL_CHAT_005_RANDOM_INTERACTION_BLOCKER.png)
- 观察到的结构：
  - 标题：`随机互动玩法上线啦`
  - 文案：`只需朋友戳一下就能随机解锁更多互动游戏，快来设置吧`
  - 按钮：
    - `稍等一下`
    - `前往设置`
- 入口：
  - 从系统通知分支继续进入
- 回读路径：
  - `BACK` 可退回到系统通知或聊天列表
- 参考价值：
  - 说明 Soul 的聊天系统会把部分互动玩法引导到设置型页面；EliteSync 若做类似能力，建议明确分层，不要和普通会话页混在一起

## 聊天页输入结构补充

从 `jingjing` 会话页的 hierarchy 可确认输入区域由以下部分构成：

- 左侧语音按钮：`menu_tab_voice_inner_outside`
- 文本输入框：`文明聊天，友善交友~`
- AI 回复入口：`img_chat_aigc`
- 表情按钮：`表情`
- 更多按钮：`更多`

低风险探索中未发送任何真实文本，仅观察输入结构。

## 关系推进 / 联动入口观察

- `关注`：可对会话对象发起关注
- `关注后可邀请通话`：说明关注是通话类关系推进前置条件
- `查看主页`：可见但本轮未深入
- `聊天设置`：可见但未进入

## Page Record

| 模块 | 页面名 | 功能名 | 页面入口 | 核心操作 | 回读路径 | 截图编号 | 对 EliteSync 的参考价值 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 聊天 | 聊天列表默认态 | 顶部分类与搜索 | 底部 `聊天` tab 默认页 | 切换 `通讯录 / 聊天`、搜索备注/昵称/聊天记录、浏览会话卡 | `BACK` / 底部导航 | `SOUL_CHAT_001_LIST_DEFAULT` | 可参考 EliteSync 聊天首页的分栏、搜索与卡片密度 |
| 聊天 | 聊天列表默认态 | 会话卡结构 | 聊天列表中的普通会话 / 活动会话卡 | 识别头像、标题、摘要、时间、未读点 | 点击会话进入详情；`BACK` 返回列表 | `SOUL_CHAT_001_LIST_DEFAULT` | 可参考 EliteSync 消息列表的会话卡信息层级 |
| 聊天 | 奇遇铃-稍后再聊 | 首聊 / 冰破列表 | 聊天列表点击 `奇遇铃-稍后再聊` | 浏览最近3天直接关闭的用户，查看 AI 灵感回复 | `BACK` 返回聊天列表 | `SOUL_CHAT_002_QIYU_LIST` | 可参考 EliteSync 的首聊推荐、破冰建议与回聊队列 |
| 聊天 | 奇遇铃-稍后再聊 | 推荐回复卡 | `奇遇铃-稍后再聊` 页底部灵感回复区 | 直接选取推荐问候语 | `BACK` 返回列表 | `SOUL_CHAT_002_QIYU_LIST` | 可参考 EliteSync 的安全问候模板、推荐回复与“经典问候”文案 |
| 聊天 | jingjing 会话页 | 对方资料卡 | 在奇遇铃列表点击 `jingjing` | 查看匹配度、星球、认证、引力签、共同点 | `返回` / `BACK` 回奇遇铃列表 | `SOUL_CHAT_003_QIYU_CONVERSATION` | 可参考 EliteSync 聊天页顶部资料卡、画像摘要与关系分数展示 |
| 聊天 | jingjing 会话页 | 关注 / 关系推进 | 会话页顶部 `关注` 与 `关注后可邀请通话` | 提升关系状态，为后续通话做准备 | `BACK` 回奇遇铃列表 | `SOUL_CHAT_003_QIYU_CONVERSATION` | 可参考 EliteSync 的关系推进按钮与通话前置条件提示 |
| 聊天 | jingjing 会话页 | 资料联动入口 | 会话页 `查看主页` | 进入对方主页查看更完整资料 | 本轮仅观察到入口，未进入 | `SOUL_CHAT_003_QIYU_CONVERSATION` | 可参考 EliteSync 聊天页到个人页的轻量联动入口 |
| 聊天 | jingjing 会话页 | 输入区结构 | 底部输入栏 | 语音、输入、AI、表情、更多 | `BACK` 回奇遇铃列表 | `SOUL_CHAT_003_QIYU_CONVERSATION` | 可参考 EliteSync 聊天输入栏组件拆分与快捷按钮布局 |
| 聊天 | 系统通知 | 系统通知卡片 | 聊天列表点击 `系统通知` | 查看防骗贴士、展开说明 | `BACK` 回聊天列表 | `SOUL_CHAT_004_SYSTEM_NOTICE` | 可参考 EliteSync 的系统通知 / 安全提醒样式 |
| 聊天 | 随机互动玩法 blocker | 互动玩法引导页 | `系统通知` -> `Soul防骗贴士` -> `展开` | 查看互动玩法说明，触发设置引导 | `BACK` 回系统通知 / 聊天列表 | `SOUL_CHAT_005_RANDOM_INTERACTION_BLOCKER` | 可参考 EliteSync 对互动玩法、设置入口和提示文案的分层设计 |

## 对 EliteSync 的参考价值

- 聊天模块不是单纯列表，而是“列表 + 冰破引导 + 资料卡 + 关系推进 + 输入栏”的组合。
- AI 灵感回复是很好的首聊入口，可作为 EliteSync 的破冰推荐模板参考。
- 会话页顶部的 `关注`、`查看主页`、`聊天设置` 形成了清晰的关系 / 联动入口层级，值得参考。
- 输入区将语音、文本、AI、表情、更多拆成独立按钮，交互层次清晰。
- 系统通知和随机互动玩法之间有明显分层，适合 EliteSync 做通知 / 引导 / 设置的边界分离。

## Notes

- Sensitive areas skipped:
  - 支付
  - 会员购买确认
  - 账号安全
  - 删除账号
  - 主动给陌生人发送真实内容
- Blockers:
  - `系统通知` 分支最终进入了 `随机互动玩法上线啦` 的设置型引导页
  - `宇宙哔哔机特权` 这类商业化入口存在，但未继续深入
- Unknowns / follow-ups:
  - `查看主页` 与 `聊天设置` 可见但本轮未深入
  - 未来若要补全聊天模块，可继续低风险探索会话页与对方主页的联动

## Evidence

- Screenshot file(s):
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_001_LIST_DEFAULT.png`
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_002_QIYU_LIST.png`
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_003_QIYU_CONVERSATION.png`
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_004_SYSTEM_NOTICE.png`
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_005_RANDOM_INTERACTION_BLOCKER.png`
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_006_RETURN_TO_CHAT_LIST.png`
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_007_RETURN_TO_QIYU_LIST.png`
- UI hierarchy file(s):
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_001_LIST_DEFAULT.xml`
  - `D:\EliteSync\docs\reference\soul_chat\assets\SOUL_CHAT_003_QIYU_CONVERSATION.xml`
- Back-navigation evidence:
  - conversation -> `BACK` -> `奇遇铃-稍后再聊`
  - `奇遇铃-稍后再聊` -> `BACK` -> chat list
  - system notice / blocker branch -> `BACK` -> returned to previous safe page
