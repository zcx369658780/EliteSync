# Cece Stage 5 Rerun Evidence Index

更新时间：2026-05-11

本索引用于收口 Stage 5 Claude rerun 的有效证据与排除项。原始文件保留在工作区以便审计，但以下 excluded 文件不得进入有效证据链。

## Valid Evidence

### Relationship Page / Overview

- `assets/xml/A_hepan_entry_and_context.xml`
  - 有效。记录 `缘分总结 / 近期关系`、双 `请选择档案`、`契合度`、关系语义句、六维评分和 `看看和朋友们的缘分`。
- `assets/screenshots/E_relation_explanation_structure.png`
  - 有效。记录 `近期关系`、`上周 / 本周 / 下周`、`以下是示例`、`建议 / 避免`、`上传截图秒懂ta`、追问入口、免责声明和底部 CTA。
- `assets/xml/C_select_complete_boundary.xml`
  - 有效，但命名不准确。实际记录关系解释层，不是 `选择完成` 边界；用于 E/F/D 子项的关系解释证据。

### Archive Selection

- `assets/xml/B_archive_selection_and_double_context.xml`
  - 有效。记录 `档案列表`、搜索、排序、筛选、`选择了1人：示例档案`、`添加档案，记录重要的人`、`我想对产品提点建议`、`选择完成`。
- `assets/screenshots/D_relation_result_or_blocker.png`
  - 有效，但命名不准确。实际记录 `档案列表` / 档案选择页，不是关系结果页；用于 B/C/H 子项。

## Excluded Evidence

以下文件保留为运行痕迹，不进入有效证据链：

- `assets/screenshots/A_hepan_entry_and_context.png`
  - 排除原因：截图内容是启动广告，不是 `缘分合盘` 页面。
- `assets/screenshots/B_archive_selection_and_double_context.png`
  - 排除原因：截图内容是首页，不是档案选择页。
- `assets/screenshots/C_select_complete_boundary.png`
  - 排除原因：截图内容是 `缘分合盘解读升级啦` 弹窗，不是 `选择完成` 边界证据。
- `assets/current_texts.txt`
  - 排除原因：Claude 临时文件，0 字节。
- `assets/current_texts3.txt`
  - 排除原因：Claude 临时文件，0 字节。
- `assets/t.txt`
  - 排除原因：Claude 临时文件，不含有效 UI 证据。
- `assets/test.txt`
  - 排除原因：Claude 临时文件，不含有效 UI 证据。

## Evidence Caveat

Stage 5 有效结论必须以 Codex 复核后的 evidence map 为准。不得仅凭文件名推断证据用途。

