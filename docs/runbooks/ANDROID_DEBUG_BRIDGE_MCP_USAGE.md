# Android Debug Bridge MCP Usage

## Purpose

Use `Android-Debug-Bridge-MCP` for Android emulator and device UI automation during competitor analysis.

This is the preferred first MCP for Windows-based Soul analysis because it is ADB-native and matches the existing emulator/device workflow.

## Installed Server

- Package: `android-debug-bridge-mcp`
- NPM global CLI: `android-debug-bridge-mcp`
- Alternate binary: `adb-mcp`

## Registered MCP Server

The repo-local plugin is registered under:

- `plugins/android-debug-bridge-mcp/.mcp.json`

Server command:

```json
{
  "mcpServers": {
    "android-debug-bridge": {
      "command": "npx",
      "args": ["android-debug-bridge-mcp"]
    }
  }
}
```

## Verified Environment

- `adb` is installed and callable
- Android emulator is online
- ADB can see both the physical phone and the emulator

## Available Tool Set

The package provides these automation tools:

- `create_test_folder`
- `list_apps`
- `open_app`
- `capture_screenshot`
- `capture_ui_dump`
- `input_keyevent`
- `input_tap`
- `input_text`
- `input_scroll`

Device enumeration is handled by the underlying `adb devices` command, which is the prerequisite check for this workflow.

## Recommended Soul Reverse-Engineering Workflow

1. Create a fresh test folder for each analysis session.
2. Use `list_apps` to confirm Soul package naming / entry points.
3. Use `open_app` to launch Soul.
4. Capture a screenshot and UI dump on every major screen.
5. Record:
   - bottom navigation
   - home feed
   - discovery / matching
   - messages
   - chat
   - notifications
   - profile / me / settings
   - version / about / help
6. Use `input_tap`, `input_scroll`, and `input_text` only to explore visible surfaces.
7. Use `input_keyevent` for `BACK`, `HOME`, `ENTER`, or `DELETE`.
8. Export page structure regularly so page transitions can be mapped back to features.

## High-Risk Operations to Avoid

Do not use this automation setup for:

- account takeover or credential abuse
- OTP interception
- bypassing privacy, moderation, or paywall controls
- mass messaging / spam
- destructive profile edits
- financial, legal, or identity-sensitive actions

Keep analysis read-only or low-risk whenever possible.

## Fallback Rule

If this MCP becomes unstable on Windows, evaluate `mobile-next/mobile-mcp` only after documenting the blocker.
