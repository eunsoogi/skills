---
name: git-workflow
description: "End-to-end Git and GitHub workflow in one skill: analyze staged/unstaged changes or commits, draft or update issues, create issue-scoped {creator}/issue{number} branches and Git Worktrees, move local staged/unstaged work into the issue worktree, publish or update PRs, address new PR reviews, and merge with post-merge cleanup. Use when asked to handle issue/PR lifecycle, worktree handoff, review follow-ups, branch management, or merge operations."
---

# Goal
- Run one flow from evidence collection to issue, worktree handoff, PR, review follow-up, and merge cleanup.
- Write issue titles/bodies, PR titles/bodies, and PR review replies in English only.
- Show issue and PR drafts before publishing and require explicit approval.
- Keep implementation work in issue-specific worktrees, not in the main worktree.
- Prefer repository-local worktrees under `worktrees/` so IDEs like VSCode can discover them.

# Authentication Requirements
1. Ensure GitHub authentication is available before running workflow steps.
2. If using a PAT, require repository permissions:
- `Contents`: Read and Write
- `Issues`: Read and Write
- `Pull requests`: Read and Write
3. Expose the token through the active client path (for example `GH_TOKEN` or `GITHUB_TOKEN`) so `gh` and GitHub MCP operations can create and update issues/PRs.

# Core Workflow

## 1) Gather Context
1. Resolve repository context.
- `git remote get-url origin`
- `git rev-parse --show-toplevel`
- `basename "$(git rev-parse --show-toplevel)"`
- `git branch --show-current`
2. Resolve identities and branches.
- `BRANCH_CREATOR` from authenticated GitHub login.
- `BASE_BRANCH` from `origin/HEAD` (fallback: `main`).
- `git fetch origin "$BASE_BRANCH"`.
3. Resolve analysis mode.
- If user provides commit SHA, use commit mode.
- Else if staged or unstaged changes exist, use worktree-change mode.
- Else use latest commit mode.
4. Resolve labels before drafting metadata.

## 2) Collect Evidence
1. Worktree-change mode: `git status --short`, `git diff --cached --name-status`, `git diff --cached --stat`, `git diff --cached`, `git diff --name-status`, `git diff --stat`, `git diff`.
2. Commit mode: `git show --name-status --stat --pretty=fuller <SHA>`, `git show <SHA>`.
3. Latest-commit mode: `git show --name-status --stat --pretty=fuller HEAD`, `git show HEAD`.

## 3) Resolve Issue Number (Issue-First Gate)
1. If user already provided an issue number, ask whether to reuse the existing issue instead of creating a new one.
2. If user chooses existing issue, load details and keep the issue number for branch naming and PR linkage.
3. If user chooses new issue or no issue number exists:
- Summarize current conversation intent in issue language.
- Summarize staged, unstaged, and untracked changes from collected evidence.
- Draft a new issue title/body from both summaries.
4. Write issue title/body in English only with issue-reporting tone.
5. If no issue number exists, finish issue draft, approval, and issue creation before branch/worktree creation.
6. After issue creation, report issue URL and issue number, then guide next step explicitly.
- "Issue #<issueNumber> is ready. Create `{BRANCH_CREATOR}/issue<issueNumber>` worktree and move current staged/unstaged changes now?"
7. Continue with worktree creation after approval or when user requested immediate execution.

## 4) Create Issue Worktree and Move Changes
1. Build identifiers:
- `ISSUE_BRANCH="{BRANCH_CREATOR}/issue{issueNumber}"`
- `REPO_ROOT="$(git rev-parse --show-toplevel)"`
- `WORKTREE_PARENT="$REPO_ROOT/worktrees"`
- `WORKTREE_PATH="$WORKTREE_PARENT/issue{issueNumber}"`
2. If `git status --porcelain` is non-empty, run `git stash push --include-untracked -m "git-workflow: handoff to $ISSUE_BRANCH"`.
3. Recreate branch/worktree from base:
- `git switch "$BASE_BRANCH"`
- `git pull --ff-only origin "$BASE_BRANCH"`
- `mkdir -p "$WORKTREE_PARENT"`
- If `WORKTREE_PATH` exists and `git -C "$WORKTREE_PATH" status --porcelain` is empty, run `git worktree remove "$WORKTREE_PATH"`
- If `WORKTREE_PATH` exists and is dirty or locked, stop and ask user to commit/stash there or explicitly approve force removal
- `git branch -D "$ISSUE_BRANCH"` when local branch exists
- `git worktree add -b "$ISSUE_BRANCH" "$WORKTREE_PATH" "origin/$BASE_BRANCH"`
4. If stash was created, run `git -C "$WORKTREE_PATH" stash pop --index`.
5. If `stash pop` conflicts, stop and ask user how to resolve.
6. Continue implementation, commit, and push only in `WORKTREE_PATH` (prefer `git -C "$WORKTREE_PATH" ...`).
7. For VSCode visibility in the same workspace, optionally run `code --add "$WORKTREE_PATH"`.

