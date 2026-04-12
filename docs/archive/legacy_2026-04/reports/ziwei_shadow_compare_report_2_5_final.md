# 紫微 Shadow Compare 实际结果报告 2.5 - 最终修正版

日期：2026-03-30

## 执行目标

在阿里云环境中对比旧链路与当前 2.5 紫微链路的影子输出，确认差异比例、差异字段排行和样例一致性。

## 实际执行命令

```powershell
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $env:USERPROFILE\.ssh\CodexKey.pem root@101.133.161.203 'cd /opt/elitesync/services/backend-laravel && php artisan app:dev:astro-shadow-compare --user-ids=6,7,8,9,10,1006 --out=docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_WHITEPAPER_FINAL.md --json=docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_WHITEPAPER_FINAL.json'
```

## 实际输出

```text
Shadow compared 6 users, any_diff=6 (100.00%)
+------+-----------+-----------+-------+--------+-------------------------+------+
| uid  | bazi_diff | west_diff | house | aspect | rollout                 | flag |
+------+-----------+-----------+-------+--------+-------------------------+------+
| 6    | Y         | N         | N/A   | N/A    | western_global_disabled | DIFF |
| 7    | Y         | N         | N/A   | N/A    | western_global_disabled | DIFF |
| 8    | Y         | N         | N/A   | N/A    | western_global_disabled | DIFF |
| 9    | Y         | N         | N/A   | N/A    | western_global_disabled | DIFF |
| 10   | Y         | N         | N/A   | N/A    | western_global_disabled | DIFF |
| 1006 | Y         | N         | N/A   | N/A    | western_global_disabled | DIFF |
+------+-----------+-----------+-------+--------+-------------------------+------+
Reports written: docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_WHITEPAPER_FINAL.md / docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_WHITEPAPER_FINAL.json
```

## 最终汇总

- 总样本数：6
- 任一差异比例：100%
- 八字文本差异：6/6
- 八字五行差异：6/6
- 西占关键字段差异：0/6/0/0/0/0
- 紫微差异：6/6
- house 未支持：6/6
- aspect 未支持：6/6

## 差异字段排行

1. `bazi_text` - 6
2. `bazi_wuxing` - 6
3. `house_unsupported` - 6
4. `aspect_unsupported` - 6
5. `ziwei` - 6

## 样例

### user 6

```text
bazi diff: true
western diff: false
ziwei diff: true
```

### user 7

```text
bazi diff: true
western diff: false
ziwei diff: true
```

### user 8

```text
bazi diff: true
western diff: false
ziwei diff: true
```

### user 9

```text
bazi diff: true
western diff: false
ziwei diff: true
```

### user 10

```text
bazi diff: true
western diff: false
ziwei diff: true
```

### user 1006

```text
bazi diff: true
western diff: false
ziwei diff: true
```

## ziwei diff 统计口径

`ziwei diff` 采用 canonical 结果的 JSON 比较口径：只要 legacy 与 candidate 的 `ziwei` 序列化结果不一致，即计 1。

本轮样本中：

- legacy `ziwei` 与 candidate `ziwei` 的 JSON 不一致
- 因此 6/6 样本均计入 `ziwei diff`
- 这与样例和字段排行保持一致

## 结论

- 紫微 shadow compare 的摘要、字段排行、样例已经对齐
- `ziwei diff` 统计口径已明确为 JSON 不一致计数
- 当前 2.5 的影子对比可以直接供顾问复核

