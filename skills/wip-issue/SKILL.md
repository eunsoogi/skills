---
name: wip-issue
description: Analyze current staged changes or latest commit, draft a GitHub issue title/body from findings, and apply appropriate existing labels after user approval.
---

# WIP Issue

Create GitHub issues from current git work state (staged diff or latest commit).

## Steps

1. Confirm repository context.

```bash
git rev-parse --show-toplevel
git branch --show-current
```

2. Determine source mode.
- If staged changes exist (`git diff --cached --name-status` not empty): use staged mode.
- Otherwise use latest commit mode unless user specified commit SHA.

3. Collect evidence.

### Staged mode

```bash
git status --short
git diff --cached --name-status
git diff --cached --stat
git diff --cached
```

### Commit mode

```bash
git show --name-status --stat --pretty=fuller <SHA>
git show <SHA>
```

4. Build issue draft with this structure.

```markdown
## Summary

(What changed and why in 2-5 bullets)

## Scope

- Components affected:
- Behavioral impact:

## Change Details

- Key implementation points
- API/schema/config changes
- Any migrations or compatibility notes

## Risks

- Potential regressions
- Edge cases to verify

## Validation

- [ ] Unit tests
- [ ] Integration/manual checks
- [ ] Rollback plan confirmed
```

5. Propose title.

- `feat: <short change goal>`
- `fix: <bug symptom>`
- `refactor: <area>`
- `chore: <maintenance item>`

6. Propose labels from existing repository labels.
- Inspect current labels before finalizing draft (for example: `gh label list`).
- Select 1 to 3 labels that match intent and risk.
- Prefer existing repository conventions over generic guesses.
- Typical mapping:
  - `feat` -> `enhancement`
  - `fix` -> `bug`
  - `docs` -> `documentation`
  - `refactor/chore` -> `maintenance`
- If no suitable label exists, proceed without labels unless user explicitly asks to create new ones.

7. Before creating issue, show title/body/labels draft and get user approval.

8. Create issue with `gh` after approval.

```bash
gh issue create --title "<TITLE>" --body-file <BODY_FILE> --label "<LABEL_1>" --label "<LABEL_2>"
```

If repo is ambiguous, use:

```bash
gh issue create -R owner/repo --title "<TITLE>" --body-file <BODY_FILE> --label "<LABEL_1>" --label "<LABEL_2>"
```

## Rules

- Never create an issue without showing title/body/labels draft first, unless user explicitly says to proceed immediately.
- Do not include a `Files touched` list in the issue body.
- Prefer concrete file and behavior references over vague summaries.
- If both staged changes and commit SHA are provided, prioritize user-specified commit SHA.
- Write in issue-reporting tone: describe the current problem, impact, and expected behavior; do not imply the issue is already resolved.
