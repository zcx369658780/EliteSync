# Flutter UI Merge Handoff (2026-03-27)

## Current state
- Android host is now pure Flutter entry.
- Compose source/依赖已从主工程下线。
- 主流程 UI 已切到 Flutter 并完成多轮验收。
- Debug 构建与安装流程已提速并脚本化。

## Key scripts
1. Build Flutter AAR (debug only)
```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_flutter_module_aar.ps1 -DebugOnly
```

2. Fast deploy to emulator
```powershell
powershell -ExecutionPolicy Bypass -File scripts/fast_deploy_flutter_android_debug.ps1 -DeviceId emulator-5554
```

3. APK size report
```powershell
powershell -ExecutionPolicy Bypass -File scripts/apk_size_report.ps1 -Top 10
```

## Latest size snapshot
- `app-debug.apk`: **181.76 MB**
- Largest entries:
  - `libflutter.so`: ~140 MB
  - `libBaiduMapSDK_map_v7_6_7.so`: ~12 MB
  - `classes9.dex`: ~9.8 MB

## Merge-ready acceptance
Use checklist:
- `docs/planning/Flutter_UI_Merge_Regression_Checklist_2026-03-27.md`

## Suggested next step
1. Final manual pass on emulator (main flows + settings + update dialog).
2. Create PR.
3. Run one daily Regression batch (respect quota rule).
4. Merge after green checks.
