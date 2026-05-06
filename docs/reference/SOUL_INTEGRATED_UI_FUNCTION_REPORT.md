# Soul UI And Function Integrated Reference Report

Date: 2026-05-02

Source observation date: 2026-05-01

Device: Android emulator `emulator-5554`

Observed package: `cn.soulapp.android`

Purpose: This file consolidates the Soul UI and feature teardown into one self-contained report for GPT project-source upload. It includes module-level observations, page structures, feature mappings, blocker boundaries, and EliteSync 5.x product references. Screenshot and XML paths are kept only as evidence appendix; the main findings are written directly in this file so it can be used without uploading every original report.

## 1. Executive Summary

Soul should not be understood as a simple feed or chat product. The observed product structure is a multi-entry social operating system built around five surfaces:

- Home / 广场 Feed: a content and interaction hub with category tabs, card CTAs, and lightweight media prompt overlays.
- Discover / 广场 extended layer: a composite entry layer combining recommendation feed, city content, search, sharing, and moderation actions.
- Chat: a relationship-progression surface combining chat list, recall queue, icebreaker suggestions, profile cards, safety notices, and message input tools.
- Me / 自己: a personal operating hub combining profile display, tags, content management, AI assistant, attraction score, and function center.
- Settings: in the observed sample, a lightweight home-background and personal-space appearance sheet rather than a traditional deep settings center.

For EliteSync, the strongest references are:

- Discover should remain a composite entrance layer, not only a feed.
- Chat should combine first-message guidance, returnflow queues, profile context, AI icebreakers, and voice rhythm.
- Me should become a personal operating hub, not only a profile page.
- Appearance settings should stay separated from account/security settings.
- Commercialization and permission-heavy flows should remain clearly separated from basic social and profile functions.

## 2. Scope And Safety Boundaries

The teardown was intentionally low risk.

Explored:

- Home feed and light overlays.
- Discover recommendation feed, city tab, search page, share/moderation sheet.
- Chat list, recall/icebreaker queue, one shallow conversation page, system notice branch.
- Me profile page, AI helper page, personal tag and function-center areas.
- Settings entry and home-background bottom sheet.

Skipped or stopped:

- Payment and membership purchase confirmation.
- Account security deep pages.
- Delete-account flows.
- Active sending of real messages to strangers.
- Camera/media permission grant.
- Deep settings and commercialized privilege pages.

Blockers:

- Chat system-notice branch reached an interaction-game setup prompt and was not continued.
- Settings background configuration triggered camera/media permission and was not continued.

## 3. Home / 广场 Feed

### 3.1 Page Positioning

Soul Home appears as a `广场` feed and main social discovery surface. It is organized as a feed with category tabs, top tools, card actions, and bottom navigation.

Observed structure:

- Top category tabs: `关注`, `推荐`, `同城`.
- Top tool area: `广场相机`, `搜索`, `音乐故事`.
- Feed cards: avatar, nickname, publish time, follow, share/report, text, image, private chat, like, comment.
- Bottom navigation: `星球`, `广场`, `发布瞬间`, `聊天`, `自己`.
- Lightweight overlay: random radio recommendation with playback actions.

### 3.2 Key UI And Function Findings

The Home surface keeps the primary content feed readable while placing low-pressure interaction actions directly on each card. `私聊` is visible as a lightweight card-level CTA rather than hidden behind a profile page. This makes the feed a relationship entry point, not only a content consumption surface.

The top category tabs provide high-level content segmentation:

- `关注` for followed content.
- `推荐` for default discovery.
- `同城` for local discovery.

The top tool area gives quick access to camera, search, and music/story features. These are visually important but do not fully replace the feed.

The bottom navigation uses a five-part model with a central publish action. This makes publishing prominent while retaining stable access to social, content, chat, and profile surfaces.

The random radio overlay demonstrates a lightweight temporary recommendation pattern:

- Title: `来跟我一起听随机电台吧`.
- Main card: `大城小事`.
- Actions: play/pause, next, random, like, close, `好的`.
- Return path: close button returns to feed; `BACK` was not a reliable close path in the observed sample.

### 3.3 Page Record

