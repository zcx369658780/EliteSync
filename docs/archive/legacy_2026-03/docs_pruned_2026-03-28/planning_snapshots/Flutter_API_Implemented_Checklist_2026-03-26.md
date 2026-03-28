# Flutter Frontend Implemented API Checklist (2026-03-26)

## A. Auth / Session
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- token attached by interceptor (Bearer)

## B. Home
- `GET /api/v1/home/banner`
- `GET /api/v1/home/shortcuts`
- `GET /api/v1/home/feed`
  - query supported by frontend:
    - `tab` (home tabs)
    - `cursor`
    - `limit`
    - `scene=discover` (discover fallback)

## C. Discover
- preferred: `GET /api/v1/discover/feed`
  - query:
    - `tab=hot|local|event|topic|live`
    - `cursor`
    - `limit`
- fallback: `GET /api/v1/home/feed?scene=discover`

## D. Content Detail
- `GET /api/v1/content/{id}`
- frontend reads (if returned):
  - `id, title, summary, author, likes`
  - `body` (optional)
  - `tags` (optional string[])
  - `media` (optional: string[] or object[] with `url`)

## E. Match
- existing endpoints already wired in match datasource/provider stack:
  - countdown / result / detail / intention
- UI now consumes detailed explanation cards and weighted reason blocks

## F. Chat
- conversation list / message list / send message endpoints already wired
- chat room supports optimistic local append + server send

## G. Profile / Verification / Questionnaire
- profile fetch + update
- verification status + submit
- questionnaire load + draft + submit + result

## H. Frontend Fallback Strategy (Current)
- Home/Discover/Content detail: backend-first, mock fallback on failure/empty
- keeps UI interactive during long-alpha backend evolution

## I. Shortcut Config Protocol (Home)
`/api/v1/home/shortcuts` item supports:
```json
{
  "key": "questionnaire",
  "title": "继续问卷",
  "action": "route",
  "target": "/questionnaire"
}
```
Rules:
- if `action=route` and `target` exists -> `context.push(target)`
- else fallback to built-in `key` mapping

## J. Pending for Next Backend Iteration
1. Discover pagination `meta.next_cursor/has_more` full support.
2. Content detail media rich schema (type/url) stable definition.
3. Home/Discover tab-specific recommendation strategy.
4. Content detail comments/interaction endpoint.
