# EliteSync Project Rule: Text-first Evidence Packs

## 0. One-line conclusion

GitHub stores the text evidence chain; screenshots are not uploaded in bulk and are only used for critical disputes or final-review needs.

## 1. Purpose

GitHub should not become a large image warehouse. Text reports remain easier to diff, review, search, and preserve across GPT advisor, Codex, Claude, Gemini, and user review.

## 2. Default evidence stored in GitHub

Default repo evidence:

```text
Codex self-review report: text
Claude horizontal / blind review report: text
Codex integrated acceptance report: text
Action Matrix: text
Evidence index: text
Screenshot inventory: text-only unless critical
```

## 3. Screenshot policy

Default: do not upload ordinary screenshots to GitHub.

Critical screenshots may be kept locally and uploaded to GPT conversation by the user when needed.

Screenshots may be committed only when they are:

- direct fail / conditional-pass evidence
- evidence for a Codex vs Claude disagreement
- key Soul / CECE / 测测 comparison screenshot showing a critical product gap
- required by GPT advisor final review
- release-chain proof such as version center / versionCode / release evidence

## 4. Screenshot index format

If screenshots are not committed, reports should still include:

- screenshot ID
- source app: EliteSync / Soul / CECE / 测测 / other
- page / module
- local path or user-held reference
- reviewer conclusion
- whether GPT advisor needs to see it

Do not include secrets or private user data.

## 5. Sensitive evidence rules

Never commit:

- `.env`, keys, tokens, cookies, sessions, credentials
- private user data
- private account screenshots
- raw logs with secrets
- large videos unless explicitly approved

## 6. Downloads / local output policy

- task prompts live in GitHub Issues
- reports / rules / plans live in repo docs
- `.codex/tasks/` remains local scratch and is not committed
- Downloads is not a long-term project source
