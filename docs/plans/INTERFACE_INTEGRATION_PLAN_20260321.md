# EliteSync 接口接入规划（资质前置版）_20260321

## 1. 目标与边界

当前阶段目标：
- 先完成技术架构与接口抽象，保证后续资质齐全后可快速切换到真实接口。
- 所有高敏接口采用“可降级”方案：无资质时走人工审核，有资质时切换自动核验。

当前阶段边界：
- 不接入需要企业签约/商户进件/政务合作的真实生产接口。
- 不承诺无犯罪记录直查、信用分直查、银行资产直查。

## 2. 接口分层与优先级

### P0（现在可做）
1. 手机号验证码登录（主登录链路）
2. 微信登录接口骨架（mock + feature flag）
3. 地图定位（单厂商优先，建议腾讯或百度二选一）
4. 摄像头/麦克风权限与设备能力检测
5. 材料上传与人工审核（身份证/学历/资产/无犯罪证明）
6. 支付网关抽象层（mock支付，不真实收款）

### P1（公司与资质到位后）
1. 微信登录正式接入
2. 微信支付/支付宝支付（至少先上一个）
3. 第三方实人认证（身份证+活体）
4. 学历核验（报告码或合作核验）

### P2（中后期）
1. 算法备案相关能力（日志、解释、申诉）
2. 深度合成/生成式AI合规能力（如上线相关功能）

### P3（暂不承诺）
1. 无犯罪记录直查
2. 芝麻信用分直查
3. 银行资产直查（工行/中行/农行/招行）

## 3. 统一接口抽象设计

### 3.1 连接器抽象（Connector）
统一定义第三方连接器状态：
- `NOT_CONFIGURED`：未配置
- `MOCK`：开发模拟
- `SANDBOX`：沙箱
- `PRODUCTION`：生产

统一调用结果：
- `SUCCESS`
- `PENDING`
- `FAILED_RETRYABLE`
- `FAILED_FINAL`
- `FALLBACK_MANUAL`

### 3.2 Feature Flag
为每个能力加开关：
- `ff_wechat_login_enabled`
- `ff_payment_wechat_enabled`
- `ff_payment_alipay_enabled`
- `ff_identity_realname_enabled`
- `ff_education_verify_enabled`
- `ff_credit_check_enabled`（默认 false）
- `ff_asset_check_enabled`（默认 false）

## 4. 数据模型（建议）

### 4.1 用户认证状态表 `user_verification_profiles`
- `id`
- `user_id`
- `realname_status` (`NOT_STARTED|PENDING|VERIFIED|REJECTED|MANUAL_REVIEW`)
- `education_status` (同上)
- `credit_status` (同上)
- `asset_status` (同上)
- `criminal_record_status` (同上)
- `risk_level` (`LOW|MEDIUM|HIGH`)
- `updated_at`

### 4.2 提交材料表 `verification_submissions`
- `id`
- `user_id`
- `verification_type` (`REALNAME|EDUCATION|CREDIT|ASSET|CRIMINAL_RECORD`)
- `provider` (`MANUAL|WECHAT|ALIPAY|THIRD_PARTY|BANK|CHSI|POLICE`)
- `payload_json`（脱敏后）
- `attachments_json`（对象存储key）
- `status` (`PENDING|APPROVED|REJECTED|NEED_MORE`)
- `reviewer_id`
- `review_note`
- `created_at`

### 4.3 第三方调用审计表 `third_party_call_logs`
- `id`
- `user_id`
- `connector_name`
- `operation`
- `request_id`
- `request_digest`
- `response_code`
- `response_digest`
- `result_status`
- `latency_ms`
- `created_at`

### 4.4 支付订单表 `payment_orders`
- `id`
- `user_id`
- `channel` (`WECHAT|ALIPAY|MOCK`)
- `business_type` (`MEMBERSHIP|BOOST|OTHER`)
- `amount_cent`
- `currency`
- `status` (`CREATED|PENDING|PAID|FAILED|REFUNDED|CLOSED`)
- `out_trade_no`
- `channel_trade_no`
- `expire_at`
- `paid_at`

## 5. API 契约（先实现可用骨架）

### 5.1 登录与绑定
1. `POST /api/v1/auth/sms/send`
2. `POST /api/v1/auth/sms/login`
3. `POST /api/v1/auth/wechat/start`（P0返回mock授权URL）
4. `POST /api/v1/auth/wechat/callback`（P0 mock token，P1真实换token）

### 5.2 认证与材料上传
1. `GET /api/v1/verification/profile`
2. `POST /api/v1/verification/submissions`
3. `POST /api/v1/verification/submissions/{id}/attachments`
4. `GET /api/v1/verification/submissions/{id}`

### 5.3 匹配准入
1. `GET /api/v1/match/eligibility`
- 输出：
  - `questionnaire_ready`
  - `realname_required`
  - `realname_passed`
  - `can_enter_match`
  - `missing_requirements[]`

### 5.4 支付网关
1. `POST /api/v1/payments/orders`
2. `POST /api/v1/payments/orders/{id}/pay`
3. `POST /api/v1/payments/callback/{channel}`
4. `GET /api/v1/payments/orders/{id}`

## 6. 降级策略（无资质时）

1. 微信登录不可用：
- 前端仅展示手机号登录
- 后端 `wechat/start` 返回 `FEATURE_DISABLED`

2. 实名核验不可用：
- 引导用户提交身份证照片+手持照+声明
- 进入人工审核队列

3. 学历核验不可用：
- 上传学信网报告PDF/截图
- 人工复核

4. 支付不可用：
- 订单允许创建，但支付返回 `MOCK_CHANNEL_ONLY`
- 内测账号可用 mock 支付

## 7. 安全与合规底线

1. 敏感信息最小化：
- 不落明文身份证号、银行卡号
- 仅保存脱敏值与哈希

2. 加密：
- 传输全程 HTTPS
- 存储层字段加密（至少身份证、姓名、联系方式）

3. 权限与审计：
- 审核后台RBAC
- 所有查看敏感信息操作留审计日志

4. 用户授权：
- 每类敏感处理单独授权文案
- 支持撤回授权与注销

## 8. 四周执行排期（仅规划与骨架）

### Week 1
1. 数据表迁移与模型
2. verification/profile 与 submissions API
3. 审核后台最小页面（列表、详情、通过/驳回）

### Week 2
1. 登录能力整理（手机号稳定化）
2. 微信登录骨架（mock）
3. 接口审计日志中间件

### Week 3
1. 支付网关抽象与mock支付
2. 匹配准入校验接口
3. 前端“待认证提示流”

### Week 4
1. 风险规则v1（简单评分）
2. 异常处理与告警
3. 联调测试与回归清单

## 9. 公司成立后的启用顺序

1. 开通微信开放平台并切换微信登录真实connector
2. 开通一个支付渠道（建议先微信或支付宝二选一）
3. 签第三方实人认证并替换实名mock
4. 再推进学历自动核验
5. 最后评估信用/资产等高门槛能力

---

这份文档用于“资质未齐全阶段”的工程落地。后续资质到位后，按 feature flag 切换对应 connector 即可。
