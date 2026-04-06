# Ziwei Release Checklist 2.5

更新时间：2026-03-30

## 1. 发布前提

- [x] 术语已统一为“紫微斗数模块”
- [x] 性格测试 / MBTI 已关闭，不再参与排序
- [x] 紫微 canonical 已落到服务端
- [x] 测试账号回填与 shadow 已具备脚本
- [x] 紫微已接入匹配评分与解释层

## 2. 代码与契约

- [x] `ZiweiCanonicalService` 可重复生成稳定画像
- [x] `AstroCompatibilityService` 支持紫微评分
- [x] `MatchingEngineService` 读写 `private_ziwei`
- [x] `MatchController` 解释层可识别紫微词条
- [x] `MatchPayloadContractTest` 已覆盖紫微模块

## 3. 数据与回填

- [x] `user_astro_profiles.ziwei` 已加入
- [x] `users.private_ziwei` 已加入
- [x] synthetic 回填命令可用
- [x] shadow compare 可输出 ziwei diff

## 4. 灰度与回滚

- [x] 灰度可通过配置调低紫微权重
- [x] 回滚可通过配置与数据镜像退回到历史兼容状态
- [x] 解释层存在降级分支，不会因紫微缺失中断匹配

## 5. 验收要求

- [x] 匹配结果中能看到紫微分项
- [x] 匹配解释中能看到紫微说明
- [x] 紫微低置信时不输出强结论
- [x] 关闭 MBTI 后不再出现在活跃排序链路

## 6. 建议上线动作

1. 先在测试账号/内测账号上跑一次 `app:dev:fill-synthetic-ziwei`
2. 再执行 `app:dev:astro-shadow-compare`
3. 若无异常，再开启对应版本发布
