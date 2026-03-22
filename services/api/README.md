# EliteSync API - P0

## 已实现能力（P0）
- 账号体系：手机号注册/登录、JWT 鉴权、Refresh Token 自动刷新。
- 学生认证：人工审核状态机（pending/approved/rejected），预留后续学信网接入点。
- 问卷系统：66 题从后端拉取；单选/多选/量表统一建模；草稿与断点续答；答案 AES-256 加密存储。
- 每周匹配：周二 00:00 执行规则匹配，周二 21:00 Drop 开放查询；返回匹配亮点。
- 双向确认：双方都 like 才 mutual=true。
- 即时聊天：文本消息接口 + WebSocket 推送 + 已读回执。
- 基础个人中心：查看/编辑资料、认证状态。
- 最小运营后台：用户管理（查看/禁用）、认证审核、基础统计。

## 启动
```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## 测试
```bash
PYTHONPATH=. pytest -q
```
