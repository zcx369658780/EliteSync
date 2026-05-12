# Codex 协作规则

更新时间：2026-05-12

## 默认角色

- Codex：默认主编排器，负责计划、实现、修复、文档收口和最终整合。
- Claude：6.0 Alpha 起承担强制横向复评门禁，基于 Soul + 测测 / CECE 做产品体验对照。
- Gemini：用于视觉 / UI / walkthrough、长上下文总结和补漏验证覆盖。

## 默认执行顺序

1. 先做需求拆解和边界确认。
2. 再做风险清单。
3. 再做最小实现或 planning-only 文档收口。
4. 再做测试与回归。
5. Codex 完成实现和自测后，必须先提交 Claude 横向复评。
6. Claude 需基于 Soul + 测测 / CECE 进行产品体验对照。
7. Claude 复评为 `pass` 或 `pass with observations` 后，才能提交 GPT 顾问最终验收。
8. GPT 顾问最终验收通过后，才允许进入下一版本。

## Claude 横向复评门禁

- `pass`：可提交 GPT 顾问最终验收。
- `pass with observations`：可提交 GPT 顾问最终验收，但必须带 observation。
- `conditional pass`：需补证据或小修。
- `fail`：必须返工。
- 无 Claude 横向复评，不得提交 GPT 顾问最终验收。
- 无 GPT 顾问最终验收，不得进入下一版本。

## 新版本开发流程

- 先看当前计划书。
- 先确认当前版本属于 A0 / A1 / A2 / A3 / A4 / A5 哪一阶段。
- 先冻结不改什么。
- 先列保护面。
- 先确认是否触碰 Flutter / Laravel / DB / API / release chain。
- A0 是 planning-only，不做 runtime。

## 本仓库固定规则

- 版本号、版本检查、下载包必须绑定同一条链。
- 发版优先使用 `scripts/release_android_update_aliyun.ps1`。
- 截图证据、回归材料、closeout 文档是验收的一部分，不是附录。
- 任何新版本若触碰高风险面，必须先做计划、风险评审、测试计划，再实施。
- 本地只做前端开发与联调；后端、迁移、备份、恢复和写库操作默认在阿里云端执行。

## 竞品 UI Research 协作规则

- Codex 仍是主编排器，负责拆分任务、复核证据、收口报告和同步项目源。
- Claude 可作为 UI 观察 subagent，用于普通用户层面的公开可见 UI 浏览、截图、Android UI hierarchy 采集和路径记录。
- 竞品 UI research 不做安全测试、逆向、抓包、接口分析、读取本地私有数据、权限绕过或批量抓取。
- Soul 是社交表达参考，测测 / CECE 是玄学解释层参考，Date Drop 是匹配机制母版；不得照抄竞品商业化链路。
