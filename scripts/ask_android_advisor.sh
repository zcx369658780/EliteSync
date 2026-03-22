#!/usr/bin/env bash
set -euo pipefail

TOPIC="${1:-Android 约会 App 的动态星图背景设计}"
OUT_FILE="${2:-ask-chatgpt.md}"

codex <<EOF > "$OUT_FILE"
请基于当前项目，生成一份要发给 ChatGPT（Android Studio Developer Agent）的中文 Markdown 简报。
主题：${TOPIC}
要求包含：
- 项目目标
- 当前方案
- 遇到的问题
- 已尝试方案
- 关键 Kotlin 文件
- 希望 ChatGPT 给出的下一步设计建议
要求：
- 聚焦 UI/渲染/性能
- 不要展开业务无关内容
EOF

echo "已生成：$OUT_FILE"

