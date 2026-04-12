# Ziwei Release Execution Log 2.5

日期：2026-03-30

## 执行内容

1. 关闭性格测试 / MBTI 活跃链路
2. 将紫微斗数接入 canonical 画像
3. 将紫微画像回填到 synthetic 测试账号
4. 将紫微评分接入匹配排序与解释层
5. 生成 2.5 发布清单与回滚手册

## 关键脚本

- `app:dev:fill-synthetic-ziwei`
- `app:dev:astro-shadow-compare`

## 已确认的实现点

- MBTI API 返回 `410 feature_disabled`
- MBTI 权重为 `0`
- 前端入口显示“性格测试已关闭”
- 匹配解释中不再把 MBTI 作为活跃排序因素
- 紫微模块可参与 `astro` 总分与模块解释

## 验证结果

- `php artisan test --filter=MbtiApiVersioningTest` PASS
- `php artisan test --filter=ZiweiCanonicalServiceTest` PASS
- `php artisan test --filter=MatchPayloadContractTest` PASS
- `php -l` PASS

## 发布结论

2.5 发布路径已具备可执行、可回退、可对拍的工程闭环。

