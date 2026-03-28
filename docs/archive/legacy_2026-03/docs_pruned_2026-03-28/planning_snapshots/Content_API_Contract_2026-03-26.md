# Content API Contract (Alpha) - 2026-03-26

## Goal
Provide backend contracts for Flutter `Home / Discover / ContentDetail` so frontend can remove mock fallback progressively.

## 1) Home Banner
- Method: `GET`
- Path: `/api/v1/home/banner`
- Response:
```json
{
  "ok": true,
  "data": {
    "title": "string",
    "subtitle": "string",
    "cta": "string"
  }
}
```

## 2) Home Shortcuts
- Method: `GET`
- Path: `/api/v1/home/shortcuts`
- Response:
```json
{
  "ok": true,
  "data": [
    { "key": "questionnaire|mbti|astro|profile", "title": "string" }
  ]
}
```

## 3) Home Feed
- Method: `GET`
- Path: `/api/v1/home/feed`
- Optional query:
  - `scene=discover` (optional fallback for discover channel)
  - `tab` (recommended; e.g. `recommend`, `nearby`, `topic`, `event`)
  - `cursor` (optional pagination cursor)
  - `limit` (optional)
- Response:
```json
{
  "ok": true,
  "data": [
    {
      "id": "string",
      "title": "string",
      "summary": "string",
      "author": "string",
      "likes": 0
    }
  ],
  "meta": {
    "next_cursor": "string|null",
    "has_more": true
  }
}
```

## 4) Discover Feed (preferred)
- Method: `GET`
- Path: `/api/v1/discover/feed`
- Optional query:
  - `tab=hot|local|event|topic|live`
  - `cursor`
  - `limit`
- Response format same as Home Feed.

## 5) Content Detail
- Method: `GET`
- Path: `/api/v1/content/{id}`
- Response:
```json
{
  "ok": true,
  "data": {
    "id": "string",
    "title": "string",
    "summary": "string",
    "author": "string",
    "likes": 0,
    "body": "string",
    "media": [
      { "type": "image|video", "url": "string" }
    ],
    "tags": ["string"],
    "updated_at": "2026-03-26T12:00:00Z"
  }
}
```

## 6) Error Format (recommended)
```json
{
  "ok": false,
  "code": "CONTENT_NOT_FOUND",
  "message": "human readable message"
}
```

## 7) Frontend Fallback Strategy (already implemented)
- if endpoint unavailable or payload empty:
  - home/discover: fallback to local mock lists
  - content detail: fallback to card seed data or placeholder

## 8) Alpha Implementation Priority
1. `/api/v1/content/{id}`
2. `/api/v1/discover/feed`
3. `/api/v1/home/feed` with pagination meta
4. `/api/v1/home/banner` and `/api/v1/home/shortcuts` dynamicization
