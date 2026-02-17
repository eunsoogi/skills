---
name: create-pr
description: "이슈 번호를 받아 {owner}/issue{번호} 브랜치를 main 기준으로 생성/재생성하고, push 후 GitHub Pull Request를 생성하거나 갱신한다. PR 생성, 브랜치 생성+푸시, PR 본문 초안 작성 요청 시 사용하고 생성 전에 제목/본문 초안을 먼저 제시해 승인받는다."
---

# Goal
- 이슈 기반 브랜치 생성부터 PR 생성까지 일관된 절차로 처리한다.
- PR 생성 전에 제목/본문 초안을 먼저 제시하고 사용자 확인을 받는다.

# Gather Context
1. 이슈 번호 확인(예: `123`).
2. 원격에서 owner/repo 확인: `git remote get-url origin`.
3. 기본 브랜치 동기화: `git fetch origin main`.
4. 변경 상태 확인: `git status -sb`.
5. staged 파일 확인: `git diff --cached --name-only`.

# Issue Branch Rules
1. 이슈 번호가 주어지면 브랜치 이름을 반드시 `{owner}/issue{issueNumber}`로 만든다.
2. 동일한 로컬 브랜치가 이미 있으면 반드시 삭제하고 다시 만든다.
3. 브랜치 재생성은 항상 `main` 기준으로 수행한다.
4. 권장 순서:
- `git switch main`
- `git pull --ff-only origin main`
- `git branch -D "{owner}/issue{issueNumber}"` (존재 시)
- `git switch -c "{owner}/issue{issueNumber}"`

# Commit Rules
1. staged 파일이 있으면 push 전에 반드시 커밋한다.
2. 커밋 제목(subject)은 staged 변경 전체 요약이며 Conventional Commits 형식을 따른다: `<type>[optional scope][optional !]: <summary>`
3. `type`은 의미에 맞게 선택한다. 기능 추가는 `feat`, 버그 수정은 `fix`를 사용하고, 그 외 `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`, `style`도 허용한다.
4. `scope`는 선택사항이다. 모듈/디렉토리를 명확히 좁힐 때만 괄호로 쓴다.
5. `summary`는 명령형 현재시제로 작성하고 50자 내외(최대 72자)로 유지한다.
6. 이슈 번호는 제목이 아니라 footer에 기록한다: `Refs: #<issueNumber>`.
7. staged 파일이 없으면 빈 커밋은 만들지 않는다.
8. unstaged 변경만 있으면 사용자에게 staged/commit 진행 여부를 확인한다.
9. 예시:
- `feat: add rebalance threshold guard`
- `feat(api): add rebalance threshold guard`
- `fix(ui): handle empty volatility response`
- `refactor(market-volatility)!: simplify signal selection`

# Draft Rules
1. 제목은 최근 커밋 메시지 첫 줄 또는 이슈 목적을 기반으로 간결하게 작성한다.
2. 본문은 아래 섹션을 기본으로 작성한다.
- `Summary`
- `Changes`
- `How to Test`
- `Risks`
3. 테스트를 실행하지 못했으면 `How to Test`에 명시한다.
4. 이슈 번호가 있으면 본문 마지막 줄에 `Fixes #<issueNumber>`를 추가한다.

# Publish Workflow
1. `{owner}/issue{issueNumber}` 브랜치를 준비한다.
2. staged 파일이 있으면 적절한 메시지로 커밋한다.
3. 브랜치를 원격에 push한다: `git push -u origin "{owner}/issue{issueNumber}"`.
4. 동일한 `head -> base(main)` 오픈 PR 존재 여부를 확인한다.
5. 초안을 먼저 보여주고 "이대로 PR 생성/수정할까요?"라고 묻는다.
6. 사용자가 승인하면 GitHub MCP로 PR을 생성하거나 업데이트한다.
7. 완료 후 PR URL, 제목, base/head를 보고한다.

# Guardrails
- 이슈 번호 기반 요청이면 브랜치 네이밍 규칙을 예외 없이 적용한다.
- 로컬 기존 브랜치를 재사용하지 말고 삭제 후 재생성한다.
- `main`에서 직접 작업 커밋하지 않는다.
- 핵심 정보가 없으면 한 번에 한 가지 질문만 한다.
