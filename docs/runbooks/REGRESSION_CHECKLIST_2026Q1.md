# 回归测试清单（2026 Q1）

更新时间：2026-03-19  
目标：在“本地验证通过后再上阿里云”流程下，保证主链路稳定。

## 1. 执行顺序
1. 本地后端回归
2. 本地安卓回归
3. 云端部署
4. 云端冒烟回归

## 2. 本地后端回归
1. 单元/特性测试  
`php artisan test`  
通过标准：全部通过。
2. 迁移与种子  
`php artisan migrate --force`  
`php artisan db:seed --class=QuestionnaireQuestionSeeder --force`  
通过标准：无报错。
3. 安全基线  
- 注册弱密码应失败（422）。
- 注册强密码应成功（201）。

## 3. 本地安卓回归
1. 构建  
`.\gradlew.bat :app:assembleDebug`  
通过标准：BUILD SUCCESSFUL。
2. 功能链路  
- 注册/登录
- 问卷答题（20题）
- 匹配页展示
- 聊天收发/已读
通过标准：无阻断性崩溃、无主链路卡死。

## 4. 云端部署回归
1. 执行部署脚本  
`powershell -ExecutionPolicy Bypass -File .\scripts\deploy_aliyun_backend.ps1 -ServerHost 101.133.161.203 -User root -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem`
2. 服务状态检查  
`systemctl status nginx php8.4-fpm mariadb redis-server elitesync-ws`
3. 健康检查  
`http://101.133.161.203/up` 返回 200

## 5. 云端接口冒烟
1. 注册接口（强密码）  
预期：201 + access token。
2. 登录接口  
预期：200 + access token。
3. 问卷接口  
`GET /api/v1/questionnaire/questions`  
预期：返回题目列表（默认20题会话抽样）。
4. 聊天接口  
消息发送成功，列表读取成功。

## 6. 安全检查（每次发布必查）
1. 数据库聊天内容是否密文存储  
- 随机抽查 `chat_messages.content`，不应为明文。
2. 限流是否生效  
- 对登录接口连续高频请求应命中 throttle。
3. 是否泄露敏感信息  
- 仓库扫描 `ghp_`/`x-access-token` 等关键字结果应为 0（脚本模板文本除外）。

## 7. P0 阻断判定
任一项出现以下情况，禁止发布：
1. 注册/登录不可用
2. 问卷无法提交或匹配完全不可用
3. 聊天无法发送/接收
4. 云端健康检查失败
5. 明文敏感信息泄露

## 8. 测试记录模板
建议每次执行后记录：
1. 分支与提交号
2. 执行时间
3. 通过/失败项
4. 缺陷编号与处理人
5. 是否允许部署到云端
