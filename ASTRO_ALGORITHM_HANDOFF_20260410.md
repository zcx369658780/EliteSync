# EliteSync 星盘算法交接文档

生成日期：2026-04-10  
适用版本：3.2 / 3.2a 收尾阶段  
文档用途：算法需求交接、能力盘点、缺口归纳、后续同事评审输入

> 冻结声明  
> 本文档提交后，星盘相关修改任务冻结：不再继续扩展、重写或自作主张补全算法实现，直到同事给出可行回复、接口定义、样本数据或明确的实现方向。

---

## 0. 结论摘要

当前 EliteSync 的星盘能力已经形成了“输入采集 - 服务端计算 - 本地绘制 - 本地偏好控制”的完整链路，但这条链路并不是“测测”式星盘的完整实现。

当前已具备的能力：

- 西洋星盘数据可以通过 Python + Kerykeion 生成 `chart_data`
- Flutter 端可以完全本地绘制 SVG 星盘
- 盘面显示开关已经细分到图上元素级别
- 八字由 `6tail/lunar-php` 生成
- 紫微由当前服务端的 `ZiweiCanonicalService` 生成
- 出生地点搜索、真太阳时修正、资料保存、缓存回写已经存在

当前尚不完整的地方：

- Laravel 侧的西洋星盘“canonical 真值”仍未统一为一个完全成熟的引擎
- 目前西洋盘算法、古典盘、现代盘、多种宫位制、恒星黄道、相位容许度、虚点等高级参数还没有完全暴露成产品级算法设置
- `docx` 里提到的“参数解读、星体、相位、主星、大限、流年”的独立解释窗还只是展示/解读需求，没有全部落成算法与数据标准
- 要完整复现“测测”式体验，还需要一套明确的图谱规则、计算规则、解释规则和测试金样本

---

## 1. 当前实现：库、数据、算法、接口

### 1.1 当前星盘链路总览

现在的系统链路可以简化为：

1. 用户在 APP 中填写或修改基础资料、出生时间、出生地
2. Laravel 根据基础资料和出生地，计算真太阳时和 canonical 画像
3. Laravel 保存 `user_astro_profiles`，并同步镜像到 `users` 上的私有字段
4. Laravel 在需要时调用 Python 星盘服务
5. Python 使用 Kerykeion 计算 `chart_data`
6. Flutter 不再依赖服务端 SVG，而是根据 `chart_data` 本地绘制星盘 SVG
7. Flutter 通过 `flutter_svg` 渲染本地生成的 SVG 字符串

这条链路和“测测”类应用最大的不同是：

- 当前实现更偏“结构化数据 + 本地渲染”
- 不是完整的“算法引擎一体化 + 解释模板 + 图层配置中心”

---

### 1.2 当前使用的库文件与职责

#### 1.2.1 Python 星盘计算库

**文件：**

- `services/api/requirements.txt`
- `services/api/app/services/astro.py`

**当前版本：**

- `kerykeion==5.12.7`

**职责：**

- 从出生日期、出生时间、出生地、经纬度、时区生成 `AstrologicalSubject`
- 基于 subject 生成 `ChartData`
- 输出标准化的星盘结构化数据，不输出最终 Flutter 图像

**当前实现方式：**

- 使用 `AstrologicalSubjectFactory.from_birth_data(...)`
- 使用 `ChartDataFactory.create_natal_chart_data(subject)`
- 通过 `chart_data.model_dump()` 拿到结构化 JSON
- 从 `subject` 里抽取：
  - `planets_data`
  - `houses_data`
  - `aspects_data`
  - `generated_at`

**说明：**

- 当前 EliteSync 并没有直接把 Kerykeion 的 `ChartDrawer` 用作最终 UI 图像渲染
- Kerykeion 的职责目前被限定在“计算数据”
- 最终绘制交给 Flutter 本地 SVG 生成器

#### 1.2.2 PHP 八字库

**文件：**

- `services/backend-laravel/composer.json`
- `services/backend-laravel/app/Services/LunarPhpBaziEngine.php`

**当前版本：**

- `6tail/lunar-php` `^1.4`

**职责：**

- 处理公历/农历、干支、星座、八字、五行、节气等
- 用于 canonical 八字计算
- 用于大运、流年等八字衍生数据

**当前实现方式：**

