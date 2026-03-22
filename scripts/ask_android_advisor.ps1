param(
    [string]$Topic = "Android 约会 App 的动态星图背景设计",
    [string]$OutFile = "ask-chatgpt.md"
)

$prompt = @"
请基于当前项目，生成一份要发给 ChatGPT（Android Studio Developer Agent）的中文 Markdown 简报。
主题：$Topic
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
"@

$tmp = New-TemporaryFile
Set-Content -Path $tmp -Value $prompt -Encoding UTF8

cmd /c "codex < `"$($tmp.FullName)`" > `"$OutFile`""
if ($LASTEXITCODE -ne 0) {
    Write-Error "codex 执行失败（exit=$LASTEXITCODE）"
    exit $LASTEXITCODE
}

Write-Host "已生成：" (Resolve-Path $OutFile)

