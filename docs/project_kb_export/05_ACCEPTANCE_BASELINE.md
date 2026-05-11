# 验收基线

更新时间：2026-05-11

## 顾问验收口径

- `conditional pass`：核心实现已成立，但缺少最终归档所需的证据链、收尾材料或回归收口。
- `pass with observations`：版本可正式归档，非阻断观察项保留在文档里，但不应阻止进入下一版本。
- `pass`：实现、验证、证据、交接都已闭环，且无需要顾问继续补强的阻断项。

## `pass with observations` 的使用原则

- 用于“主功能已经成立，但仍保留少量可优化项”的版本。
- 不能因为有 observation 就重开同一条主链。
- observation 必须是非阻断的，且要写清楚为什么不阻断。

## 什么算正式归档通过

- 主实现完成
- 回归测试通过
- 保护面未受影响
- 截图证据足够
- closeout / handoff 文档齐备
- 顾问可直接接下一版本，不需要再回头补主链

## 什么算 conditional pass

- 代码基本完成，但证据包偏轻
- 或者收尾文档不足
- 或者回归 / 保护面说明还不够厚
- 这类版本通常允许先补小回合，不建议直接归档

## 多 Agent 审查的角色

- Claude：边界、架构风险、隐藏回归风险、高风险分层审查
- Gemini：截图、UI 可读性、walkthrough、长上下文归纳
- Codex：主实现、计划落地、文档收口、验收整合

## 截图 / 回归 / closeout 的作用

- 截图证据：证明用户真的能走通关键流程
- 回归材料：证明旧功能没被误伤
- closeout 文档：证明当前版本已经收口，后续该怎么承接

## 当前项目习惯

- 新版本尽量在归档前形成一份“验收摘要 + 交接说明 + closeout note + 证据索引”的最小包。
- 若顾问意见是 `pass with observations`，应将 observation 固化，但不要把 observation 当成阻断。

## 5.6 Planning-Only 验收口径

- 5.6 是 planning / boundary / calibration 版本，不做 runtime implementation。
- 验收标准是路线、边界、non-goals、protected surfaces、derived-only / display-only contract 和后续版本计划书齐备。
- 不因没有 runtime 截图、XML、UI hierarchy 或实现证据而降级。
- 不允许用 5.6 planning-only 验收推动 5.7 runtime；5.7 之前必须先完成并验收 5.6 具体开发计划书与 `5.6_HANDOFF_MASTER.md`。
- 5.6 验收必须确认没有触碰 Flutter、Laravel、数据库、API、版本号或 release chain。

## 5.7 Match 解释层验收口径

- 5.7 是 Match 关系解释层最小产品化 runtime slice。
- 验收标准是 `为什么值得聊` 在 Match result / detail presentation 可见，且包含摘要、`共同点`、`表达节奏`、`慢约会适配度`、建议 / 避免、轻追问 disabled 占位和 display-only 免责声明。
- 5.7 必须确认没有新增 API、没有新增 DB / migration、没有修改 Laravel backend、routes / config、release chain、Android version、真实 AI、chat message 写入、profile / astro canonical truth 写入或 Match algorithm 改动。
- 若核心 widget/page test 通过、保护面检查为空，但真实 active match 实机截图因账号状态受限未补齐，可按 `pass with observations` 处理，不重开 5.7 主链。

## 5.8 Me / Profile 解释层验收口径

- 5.8 是 Me / Profile 个人解释层与表达建议 runtime slice。
- 验收标准是 `我的慢约会表达建议` 在 Profile presentation 可见，且包含摘要、`真实感`、`表达清晰度`、`慢约会适配度`、`开场友好度`、资料展示建议、慢约会友好表达、可以补充什么、AI 草稿 disabled / coming soon 占位和 display-only 免责声明。
- 5.8 必须确认没有新增 API、没有新增 DB / migration、没有修改 Laravel backend、routes / config、release chain、Android version、真实 AI、profile / astro canonical truth 写入或自动修改资料。
- 若 focused widget/page test 通过、保护面检查为空、runtime screenshot/XML 可读，但既有 provider 守护测试存在异步超时，可按 `pass with observations` 处理，不重开 5.8 主链。

## 5.9 Chat 轻追问与低压开场验收口径

- 5.9 是 Chat 轻追问与低压开场 runtime slice。
- 验收标准是 `低压开场建议` 在 Chat room presentation 可见，且包含 `从共同点开始`、`换个更自然的说法`、`低压问候建议`、`不要太急`、`可编辑草稿`、`填入后仍需你自己确认发送` 和 no-auto-send 免责声明。
- 5.9 必须确认没有新增 API、没有新增 DB / migration、没有修改 Laravel backend、routes / config、release chain、Android version、真实 AI、私密聊天历史读取、自动发送、`chat_messages` 写入、profile / astro / match canonical truth 写入。
- 若 focused widget/page test 通过、保护面检查为空、runtime screenshot/XML 可读，但证据来自 debug host 或真实会话历史较多需要滚动，可按 `pass with observations` 处理，不重开 5.9 主链。

## 5.10 Settings 解释层治理与用户控制验收口径

- 5.10 是 Settings 解释层治理与用户控制 runtime slice。
- 验收标准是 `解释与建议设置` 在 Settings presentation 可见，且包含 `关系解释提示`、`个人表达建议`、`聊天开场建议`、说明型开关占位、`了解这些建议如何工作` 和 display-only / no-write / no-auto-send 免责声明。
- 5.10 必须确认没有新增 API、没有新增 DB / migration、没有修改 Laravel backend、routes / config、release chain、Android version、真实 AI、后端用户偏好持久化、跨页强联动、profile / astro / match / chat canonical truth 写入。
- 若 focused Settings test 通过、保护面检查为空、runtime screenshot/XML 可读，但当前控制仅为说明型占位且证据来自 debug host，可按 `pass with observations` 处理，不重开 5.10 主链。
