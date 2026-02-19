---
name: create-pr
description: "Create or recreate an issue branch named {creator}/issue{number} from the repository default branch, push it, then create or update a GitHub Pull Request. Use when asked to create a PR, prepare and push an issue branch, or draft a PR body. Always show PR title/body draft first for approval, then apply appropriate labels."
---

# Goal
- Execute a consistent issue-driven flow from branch creation to PR publication.
- Show PR title/body draft before creating or updating the PR.
- Apply appropriate existing repository labels to the PR.

# Gather Context
1. Confirm issue number (example: `123`).
2. Resolve owner/repo from remote: `git remote get-url origin`.
3. Resolve branch creator login and store it as `BRANCH_CREATOR` (prefer the authenticated GitHub user login).
4. Resolve base branch dynamically from remote HEAD and store it as `BASE_BRANCH`.
5. Sync base branch metadata: `git fetch origin "$BASE_BRANCH"`.
6. Check working tree status: `git status -sb`.
7. Check staged files: `git diff --cached --name-only`.
8. Check available repository labels before drafting final PR metadata.

# Issue Branch Rules
1. If an issue number is provided, branch name must be `{branchCreator}/issue{issueNumber}`.
2. If a local branch with the same name exists, delete and recreate it.
3. Always recreate from `BASE_BRANCH`.
4. Recommended sequence:
- `BASE_BRANCH="$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')"` (fallback to `main` if empty)
- `BRANCH_CREATOR="$(gh api user -q .login)"` (or equivalent authenticated GitHub login)
- `ISSUE_BRANCH="${BRANCH_CREATOR}/issue${issueNumber}"`
- `git switch "$BASE_BRANCH"`
- `git pull --ff-only origin "$BASE_BRANCH"`
- `git branch -D "$ISSUE_BRANCH"` (if it exists)
- `git switch -c "$ISSUE_BRANCH"`

# Commit Rules
1. If staged files exist, create a commit before push.
2. Use Conventional Commits for subject: `<type>[optional scope][optional !]: <summary>`.
3. Choose `type` by intent (`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`, `style`).
4. Use `scope` only when it narrows module/directory clearly.
5. Keep summary imperative and concise (about 50 chars, max 72).
6. Put issue reference in footer, not title: `Refs: #<issueNumber>`.
7. Never create empty commits.
8. If only unstaged changes exist, ask whether to stage/commit first.
9. Examples:
- `feat: add rebalance threshold guard`
- `feat(api): add rebalance threshold guard`
- `fix(ui): handle empty volatility response`
- `refactor(market-volatility)!: simplify signal selection`

# Draft Rules
1. Derive title from latest commit subject or issue goal.
2. Use this body structure:
- `Summary`
- `Changes`
- `How to Test`
- `Risks`
3. If tests were not run, state it explicitly in `How to Test`.
4. If issue number is known, append `Fixes #<issueNumber>` as final line.
5. Propose 1 to 3 labels based on change type and risk, using existing repository labels only.
6. Write in issue-reporting tone when describing problems: focus on current symptoms, impact, and expected behavior, and avoid implying the issue is already resolved.

# Label Rules
1. Discover existing labels before finalizing metadata.
2. Map intent to closest available labels. Typical mapping:
- `feat` -> `enhancement` or equivalent
- `fix` -> `bug` or equivalent
- `docs` -> `documentation` or equivalent
- `refactor/chore` -> `maintenance` or equivalent
3. Prefer specific labels already used by the repository over generic guesses.
4. If no suitable label exists, proceed without adding new labels unless user explicitly asks to create labels.
5. Apply labels to the PR at creation time or immediately after PR creation/update.

# Publish Workflow
1. Prepare `{branchCreator}/issue{issueNumber}` branch.
2. Commit staged files with an appropriate message, if any.
3. Push the branch: `git push -u origin "$ISSUE_BRANCH"`.
4. Check whether an open PR already exists for `head -> base(BASE_BRANCH)`.
5. Show title/body/labels draft first and ask: "Create or update the PR with this draft?"
6. After approval, create or update PR through GitHub MCP.
7. Apply approved labels to the PR.
8. Report PR URL, title, base/head, resolved `BASE_BRANCH`, resolved `ISSUE_BRANCH`, and applied labels.

# Guardrails
- Enforce `{branchCreator}/issue{issueNumber}` naming without exception when issue number is provided.
- Do not reuse existing local issue branch; recreate it.
- Do not commit implementation work directly on `BASE_BRANCH`.
- If critical info is missing, ask one focused question at a time.
