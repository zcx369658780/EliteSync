# License Dependency Status

- Last Updated: 2026-03-29 (Phase 0 verified pass #1)
- Purpose: 跟踪本项目所有关键依赖的授权状态，明确哪些可直接商用、哪些必须先取得授权。
- Mandatory Rule: 每次新增/升级依赖后，必须更新本文件。

## Status Legend
- `OPEN_OK`: 许可证明确且可用于闭源商用（仍需保留版权声明等义务）
- `OPEN_VERIFY`: 疑似开源但待核验（仓库/版本/LICENSE 文本未锁定）
- `RESTRICTED`: 有条件授权或强Copyleft，闭源商用需法务确认
- `BLOCKED_DEFAULT`: 默认禁止用于闭源生产，除非拿到商业授权

## Current Registry
| Dependency | Version/Ref | License | Commercial Use | Status | Notes |
|---|---|---|---|---|---|
| lunar-java | master@`0194eb4574f33ab056fe7cac62a9d8bf24272478` | MIT | Allowed | OPEN_OK | License snapshot: `docs/licenses/astrology/lunar-java__LICENSE.txt` |
| lunar-python | master@`448f397c1695cadab3899bf460e0042cab7f0e66` | MIT | Allowed | OPEN_OK | License snapshot: `docs/licenses/astrology/lunar-python__LICENSE.txt` |
| lunar-php | composer `6tail/lunar-php:^1.4` (lock 1.4.0) | MIT | Allowed | OPEN_OK | 已接入服务端 canonical 八字链路；snapshot: `docs/licenses/astrology/lunar-php__LICENSE.txt` |
| Tyme (`tyme4kt`) | master@`00c5bbb5f9c323f78553bc5ab27e68a6a685e4dc` | MIT | Allowed | OPEN_OK | License snapshot: `docs/licenses/astrology/tyme4kt__LICENSE.txt` |
| Tyme (`tyme4py`) | master@`baa89acb48d45a04e47bde00d7ed725c52d70cec` | MIT | Allowed | OPEN_OK | License snapshot: `docs/licenses/astrology/tyme4py__LICENSE.txt` |
| sxtwl_cpp (`yuangu/sxtwl_cpp`) | master@`7598b0601a76cfdaa9266257b1b5690720c1e2ce` | BSD-3-Clause | Allowed | OPEN_OK | PyPI `sxtwl 2.0.7` 指向该仓库；snapshot: `docs/licenses/astrology/sxtwl_cpp__LICENSE.txt` |
| Swiss Ephemeris (source mirror) | master@`768a4035171c9fdb381445bf974d04340de935ee` | AGPL/commercial dual (official) | Restricted | BLOCKED_DEFAULT | 未取得商业授权前禁止闭源默认生产 |
| pyswisseph | master@`778903d59bed84b8da020cee77f1995b0df5106b` | AGPL-3.0 | Restricted | BLOCKED_DEFAULT | License snapshot: `docs/licenses/astrology/pyswisseph__LICENSE.txt` |
| Flatlib | master@`fba89c72c13279c0709b0967a597427ee177665b` | MIT (self) | Restricted chain | RESTRICTED | 依赖Swiss链路，商业闭源需连带审计 |
| Kerykeion | main@`bd60d8847b1fef447f17078ca9d9652a7f5dde9a` | AGPL-3.0 | Restricted | BLOCKED_DEFAULT | License snapshot: `docs/licenses/astrology/kerykeion__LICENSE.txt` |
| Astronomy Engine | master@`865d3da7d8112bbc7911238052c6af4aaf877181` | MIT | Allowed | OPEN_OK | License snapshot: `docs/licenses/astrology/astronomy-engine__LICENSE.txt` |

## Maintenance Checklist (must run on dependency change)
1. 记录依赖名、版本、仓库URL。
2. 保存 LICENSE 文本快照到 `docs/licenses/`。
3. 更新本文件状态与备注。
4. 若为 `RESTRICTED` 或 `BLOCKED_DEFAULT`，在 PR 描述中显式标红。
5. 未完成许可证核验，不得标记为生产默认依赖。

## Related Docs
- `docs/dependency_audit_astrology.md`
- `.codex/LONG_TERM_MEMORY.md`