- 基于 `com\nlf\calendar\Solar`
- 从 `birthday + true_solar_time` 生成八字
- 输出：
  - `sun_sign`
  - `moon_sign`
  - `asc_sign`
  - `bazi`
  - `true_solar_time`
  - `da_yun`
  - `liu_nian`
  - `wu_xing`
  - `notes`

**说明：**

- 这是当前 Laravel 侧八字 canonical 的主实现
- 如果缺少生日或出生时间，会 fallback 到保守估计

#### 1.2.3 Flutter SVG 渲染库

**文件：**

- `apps/flutter_elitesync_module/pubspec.yaml`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/widgets/natal_chart_svg_card.dart`

**当前版本：**

- `flutter_svg: ^2.2.4`

**职责：**

- 将 Flutter 本地拼接出的 SVG 字符串渲染到页面
- 支持 `SvgPicture.string(...)`
- 支持 `BoxFit.contain`

**说明：**

- 当前星盘图本体不再由服务端输出 SVG
- Flutter 直接根据 `chart_data` 生成 SVG 再渲染

#### 1.2.4 其他配套库

**文件：**

- `apps/flutter_elitesync_module/pubspec.yaml`

**当前相关库：**

- `flutter_riverpod`
- `go_router`
- `shared_preferences`
- `flutter_secure_storage`
- `dio`
- `fl_chart`

**说明：**

- `fl_chart` 仅用于页面中的技术参数柱状图等 UI 辅助图表
- 它不参与星盘计算

---

### 1.3 当前代码级职责分层

#### 1.3.1 输入与资料层

**核心文件：**

- `services/backend-laravel/app/Http/Controllers/Api/V1/ProfileController.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/GeoController.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/AstroProfileController.php`
- `services/api/app/routers/astro.py`

**职责：**

- 接收用户生日、出生时间、出生地、经纬度
- 处理出生地搜索
- 触发星盘重算
- 保存资料

#### 1.3.2 真太阳时修正层

**核心文件：**

- `services/backend-laravel/app/Services/BirthLocationSolarTimeService.php`

**职责：**

- 用出生地经度和均时差推算 `true_solar_time`
- 生成 `location_shift_minutes`
- 生成 `position_signature`

**当前算法特点：**

- 以东八区 120E 作为默认参考经线
- 经度修正公式：`(birthLng - 120.0) * 4`
- 均时差使用一个简化的近似公式

**限制：**

- 这是一个实用型近似，不是完整天文台级算法
- 适合当前产品收口和可解释性，但不足以代表高精度专业排盘引擎

#### 1.3.3 八字 canonical 层

**核心文件：**

- `services/backend-laravel/app/Services/BaziCanonicalService.php`
- `services/backend-laravel/app/Services/LunarPhpBaziEngine.php`
- `services/backend-laravel/app/Services/LegacyClientBaziEngine.php`

**职责：**

- 将生日和真太阳时转成八字及五行信息
- 输出 `da_yun / liu_nian / wu_xing`

**当前策略：**

- 默认使用 `LunarPhpBaziEngine`
- 当生日/时间缺失或异常时 fallback 到 `LegacyClientBaziEngine`

#### 1.3.4 西洋星盘 canonical 层

**核心文件：**

- `services/backend-laravel/app/Services/WesternNatalCanonicalService.php`
- `services/backend-laravel/app/Services/WesternNatalEngine.php`
- `services/backend-laravel/app/Services/LegacyInputWesternNatalEngine.php`
- `services/backend-laravel/app/Providers/AppServiceProvider.php`
- `services/backend-laravel/config/western_natal.php`
- `services/backend-laravel/config/astrology_dependency_gate.php`

**当前状态：**

- Laravel 侧并没有真正实现一个完整的西洋天文历法引擎
- 目前注入的 `WesternNatalEngine` 实际上仍是 `LegacyInputWesternNatalEngine`
- 该引擎是一个保守估计/兜底实现，不是完整的天文推算引擎

**当前输出：**

- `sun_sign`
- `moon_sign`
- `asc_sign`
- `engine`
- `precision`
- `confidence`
- `degraded`
- `degrade_reason`

**重要说明：**

- 这是当前系统的“接口层”
- 它并不等价于完整的“古典/现代星盘引擎”
- 真正的星盘 `chart_data` 计算，当前交给 Python 的 Kerykeion 服务

#### 1.3.5 紫微 canonical 层

**核心文件：**

- `services/backend-laravel/app/Services/ZiweiCanonicalService.php`
- `services/backend-laravel/app/Services/AstroCanonicalRolloutService.php`

**当前状态：**

- 这是一个当前可用的服务端 canonical 生成器
- 但它是“种子驱动的确定性伪实现”
- 不是完整专业紫微命盘引擎

**当前输出：**

- `life_palace`
- `body_palace`
- `major_themes`
- `palaces`
- `summary`
- `engine`
- `precision`
- `confidence`

**说明：**

- 适合做产品阶段的画像和可解释演示
- 不适合作为“测测”级别的最终紫微算法真源

#### 1.3.6 西洋星盘数据层（Python）

**核心文件：**

- `services/api/app/services/astro.py`
- `services/api/app/routers/astro.py`
- `services/api/app/schemas/api.py`

**职责：**

- 使用 Kerykeion 计算西洋星盘数据
- 输出 `chart_data`
- 以结构化 JSON 提供给 Laravel / Flutter

#### 1.3.7 Flutter 本地绘制层

**核心文件：**

- `apps/flutter_elitesync_module/lib/features/profile/presentation/widgets/natal_chart_svg_builder.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/widgets/natal_chart_svg_card.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_natal_chart_page.dart`

**职责：**

- 读取 `chart_data`
- 在本地拼出 SVG 字符串
- 使用 `flutter_svg` 渲染
- 通过本地设置控制元素显示

**当前可控图层：**

- 星座分区线
- 星座文字
- 宫位分割线
- 宫位编号
- 相位连线
- 行星引导线
- 行星点位
- 行星文字
- 盘心标题
- 盘心时间
- 盘心地点

---

### 1.4 当前存储结构

#### 1.4.1 Laravel `users` 表镜像字段

**文件：**

- `services/backend-laravel/database/migrations/2026_03_21_120000_add_profile_privacy_fields_to_users_table.php`

**关键字段：**

- `birthday`
- `private_bazi`
- `private_natal_chart`
- `private_birth_place`
- `private_birth_lat`
- `private_birth_lng`

**说明：**

- `private_natal_chart` 目前是星盘缓存镜像
- 过去可能包含 SVG 缓存或服务端 render payload
- 当前 APP 端绘制已经迁移到本地，所以它更适合存结构化 chart data / profile cache，而不应再作为唯一图像真源

#### 1.4.2 `user_astro_profiles` 表

**文件：**

- `services/backend-laravel/database/migrations/2026_03_21_200000_create_user_astro_profiles_table.php`
- `services/backend-laravel/database/migrations/2026_03_21_210000_add_luck_and_wuxing_to_user_astro_profiles_table.php`

**关键字段：**

- `user_id`
- `birth_time`
- `birth_place`
- `birth_lat`
- `birth_lng`
- `sun_sign`
- `moon_sign`
- `asc_sign`
- `bazi`
- `true_solar_time`
- `da_yun`
- `liu_nian`
- `wu_xing`
- `notes`
- `computed_at`

**说明：**

- 这是当前 astro canonical 主表
- Flutter 和 Python 生成的数据可以回写到这里的镜像字段

#### 1.4.3 Python 侧 `UserAstroProfile`

**文件：**

- `services/api/app/models/entities.py`

**关键字段：**

- `birthday`
- `birth_time`
- `birth_place`
- `birth_lat`
- `birth_lng`
- `tz_str`
- `natal_chart_svg`
- `natal_chart_json`
- `computed_at`

**说明：**

- Python 侧既可保留 JSON，也有 `natal_chart_svg` 列
- 但当前产品实现已经把最终展示迁移到 Flutter 本地 SVG

---

### 1.5 当前接口清单

#### 1.5.1 资料与星盘相关接口

| 接口 | 作用 | 输入 | 当前输出 |
|---|---|---|---|
| `GET /api/v1/profile/basic` | 获取基础资料 | 无 | 生日、城市、关系目标、出生地等 |
| `POST /api/v1/profile/basic` | 保存基础资料并重算 astro | `birthday/name/gender/city/relationship_goal/birth_place/birth_lat/birth_lng` | `ok + user` |
| `GET /api/v1/profile/astro` | 获取完整 astro 资料 | 无 | `exists/profile`，可含星盘数据 |
| `POST /api/v1/profile/astro` | 保存 astro 资料并重算 canonical 画像 | `birth_time/birth_place/lat/lng` 等 | `ok + profile` |
| `GET /api/v1/profile/astro/summary` | 获取 astro 概览 | 无 | 不含 SVG，适合轻量展示 |
| `GET /api/v1/profile/astro/chart` | 获取 chart data | 无 | `chart_data/planets_data/houses_data/aspects_data` |
| `POST /api/v1/profile/astro/render` | Python 端直接渲染数据 | `name/birthday/birth_time/birth_place/lat/lng/tz_str` | `chart_data/...` |
| `GET /api/v1/geo/places` | 百度地点候选 | `query/region` | 地点候选列表 |

#### 1.5.2 当前接口调用路径

**基础资料保存路径：**

`ProfileController::saveBasic`

- 保存 `users` 基础字段
- 调用 `BirthLocationSolarTimeService`
- 调用 `BaziCanonicalService`
- 调用 `WesternNatalCanonicalService`
- 调用 `ZiweiCanonicalService`
- 更新 `user_astro_profiles`
- 镜像回写 `users`

**星盘保存路径：**

`AstroProfileController::save`

- 保存用户星盘输入
- 计算真太阳时
- 计算八字、紫微、西洋摘要
- 调用 `UserAstroMirrorService`
- 更新 `user_astro_profiles`
- 通过 `PythonAstroRenderService` 获取 `chart_data`
- 同步或复用 `users.private_natal_chart`

**星盘展示路径：**

`AstroProfileController::showSummary / showChart / show`

- 先从 `user_astro_profiles` / `users.private_natal_chart` 取缓存
- 再决定是否调用 Python render 服务
- 返回结构化 `chart_data`
- Flutter 根据 `chart_data` 本地绘制

---

### 1.6 当前算法详细说明

#### 1.6.1 出生地与真太阳时修正

**文件：**

- `services/backend-laravel/app/Services/BirthLocationSolarTimeService.php`

**输入：**

- `birthday`
- `birth_time`
- `birth_place`
- `birth_lat`
- `birth_lng`

**输出：**

- `effective_birthday`
- `effective_birth_time`
- `true_solar_time`
- `location_shift_minutes`
- `longitude_offset_minutes`
- `equation_of_time_minutes`
- `location_source`
- `position_signature`

**当前算法逻辑：**

- 以北京时间 `Asia/Shanghai` 为基础
- 依据经度计算 `longitude_offset_minutes = round((lng - 120) * 4)`
- 使用简化版均时差公式计算 `equation_of_time_minutes`
- 两者相加得到 `shift_minutes`
- 将源时间加上 `shift_minutes` 得到真太阳时

**当前边界：**

- 这是当前可用的工程化真太阳时修正
- 不是完整天文历法意义上的高精度算法
- 如果要接近专业排盘软件，仍需明确时区历史、夏令时、经纬度精度、真太阳时定义口径

#### 1.6.2 八字与五行

**文件：**

- `services/backend-laravel/app/Services/LunarPhpBaziEngine.php`

**输入：**

- `birthday`
- `true_solar_time` 或 `birth_time`
- `gender`
- 以及可选的 `birth_lat / birth_lng / notes`

**输出：**

- `sun_sign`
- `moon_sign`
- `asc_sign`
- `bazi`
- `true_solar_time`
- `da_yun`
- `liu_nian`
- `wu_xing`
- `notes`
- `accuracy`
- `confidence`

**实现特点：**

- 使用 `Solar::fromYmdHms(...)`
- 通过 lunar-php 得到 lunar / eight-char
- 计算八字、五行、大运、流年
- 缺少出生地时降低置信度

**当前限制：**

- 这是八字 canonical 的可解释实现
- 但仍需确认与目标“测测”软件在节气切换、时辰边界、真太阳时边界上的完全一致性

#### 1.6.3 西洋星盘

**现状：**

- Laravel 侧 `WesternNatalEngine` 当前仍是 `LegacyInputWesternNatalEngine`
- 这是一个兜底/占位实现，不是完整的高精度西洋天文历法引擎
- 真正的 `chart_data` 由 Python 端 Kerykeion 计算

**当前 `LegacyInputWesternNatalEngine` 输出：**

- 太阳星座
- 月亮星座
- 上升星座
- 引擎标记
- 精度标记
- 置信度
- 降级原因

**为什么这很重要：**

- 如果要复现“测测”式古典盘/现代盘设置，当前 Laravel 兜底层是不够的
- 需要确认真正的计算引擎、参数和输出结构

#### 1.6.4 紫微

**现状：**

- 当前 `ZiweiCanonicalService` 已经提供了完整的产品级接口
- 但算法本质上是种子驱动的确定性生成器

**输出重点：**

- 命宫、身宫
- 十二宫宫位
- 主星、辅星、辅助星
- 主要主题解释

**不足：**

- 不是传统意义上完整的紫微斗数排盘引擎
- 若要复现专业软件，需要提供更完整的星系、四化、星曜落宫、庙旺陷、流派参数等规则

#### 1.6.5 Python Kerykeion 西洋星盘计算

**文件：**

- `services/api/app/services/astro.py`

**当前实现：**

- `AstrologicalSubjectFactory.from_birth_data(...)`
- `ChartDataFactory.create_natal_chart_data(subject)`
- 采用 `online=False`
- 使用显式经纬度与时区

**当前输出：**

- `chart_data`
- `planets_data`
- `houses_data`
- `aspects_data`
- `generated_at`

**当前理念：**

- 结构化数据先行
- SVG 绘制分离
- 将最终渲染权交给 APP

#### 1.6.6 Flutter 本地绘图

**文件：**

- `apps/flutter_elitesync_module/lib/features/profile/presentation/widgets/natal_chart_svg_builder.dart`

**当前绘制项：**

- 背景
- 星座环
- 宫位环
- 相位线
- 行星点
- 行星文字
- 盘心标题/时间/地点

**当前可控开关：**

- 下方摘要显示
- 盘面元素的细粒度开关
- 预设档位（完整版 / 平衡版 / 极简版）

---

### 1.7 当前有关星盘的本地偏好

**文件：**

- `apps/flutter_elitesync_module/lib/features/profile/presentation/providers/astro_chart_settings_provider.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_chart_settings_page.dart`

**本地持久化 key：**

- `astro_chart_preferences_v1`

**当前偏好类型：**

- 下方摘要显示
- 紧凑模式
- 盘面元素细分开关
- 盘面预设档位

**重要原则：**

- 这些偏好只影响 Flutter 本地渲染
- 不得回写后端 canonical 真值

---

## 2. `排盘要求_yang_20260409.docx` 里的星盘拆分算法需求

### 2.1 文档主题概述

这份文档明确表达的不是单纯“显示更好看”，而是三类需求叠加：

1. **排盘参数要更多**
2. **星盘图本体要更可读**
3. **每个模块要可以单独解读**

也就是说，它既要求算法能力，也要求图层能力，还要求解释层能力。

---

### 2.2 V7 版本需求：显示细节与输入体验

文档中的 V7 要求可以拆成三部分。

#### 2.2.1 星座文字需要更小、更克制

原文要点：

- 星座字体大了
- 要再小一点
- 比如“金牛座”的“牛”字小一些

**算法/渲染含义：**

- 不是改数据，而是改文本布局策略
- 需要更细的字号、字重、字间距、换行或缩略规则
- 需要针对长中文名称做溢出控制

#### 2.2.2 出生日期输入要更方便

原文要点：

- 出生日期输入最好能像日历一样点选

**算法/产品含义：**

- 这是输入层需求，不是星盘计算层需求
- 但它会影响日期数据质量和生日边界错误率

#### 2.2.3 盘面文字不要重合

原文要点：

- 星盘上的字体不要重合
- 例子里提到“水日”这种容易贴在一起的情况

**算法/渲染含义：**

- 需要一套标签避让策略
- 需要对同一象限、同一密度的行星/虚点做角度偏移、半径错层、优先级分层
- 需要决定“重叠时谁优先显示、谁缩短、谁隐藏、谁改写到图例”

---

### 2.3 V6 版本需求：分窗解释、相位简化、宫位延申、拥挤优化

#### 2.3.1 参数 / 解读 / 星体 / 相位 / 主星 / 大限 / 流年都要可点开单独解释

原文要点：

- 用户点击按钮后要弹出单独窗口解释
- 让用户更清楚

**算法/产品含义：**

- 这不是“一个列表页”的问题
- 需要每个模块都能从同一个星盘数据源独立生成解释内容
- 解释窗要支持：
  - 参数解释
  - 星体解释
  - 相位解释
  - 主星解释
  - 大限解释
  - 流年解释

#### 2.3.2 相位线太多，需要简化

原文要点：

- 只留下主要、必要的相位

**算法含义：**

- 需要对相位列表做筛选
- 需要定义“主要相位”的优先级
- 需要定义 orb 阈值
- 需要定义不同 chart mode 下的显示集合

#### 2.3.3 中间空，盘面乱，要延申宫位线

原文要点：

- 宫位线从外圈延申到中心
- 形成一个圆心向周围区分出 12 宫的结构

**算法/绘图含义：**

- 需要改变当前 SVG 结构
- 不只是画更多线，而是重构盘面分区规则
- 需要明确中心空洞、内外圈、宫位分割线、标签位置

#### 2.3.4 群星落宫拥挤，主星名字要分开

原文要点：

- 群星聚集时要把主星名字分开
- 让阅读成本更低

**算法含义：**

- 需要标签碰撞避让
- 需要按星体权重决定标签层级
- 需要考虑“同宫多星”的显示优先级、缩写策略和图例补充

---

### 2.4 V5 版本需求：可选择的排盘参数全面扩展

文档里的 V5 是最关键的一段，它要求的其实是“多模型排盘”。

#### 2.4.1 古典盘和现代盘

原文要点：

- 用户可选择古典盘和现代盘
- 还包括合盘、男女对比盘、行运、三限、次限、月返、日返、法达、小限盘等

**算法含义：**

- 这不是单一 natal chart
- 需要支持多 chart type dispatch：
  - natal
  - synastry
  - composite
  - transit
  - progression
  - return chart
  - firdaria
  - minor directions / minor returns

#### 2.4.2 黄道制选择

原文要点：

- 回归黄道（西占）
- 恒星黄道（印占）

**算法含义：**

- 需要明确 zodiac type
- 必须能区分 Tropical / Sidereal
- 如果用 Sidereal，还要明确 ayanamsa 体系

#### 2.4.3 宫位制选择

原文要点：

- Placidus
- Koch
- Equal
- Campanus
- Meridian
- Regiomontanus
- Porphyry
- Morinus
- Topecentric
- Alcabitius
- Equal(MC)
- Neo-Porphyry
- Whole
- Vedic

**算法含义：**

- 这是完整的 house system 选择矩阵
- 需要引擎支持不同宫位制的分宫算法
- 需要统一 house cusp 输出格式

#### 2.4.4 相位容许度设置

原文要点：

- 相位容许度可以调

**算法含义：**

- 需要可配置 orb
- 需要按相位类型、星体类型、chart type 设定不同 orb 表

#### 2.4.5 虚点设置

原文要点：

- 虚点要可配置

**算法含义：**

- 需要定义哪些虚点是必须计算的
- 需要确定 vertex / part of fortune / lunar nodes / lilith / east point 等点位是否启用

#### 2.4.6 十二地支映射到十二宫位

原文要点：

- 把中国十二地支配到十二星座的宫位里面

**算法含义：**

- 这不是单纯 UI 文案
- 需要定义“地支 - 星座 - 宫位”的映射规则
- 需要明确是：
  - 视觉映射
  - 解释映射
  - 还是参与实际计算

#### 2.4.7 参数解读窗口

原文要点：

- 参数解读窗口要包括：
  - 星座度数
  - 宫位
  - 顺逆
  - 星体列表
  - 小行星信息
  - 相位表
  - 宫主星
  - 飞入何宫

**算法含义：**

- 需要输出完整的“可解释字段集”
- 需要定义每个字段的来源、精度、单位、显示格式

---

### 2.5 文档第 IV 段：解读逻辑要求

文档里明确要求的解释逻辑有四类：

1. **主星落入第几宫代表什么**
2. **第几宫主飞入几宫代表什么**
3. **大限解读**
4. **流年 / 流星划过命宫的解释**

**算法含义：**

- 这是解释引擎，不只是排盘引擎
- 需要星盘结构 + 规则库 + 文案模板 + 优先级
- 需要支持“当前大运/流年/流月/流日”的时间轴解释

---

## 3. 要完整复现“测测”类星盘，还缺哪些信息

这一部分是关键。  
当前我们已经能做“看起来像星盘”的东西，但要复现一款成熟软件的星盘系统，还需要补足下面这些信息。

---

### 3.1 需要明确的算法决策

#### 3.1.1 西洋盘的最终权威引擎

需要确认：

- 最终星盘真值由谁计算
- 是 Kerykeion
- 还是 Swiss Ephemeris
- 还是别的 ephemeris 引擎
- 是否要同时保留多个引擎对照

当前问题：

- Laravel 侧没有一个完整、统一、可切换的高精度西洋引擎
- 当前西洋 canonical 仍然是分裂的：
  - PHP 兜底层是 `LegacyInputWesternNatalEngine`
  - Python 侧是 Kerykeion `chart_data`

#### 3.1.2 黄道制与宫位制的默认值

需要确认：

- 默认是 Tropical 还是 Sidereal
- Sidereal 用哪个 ayanamsa
- 默认 house system 是 Whole、Placidus 还是别的
- 不同 chart type 是否允许不同默认值

#### 3.1.3 相位集合和 orb 表

需要确认：

- 保留哪些相位
- 每个相位的 orb 阈值
- 太阳/月亮/行星/虚点的 orb 是否不同
- 主要相位、次要相位、弱相位如何分层显示

#### 3.1.4 虚点清单

需要确认：

- 哪些点算“虚点”
- 哪些点默认显示
- 哪些点只在专家模式显示
- 哪些点要参与解释，不参与主盘绘图

#### 3.1.5 多盘型输出规范

需要确认：

- natal / transit / synastry / composite / return / progression / firdaria 的统一数据结构
- 不同 chart type 的共享字段和私有字段
- 是否要允许同一个界面切换不同 chart type

---

### 3.2 需要明确的数据标准

要完整复现目标软件，还需要一套统一的星盘数据字典。

#### 3.2.1 点位标准

至少需要明确：

- 每个点的英文 key
- 中文名称
- 是否属于星体、虚点、角点、交点、特殊点
- 是否可绘制
- 是否可解释
- 是否可参与相位
- 是否可参与宫位归属

#### 3.2.2 角度标准

需要明确：

- `abs_pos`
- `position`
- `sign`
- `sign_num`
- `house`
- `retrograde`
- `speed`
- `declination`
- `latitude`
- `distance`

#### 3.2.3 宫位标准

需要明确：

- cusp 度数
- 宫头星座
- 宫主星
- 飞入宫位
- 同宫判定规则

#### 3.2.4 相位标准

需要明确：

- 相位名
- 相位角度
- orb
- 是否应用到绘图
- 是否应用到解释
- 是否应用到评分

#### 3.2.5 解释字段标准

需要明确：

- 每个解释窗需要展示哪些字段
- 字段的显示顺序
- 是否支持折叠展开
- 是否需要摘要 + 详细层两级内容

---

### 3.3 需要明确的渲染标准

#### 3.3.1 盘面结构

需要明确：

- 外圈、星座环、宫位环、中心空洞的半径比例
- 星体点位放在哪一圈
- 标签放在哪个半径
- 相位线放在哪一层
- 何时显示中文、何时显示英文

#### 3.3.2 标签避让规则

需要明确：

- 同象限标签如何错开
- 同宫星群如何分层
- 文字过长时如何缩写
- 太密时哪些标签隐藏，哪些进入图例或表格

#### 3.3.3 字体与视觉规则

需要明确：

- 字号
- 字重
- 行距
- 中英文混排规则
- 星座名称缩写规则
- 星体 glyph 使用规则

#### 3.3.4 预设档位定义

需要明确：

- “完整版 / 平衡版 / 极简版”分别对应哪些元素
- 是否允许用户自定义预设
- 是否保留专家模式

---

### 3.4 需要明确的解释引擎规则

“测测”式星盘不只是图，而是图 + 解释。

需要明确：

- 每个星体、宫位、相位的解释文本模板
- 主星落宫的解释逻辑
- 宫主飞宫的解释逻辑
- 大限 / 流年 / 流月 / 流日的解释逻辑
- 西洋盘和东方盘之间是否共享解释引擎
- 用户可见解释和后台算法解释是否分层

---

### 3.5 需要明确的历史数据与金样本

要复现一个成熟排盘软件，最缺的是“金样本”。

需要至少准备：

- 固定生日样本
- 固定出生地样本
- 固定时区样本
- 固定夏令时样本
- 固定极端边界样本
- 不同 house system 的同日对照样本
- Tropical vs Sidereal 对照样本
- 不同 orb 设置的对照样本

这些样本必须带有：

- 目标软件截图
- 输入参数
- 期望输出
- 实际输出
- 差异说明

没有这些样本，算法就很难对齐。

---

### 3.6 需要明确的产品定义

当前最需要同事确认的问题不是“能不能画”，而是：

1. **哪些排盘设置是必须的，哪些只是高级模式**
2. **哪些设置会影响计算，哪些只影响展示**
3. **哪些点必须参与相位计算，哪些只是可见项**
4. **哪些解释必须实时生成，哪些可以预计算**
5. **哪些信息应该在主盘显示，哪些应该进入参数窗**

---

## 4. 当前实现与目标复现之间的差距

### 4.1 已经接近的部分

- 盘面 SVG 本地绘制
- 盘面元素的细粒度开关
- 出生地搜索
- 真太阳时修正
- 八字大运流年
- 结构化 chart data
- 盘心信息、行星点、相位、宫位等基本元素

### 4.2 还不够的部分

- 完整古典/现代盘模式切换
- 完整黄道制切换
- 完整 house system 切换
- 精确的 orb / point / aspect 参数矩阵
- 专业级标签避让与排版
- 完整解释窗系统
- 专业紫微引擎
- 统一的多 chart type 数据契约
- 与目标软件一致的金样本

### 4.3 当前实现里最明显的分裂点

1. Laravel 侧西洋 canonical 仍是兜底实现
2. Python 侧 Kerykeion 负责星盘 `chart_data`
3. Flutter 侧负责最终图像
4. 八字 / 紫微 / 西洋盘各自的参数体系还没有统一成同一套产品级设置中心

---

## 5. 建议同事优先反馈的问题清单

如果要把这套星盘做成类似“测测”的完整体验，建议同事优先确认以下问题：

### 5.1 算法优先级

- 西洋盘最终真值以哪套引擎为准
- Tropical / Sidereal 默认值是什么
- 默认 house system 是什么
- 是否必须支持所有 V5 中列出的 house system

### 5.2 点位优先级

- 需要显示哪些星体
- 需要显示哪些虚点
- 哪些点默认隐藏但必须可展开

### 5.3 相位优先级

- 哪些相位属于主显示
- orb 如何设定
- 同一屏幕中最多显示多少条相位线

### 5.4 解释优先级

- 参数窗必须包含哪些字段
- 主星/宫位/大限/流年解释模板是否有既定文案
- 是否有标准答案或标准截图

### 5.5 视觉优先级

- 中文名称是否必须保留全称
- 星座字是否要缩小到什么程度
- 标签冲突时的隐藏策略
- 中心盘心是否必须留空

---

## 6. 本轮不再继续改什么

按照冻结要求，本文档提交后不再做以下事情：

- 不再擅自扩展星盘计算引擎
- 不再擅自切换后端 canonical 真值
- 不再把当前 `legacy_input` 伪装成专业西洋算法
- 不再继续改造盘面设置而不先确认同事反馈
- 不再把“看起来像”当成“已经算法对齐”

---

## 7. 参考文件与源码入口

### 7.1 当前实现相关源码

- `services/api/app/services/astro.py`
- `services/api/app/routers/astro.py`
- `services/api/app/schemas/api.py`
- `services/api/app/models/entities.py`
- `services/backend-laravel/app/Http/Controllers/Api/V1/AstroProfileController.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/ProfileController.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/GeoController.php`
- `services/backend-laravel/app/Services/BirthLocationSolarTimeService.php`
- `services/backend-laravel/app/Services/LunarPhpBaziEngine.php`
- `services/backend-laravel/app/Services/LegacyInputWesternNatalEngine.php`
- `services/backend-laravel/app/Services/ZiweiCanonicalService.php`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/widgets/natal_chart_svg_builder.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/widgets/natal_chart_svg_card.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_natal_chart_page.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/providers/astro_chart_settings_provider.dart`

### 7.2 当前配置相关文件

- `services/backend-laravel/config/python_astro.php`
- `services/backend-laravel/config/astro_canonical.php`
- `services/backend-laravel/config/western_natal.php`
- `services/backend-laravel/config/astro_rollout.php`
- `services/backend-laravel/config/astrology_dependency_gate.php`

### 7.3 相关依赖文件

- `services/api/requirements.txt`
- `services/backend-laravel/composer.json`
- `apps/flutter_elitesync_module/pubspec.yaml`

### 7.4 同事建议源文

- `docs/同事建议/排盘要求_yang_20260409.docx`

---

## 8. 参考资料

- Kerykeion GitHub: https://github.com/g-battaglia/kerykeion
- Flutter SVG package: https://pub.dev/packages/flutter_svg
- 6tail/lunar-php GitHub: https://github.com/6tail/lunar-php
- 6tail/lunar-php Packagist: https://packagist.org/packages/6tail/lunar-php

