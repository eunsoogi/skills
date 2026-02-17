---
name: wip-issue
description: Analyze current staged changes or latest commit and create a GitHub issue draft/body from the findings.
---

# WIP Issue

Create GitHub issues from current git work state (staged diff or latest commit).

## When to use

Use this skill when the user asks to create/write a GitHub issue based on:
- current staged changes
- a specific commit
- the latest commit
- current WIP status in a git repository

## Required tools

- `git`
- `gh`

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

4. Build issue draft in this structure.

```markdown
## Summary

(What changed and why in 2-5 bullets)

## Scope

- Files touched:
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

5. Propose title format.

- `feat: <short change goal>`
- `fix: <bug symptom>`
- `refactor: <area>`
- `chore: <maintenance item>`

6. Before creating issue, show title/body draft and get user approval.

7. Create issue with `gh` after approval.

```bash
gh issue create --title "<TITLE>" --body-file <BODY_FILE>
```

If repo is ambiguous, use:

```bash
gh issue create -R owner/repo --title "<TITLE>" --body-file <BODY_FILE>
```

## Rules

- Never create issue without showing draft first unless user explicitly says to proceed immediately.
- Prefer concrete file and behavior references over vague summaries.
- If both staged changes and commit SHA are provided, prioritize user-specified commit SHA.
