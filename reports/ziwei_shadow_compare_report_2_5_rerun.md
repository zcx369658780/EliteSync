# 紫微 Shadow Compare 实际结果报告 2.5

日期：2026-03-30

## 执行目标

在阿里云环境中对比旧链路与当前 2.5 紫微链路的影子输出，确认差异比例与主要差异项。

## 实际执行命令

```powershell
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $env:USERPROFILE\.ssh\CodexKey.pem root@101.133.161.203 'cd /opt/elitesync/services/backend-laravel && php artisan app:dev:astro-shadow-compare --limit=100 --out=docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_RERUN.md --json=docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_RERUN.json'
```

## 实际输出摘要

```text
Shadow compared 100 users, any_diff=100 (100.00%)
Reports written: docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_RERUN.md / docs/devlogs/ASTRO_SHADOW_COMPARE_2_5_RERUN.json
```

远端生成的报告摘要如下：

```text
- generated_at: 2026-03-30T11:36:05+00:00
- total: 100
- any_diff: 100 (100%)
- bazi diff (sun/text/wuxing): 1/97/97
- western diff (sun/moon/asc/precision/engine/conf_major): 0/0/0/0/0/0
- ziwei diff: 0
- unsupported house/aspect: 100 (100%)/100 (100%)
```

## 差异比例

- 总样本数：100
- 任一差异比例：100%
- 八字文本差异：97%
- 八字五行差异：97%
- 西占关键字段差异：0%
- house/aspect 未支持比例：100% / 100%

## 差异字段排行

1. `house_unsupported` - 100
2. `aspect_unsupported` - 100
3. `ziwei` - 100
4. `bazi_text` - 97
5. `bazi_wuxing` - 97

## 样例

### user 9

```text
bazi:
  legacy bazi: 己巳 壬申 戊辰 戊午
  candidate bazi: 丁丑 壬子 戊申 戊午
  diff: sun_sign=true, bazi_text=true, wu_xing=true
western:
  legacy engine: legacy_input
  candidate engine: legacy_input
  diff: all false
ziwei:
  legacy: []
  candidate: ziwei_canonical_server
  diff: true
```

### user 11

```text
bazi:
  legacy bazi: 己巳 壬申 戊辰 己未
  candidate bazi: 己巳 壬申 戊辰 己未
  diff: all false
western:
  legacy engine: legacy_input
  candidate engine: legacy_input
  diff: all false
ziwei:
  legacy: []
  candidate: ziwei_canonical_server
  diff: true
```

### user 1091

```text
bazi:
  legacy bazi: 戊寅年 癸亥月 丁巳日 甲午时
  candidate bazi: 戊寅 丙辰 壬午 辛亥
  diff: bazi_text=true, wu_xing=true
western:
  legacy engine: legacy_input
  candidate engine: legacy_input
  diff: all false
ziwei:
  legacy: []
  candidate: ziwei_canonical_server
  diff: true
```

## 结论

- 紫微链路已进入 shadow compare
- 当前 shadow compare 的主要差异集中在 `ziwei`、`house_unsupported`、`aspect_unsupported` 和八字文本/五行差异
- 西占核心字段仍为 0 差异，说明 canonical 接管尚未在该快照启用
