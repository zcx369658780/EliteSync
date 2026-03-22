# EliteSync UI 组件架构图（2026-03-22）

## 1. 目标
- 给顾问和开发者一眼看懂当前 UI 层结构。
- 明确每个组件文件职责、调用关系、后续扩展入口。

## 2. 当前组件分层

```text
ui/components/
  EliteSyncTokens.kt        # 视觉 token（颜色、间距、圆角、动效时长）
  StarryInteraction.kt      # 全局手势/点击反馈/性能开关上下文
  StarryBackground.kt       # 星空背景渲染（单一 owner）
  EliteSyncPageScaffold.kt  # 页面骨架（标题 + 状态条 + 滚动容器）
  EliteSyncStatus.kt        # 状态条（Info/Success/Warning/Error）
  EliteSyncCards.kt         # 统一分组卡片
  EliteSyncButtons.kt       # Primary/Secondary 按钮
  EliteSyncFields.kt        # TextField/Dropdown/DateDropdown
  EliteSyncTabs.kt          # 底部导航 Tab（纯色选中块）
  StarryScaffold.kt         # 轻量兼容层（ListItemCard/OptionCard/GlassSection）
```

## 3. 调用关系（简图）

```text
MainActivity
  -> AppNavHost
     -> ProvideUiPerformanceSettings (StarryInteraction)
     -> ProvideUiFeedbackSettings (StarryInteraction)
     -> StarryAppBackground (StarryBackground) [非 register]
     -> EliteSyncBottomTabs (EliteSyncTabs)
     -> Screens...

Screens
  -> GlassScrollPage (EliteSyncPageScaffold)
     -> StarryStatusBanner (EliteSyncStatus)
  -> StarrySectionCard (EliteSyncCards)
  -> StarryPrimaryButton / StarrySecondaryButton (EliteSyncButtons)
  -> StarryTextField / StarryDropdownField / StarryDateDropdownField (EliteSyncFields)
  -> StarryListItemCard / StarryOptionCard (StarryScaffold)
```

## 4. 页面接入现状
- 已接入统一骨架与卡片分区：
  - Register / Recommend / Discover / Match / Messages / Chat
  - Me / MeSettings / BasicProfile / ProfileInsights
  - OnboardingHub / Preferences / Questionnaire

## 5. 已解决问题对照
1. 双背景渲染：已修复（背景归 `AppNavHost` owner）。
2. Tab 渐变不统一：已修复（纯色选中块，`EliteSyncTabs`）。
3. 组件风格散乱：已统一到 Token + 组件层。
4. 登录页动画过重：已改为两态轻量切换。

## 6. 仍建议后续优化（可选）
1. 增加 `EliteSyncTypography.kt`：把 `MainActivity` 字体层级抽成统一文件。
2. 增加 `EliteSyncMotion.kt`：统一页面转场/按压/状态动画时长。
3. 为 `StarryListItemCard` 增加 title/subtitle/trailing 参数，替代单字符串展示。
4. 增加 UI 回归截图清单（核心页面 1 套）。

## 7. 维护约束
1. 页面中禁止直接硬编码主色/间距/圆角，必须走 `EliteSyncTokens`。
2. 新页面默认使用 `GlassScrollPage + StarrySectionCard`。
3. 非登录页禁止再单独绘制背景层。
4. 新增按钮/输入样式必须扩展组件层，不允许在页面重复实现。

## 8. 编译状态
- 最新验证：`:app:compileDebugKotlin` 通过。
