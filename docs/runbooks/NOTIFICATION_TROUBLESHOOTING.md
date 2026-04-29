# 通知链路排障手册

更新时间：2026-04-28

## 适用范围

适用于以下通知链路：

- 消息新通知
- 动态点赞 / 回复通知
- 匹配成功通知
- RTC 来电 / 接听 / 拒绝 / 结束通知
- 通知已读 / 全部已读
- 通知回流到目标页面

## 首先看什么

1. `notification_marked_read`
2. `notification_marked_all_read`
3. `notifications.kind`
4. `notifications.title`
5. `notifications.body`
6. `notifications.payload.route_name`
7. `notifications.payload.route_args`

## 排查顺序

### 1. 通知是否生成

检查：

- 上游操作是否真的发生；
- `notifications` 表是否新增记录；
- `kind` 是否符合预期；
- `title` / `body` 是否自然；
- `payload` 是否含路由信息。

### 2. 通知是否被前端自然展示

检查：

- 通知中心卡片底部是否还直接显示工程 slug；
- 旧通知是否也能映射为自然文案；
- 未知类型是否显示为 `新通知`。

### 3. 通知是否可以打开

检查：

- `route_name` 是否缺失；
- `route_args` 是否缺字段；
- 路由是否存在；
- RTC 通知是否走到正确 call / result 页面；
- 消息通知是否跳到正确会话页。

### 4. 已读是否正常

检查：

- `POST /api/v1/notifications/{notificationId}/read`；
- `POST /api/v1/notifications/read-all`；
- `read_at` 是否更新；
- unread count 是否变化。

## 常见问题

### 工程 slug 外露

- 现象：`rtc_call_invite`、`rtc_call_ended` 等直接显示给用户；
- 处理：只改展示层，不改通知表和 read 流程。

### 回流失败

- 现象：点击通知无反应或提示暂无法打开；
- 处理：检查 `route_name` 与 `route_args`。

### 去重误吞

- 现象：短时间重复通知只出现一条；
- 原因：`NotificationService` 有 5 分钟去重窗口；
- 处理：先确认是否真的是重复事件，而不是展示问题。

## 4.9 最小验证

- 新消息通知可自然打开；
- 匹配通知可自然打开；
- RTC 通知可自然打开；
- 已读 / 全部已读可回流；
- 不再直接暴露工程 slug。

## 云端边界

- 通知生成与写库排障优先在云端；
- 本地只做展示、截图、文档与最小验证。