| Page | Feature | Entry | Core Action | Return Path | EliteSync Reference |
| --- | --- | --- | --- | --- | --- |
| Home feed | Category tabs | App default / bottom `广场` | Switch `关注 / 推荐 / 同城` | Remain on Home | Reference for Discover/Home tab segmentation |
| Home feed | Top tools | Top camera/search/music area | Open camera, search, music story | Back to feed | Reference for compact top utility layout |
| Feed card | Card interactions | Feed card CTAs | Private chat, like, comment, follow, share/report | Back to current card | Reference for low-pressure content-to-chat conversion |
| Main navigation | Bottom tabs | Bottom bar | Switch `星球 / 广场 / 发布 / 聊天 / 自己` | Bottom tab return | Reference for five-part navigation with central publish |
| Random radio overlay | Temporary media prompt | Light tap in top/feed area | Play, next, random, like, close | Close to feed | Reference for lightweight recommendation overlays |

### 3.4 EliteSync Implications

EliteSync should treat Discover/Home as a layered entry surface:

- Keep content cards readable.
- Preserve low-pressure `私聊` or chat conversion affordances.
- Separate top quick tools from core feed navigation.
- Use temporary overlays sparingly and provide a clear close path.
- Do not turn feed cards into heavy commercial or noisy interaction panels.

## 4. Discover / 广场 Composite Layer

### 4.1 Page Positioning

The Discover module is not a single feed. It is a composite discovery layer combining recommendation, city content, search, share sheet, moderation, and content interaction.

Observed primary entrances:

- Top tabs: `关注`, `推荐`, `同城`.
- Top tools: `广场相机`, `搜索`, `音乐故事`.
- Card actions: `私聊`, `喜欢`, `评论`, `关注`, `分享或举报`.
- Right-side quick entry: `小信封`.
- Bottom navigation: `星球`, `广场`, `发布瞬间`, `聊天`, `自己`.

### 4.2 Recommendation Feed

The recommendation feed includes:

- User avatar and nickname.
- Publish time.
- Text content.
- Image content.
- Private chat button.
- Follow button.
- Like and comment.
- Share/report menu.

The structure proves that Soul's discovery feed is not passive. It directly supports low-risk social actions.

### 4.3 Share And Moderation Sheet

Opening `分享或举报` reveals a bottom sheet titled `分享至好友`.

Observed external share targets:

- `微信`
- `朋友圈`
- `QQ`
- `QQ空间`
- `微博`
- `更多`

Observed in-product actions:

- `私聊`
- `关注`
- `不喜欢`
- `举报`
- `复制链接`

This sheet separates social sharing, relationship actions, negative feedback, reporting, and link copying in one surface.

### 4.4 City Tab

The `同城` tab includes:

- Selected `同城` state.
- Prompt: `为您推荐了8个瞬间`.
- Location unlock card:
  - `开启定位，解锁同城瞬间`
  - `发现同城的小美好`
  - `开启`
- Feed cards continue to retain `私聊`, `关注`, `喜欢`, `评论`, `分享或举报`.

The important UX pattern is permission-gated local discovery: the content surface still works, while location unlock is presented as an optional enhancement.

### 4.5 Search Page

The search page includes:

- Search box: `搜索`.
- Search action button.
- Prompt card: `测测今日的恋爱幸运数字`.
- Secondary action: `问问其他`.
- Hot section: `热SOUL`.
- Example hot terms:
  - `五一劳动节快乐`
  - `五月的天 刚诞生的夏天`
  - `其他水果统统让道！荔枝季来了`
  - `强扭的瓜不甜但是解渴`
  - `Soul星神仙画手申请出战！`
  - `蓝花楹最佳观赏期`
  - `带上256G的胃见面吧`

Search is therefore both utility and content prompt surface.

### 4.6 Page Record

| Page | Feature | Entry | Core Action | Return Path | EliteSync Reference |
| --- | --- | --- | --- | --- | --- |
| Recommend feed | Feed segmentation | Bottom `广场`, top `推荐` | Browse recommended content | Stay in feed | Reference for Discover default content state |
| Recommend feed | Card CTAs | Feed card | Private chat, like, comment, follow | Back to card | Reference for content-to-chat low-pressure conversion |
| Share sheet | Share / moderation | `分享或举报` | Share externally, dislike, report, copy link | Close or BACK to feed | Reference for moderation and sharing action grouping |
| City tab | Local feed | Top `同城` | Browse local content, see location prompt | Switch tab or back | Reference for city/local feature and permission prompt |
| Search | Hot search and prompt | Top `搜索` | Search, view hot terms, enter prompt card | Back to feed | Reference for EliteSync search/hot topics/prompt cards |

