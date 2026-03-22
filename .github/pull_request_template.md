## Summary
- What changed:
- Why:

## Scope
- [ ] Android UI
- [ ] Android logic/state
- [ ] Backend API
- [ ] Database migration
- [ ] CI / deploy scripts

## Risk Check (Required)
- [ ] API compatibility checked (`/api/v1/*` routes, request/response fields)
- [ ] DB migration is safe (forward + rollback considered)
- [ ] Privacy/auth impact reviewed (no public leak of private profile data)
- [ ] Critical user flow verified (register/login/profile/astro path)
- [ ] Map/navigation state retention verified (no form reset on return)
- [ ] CI passed (`release-gate-quick`, `backend-tests`, `android-build`)

## Verification
### Local
- Backend:
  - [ ] `php artisan test`
- Android:
  - [ ] `./gradlew :app:assembleDebug` (or `gradlew.bat` on Windows)
- Gate:
  - [ ] `powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -QuickUpdateOnly`
  - [ ] (Before release) `powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -Phone 13800000022 -Password "******"`

### Manual Smoke
- [ ] Login / register works
- [ ] Profile save works
- [ ] Astro compute + save + reload works
- [ ] Messages / Discover open without crash

## Deployment Notes
- Aliyun deploy needed:
  - [ ] No
  - [ ] Yes (describe command and migration)
- Rollback plan:

## Screenshots / Logs (if UI or runtime behavior changed)
- Before:
- After:
- Key logs:
