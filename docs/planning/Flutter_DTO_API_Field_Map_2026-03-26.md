# Flutter DTO/API Field Mapping (2026-03-26)

## 1) Home Banner
### Endpoint
`GET /api/v1/home/banner`

### API -> DTO -> Entity
- `data.title` -> `HomeBannerDto.title` -> `HomeBannerEntity.title`
- `data.subtitle` -> `HomeBannerDto.subtitle` -> `HomeBannerEntity.subtitle`
- `data.cta` -> `HomeBannerDto.cta` -> `HomeBannerEntity.cta`

## 2) Home Shortcuts
### Endpoint
`GET /api/v1/home/shortcuts`

### API item schema
```json
{
  "key": "questionnaire",
  "title": "继续问卷",
  "action": "route",
  "target": "/questionnaire"
}
```

### API -> DTO -> Entity
- `key` -> `ShortcutEntryDto.key` -> `HomeShortcutEntity.key`
- `title` -> `ShortcutEntryDto.title` -> `HomeShortcutEntity.title`
- `action` -> `ShortcutEntryDto.action` -> `HomeShortcutEntity.action`
- `target` -> `ShortcutEntryDto.target` -> `HomeShortcutEntity.target`

## 3) Home/Discover Feed (List)
### Endpoints
- `GET /api/v1/home/feed`
- `GET /api/v1/discover/feed` (preferred)
- fallback: `GET /api/v1/home/feed?scene=discover`

### Query consumed by frontend
- `tab`
- `cursor`
- `limit`
- `scene=discover` (discover fallback)

### API item -> DTO -> Entity
- `id` -> `HomeFeedDto.id` -> `HomeFeedEntity.id`
- `title` -> `HomeFeedDto.title` -> `HomeFeedEntity.title`
- `summary` -> `HomeFeedDto.summary` -> `HomeFeedEntity.summary`
- `author` -> `HomeFeedDto.author` -> `HomeFeedEntity.author`
- `likes` -> `HomeFeedDto.likes` -> `HomeFeedEntity.likes`
- `body` (optional) -> `HomeFeedDto.body` -> `HomeFeedEntity.body`
- `media` (optional) -> `HomeFeedDto.media` -> `HomeFeedEntity.media`
- `tags` (optional) -> `HomeFeedDto.tags` -> `HomeFeedEntity.tags`

### Meta (pagination)
- `meta.next_cursor` (or `meta.next`) -> page next cursor
- `meta.has_more` -> page hasMore

## 4) Content Detail
### Endpoint
`GET /api/v1/content/{id}`

### API -> DTO -> Entity (same feed mapping)
- frontend reuses `HomeFeedDto/HomeFeedEntity` as detail model.
- detail page rendering priority:
  1. `body`
  2. fallback `summary`
- media rendering:
  - image-like url suffix -> `Image.network`
  - otherwise link-row placeholder

## 5) Current Fallback Policy
- If endpoint unavailable/empty:
  - Home/Discover list: fallback to `HomeMock` list
  - Content detail: fallback to seed item or placeholder entity

## 6) Backend Notes
To remove all frontend fallbacks in later phase, backend should guarantee:
1. stable `data` list/object envelope
2. stable `meta.next_cursor/has_more`
3. shortcut action config delivered from server
4. content detail returns `body/media/tags` consistently