### 4.7 EliteSync Implications

For EliteSync 5.x:

- Discover should combine search, city, content feed, and light governance.
- The city layer should support optional permission unlock instead of blocking the page.
- Share and report should be grouped but visually separated from positive interactions.
- Search can include dating or relationship prompts, but should avoid becoming noisy entertainment.
- Card-level chat conversion should remain low-pressure and reversible.

## 5. Chat Module

### 5.1 Page Positioning

Soul Chat is a relationship-progression system, not just an IM list. It combines:

- Contacts / chat tabs.
- Search.
- Conversation list.
- Activity/commercial entries.
- System notifications.
- `奇遇铃-稍后再聊` recall queue.
- Conversation profile/context card.
- Icebreaker suggestions.
- Input tools.

### 5.2 Chat List

Observed top structure:

- Tabs: `通讯录`, `聊天`.
- Top `+` button.
- Search placeholder: `搜索备注、昵称或者聊天记录`.
- Right-side sorting/filtering button.

Observed list items:

- `宇宙哔哔机特权`
- `有趣的灵魂正在等你`
- `奇遇铃-稍后再聊`
- `系统通知`
- `Soul空间站`

Conversation card structure:

- Left avatar or icon.
- Main title.
- Subtitle / summary.
- Right-side time.
- Unread red dot.

### 5.3 `奇遇铃-稍后再聊`

This is the highest-value observed chat reference for EliteSync.

Observed content:

- Title: `奇遇铃-稍后再聊`.
- Explanation: `仅保留最近3天你直接关闭的用户哦`.
- User examples:
  - `jingjing`
  - `微塔女孩`
- Relationship/recommendation tags:
  - `处女座的他，今天和你最搭`
  - `你们距离很近哦`
- AI inspiration reply area:
  - `你好 / 可以认识一下么`
  - `哈喽哈喽 / 小姐姐好呀`
  - `经典问候，安全不出错`
- Input bar:
  - Voice button.
  - Text input.
  - AI reply button.
  - Emoji button.
  - More button.

The key product pattern is a recall queue for users the viewer previously closed or deferred. It transforms missed or delayed interactions into safe return opportunities.

### 5.4 Conversation Page

Observed `jingjing` conversation page:

Top bar:

- Back.
- Conversation title `jingjing`.
- `关注`.
- `聊天设置`.

Relationship progression:

- `关注后可邀请通话`.
- `展开`.

Profile/context card:

- `匹配度 94%`.
- `Ta忧郁骑士星球`.
- `查看主页`.
- `Ta的认证：ISFJ`.
- `Ta的引力签：无聊很闷的一个人`.
- `你们的共同点：河南`.

Icebreaker/AI reply area:

- `灵感回复可提升回复率哦`.
- `你好 / 可以认识一下么`.
- `哈喽哈喽 / 小姐姐好呀`.

Input area:

- Voice button.
- Text input placeholder: `文明聊天，友善交友~`.
- AI button.
- Emoji button.
- More button.

Observed input hierarchy includes voice, text, AI reply, emoji, and more as separate controls.

### 5.5 System Notice And Interaction Blocker

System notification branch:

- `系统通知`.
- `Soul防骗贴士`.
- `展开`.

Further navigation reached an interaction-game setup prompt:

- Title: `随机互动玩法上线啦`.
- Copy: `只需朋友戳一下就能随机解锁更多互动游戏，快来设置吧`.
- Buttons: `稍等一下`, `前往设置`.

This was treated as a blocker because it shifts from chat notification into settings/game configuration.

Commercial/activity risk observed:

- `宇宙哔哔机特权`.
- Copy: `扩散消息给5位souler`.

This was not explored because it is a privilege/commercial/activity path.

### 5.6 Page Record

