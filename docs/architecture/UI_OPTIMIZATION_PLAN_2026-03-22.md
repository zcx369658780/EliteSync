# EliteSync 整体 UI 优化方案（顾问评审版）

日期：2026-03-22
来源：Android Studio Developer 顾问 Agent

## 一、问题诊断（当前）
1. 非登录页存在双层星空背景渲染：`AppNavHost` 与 `GlassScrollPage` 同时绘制背景。
2. 视觉 token 分散在 `MainActivity` 与 `StarryScaffold`，导致颜色、字号、圆角不统一。
3. 底部 Tab 仍使用渐变指示器，不符合当前“纯色统一”方向。
4. 登录页动画层级偏多，视觉杂乱且性能不稳。
5. 多页面仍是裸文本堆叠，缺少统一页面骨架（header/card/status）。

## 二、设计系统（可直接编码）
- 主色：`BrandPrimary #4B6796`（按下态 `#3D557C`）
- 次色：`BrandSecondary #162134`
- 背景：`BgBase #050814`，`BgDepth #0A1221`
- 卡片：`SurfaceCard #101A2B @ 0.88`，边框 `BorderSubtle #24344D`
- 文本：`TextPrimary #F2F6FF`，`TextSecondary #B5C2D8`，`TextTertiary #7E8CA5`
- 错误/警告/成功：`#D96B72 / #C89D57 / #4EAD84`

- 字号层级：
  - LandingTitle `32/40 SemiBold`
  - PageTitle `24/32 SemiBold`
  - SectionTitle `18/26 Medium`
  - Body `15/22`
  - BodySmall `13/19`
  - Button `15/20 Medium`
  - Tab `13/18 Medium`

- 尺寸：
  - 按钮高 `48dp`，输入高 `52dp`
  - 圆角：按钮/输入 `14dp`，卡片 `16dp`，Tab 容器 `18dp`
  - 页面左右 padding `16dp`

- 动效：
  - 按压 `90~120ms`
  - 状态色切换 `160ms`
  - 页面切换 `220ms`
  - 登录页保留星空动态，业务页禁止无意义无限 pulse

## 三、组件规范
- 统一 Primary/Secondary/Text Button；统一输入框 focus/error 样式；统一卡片和列表项。
- 新增统一状态组件：`InlineStatusBanner`（成功/处理中/失败）。
- 底部 Tab 改为纯色选中块，去掉渐变。

## 四、页面规范
- Register：保留星空沉浸，但仅两态（品牌引导态、认证表单态）。
- Recommend：改为“摘要卡 + CTA卡”。
- Discover：改为“当前位置卡 + 搜索卡 + 结果列表”。
- Me：改为“个人摘要卡 + 菜单分组 + 危险操作分离”。
- ProfileInsights：改为“输入参数卡 + 出生地卡 + 结果卡”。
- BasicProfile：改为标准表单页，顶部统一返回栏，底部单主按钮保存。

## 五、性能策略
- 非登录页只保留一个背景 owner（建议由 `AppNavHost` 负责）。
- `liteMode` 下：关闭 route pulse、简化转场、降低星点密度/发光/更新频率。
- 同屏动画类型不超过 2 类。

## 六、分阶段执行
### 阶段1（当天）
1. 落 `tokens`（颜色/字号/间距/圆角/时长）
2. Tab 纯色化 + 去 route pulse
3. 删除 `GlassScrollPage` 背景绘制（消除双背景）
4. 统一 Button/TextField 参数
5. 六个页面加统一 header + card 骨架
6. 登录页动画减负

### 阶段2（1~2天）
1. 拆分 `StarryScaffold` 为职责单一文件
2. 新增 `EliteSyncPageScaffold / TopBar / Status / Tabs`
3. 画像页结果组件化（五行/大运/流年）
4. 自动性能降级策略接入登录页

## 七、建议新增文件
- `ui/components/EliteSyncTokens.kt`
- `ui/components/EliteSyncButtons.kt`
- `ui/components/EliteSyncFields.kt`
- `ui/components/EliteSyncCards.kt`
- `ui/components/EliteSyncPageScaffold.kt`
- `ui/components/EliteSyncTopBar.kt`
- `ui/components/EliteSyncStatus.kt`
- `ui/components/EliteSyncTabs.kt`
- `ui/components/EliteSyncMotion.kt`

## 八、建议先做的四件事（优先级）
1. 解决双背景渲染
2. 底部 Tab 纯色化
3. token 收口
4. 页面骨架统一
