# 媒体链路排障手册

更新时间：2026-04-28

## 适用范围

适用于以下链路：

- 图片消息
- 视频消息
- 媒体上传
- 媒体读取
- 媒体处理队列
- `public_url` / `storage_key` / `storage_disk`

## 首先看什么

1. `media_upload_failed`
2. `media_asset_saved`
3. `media_content_stream_failed`
4. `media_process_demo_triggered`
5. `media_assets.status`
6. `media_processing_jobs.status`

## 排查顺序

### 1. 上传入口是否成功

检查：

- `POST /api/v1/media` 返回码；
- `asset.status`；
- `error_code`；
- `storage_disk`；
- `storage_key`；
- `public_url`。

若失败：

- 先看 `mime_not_allowed`；
- 再看 `upload_too_large`；
- 再看 `storage_write_failed`。

### 2. 队列 / 处理是否成功

检查：

- `media_processing_jobs.status`；
- `attempt_count`；
- `max_attempts`；
- `locked_at`；
- `processed_at`；
- `error_code`；
- `error_message`。

若失败：

- 先看 `asset_missing`；
- 再看 `awaiting_upload`；
- 再看 `processing_failed`。

### 3. 读取是否成功

检查：

- `GET /api/v1/media/{assetId}/content`；
- `storage_disk` 是否可读；
- `storage_key` 是否存在；
- `public_url` 是否被错误路由到 localhost；
- `media_content_stream_failed` 是否出现。

### 4. UI 是否把失败假装成成功

检查：

- 聊天气泡是否显示真实图片 / 视频；
- 预览页是否能打开；
- 是否只是缓存截图或旧 URL。

## 常见问题与处理

### `mime_not_allowed`

- 文件类型不在白名单；
- 先确认前端文件类型和后端策略是否一致。

### `upload_too_large`

- 文件超过媒体限制；
- 先确认大小限制，再决定是否压缩或拒绝。

### `storage_write_failed`

- 对象存储 / 文件系统写入失败；
- 先看 storage provider、disk、storage_key；
- 不要只看前端提示。

### `processing_failed`

- 同步处理任务失败；
- 检查 job 执行日志、队列状态与 asset 状态。

### `media_content_stream_failed`

- 读取流失败；
- 先看 storage_key 和磁盘可读性；
- 再看 public_url 是否被错误代理。

## 4.9 最小验证要求

- 上传成功；
- 读取成功；
- 视频 / 图片在聊天里可回读；
- 队列失败时可读出 asset_id 和 error_code；
- 不用 UI 假成功掩盖读取失败。

## 云端边界

- 生产库与生产存储的写入排障统一在云端；
- 本地只做读取、截图、文档与最小构建。