| Page | Feature | Entry | Core Action | Return Path | EliteSync Reference |
| --- | --- | --- | --- | --- | --- |
| Chat list | Top tabs and search | Bottom `聊天` | Switch contacts/chat, search chats | Back or bottom nav | Reference for message list segmentation |
| Chat list | Conversation cards | Chat list items | View unread, title, summary, time | Tap to detail, back to list | Reference for EliteSync conversation card hierarchy |
| Qiyu recall list | Later-chat queue | `奇遇铃-稍后再聊` | Browse deferred users | BACK to chat list | Reference for first-chat/rechat/cold-start recovery queue |
| Qiyu recall list | AI inspiration replies | Recall list bottom | Use safe greeting suggestions | Back to list | Reference for low-risk icebreaker templates |
| Conversation | Profile card | Tap `jingjing` | View match score, tags, commonality | Back to recall list | Reference for chat context card |
| Conversation | Relationship progression | `关注`, `关注后可邀请通话` | Follow before voice/call | Back to conversation/list | Reference for relationship-gated voice progression |
| Conversation | Input tools | Bottom input bar | Voice, text, AI, emoji, more | Stay in chat | Reference for chat input composition |
| System notice | Safety card | `系统通知` | View anti-fraud notice | Back to chat list | Reference for system safety notice |
| Interaction prompt | Blocker | System notice deep branch | Setup prompt, not continued | Back | Reference for separating game/settings from chat |

### 5.7 EliteSync Implications

For EliteSync:

- Chat should include relationship context, not just messages.
- `稍后再聊` or deferred-user queue is highly relevant to slow dating.
- Icebreaker suggestions should be low-pressure and safe.
- Voice should be framed as relationship progression, not a raw button.
- Profile summary and commonality inside chat can reduce awkwardness.
- Commercial/activity prompts should not pollute core chat.
- System safety and game/interaction settings should be separated.

## 6. Me / 自己 Personal Center

### 6.1 Page Positioning

Soul Me is a personal operating hub. It combines profile identity, social proof, tags, content management, AI assistant, attractiveness scoring, and feature center.

Observed structure:

- Top profile area: avatar, nickname, follow count, follower count, visitors.
- Top functions: switch user, QR code, settings.
- Profile markers: display identity, charm tag, active days, personality label.
- Content tabs: `瞬间`, `收藏`, `赞过`, `全部`.
- Quality/assistant cards: `查看AI助理`, `主页吸引力42.3分`.
- Personal content card.
- Function center: `数字藏馆`, `Soul币中心`, `超级星人`, `个性商城`, `娱乐中心`.
- Bottom navigation: `星球`, `广场`, `发布瞬间`, `聊天`, `自己`.

### 6.2 Default Personal Page

Observed profile/default content:

- Nickname: `华霜魂`.
- Counts: `0 关注`, `0 被关注`, `1 看过我`.
- Profile display markers:
  - `我的展示标识`.
  - `魅力少帅`.
  - `42天`.
- Tags:
  - `ENFJ`.
  - `职场Gap期`.
  - `AI训练师`.
  - `相信爱情`.
  - `母胎单身`.
  - `+` add more tags.
- Content and relation section:
  - `瞬间`.
  - `收藏`.
  - `赞过`.
  - `全部`.
  - `查看AI助理`.
  - `主页吸引力42.3分`.
- Function center:
  - `数字藏馆`.
  - `Soul币中心`.
  - `超级星人`.
  - `个性商城`.
  - `娱乐中心`.

### 6.3 AI Helper Page

Observed AI helper content:

- Greeting: `Hi, 华霜魂我是你的专属小助手`.
- Profile attractiveness score: `42.3分`.
- Comparative feedback: `领先全站42%的用户`.
- Daily task.
- `换个任务`.
- `AI帮发`.
- AI diagnosis.
- Persona suggestion: `阳光少年`.
- Interaction and chat improvement suggestions.

The AI helper works as a homepage optimization and content-generation guidance layer, not just a chatbot.

### 6.4 Function Center And Commercialization

The function center contains both utility and commercialized areas:

- `数字藏馆`.
- `Soul币中心`.
- `超级星人`.
- `个性商城`.
- `娱乐中心`.

For EliteSync, this is useful as a structural reference but should not be copied directly. EliteSync should avoid turning the profile page into a commercial hub before core relationship utility is stable.

### 6.5 Page Record

