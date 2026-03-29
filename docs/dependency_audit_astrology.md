# Astrology Dependency Audit (Phase 0)

- Date: 2026-03-29
- Verification pass: #1 (GitHub repo metadata + commit ref + LICENSE snapshot)
- Scope: Bazi / Chinese calendar / Western astrology / personality adjacent tooling
- Rule: 未完成许可证核验与闭源影响评估的依赖，不得作为默认生产路径上线。

## Status Legend
- `PENDING_VERIFY`: 待二次联网核验（仓库可用性、LICENSE文本、发行版条款）
- `ALLOWED_CANDIDATE`: 当前可作为低风险候选（仍需锁版本）
- `RESEARCH_ONLY`: 仅用于研究/对拍/原型
- `BLOCKED_FOR_DEFAULT_PROD`: 在闭源商用下默认阻断（需商业授权或法务批准）

## Dependency Matrix

| Name | Repo / Official | Intended Use | License (verified/claimed) | Closed-source impact | Status | Notes |
|---|---|---|---|---|---|---|
| lunar-java | https://github.com/6tail/lunar-java | Bazi/calendar canonical candidate | MIT (LICENSE verified) | Low | ALLOWED_CANDIDATE | ref `0194eb4574f33ab056fe7cac62a9d8bf24272478` |
| lunar-python | https://github.com/6tail/lunar-python | Bazi service / batch backfill | MIT (LICENSE verified) | Low | ALLOWED_CANDIDATE | ref `448f397c1695cadab3899bf460e0042cab7f0e66` |
| lunar-php | https://github.com/6tail/lunar-php | Laravel bridge/transition | MIT (LICENSE verified) | Low | ALLOWED_CANDIDATE | ref `394d9f5afc78d3364456a6bb1369dbbb6f3ba88a` |
| Tyme (`tyme4kt`) | https://github.com/6tail/tyme4kt | Next-gen calendar engine evaluation | MIT (LICENSE verified) | Low | ALLOWED_CANDIDATE | ref `00c5bbb5f9c323f78553bc5ab27e68a6a685e4dc` |
| Tyme (`tyme4py`) | https://github.com/6tail/tyme4py | Next-gen calendar engine evaluation | MIT (LICENSE verified) | Low | ALLOWED_CANDIDATE | ref `baa89acb48d45a04e47bde00d7ed725c52d70cec` |
| sxtwl_cpp | https://github.com/yuangu/sxtwl_cpp + PyPI `sxtwl` | High-precision cross-check | BSD-3-Clause (LICENSE verified) | Low/Medium | ALLOWED_CANDIDATE | ref `7598b0601a76cfdaa9266257b1b5690720c1e2ce`, PyPI 2.0.7 指向该仓库 |
| Swiss Ephemeris | https://www.astro.com/swisseph/ + https://github.com/aloistr/swisseph | Western canonical high-precision | Official AGPL/commercial dual | High | BLOCKED_FOR_DEFAULT_PROD | ref `768a4035171c9fdb381445bf974d04340de935ee` (mirror) |
| pyswisseph | https://github.com/astrorigin/pyswisseph | Prototype / validation | AGPL-3.0 (LICENSE verified) | High | BLOCKED_FOR_DEFAULT_PROD | ref `778903d59bed84b8da020cee77f1995b0df5106b` |
| Flatlib | https://github.com/flatangle/flatlib | Prototype / rules experimentation | MIT (self, LICENSE verified) | Medium/High | RESEARCH_ONLY | ref `fba89c72c13279c0709b0967a597427ee177665b`, Swiss链路待法务审计 |
| Kerykeion | https://github.com/g-battaglia/kerykeion | Synastry/composite research | AGPL-3.0 (LICENSE verified) | High | BLOCKED_FOR_DEFAULT_PROD | ref `bd60d8847b1fef447f17078ca9d9652a7f5dde9a` |
| Astronomy Engine | https://github.com/cosinekitty/astronomy | Numeric validation / lightweight astronomy | MIT (LICENSE verified) | Low | ALLOWED_CANDIDATE | ref `865d3da7d8112bbc7911238052c6af4aaf877181` |

## Mandatory Gates
1. Swiss/AGPL stack must be reviewed by legal/product owner before any default production enablement.
2. Android client must not embed AGPL-risk stack for closed-source distribution without explicit approval.
3. Any dependency marked `PENDING_VERIFY` cannot be used as `canonical_default=true`.

## Next Actions
1. Produce `docs/tyme_vs_lunar_eval.md` in Phase 2. (done)
2. Attach commercial-license decision note for Swiss stack before production rollout.
3. Keep `config/astrology_dependency_gate.php` aligned with legal decisions and env rollout policy.
