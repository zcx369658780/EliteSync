# Release Smoke Checklist

> 版本发布前的最小烟测清单。任何高风险变更进入 release 前都必须执行。

## 1. 基础项

- [ ] 应用可启动
- [ ] 登录可成功
- [ ] 版本号正确
- [ ] 主要入口可进入
- [ ] 无致命空白页 / 崩溃

## 2. 资料链路

- [ ] `EditProfilePage` 可进入
- [ ] 昵称可保存
- [ ] 生日可保存
- [ ] 出生时间可保存
- [ ] 出生地搜索可返回候选
- [ ] 选择出生地后可保存
- [ ] 保存后能回读最新资料

## 3. 画像链路

- [ ] `GET /api/v1/profile/astro/summary` 可读
- [ ] `GET /api/v1/profile/astro/chart` 可读
- [ ] `AstroOverviewPage` 可打开
- [ ] `AstroBaziPage` 可打开
- [ ] `AstroNatalChartPage` 可打开
- [ ] `AstroZiweiPage` 可打开
- [ ] `AstroProfilePage` 可打开

## 4. 错误态

- [ ] 未登录能正确提示
- [ ] 服务端错误能正确提示
- [ ] chart 失败不拖垮 summary
- [ ] 地点搜索失败能降级提示
- [ ] 保存失败能明确反馈
- [ ] 回归烟测账号失效时，脚本可自动用临时 synthetic 账号自举并继续 auth chain；fallback 注册支持重试，smoke log 需要记录 fallback 账号信息（非真实号段），并在 smoke 结束后尝试自删，避免污染后续匹配测试

## 5. 发布相关

- [ ] changelog 已更新
- [ ] 版本检查接口正确
- [ ] 下载地址可访问
- [ ] 回滚点已确认
- [ ] 备份已确认

## 6. 复核输出

- [ ] 已记录通过项
- [ ] 已记录风险项
- [ ] 已记录未验证项
- [ ] 已记录回滚点