| Page | Feature | Entry | Core Action | Return Path | EliteSync Reference |
| --- | --- | --- | --- | --- | --- |
| Me default | Profile summary | Bottom `自己` | View avatar, nickname, counts, markers | Stay or back | Reference for profile identity aggregation |
| Me default | Top functions | Right-side icons | Switch user, QR, settings | Back to Me | Reference for personal center quick tools |
| Me default | Tags | Profile tags | View/add identity and emotional tags | Stay on Me | Reference for EliteSync tag expression system |
| Me default | Content/relationship area | `瞬间 / 收藏 / 赞过 / AI助理` | Manage content, open assistant | Back to Me | Reference for content and relationship operating hub |
| Me default | Function center | Icon grid | Enter secondary functions | Back to Me | Reference for secondary entry grid, with caution |
| AI helper | Attraction score | `查看AI助理` | View score and suggestions | BACK to Me | Reference for profile quality score and display advice |
| AI helper | Task and AI posting | `换个任务 / AI帮发` | Get tasks and AI posting help | BACK to Me | Reference for AI draft/content helper |
| AI helper | AI diagnosis | AI diagnosis/persona suggestions | See persona and improvement advice | BACK to Me | Reference for profile/persona feedback |

### 6.6 EliteSync Implications

For EliteSync:

- Me should become a personal operating hub.
- Tags should express identity, relationship intent, and interaction style.
- AI helper should focus on profile clarity, self-introduction, and low-pressure expression.
- A health/quality score can be useful, but it should not shame users or overpromise results.
- Secondary function grids should be restrained and not dominate profile truth or relationship utility.
- Commercialized centers should not be copied directly.

## 7. Settings / Personal Appearance Layer

### 7.1 Page Positioning

In the observed sample, Soul Settings from the Me page does not behave like a traditional full settings center. It opens a bottom sheet titled `主页背景`.

The visible settings surface is mainly personal-home appearance configuration.

Observed content:

- `主页背景`.
- `我的空间装扮`.
- `立即开通`.
- `图片背景`.
- Copy: `固定单张展示背景图`.
- Button: `去设置`.
- `互动背景`.
- Copy: `旋转手机时背景图可切换`.
- Button: `去设置`.

### 7.2 Home Background Sheet

This sheet combines:

- Visual background settings.
- Commercialized dressing prompt.
- Image background.
- Interactive background.

This is more like a personal appearance panel than a general settings center.

### 7.3 Commercial Dressing Entry

Observed commercial copy:

- `我的空间装扮`.
- `立即开通`.

The commercial entry is visually separated from the basic background options. This separation is important: commercial dressing should not be confused with safety/account settings.

### 7.4 Permission Blocker

Clicking `图片背景 / 去设置` triggered a system permission request:

- `Soul想访问你的相机和媒体文件`.
- System copy: `Allow Soul to take pictures and record video?`.

Permission was not granted. Exploration stopped to avoid entering camera/media selection flows.

### 7.5 Page Record

| Page | Feature | Entry | Core Action | Return Path | EliteSync Reference |
| --- | --- | --- | --- | --- | --- |
| Settings sheet | Home background | Me top settings icon | Open bottom sheet | BACK to Me | Reference for lightweight appearance settings sheet |
| Settings sheet | Dressing commercial entry | `我的空间装扮 / 立即开通` | View/open benefits | Not entered | Reference for separating commercial from utility |
| Settings sheet | Image background | `图片背景 / 去设置` | Configure fixed background | Blocked by permission | Reference for appearance setting with permission boundary |
| Settings sheet | Interactive background | `互动背景 / 去设置` | Configure rotation-based background | Not deeply entered | Reference for device-state visual effects |
| Permission dialog | Camera/media permission | Image background setup | Allow/deny permission | BACK to Me | Reference for permission-gated visual settings |

### 7.6 EliteSync Implications

For EliteSync:

- Personal appearance can be a lightweight profile layer.
- Appearance must remain separate from account/security/privacy settings.
- If media permission is needed, show clear context before requesting it.
- Do not make appearance settings a paid dressing center by default.
- If a commercial layer exists later, keep it visually and functionally separate from baseline settings.

## 8. Blocker Summary

### 8.1 Chat Blocker

Trigger chain:

- Chat list -> `系统通知` -> `Soul防骗贴士` -> `展开` -> `随机互动玩法上线啦`.

Observed blocker page:

- Title: `随机互动玩法上线啦`.
- Copy: `只需朋友戳一下就能随机解锁更多互动游戏，快来设置吧`.
- Buttons: `稍等一下`, `前往设置`.

Reason for stopping:

- The branch moved from chat notice into interaction-game setup.
- Continuing would enter settings/configuration or gameplay paths beyond low-risk chat observation.

Safe conclusions:

- Chat list, recall queue, conversation profile card, and input structure were already sufficiently observed.
- Interaction-game setup should be separated from core chat in EliteSync.

