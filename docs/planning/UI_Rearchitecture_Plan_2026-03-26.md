# EliteSync UI 重构计划（2026-03-26）

## 1. 输入文档与约束
已阅读并作为唯一规范源：
1. `UI_example/开发命令.md`
2. `UI_example/Flutter_UI_Implementation_Plan_EliteSync_V1.md`
3. `UI_example/Flutter_Project_Scaffold_And_Directory_Blueprint_EliteSync_V1.md`
4. `UI_example/Flutter_First_File_Generation_Checklist_And_Prompt_Templates_EliteSync_V1.md`
5. `UI_example/Flutter_T01_T05_Continuous_Prompt_Pack_EliteSync_V1.md`
6. `UI_example/Flutter_T06_T10_Continuous_Prompt_Pack_EliteSync_V1.md`
7. `UI_example/Flutter_T11_T15_Continuous_Prompt_Pack_EliteSync_V1.md`
8. `UI_example/Flutter_T16_T18_Continuous_Prompt_Pack_EliteSync_V1.md`
9. `UI_example/Flutter_Route_Guard_And_Navigation_Flow_Prompt_Pack_EliteSync_V1.md`

风格参考截图已读取（信息流卡片 + 顶部分类 + 底部导航 + 品牌渐变/圆角）。

## 2. 当前仓库现实状态判断
- 当前移动端是 **Android 原生（Jetpack Compose）**，并非 Flutter。
- 仓库中不存在 `pubspec.yaml` 与 Flutter 工程骨架。
- 因此本次属于 **UI 架构重建（Greenfield Flutter Client）**，不是小修小改。

## 3. 总体实施策略（避免一次性推倒）
采用“双轨并行 + 分阶段切换”：
- 旧轨：保留现有 Android 客户端，继续可用。
- 新轨：新建 Flutter 客户端，按 T01-T18 + RG01-RG06 顺序实现。
- 切换点：Flutter 完成核心链路并通过验收后，再替换发布主客户端。

## 4. 目录与分支策略
- 新客户端目录建议：`apps/flutter_elitesync/`
- 不覆盖现有 `apps/android/`。
- 分支：继续使用当前功能分支推进，合并按“每天一次 Review/Merge/Regression”规则执行。

## 5. 分阶段计划（可执行）

### Phase A：工程落地与设计系统地基（T01-T05）
目标：能启动、有主题、有组件、有统一视觉底座。
- T01 App 入口/Router/Shell
- T02 Tokens
- T03 Theme
- T04 Buttons/Cards/Tags
- T05 Fields/Bars/States/Layout
验收：
- Flutter 工程可编译启动
- 组件 demo 可见
- 无页面硬编码样式

### Phase B：基础设施与登录闭环（T06-T10）
目标：具备网络/存储/错误处理/session/mock/auth。
- T06 Core(Logging/Error/Storage)
- T07 Core(Network)
- T08 Shared & Session
- T09 Mock 数据体系
- T10 Auth（登录/注册）
验收：
- mock 登录可跑通
- session 状态可恢复
- 页面具备 loading/error

### Phase C：核心产品链路页面（T11-T15）
目标：认证、问卷、首页、匹配结果链路产品化。
- T11 Verification
- T12 Questionnaire
- T13 Home Feed
- T14 Match Countdown/Result
- T15 Match Detail/Intention
验收：
- 从登录到匹配可完整走通
- 匹配结果页为“产品解释页”非调试页

### Phase D：聊天/我的/测试骨架（T16-T18）
目标：主流程闭环与测试基础。
- T16 Chat（文本闭环）
- T17 Profile
- T18 测试骨架（unit/widget/golden/integration）
验收：
- 聊天文本闭环可运行
- 我的页可编辑与设置
- 测试命令可执行

### Phase E：路由守卫与导航分流（RG01-RG06）
目标：统一状态驱动导航，避免页面内乱跳。
- RG01 导航状态聚合
- RG02 Router Guard 基础接入
- RG03 Splash 启动分流
- RG04 Shell Tab 动态分流
- RG05 页面级访问限制
- RG06 统一导航 helper
验收：
- 未登录/未认证/未问卷/已出结果均能自动分流
- 无循环跳转

### Phase F：联调与切换
目标：Flutter 对接现有 Laravel API，达到可替换发布。
- 逐模块从 mock 切到 real API
- 埋点接入（登录、问卷、匹配、聊天、资料）
- 性能与稳定性回归
验收：
- Android 真机流程通过
- Regression 通过
- 准备替换旧客户端发布

## 6. 本轮建议立即执行范围
按文档要求，从最早缺失阶段开始：
1. 新建 `apps/flutter_elitesync` 工程
2. 直接执行 T01
3. 编译验证通过后进入 T02

本轮不动：
- 现有 Compose UI 代码
- 后端算法逻辑
- 发布脚本（先保持现状）

## 7. 风险与控制
1. 风险：重构周期长。
- 控制：每轮 5~15 文件，阶段验收。
2. 风险：新旧端并行导致维护压力。
- 控制：旧端仅修阻塞 bug；新功能只进 Flutter。
3. 风险：UI与接口字段不匹配。
- 控制：坚持 DTO/Entity/ViewData 三层，先 mock 后联调。

## 8. 与顾问建议的一致性结论
本计划与 Android Studio Developer 提供的 Flutter 轨道一致：
- 技术栈一致（Flutter + Riverpod + go_router）
- 任务顺序一致（T01→T18→Route Guard）
- 视觉策略一致（深色仪式感 + 浅色浏览页 + 信息流）

---

## 结论
这是一次“客户端技术栈级重构”，建议从 **T01** 正式开工，采用新目录并行推进，保证当前版本可用且可回滚。
