# Long-term Memory

## 2026-03-28 Open-source verification rule (from user)
- Before handing any advisor-proposed open-source repository to user as implementation dependency, Codex must locally verify:
  1) repository availability (URL reachable/repo exists and active enough),
  2) license type and commercial compatibility,
  3) whether the suggested usage in our project scope is license-compliant.
- If verification is incomplete, label recommendation as "unverified" and do not treat it as final dependency advice.

## 2026-03-29 PR + Code Review workflow rule (from user)
- Code Review is required before each PR.
- PR creation must have explicit user approval first.
- Execution order must be:
  1) request/obtain user approval for PR,
  2) run Code Review,
  3) create PR.

## 2026-03-29 License tracking rule (from user)
- In project root, keep a continuously updated license tracker file for all app dependencies:
  - `D:\EliteSync\LICENSE_DEPENDENCY_STATUS.md`
- This tracker must explicitly mark which libraries:
  1) can be used in commercial closed-source distribution,
  2) require additional authorization/commercial license,
  3) are open-source but still pending verification.
- Any dependency addition or version upgrade must update this tracker in the same task.