### 8.2 Settings Blocker

Trigger chain:

- Me page -> settings icon -> `主页背景` bottom sheet -> `图片背景 / 去设置`.

Observed blocker:

- Camera/media permission request.
- Copy: `Soul想访问你的相机和媒体文件`.
- System copy: `Allow Soul to take pictures and record video?`.

Reason for stopping:

- Granting camera/media permission could open image selection or recording flows.
- This exceeded the low-risk settings teardown scope.

Safe conclusions:

- Home-background sheet structure was fully useful as a reference.
- Permission-gated appearance settings should be explicitly explained and reversible.

## 9. Cross-Module Product Patterns

### 9.1 Composite Entry Layers

Soul rarely presents a single-purpose page. Home, Discover, Chat, and Me all combine multiple jobs:

- Home: content, social action, media overlay, navigation.
- Discover: recommendation, local content, search, share, moderation.
- Chat: list, recall queue, profile context, AI suggestions, safety, input tools.
- Me: identity, tags, content, AI, score, function center.
- Settings: appearance configuration plus commercial dressing prompt.

EliteSync should use composite layers where they improve relationship progression, but avoid clutter.

### 9.2 Low-Pressure Relationship Conversion

Observed low-pressure conversion patterns:

- Feed card `私聊`.
- Discover card interactions and share/moderation sheet.
- Chat `奇遇铃-稍后再聊`.
- Conversation profile card with commonality.
- AI inspiration replies.
- `关注后可邀请通话`.

EliteSync should use similar low-pressure conversion:

- Content/status to private chat.
- Match explanation to chat suggestion.
- Deferred chat queues.
- Relationship summary in chat.
- Voice only after relationship context.

### 9.3 AI As Expression Support

Soul uses AI for:

- Profile attractiveness evaluation.
- Daily tasks.
- AI-assisted posting.
- Persona suggestions.
- Chat inspiration replies.

EliteSync should position AI as:

- Expression helper.
- Draft helper.
- Profile clarity assistant.
- Icebreaker generator.
- Relationship pace advisor.

It should not auto-send, auto-publish, or overwrite profile truth without explicit user action.

### 9.4 Personal Operating Hub

Soul Me shows that profile is not only self-description. It is:

- Identity display.
- Tag expression.
- Content management.
- AI assistance.
- Quality feedback.
- Secondary function access.

EliteSync 5.2 aligns with this direction through:

- `个人经营区`.
- `标签表达体系`.
- `AI 展示建议`.
- `AI 草稿助手`.
- `轻语音表达候选位`.
- `个人空间外观层`.

### 9.5 Appearance Layer Separation

Soul's settings sample supports a key separation:

- Appearance and home background can be lightweight and visual.
- Account/security/privacy should remain separate.
- Commercial dressing should not obscure baseline settings.

EliteSync should preserve this separation.

## 10. Mapping To EliteSync 5.x

### 10.1 Discover

Soul reference:

- `关注 / 推荐 / 同城` tabs.
- Search and hot terms.
- City permission prompt.
- Card-level chat and share/moderation actions.

EliteSync mapping:

- Discover should support composite entry: recommendation, city, search, light governance.
- Content cards should support low-pressure chat conversion.
- Same-city content should be permission-aware but not page-blocking.
- Report/dislike/share should be grouped and reversible.

### 10.2 Chat

Soul reference:

- Chat list with tabs and search.
- `奇遇铃-稍后再聊`.
- AI inspiration replies.
- Conversation profile card.
- `关注后可邀请通话`.
- Voice/text/AI/emoji/more input bar.

EliteSync mapping:

- Keep first-chat/rechat/cold-start recovery queues.
- Keep relationship summary and profile context in chat.
- Use AI suggestions as optional, low-pressure drafts.
- Gate voice prompts behind relationship rhythm and consent.
- Keep safety and settings/gameplay separate.

### 10.3 Me / Profile

Soul reference:

- Profile identity aggregation.
- Tags.
- AI helper.
- Attraction score.
- Content and function center.

EliteSync mapping:

- Continue Me/Profile as personal operating hub.
- Use tags for expression, not absolute judgement.
- Use AI for display advice and drafts.
- Keep truth-chain disclaimers visible.
- Avoid copying coin/shop/commercial center.

### 10.4 Settings / Appearance

Soul reference:

- `主页背景` bottom sheet.
- `图片背景`.
- `互动背景`.
- Permission gate.
- Commercial dressing prompt.

EliteSync mapping:

- Keep appearance as a lightweight profile-expression layer.
- Do not replace real Settings center.
- Do not introduce paid dressing by default.
- If media permissions are needed later, provide explicit pre-permission explanation.

## 11. Risks If Copied Blindly

Do not copy these patterns directly without adaptation:

- Commercial privilege entries in chat list.
- Coin center / shop / paid dressing as early-stage profile functions.
- Interaction-game setup inside chat notification flow.
- AI score that may make users anxious.
- Permission prompts without clear pre-explanation.
- Auto-publishing or auto-sending AI content.

EliteSync's product positioning is slow dating, trust, and relationship pace. Soul's high-density social/entertainment model should be mined for structure, not copied wholesale.

## 12. Recommended EliteSync Design Principles From Soul Reference

- Treat Discover as a composite relationship-entry layer.
- Treat Chat as relationship progression, not only messaging.
- Treat Me as personal operating hub.
- Keep AI optional, draft-like, and user-confirmed.
- Keep voice tied to pace and consent.
- Keep appearance lightweight and separated from settings/security.
- Keep permissions contextual and reversible.
- Keep commercial systems out of the core relationship path unless a future version explicitly plans them.
- Preserve screenshot evidence discipline: filename, screenshot content, and actual page content must match.

## 13. Evidence Appendix

Original reports consolidated into this file:

- `docs/reference/SOUL_HOME_MODULE_REPORT.md`
- `docs/reference/SOUL_DISCOVER_MODULE_REPORT.md`
- `docs/reference/SOUL_CHAT_MODULE_REPORT.md`
- `docs/reference/SOUL_ME_MODULE_REPORT.md`
- `docs/reference/SOUL_SETTINGS_MODULE_REPORT.md`
- `docs/reference/SOUL_CHAT_BLOCKER_REPORT.md`
- `docs/reference/SOUL_SETTINGS_BLOCKER_REPORT.md`

Screenshot and XML evidence directories:

- `docs/reference/soul_home/assets/`
- `docs/reference/soul_discover/assets/`
- `docs/reference/soul_chat/assets/`
- `docs/reference/soul_me/assets/`
- `docs/reference/soul_settings/assets/`

Key Home evidence:

- `SOUL_HOME_001_HOME.png/xml`
- `SOUL_HOME_002_OVERLAY.png/xml`
- `SOUL_HOME_003_RETURN_HOME.png/xml`

Key Discover evidence:

- `SOUL_DISCOVER_001_RECOMMEND_FEED.png/xml`
- `SOUL_DISCOVER_002_SHARE_SHEET.png/xml`
- `SOUL_DISCOVER_003_RETURN_FEED.png/xml`
- `SOUL_DISCOVER_004_CITY_TAB.png/xml`
- `SOUL_DISCOVER_005_SEARCH_PAGE.png/xml`

Key Chat evidence:

- `SOUL_CHAT_001_LIST_DEFAULT.png/xml`
- `SOUL_CHAT_002_QIYU_LIST.png`
- `SOUL_CHAT_003_QIYU_CONVERSATION.png/xml`
- `SOUL_CHAT_004_SYSTEM_NOTICE.png`
- `SOUL_CHAT_005_RANDOM_INTERACTION_BLOCKER.png`
- `SOUL_CHAT_006_RETURN_TO_CHAT_LIST.png`
- `SOUL_CHAT_007_RETURN_TO_QIYU_LIST.png`

Key Me evidence:

- `SOUL_ME_001_DEFAULT.png/xml`
- `SOUL_ME_002_AI_HELPER.png/xml`
- `SOUL_ME_003_PROFILE_PANEL.png`

Key Settings evidence:

- `SOUL_SETTINGS_001_PROFILE_DEFAULT.png`
- `SOUL_SETTINGS_002_HOME_BACKGROUND_SHEET.png/xml`
- `SOUL_SETTINGS_003_PERMISSION_DIALOG.png`
- `SOUL_SETTINGS_004_RETURN_PROFILE.png`

## 14. One-File Upload Note

For GPT project-source upload limits, this file should be uploaded as the primary Soul competitor reference. The original module reports and screenshot directories can remain in the repository as audit evidence, but the main product and UI findings needed by the GPT advisor are contained directly in this document.