## 5) Draft Rules and Approval Gate
1. Use issue sections: `## Summary`, `## Conversation Context`, `## Working Tree Snapshot`, `## Scope`, `## Change Details`, `## Risks`, `## Validation`.
2. Use PR sections: `Summary`, `Changes`, `How to Test`, `Risks`.
3. Derive title from intent and evidence.
4. If tests were not run, state it clearly.
5. If issue number is known, end PR body with `Fixes #<issueNumber>`.
6. Propose 1 to 3 labels using existing repository labels only.
7. Derive an execution checklist and resolve as many items as possible before approval.
- Run targeted tests, lint, and checks when available.
- Apply straightforward fixes discovered during validation.
8. Mark each checklist item as done or pending with short reasons.
9. Show final issue draft, PR draft, labels, and checklist status.
10. Ask for one approval covering both operations: issue create/update and PR create/update.

## 6) Publish Workflow
1. After approval, create or update the issue first.
2. Continue directly to PR workflow after issue completion unless user explicitly pauses.
3. Ensure issue number is resolved (existing or newly created).
4. Run issue-first gate and worktree workflow.
5. Commit rules in issue worktree:
- Commit staged changes before push when staged changes exist.
- Use Conventional Commits: `<type>[optional scope][optional !]: <summary>`.
- Put issue reference in footer: `Refs: #<issueNumber>`.
- Never create empty commits.
- If only unstaged changes exist, ask whether to stage and commit.
6. Push branch from issue worktree: `git -C "$WORKTREE_PATH" push -u origin "$ISSUE_BRANCH"`.
7. Create or update PR with approved title/body/labels.
8. Report issue URL, PR URL, title, base/head, `BASE_BRANCH`, `ISSUE_BRANCH`, `WORKTREE_PATH`, and applied labels.

## 7) Review Handling Workflow
1. When new PR review comments are present, fetch latest review threads and unresolved comments.
2. Apply requested fixes in code.
3. Run relevant checks for modified scope.
4. Commit and push follow-up changes.
5. Reply to addressed review comments in English, summarizing what changed and what remains.
6. Keep follow-up commits in the same issue worktree.

## 8) Merge Workflow
1. If user asks to merge, merge the PR using Squash and Merge only.
2. After successful merge:
- Delete remote issue branch: `git push origin --delete "$ISSUE_BRANCH"`.
- Remove issue worktree: `git worktree remove "$WORKTREE_PATH"` (if dirty/locked, stop and ask before force removal).
- Delete local issue branch: `git branch -D "$ISSUE_BRANCH"` when present.
- Switch main worktree to `BASE_BRANCH`.
- Pull latest base branch: `git pull --ff-only origin "$BASE_BRANCH"`.
3. Report merge commit and cleanup status, including worktree cleanup.

# Guardrails
- Do not create a new issue when an issue number is provided until the reuse/new choice is confirmed.
- Do not publish issue or PR without showing drafts first and getting approval.
- Do not start branch/worktree creation before issue number is finalized.
- Do not reuse an old local issue branch or old issue worktree; recreate both from `BASE_BRANCH`.
- Do not leave staged/unstaged/untracked implementation changes behind in the main worktree when handoff is required.
- Do not default to hidden or repository-external worktree paths when repository-local `worktrees/` can be used.
- Do not run `git worktree remove --force` on an existing issue worktree without explicit user approval.
- Do not commit implementation work directly on `BASE_BRANCH` or outside the issue worktree.
- Ask one focused clarification question if critical information is missing.
