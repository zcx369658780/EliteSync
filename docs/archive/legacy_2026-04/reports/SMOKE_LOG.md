# Smoke Log


## 2026-04-03 23:28:07
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [FAIL] MBTI Quiz GET: Response status code does not indicate success: 410 (Gone).
  - [FAIL] MBTI Result GET: Response status code does not indicate success: 410 (Gone).
  - [PASS] Astro GET: profile field present

## 2026-04-03 23:28:19
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [FAIL] MBTI Quiz GET: Response status code does not indicate success: 410 (Gone).
  - [FAIL] MBTI Result GET: Response status code does not indicate success: 410 (Gone).
  - [PASS] Astro GET: profile field present

## 2026-04-03 23:29:59
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-06 07:17:46
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-06 09:19:22
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90)
  - [PASS] Profile Basic GET: id=8, phone=90
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-06 09:20:05
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90000000000)
  - [PASS] Profile Basic GET: id=9, phone=90000000000
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-06 09:21:32
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [FAIL] Auth chain: Phone/Password missing (or pass -SkipAuthChecks)

## 2026-04-06 09:21:42
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [FAIL] Auth chain: Phone/Password missing (or pass -SkipAuthChecks)

## 2026-04-06 09:22:40
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90161086331)
  - [PASS] Profile Basic GET: id=10, phone=90161086331
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-06 09:35:50
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90806462146)
  - [PASS] Profile Basic GET: id=11, phone=90806462146
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present
  - [FAIL] Smoke Cleanup: Response status code does not indicate success: 404 (Not Found).

## 2026-04-06 09:36:02
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90902669655)
  - [PASS] Profile Basic GET: id=12, phone=90902669655
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present
  - [FAIL] Smoke Cleanup: Response status code does not indicate success: 404 (Not Found).

## 2026-04-06 10:03:45
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [FAIL] Login: 422 fallback register failed: The remote server returned an error: (422) Unprocessable Content.

## 2026-04-06 10:05:52
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90185469267)
  - [PASS] Profile Basic GET: id=14, phone=90185469267
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present
  - [PASS] Smoke Cleanup: fallback account deleted (phone=90185469267)

## 2026-04-06 10:07:43
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.06(206)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90887299387)
  - [PASS] Profile Basic GET: id=15, phone=90887299387
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present
  - [PASS] Smoke Cleanup: fallback account deleted (phone=90887299387)

## 2026-04-07 20:34:09
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-07 20:34:29
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-07 20:34:34
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-07 22:33:59
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [FAIL] Auth chain: Phone/Password missing (or pass -SkipAuthChecks)

## 2026-04-07 22:34:07
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [FAIL] Auth chain: Phone/Password missing (or pass -SkipAuthChecks)

## 2026-04-07 22:34:16
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: 422 fallback register ok (phone=90624035273)
  - [PASS] Profile Basic GET: id=28, phone=90624035273
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present
  - [PASS] Smoke Cleanup: fallback account deleted (phone=90624035273)

## 2026-04-07 22:34:28
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [FAIL] Auth chain: Phone/Password missing (or pass -SkipAuthChecks)

## 2026-04-08 08:40:24
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: SKIPPED
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200

## 2026-04-08 09:26:50
- BaseUrl: http://101.133.161.203
- Overall: FAIL
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [FAIL] Auth chain: Phone/Password missing (or pass -SkipAuthChecks)

## 2026-04-08 09:27:22
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present

## 2026-04-08 09:27:55
- BaseUrl: http://101.133.161.203
- Overall: PASS
- AuthChecks: ENABLED
- CheckPasswordChange: False
- Details:
  - [PASS] Version API: latest=0.02.08(208)
  - [PASS] Download URL: HTTP/1.1 200
  - [PASS] Login: token ok
  - [PASS] Profile Basic GET: id=5, phone=17094346566
  - [PASS] Profile Basic POST: ok=True, city=Nanyang
  - [PASS] MBTI Quiz GET: 410 Gone (feature closed)
  - [PASS] MBTI Result GET: 410 Gone (feature closed)
  - [PASS] Astro GET: profile field present
