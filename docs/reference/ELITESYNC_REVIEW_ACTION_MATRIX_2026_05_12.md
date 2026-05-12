# EliteSync Review Action Matrix

生成日期: 2026-05-12

严重度定义: P0=阻断主流程 | P1=严重困惑/误操作风险 | P2=体验不顺/信息不清 | P3=文案/布局/节奏优化 | Observation=非阻断观察

| ID | 来源 | App | 页面 | 问题 | 严重度 | 类型 | 证据路径 | 用户感受 | 建议 | 是否进入后续版本 |
|---|---|---|---|---|---|---|---|---|---|---|
| P0-01 | 文档复测 | EliteSync | Settings | 5.10 "解释与建议设置"完全缺失，5.7-5.10解释层闭环断裂 | P0 | 解释层问题 | `elitesync/xml/EliteSync_guided_settings_001_entry.xml` | 用户无法知道解释和建议不会写资料/改算法/自动发送 | 立即在Settings页添加解释与建议设置入口，包含统一免责声明 | ✅ 5.11 |
| P1-01 | 文档复测 | EliteSync | Profile | 5.8 "我的慢约会表达建议"整套不可见 | P1 | 解释层问题 | `elitesync/screenshots/EliteSync_blind_me_001_entry.png` | 用户无法获得个人表达指导 | 在Profile页添加慢约会表达建议卡片 | ✅ 5.11 |
| P2-04 | 盲测+文档复测 | EliteSync | Match | 5.7 解释层在匹配等待阶段不可见（等待期缺少预热说明，不证明揭晓后5.7不存在） | P1-Observation | 解释层问题 | `elitesync/screenshots/EliteSync_blind_match_001_entry.png` | 等待期间用户不知道"为什么值得聊"意味着什么 | 等待期增加"揭晓后你将看到..."预览说明；需Codex复核揭晓后5.7是否存在 | ✅ 5.11 |
| P1-03 | 盲测 | EliteSync | Profile | "治理与账号可用性"/"治理状态正常"术语行政化 | P1 | 文案问题 | `elitesync/screenshots/EliteSync_blind_me_001_entry.png` | "这是后台管理系统吗？" | 改为"账号状态"/"正常"，去掉"治理"一词 | ✅ 5.11 |
| P1-04 | 盲测 | EliteSync | Profile | 出生地显示火车站名+经纬度 | P1 | 信任问题 | `elitesync/xml/EliteSync_blind_me_001_entry.xml` | "我的位置被精确追踪了？" | 移除经纬度展示；修正出生地为行政地名 | ✅ 5.11 |
| P1-05 | 盲测+文档复测 | EliteSync | Match | "Drop"/"Squad"/"群联"/"总版"术语暴露工程用语 | P1 | 文案问题 | `elitesync/xml/EliteSync_blind_match_001_entry.xml` | "这是什么意思？我不能理解" | 替换为说明书标准术语："匹配结果"/"关系详情"/"解锁资料" | ✅ 5.11 |
| P1-06 | 盲测+文档复测 | EliteSync | Discover | "直播"标签与慢约会定位冲突，且与"语音房"术语不一致 | P1 | 慢约会一致性问题 | `elitesync/screenshots/EliteSync_blind_discover_001_entry.png` | "这是看直播的吗？和约会有什么关系？" | 改为"语音房"或"话题互动" | ✅ 5.11 |
| P1-07 | 盲测+文档复测 | EliteSync | 星盘画像 | 页面只展示原始数据（八字/星象/五行数值），缺少约会场景连接的解释层 | P1 | 解释层问题 | `elitesync/xml/EliteSync_blind_home_001_entry.xml` | "这些数字对我有什么用？" | 增加分区/折叠；每区增加"这对你的约会意味着什么"摘要句 | ✅ 5.11 |
| P2-01 | 盲测 | EliteSync | Home | 首页首屏被问卷卡片占据，慢约会定位不突出 | P2 | 入口问题 | `elitesync/screenshots/EliteSync_blind_home_001_entry.png` | "打开App是做问卷的？" | 将约会相关入口前置，问卷卡片降位或折叠 | 建议 5.12 |
| P2-02 | 盲测 | EliteSync | Home | 状态广场展示测试数据（如"3243434"）和工程标签 | P2 | 信任问题 | `elitesync/xml/EliteSync_blind_home_001_entry.xml` | "这个App是不是没人用？" | 清理测试数据，增加真实用户内容或隐藏空态 | 建议 5.12 |
| P2-03 | 盲测 | EliteSync | Discover | 一级+二级标签共9个，认知负担过重 | P2 | 信息密度问题 | `elitesync/xml/EliteSync_blind_discover_001_entry.xml` | "我该点哪个？太多了" | 合并相似标签，保持≤6个入口 | 建议 5.12 |
| P2-04 | 盲测+文档复测 | EliteSync | Match | 匹配等待期间无中间兴趣点或分流引导 | P2 | 互动节奏问题 | `elitesync/screenshots/EliteSync_blind_match_001_entry.png` | "我现在该干什么？" | 等待期增加"去看看发现"/"完善你的资料"等分流引导 | 建议 5.12 |
| P1-08 | 文档复测 | EliteSync | Settings | "Beta运营准备""回归门禁""版本检查"等开发入口面向用户，直接破坏产品可信度 | P1 | 信息密度问题 | `elitesync/xml/EliteSync_guided_settings_001_entry.xml` | "这是开发者面板吗？产品不可信" | 移至开发者/运营单独入口或隐藏，非开发用户不可见 | ✅ 5.11 |
| P2-05 | 盲测+文档复测 | EliteSync | Chat | "通知回流"术语技术化程度高 | P2 | 文案问题 | `elitesync/xml/EliteSync_blind_chat_001_entry.xml` | 不理解 | 改为"回到聊天"或"查看通知" | 建议 5.12 |
| P2-06 | 盲测+文档复测 | EliteSync | Profile | "个人经营区"入口名称含义模糊 | P2 | 入口问题 | `elitesync/screenshots/EliteSync_blind_me_001_entry.png` | "点进去是赚钱还是编辑资料？" | 改为"完善个人主页"或拆分为明确子入口 | 建议 5.12 |
| P2-07 | 盲测 | EliteSync | Profile | "婚恋目标"值为"交友"，与产品核心定位"慢约会"不一致 | P2 | 慢约会一致性问题 | `elitesync/xml/EliteSync_blind_me_001_entry.xml` | "交友"传达的是泛化社交 | 改为"慢约会"/"认真关系"或保持可选项一致 | 建议 5.12 |
| P2-08 | 盲测 | EliteSync | 星盘画像 | 引擎版本("legacy_input")和数字签名("9d369132")暴露 | P2 | 信息密度问题 | `elitesync/xml/EliteSync_blind_home_001_entry.xml` | "这些是什么？为什么给我看？" | 隐藏开发标签，仅保留用户可理解的置信度说明 | 建议 5.12 |
| P2-09 | 盲测 | EliteSync | 星盘画像 | 页面不可交互（只有返回按钮），用户体验为"死胡同" | P2 | 互动节奏问题 | `elitesync/xml/EliteSync_blind_home_001_entry.xml` | "看完了，然后呢？" | 增加相关功能跳转（如"查看匹配"或"完善资料"） | 建议 5.12 |
| P3-01 | 盲测 | EliteSync | Home | 快捷入口"星盘画像"缺乏上下文解释 | P3 | 文案问题 | `elitesync/screenshots/EliteSync_blind_home_001_entry.png` | "这是什么？点进去有什么？" | 增加简短副标题："了解你的星盘与画像" | 后续优化 |
| P3-02 | 盲测 | EliteSync | Discover | "直播发现"和"你可能喜欢"内容重复 | P3 | 信息密度问题 | `elitesync/xml/EliteSync_blind_discover_001_entry.xml` | "为什么同一内容出现两次？" | 去重或明确区分两个分区的推荐逻辑 | 后续优化 |
| P3-03 | 文档复测 | EliteSync | Profile/Settings | 设置齿轮图标缺少无障碍标签 | P3 | 技术阻塞 | `elitesync/xml/EliteSync_blind_me_001_entry.xml` | 无法通过辅助功能发现设置入口 | 为齿轮图标添加 content-desc="设置" | 后续优化 |
| P3-04 | 盲测 | EliteSync | Match | "完整解释"按钮功能预期不明确 | P3 | 文案问题 | `elitesync/xml/EliteSync_blind_match_001_entry.xml` | "点击会看到什么？" | 改为"查看完整解释"并增加副文本提示 | 后续优化 |
| P3-05 | 盲测 | EliteSync | Chat | "去匹配"在消息页功能区和底部导航重复出现 | P3 | 入口问题 | `elitesync/xml/EliteSync_blind_chat_001_entry.xml` | "两个匹配入口有什么区别？" | 消息页保留一个去匹配入口 | 后续优化 |
| P3-06 | 盲测 | EliteSync | Chat | "聊天节奏"按钮功能预期不明 | P3 | 文案问题 | `elitesync/xml/EliteSync_blind_chat_001_entry.xml` | 不知道点击后会发生什么 | 增加副文本说明 | 后续优化 |
| P3-07 | 盲测 | EliteSync | Profile | 资料完整度50%可能对用户产生压力感 | P3 | 互动节奏问题 | `elitesync/screenshots/EliteSync_blind_me_001_entry.png` | "我被打了低分" | 改为正向引导："完善3项资料让你的主页更清晰" | 后续优化 |
| OB-01 | Soul对照 | Soul | 广场 | Soul "发布自我介绍贴" CTA 激励自我表达 | Observation | 竞品差距 | `soul/screenshots/Soul_home_001_entry.png` | — | 在EliteSync Status/Profile增加轻量表达引导 | 长期观察 |
| OB-02 | Soul对照 | Soul | Chat | Soul 关系阶段标签（暧昧期等） | Observation | 竞品差距 | — | — | 吸收为轻量关系节奏提示，不用固定阶段名 | 长期观察 |
| OB-03 | CECE对照 | CECE | 首页 | CECE 功能图标矩阵（人盘/星盘/生辰/合盘） | Observation | 竞品差距 | `cece/screenshots/CECE_home_001_adb.png` | — | 重构 EliteSync 玄学入口为分类图标导航 | 长期观察 |
| OB-04 | CECE对照 | CECE | 首页 | CECE 生活化CTA文案 | Observation | 竞品差距 | `cece/screenshots/CECE_home_001_adb.png` | — | EliteSync 引导文案向生活化方向优化 | 长期观察 |
| OB-05 | 文档复测 | EliteSync | Chat | 5.9 低压开场建议未在活跃会话中验证 | Observation | — | — | — | 需进入有实际消息的会话 | 后续测试 |
| OB-06 | 盲测 | EliteSync | — | 双端互动测试未完成 | Observation | — | — | — | 需模拟器+手机同时操作 | 后续测试 |
| OB-07 | 盲测 | EliteSync | — | 媒体消息/语音通话功能未验证 | Observation | — | — | — | 需完整测试环境 | 后续测试 |
