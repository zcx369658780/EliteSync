# EliteSync 整体开发计划书 5.6+ 玄学能力二次产品化修订版

更新时间：2026-05-11

状态：planning draft

当前口径：本文件只修订路线与整体开发计划，不进入 runtime 实现，不提出数据库迁移，不提交，不 push。

## 0. 本次修订目的与最终结论

本次修订用于承接两类研究结论：

- Soul 仍作为 EliteSync 社交主链参考，继续服务 Discover、Match、Chat、Me、关系推进、低压开场、个人经营等主链设计。
- 测测 Stage 1-5 已完成，作为玄学解释层参考，不再继续扩大 Stage 6 拆解。

修订后的总判断：

> 5.0-5.5 作为已完成历史链路，不重写；5.6 起进入“玄学能力二次产品化与校准线”，把已有星盘、画像、匹配解释、关系理解能力转化为 Match / Me / Chat 主链中的 derived-only / display-only / explanation layer。

本轮不是把 EliteSync 改成测测，也不是启动真人玄学咨询、付费报告或上传截图链。测测只提供结构启发：入口层、上下文层、解释对象层、解释 / 建议层。追问 / 转化层只做克制参考，不作为近期主线。

## 1. 本轮只读参考与缺失记录

已读取并用于本文件的参考：

- `docs/reference/CECE_ALL_DECOMPOSITION_REPORTS_AND_TEXT_EVIDENCE_2026_05_11.md`
- `docs/reference/CECE_STAGE2_AIASK_ONLINE_REPORT_CLAUDE_RERUN.md`
- `docs/reference/CECE_STAGE3_TEST_RESULT_REPORT_CLAUDE_RERUN.md`
- `docs/reference/CECE_STAGE4_ASTRO_OVERVIEW_REPORT_CLAUDE_RERUN.md`
- `docs/reference/CECE_STAGE5_RELATIONSHIP_COMPOSITE_REPORT_CLAUDE_RERUN.md`
- `docs/version_plans/elite_sync_整体开发计划书_5_x方向重排版_2026_05_01.md`
- `docs/version_plans/elite_sync_未来版本开发路线图草案_2026_05_01.md`
- `docs/agents/CODEX_CYBER_SAFE_UI_RESEARCH_RULES.md`

用户指定但当前工作树不存在的参考：

- `docs/02_ARCHITECTURE_AND_BOUNDARIES.md`
- `docs/06_PRODUCT_MODULES.md`
- `docs/08_UI_IA_RULES.md`

缺失文件不阻断本草稿；本文件继续继承现有 5.x 计划、UI research 安全规则、4.9 稳定基线与仓库级 protected surfaces 口径。

## 2. 5.0-5.5 历史链路处理

5.0-5.5 不在本文件中重写。它们作为已完成或既定历史链路保留：

- 5.0-5.3：产品化补强、关系推进、个人经营页、测试运营准备与云端治理增强。
- 5.4-5.5：真实小样本反馈吸收、治理收口、当前阶段前置结论沉淀。
- 4.9：继续作为稳定门禁基线。

本文件只定义 5.6+ 的新增方向，不回头修改 5.0-5.5 的版本定位和既有归档结论。

## 3. 新阶段定位：玄学能力二次产品化与校准线

5.6+ 的核心不是继续堆新工具，而是把 EliteSync 已经具备的玄学 / 星盘 / 画像 / 匹配解释能力转译成用户可理解、可忽略、可关闭的解释层。

“二次产品化”指：

- 从能力存在，转向主链可理解。
- 从图谱与资料，转向关系解释、表达建议、低压开场。
- 从结果展示，转向可被用户消费的短句、维度、建议 / 避免。
- 从可能的 AI 追问，转向受控的 explanation layer。

“校准线”指：

- 校准哪些解释可以进入 Match、Me、Chat。
- 校准哪些文案不能写成事实、预测、诊断或真值。
- 校准哪些能力只能作为 display-only。
- 校准所有解释层不得反写 canonical truth。

