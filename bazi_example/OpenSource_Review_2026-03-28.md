# 开源依赖复核台账（2026-03-28）

> 目的：对顾问建议涉及的开源项目做首轮复核（可用性 + 许可证 + 商用兼容）
> 结论标签：`approved` / `conditional` / `unverified`
> 说明：本台账用于工程决策，不替代正式法律意见。

---

## 1) 6tail/lunar-java
- 仓库：<https://github.com/6tail/lunar-java>
- 可用性：通过（GitHub 可访问，194 commits，71 releases，Latest Nov 5, 2025）
- 许可证：MIT（仓库页面显示 MIT license）
- 商用兼容：高（MIT 通常可用于闭源商用，需保留许可证文本）
- 结论：`approved`
- 备注：适合作为八字/历法主链路之一。

## 2) 6tail/lunar-python
- 仓库：<https://github.com/6tail/lunar-python>
- 可用性：通过（GitHub 可访问，77 commits，37 releases，Latest Nov 5, 2025）
- 许可证：MIT（仓库页面显示 MIT license）
- 商用兼容：高（MIT）
- 结论：`approved`
- 备注：适合做服务端批量计算、对拍与离线验证。

## 3) aloistr/swisseph（Swiss Ephemeris）
- 仓库：<https://github.com/aloistr/swisseph>
- 可用性：通过（GitHub 可访问，751 commits，3 releases）
- 许可证：双许可（LICENSE 文件明确）
  - AGPL
  - Swiss Ephemeris Professional License（商业授权）
- 商用兼容：有条件
  - 若走 AGPL，网络服务场景会触发更强开源义务
  - 闭源商用通常需购买 Professional License
- 结论：`conditional`
- 备注：可技术上采用，但上线前必须明确许可路径。

## 4) g-battaglia/kerykeion
- 仓库：<https://github.com/g-battaglia/kerykeion>
- 可用性：通过（GitHub 可访问，1530 commits，26 releases，Latest Mar 17, 2026）
- 许可证：AGPL-3.0（仓库 License 与 README 均明确）
- 商用兼容：有条件
  - 闭源系统直接集成风险高
  - 仅在满足 AGPL 义务或采用其商业替代服务时可用
- 结论：`conditional`
- 备注：更适合作为研发验证/算法对拍，不建议直接并入闭源主系统。

## 5) flatangle/flatlib
- 仓库：<https://github.com/flatangle/flatlib>
- 可用性：通过（GitHub 可访问，149 commits，2 releases，Latest Apr 5, 2021）
- 许可证：MIT
- 商用兼容：高（MIT）
- 结论：`approved`
- 备注：许可友好，但版本较老；可作为辅助验证库，不建议作为唯一生产内核。

## 6) sxtwl / 寿星天文历相关实现（顾问建议的“校验源”）
- 可用性：未完成复核（存在多个分叉与镜像，尚未锁定唯一主仓）
- 许可证：未完成复核
- 商用兼容：未完成复核
- 结论：`unverified`
- 备注：在锁定具体仓库前，不可作为正式依赖。

---

## 建议采用策略（当前阶段）

1. 生产可先采用：`lunar-java` / `lunar-python`（MIT）
2. Swiss Ephemeris 作为 2.0 星盘标准内核候选，但进入生产前必须先确定授权路径（AGPL or 商业授权）
3. Kerykeion 仅作为对拍/原型参考，暂不作为闭源主链依赖
4. `sxtwl` 类项目先补齐“唯一仓库 + 许可证”再评估

---

## 复核证据来源（关键摘录）

- `lunar-java` 页面显示 MIT license，且有 releases/commits/stars 信息
- `lunar-python` 页面显示 MIT license，且有 releases/commits/stars 信息
- `kerykeion` 页面显示 AGPL-3.0，README 明确 AGPL 使用提醒
- `swisseph` LICENSE 明确 dual licensing：AGPL 或 Professional License
- `flatlib` LICENSE 为 MIT

（复核时间：2026-03-28，来源为公开仓库页面与 LICENSE 文件。）
