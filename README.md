# skills

Codex에서 재사용하는 커스텀 스킬을 모아두는 저장소입니다.

## `.agents` 안에 꼭 있어야 하나?

아니요. `.agents`는 프로젝트 로컬 스킬용 경로일 뿐 필수는 아닙니다.

- 프로젝트 로컬 전용 스킬: `<project>/.agents/skills/...`
- 전역/공용 스킬: `~/.codex/skills/...`

이 저장소는 전역/공용 스킬을 관리합니다.

## 저장소 구조

```text
skills/
  create-pr/
    SKILL.md
    agents/openai.yaml
  wip-issue/
    SKILL.md
scripts/
  install-skills.sh
```

각 스킬 디렉터리(`skills/<name>/`)에는 최소 `SKILL.md`가 필요합니다.

## 설치 방법

```bash
cd /Users/eunsoo/Documents/Git/skills
./scripts/install-skills.sh
```

기본 동작:

- 스캔 경로: `skills/`
- 대상 경로: `${CODEX_HOME:-~/.codex}/skills`
- 설치 방식: `copy`
- 기존 동일 이름 스킬이 있으면 skip

설치 후 Codex 재시작이 필요합니다.

## 설치 스크립트 옵션

```bash
./scripts/install-skills.sh --help
```

옵션:

- `--dest <path>`: 설치 대상 경로 지정
- `--mode copy|symlink`: 복사 또는 심볼릭링크 설치
- `--force`: 기존 스킬 덮어쓰기

예시:

```bash
./scripts/install-skills.sh --mode symlink --force
```

## 권장 운영 방식

- 공용으로 재사용할 스킬: 이 저장소(`skills/`)에 관리
- 프로젝트 문맥 강한 스킬: 각 프로젝트의 `.agents/skills`에 유지
