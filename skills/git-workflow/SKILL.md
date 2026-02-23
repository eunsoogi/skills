---
name: git-workflow
description: "End-to-end Git and GitHub workflow in one skill: analyze staged changes or commits, draft or update issues, create or recreate {creator}/issue{number} branches from the default base branch, publish or update PRs, address new PR reviews, and merge with post-merge cleanup. Use when asked to handle issue/PR lifecycle, review follow-ups, branch management, or merge operations."
---

# Goal
- Run one consistent workflow from work analysis to issue, PR, review response, and merge cleanup.
- Keep issue titles, issue bodies, PR titles, PR bodies, and PR review comments in English only.
- Show issue and PR drafts before publishing and request explicit approval.

# Authentication Requirements
1. Ensure GitHub authentication is available before running workflow steps.
2. If using a PAT, require repository permissions:
- `Contents`: Read and Write
- `Issues`: Read and Write
- `Pull requests`: Read and Write
3. Expose the token through the active client path (for example `GH_TOKEN` or `GITHUB_TOKEN`) so `gh` and GitHub MCP operations can create and update issues/PRs.

# Gather Context
1. Resolve repository context.
- `git remote get-url origin`
- `git rev-parse --show-toplevel`
- `git branch --show-current`
2. Resolve identities and branches.
- `BRANCH_CREATOR` from authenticated GitHub login.
- `BASE_BRANCH` from `origin/HEAD` (fallback: `main`).
- `git fetch origin "$BASE_BRANCH"`.
3. Resolve analysis source.
- If user provides commit SHA, use commit mode.
- Else if staged changes exist, use staged mode.
- Else use latest commit mode.
4. Resolve labels before drafting metadata.

# Branch Safety Check
1. Detect potentially wrong branch usage before branch recreation.
- If staged changes exist and current branch is not `BASE_BRANCH`, treat it as a potential wrong-branch situation.
- If issue number is known and current branch is neither `BASE_BRANCH` nor `{BRANCH_CREATOR}/issue{issueNumber}`, treat it as wrong-branch work.
2. Ask before moving staged changes.
- Ask: "Staged changes are on `<CURRENT_BRANCH>` instead of `BASE_BRANCH` (`<BASE_BRANCH>`). Move staged changes to `BASE_BRANCH` and continue from there?"
3. Check unstaged changes before switching branches.
- If `git diff --name-only` is not empty, ask user to stash, commit, or discard unstaged changes first.
- Do not run `git switch "$BASE_BRANCH"` while unstaged changes remain in the working tree.
4. If user approves and unstaged changes are cleared, move only staged changes to `BASE_BRANCH`.
- `git stash push --staged -m "git-workflow: move staged from <CURRENT_BRANCH> to <BASE_BRANCH>"`
- `git switch "$BASE_BRANCH"`
- `git pull --ff-only origin "$BASE_BRANCH"`
- `git stash pop`
5. If user declines, continue on current branch only after explicit confirmation.

# Evidence Collection
1. Staged mode:
- `git status --short`
- `git diff --cached --name-status`
- `git diff --cached --stat`
- `git diff --cached`
2. Commit mode:
- `git show --name-status --stat --pretty=fuller <SHA>`
- `git show <SHA>`

# Issue Strategy
1. If user already provided an issue number, ask whether to reuse the existing issue instead of creating a new one.
2. If user chooses existing issue:
- Load issue details and decide whether to update it or only reference it.
- Keep the issue number for branch naming and PR linkage.
3. If user chooses new issue or no issue number exists:
- Draft a new issue title/body from collected evidence.
4. Write issue title/body in English only.
5. Use issue-reporting tone for problem statements: current symptoms, impact, expected behavior.

# Draft Rules
1. Issue body structure:
- `## Summary`
- `## Scope`
- `## Change Details`
- `## Risks`
- `## Validation`
2. PR body structure:
- `Summary`
- `Changes`
- `How to Test`
- `Risks`
3. Derive title from change intent and evidence.
4. If tests were not run, state it clearly.
5. If issue number is known, end PR body with `Fixes #<issueNumber>`.
6. Propose 1 to 3 labels using existing repository labels only.

# Checklist Resolution Before Approval
1. Derive an execution checklist from evidence and draft content.
2. Resolve as many checklist items as possible before requesting publish approval.
- Run targeted tests, lint, and checks when available.
- Apply straightforward fixes discovered during validation.
3. Mark each checklist item as done or pending, with short reasons for pending items.
4. Show final issue draft, PR draft, labels, and checklist status.
5. Ask for one approval covering both operations: issue create/update and PR create/update.

# Publish Workflow
1. After approval, create or update the issue first.
2. Continue directly to PR workflow after issue completion unless user explicitly pauses.
3. Ensure issue number is resolved (existing or newly created).
4. Build issue branch name as `{BRANCH_CREATOR}/issue{issueNumber}`.
5. Recreate issue branch from `BASE_BRANCH`.
- `git switch "$BASE_BRANCH"`
- `git pull --ff-only origin "$BASE_BRANCH"`
- `git branch -D "$ISSUE_BRANCH"` when local branch exists
- `git switch -c "$ISSUE_BRANCH"`
6. Commit rules:
- Commit staged changes before push when staged changes exist.
- Use Conventional Commits: `<type>[optional scope][optional !]: <summary>`.
- Put issue reference in footer: `Refs: #<issueNumber>`.
- Never create empty commits.
- If only unstaged changes exist, ask whether to stage and commit.
7. Push branch: `git push -u origin "$ISSUE_BRANCH"`.
8. Create or update PR with approved title/body/labels.
9. Report issue URL, PR URL, title, base/head, `BASE_BRANCH`, `ISSUE_BRANCH`, and applied labels.

# Review Handling Workflow
1. When new PR review comments are present, fetch latest review threads and unresolved comments.
2. Apply requested fixes in code.
3. Run relevant checks for modified scope.
4. Commit and push follow-up changes.
5. Reply to addressed review comments in English, summarizing what changed and what remains.

# Merge Workflow
1. If user asks to merge, merge the PR using Squash and Merge only.
2. After successful merge:
- Delete remote issue branch: `git push origin --delete "$ISSUE_BRANCH"`.
- Switch local branch to `BASE_BRANCH`.
- Delete local issue branch: `git branch -D "$ISSUE_BRANCH"`.
- Pull latest base branch: `git pull --ff-only origin "$BASE_BRANCH"`.
3. Report merge commit and cleanup status.

# Guardrails
- Do not create a new issue when an issue number is provided until the reuse/new choice is confirmed.
- Do not publish issue or PR without showing drafts first and getting approval.
- Do not reuse an old local issue branch; recreate from `BASE_BRANCH`.
- If staged changes are detected on a wrong branch, ask whether to move them to `BASE_BRANCH` before proceeding.
- If unstaged changes exist, do not switch branches until user decides how to handle unstaged work.
- Do not commit implementation work directly on `BASE_BRANCH`.
- Ask one focused clarification question if critical information is missing.
