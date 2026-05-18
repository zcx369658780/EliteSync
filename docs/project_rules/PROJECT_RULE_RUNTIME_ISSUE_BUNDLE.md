# EliteSync Project Rule: Runtime Issue Bundle

## 0. One-line conclusion

Runtime/program-development tasks must be handled as a GitHub Issue Bundle rather than one giant issue.

## 1. Purpose

Runtime work needs separate planning, implementation, evidence, Claude review, observation handling, and GPT final acceptance stages. Splitting these stages keeps scope reviewable, preserves authorization gates, and prevents one issue from silently mixing implementation, verification, and acceptance.

## 2. Standard issue bundle

Default bundle:

```text
A. Plan runtime slice <feature>
B. Implement runtime slice <feature>
C. Build text-first evidence pack <feature>
D. Claude horizontal / blind review <feature>
E. Address Claude observations <feature>  # only if needed
F. GPT final acceptance <feature>
```

Small low-risk changes may combine A+B only if GPT advisor explicitly allows it. Evidence, Claude review, and GPT final acceptance should not be silently skipped.

## 3. Required gate separation

The following must remain separate gates when relevant:

- server write operation
- Nginx / tunnel / endpoint operation
- DB / migration / restore
- Flutter base URL switch
- release chain / APK / versionCode
- production request
- Claude horizontal / blind review
- GPT final acceptance

## 4. Runtime issue output expectations

Each issue should produce a text report or commit / PR summary stating:

- issue number
- scope
- files changed
- tests run
- what was not done
- protected surfaces
- evidence location
- next gate

## 5. Current A1 note

- current active version: 6.0-A1
- current stage: Option B / SSH Tunnel staging preparation
- Option B symlink execution remains paused
- this rule does not authorize symlink, nginx -t, reload, endpoint verification, staging request, or production request