## 4. 测测 Stage 1-5 可吸收结论

### 4.1 Stage 1：入口矩阵与浅层 IA

吸收：

- 玄学能力不应只藏在深层工具页，可以通过首页、频道、快捷入口、个人页形成入口矩阵。
- 入口需要先解释价值，再允许用户进入深层。
- 首页可以承载能力入口，但不能压过 EliteSync 的慢约会主线与资料真值链。

不吸收：

- 商业入口与咨询入口密集混排。
- 过早把工具、测试、服务市场和内容流压在同一主屏。

### 4.2 Stage 2：AI问 / 在线分层

吸收：

- AI 解释层、问题导航层、真人服务层必须分开。
- `AI问` 类结构可启发 EliteSync 的轻追问入口，但不能直接通向成交链。
- 关系 / 匹配解释页可以先给轻问题入口，再给可选深问路径。

不吸收：

- 真人 1v1 服务市场。
- `在线` 达人服务大厅。
- 优惠券、连麦、付费咨询、强服务转化。
- 把 `AI问 -> 在线` 写成已验证闭环。

### 4.3 Stage 3：测试频道

吸收：

- 测试频道的新版结论显示，本轮样本更像互动答题入口层，而不是稳定的结果解释页。
- 可以借鉴“用户先进入轻互动，再获得解释”的节奏，但只能作为可选体验设计参考。

不吸收：

- 娱乐化测试作为主路径。
- 提交测试答案后反写用户画像。
- 把测试结果当作事实资料或匹配算法输入。
- 把“本轮样本”外推成全量频道事实。

### 4.4 Stage 4：星盘总览 / 图谱 / 档案上下文

吸收：

- 单人档案上下文可以承接图谱、摘要、分层解释、轻追问入口。
- 星盘类信息适合“图谱先行 + 结论摘要 + 分层解释”的阅读节奏。
- 档案列表是上下文管理页，不是结果页。

不吸收：

- 把 `DeepSeek解读`、AI 追问、AI问、在线、真人服务混成一条已验证链。
- 未点击的入口不能写成已验证目标页。
- 参数、预览报告、深层解释未验证前不能写成可用链路。

### 4.5 Stage 5：缘分合盘 / 双人关系解释

吸收：

- 双人上下文适合承接关系解释层。
- 可吸收“关系短句 + 维度解释 + 建议 / 避免 + 轻追问入口”的结构。
- Match 可以优先承接关系解释层，因为它天然已有双人上下文。

不吸收：

- 上传截图作为主路径。
- 真实双人合盘结果页未验证，却写成已验证。
- `选择完成` 后续行为未验证，却写成结果页入口。
- `合盘 -> AI问 / 在线 / 真人服务` 未验证，却写成完整桥接链。

## 5. 全局产品边界

所有 5.6+ 玄学 / 关系解释输出必须保持：

```text
derived-only / display-only / explanation layer
```

不得反写：

```text
profile/basic
profile/astro/summary
profile/astro/chart
user_astro_profiles
```

不得改：

- canonical truth。
- profile contract。
- astro contract。
- match algorithm contract。
- release contract。
- API contract。
- 数据库 schema。
- migration。

不得提出：

- 真人玄学咨询市场。
- 付费报告商店。
- 上传截图主路径。
- 强出生资料收集。
- 娱乐化测试主路径。
- 测试结果反写画像。
- 大规模社区讨论。
- 测测术语体系复制。
- 从竞品 UI 推断服务端 contract、算法、接口或数据库。

## 6. 5.6+ 总体版本线

### 5.6：玄学能力二次产品化边界与校准版

定位：路线冻结、解释层 contract、文案边界、non-goals、protected surfaces 校准。

重点：

- 明确 Soul / 测测双参考关系。
- 明确测测只吸收结构，不吸收商业化与真人服务。
- 冻结 derived-only / display-only 规则。
- 制定 Match / Me / Chat 后续版本计划书。

不做 runtime 实现。

### 5.7：Match 关系解释层最小产品化版

定位：第一个 runtime 候选，但必须等 5.7 正式开发计划书批准后再进入。

重点：

- Match detail 中的关系解释层。
- 一句关系摘要。
- 2-4 个解释维度。
- 建议 / 避免。
- 轻追问 disabled / coming soon 或受控占位。
- display-only 免责声明。

不改匹配算法，不写聊天消息，不接真实 AI。

### 5.8：Me 个人解释层与表达建议版

定位：把解释层扩展到个人经营页，但更靠近资料真值，必须更保守。

重点：

- 个人表达风格。
- 资料展示建议。
- 慢约会友好表达。
- 展示建议与自我介绍辅助。

不重写资料，不做人格诊断，不强收出生资料。

### 5.9：Chat 轻追问与低压开场版

定位：把 Match / Me 的解释层轻量衔接到 Chat，但不做自动代聊。

重点：

- 低压开场。
- 换个问法。
- 冷场续话。
- 可编辑草稿候选。
- 用户主动确认后才可发送。

不自动发送，不读取未授权聊天内容，不写消息正文。

### 5.10：解释层治理、用户控制与回归校准版

定位：统一治理 5.7-5.9 的解释层能力。

重点：

- 解释层统一开关。
- AI 辅助建议开关。
- 固定免责声明。
- 关闭后的 fallback。
- Match / Me / Chat 回归。

不做重后台，不做付费，不做真人服务，不做算法训练。

## 7. 与既有 5.x 计划的关系

本文件不是替代 2026-05-01 的 5.x 总计划，而是它的 5.6+ 修订延伸。

继承：

- 4.9 稳定门禁基线。
- Discover / Chat / Me 产品化补强主线。
- Soul 作为社交主链参考。
- AI 必须嵌入主链，而不是孤立平台。
- 所有新能力必须 additive，不破坏旧主链。

新增：

- 测测作为玄学解释层参考。
- 5.6+ 进入玄学能力二次产品化与校准线。
- 所有玄学 / 合盘 / 关系解释能力必须保持 derived-only / display-only。
- 明确不吸收测测商业化、真人服务、付费报告、上传截图、娱乐化测试。

## 8. 固定工作包

### 8.1 产品工作包

- Match：关系解释、建议 / 避免、轻追问占位。
- Me：个人解释、表达建议、资料展示建议。
- Chat：低压开场、换个问法、可编辑草稿。
- Settings：解释层开关、免责声明、用户控制。

### 8.2 工程工作包

- 默认先 Flutter UI。
- 默认不改 Laravel。
- 默认不改 DB。
- 默认不改 API。
- 默认不改 release chain。
- 每个 runtime 版本必须有 widget test、analyze、截图 / UI hierarchy evidence。

### 8.3 安全工作包

- derived-only。
- display-only。
- no silent writeback。
- no auto send。
- no upload-first。
- no paid service。
- no human consulting marketplace。

## 9. Blocker 与停止条件

任一后续版本如出现以下情况，必须停止并回到计划阶段：

- 需要改 API 才能实现。
- 需要新增数据库字段或 migration。
- 需要写 `profile/basic`、`profile/astro/summary`、`profile/astro/chart`、`user_astro_profiles`。
- 需要改变 Match 推荐算法输入。
- 需要自动写聊天消息或自动发送。
- 需要上传截图、图片或文件。
- 需要接真人服务、付费报告或咨询市场。
- 需要把竞品 UI 术语或链路直接复制到 EliteSync。

## 10. 当前结论

本文件只是 5.6+ 路线与整体开发计划草稿。

当前不进入实现，不修订代码，不提出数据库迁移，不处理 release chain。

下一步应先验收本文件与配套路线图草稿；验收通过后，再单独制定 5.6 具体版本开发计划书。
