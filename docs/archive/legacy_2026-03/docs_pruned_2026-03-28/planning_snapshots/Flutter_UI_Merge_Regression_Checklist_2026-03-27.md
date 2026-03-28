# Flutter UI Merge & Regression Checklist (2026-03-27)

## Scope
- Android host switched to pure Flutter entry.
- Compose source and Compose dependencies removed from Android app module.
- Main user journeys run on Flutter module UI.
- Debug build path optimized for faster iteration.

## Completed in this round
1. Architecture
- `MainActivity` now directly extends `FlutterActivity`.
- `AndroidManifest` uses `MainActivity` as Flutter activity launcher.
- Compose plugin/dependencies removed from `apps/android/app/build.gradle.kts`.
- Compose source tree removed from `apps/android/app/src/main/java/com/elitesync/ui/**`.

2. UX and consistency
- Bottom bar overflow fixed for 5-tab layout.
- Removed center “速配” floating action from bottom dock.
- Profile edit: gender/relationship goal converted to selectors; birthday converted to date picker.
- Home/Discover/Messages search “clear” action unified to chip style.
- Match result/countdown/chat error actions unified to design-system button components.
- Splash loading screen aligned to app visual style.

3. Performance and package size
- Debug dependency switched from `flutter_debug` to `flutter_release`.
- Added APK size inspection script: `scripts/apk_size_report.ps1`.
- Removed stale large drawable assets from Android `res` (Compose leftovers).
- APK reduced from ~434MB to ~188MB in current debug flow.
- Added fast deploy helper: `scripts/fast_deploy_flutter_android_debug.ps1`.

4. Build pipeline
- `build_flutter_module_aar.ps1 -DebugOnly` now builds debug-only AAR (`--no-profile --no-release`) to cut iteration time.
- Local verification passed repeatedly:
  - `flutter analyze`
  - `:app:assembleDebug`
  - `adb install -r`

## Manual acceptance set before Merge
1. Navigation shell
- Bottom 5 tabs render without overflow warnings.
- No center “速配” button.

2. Profile edit page
- Gender is dropdown.
- Birthday uses date picker.
- Relationship goal is dropdown.

3. Primary flows
- Login/Register usable.
- Home/Discover/Messages/Match/Profile pages open and switch smoothly.
- About update popup buttons function and style are correct.

4. Performance sanity
- Cold start acceptable on emulator.
- Input latency on login/password is acceptable.
- Scrolling in Home/Discover/Messages is smooth with no obvious jank spikes.

## Merge/Regression recommendation
- Current code is ready for user-side final pass, then GitHub PR + Regression.
- Suggested one-shot sequence:
1. Run `powershell -ExecutionPolicy Bypass -File scripts/fast_deploy_flutter_android_debug.ps1`
2. Complete manual acceptance items above.
3. Open PR and run one daily Regression batch (per team quota rule).
