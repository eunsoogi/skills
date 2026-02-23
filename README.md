# Codex Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/Installer-Bash-1f425f.svg)](scripts/install-skills.sh)
[![Codex](https://img.shields.io/badge/For-Codex-blue.svg)](https://openai.com)

A curated collection of reusable Codex skills for day-to-day engineering workflows.

This repository is intended for shared/global skills (typically installed under `~/.codex/skills`), while project-specific skills can live in each repo under `.agents/skills`.

## Table of Contents

- [What This Repo Is For](#what-this-repo-is-for)
- [Included Skills](#included-skills)
- [Quick Start](#quick-start)
- [Installer Options](#installer-options)
- [Repository Layout](#repository-layout)
- [How Skills Are Structured](#how-skills-are-structured)
- [Development](#development)
- [License](#license)

## What This Repo Is For

- Maintain reusable Codex skills in one place.
- Install those skills into your Codex home directory.
- Keep project-local skills separate from globally shared skills.

Use:
- Project-local skills: `<project>/.agents/skills/...`
- Shared/global skills: `~/.codex/skills/...`

## Included Skills

- `git-workflow`: End-to-end GitHub delivery workflow with issue drafting/updating, branch/PR publishing, review response, squash merge, and post-merge cleanup.

## Quick Start

```bash
git clone https://github.com/eunsoogi/skills.git
cd skills
bash scripts/install-skills.sh
```

Default behavior:
- Source scan path: `skills/`
- Destination path: `${CODEX_HOME:-$HOME/.codex}/skills`
- Install mode: `copy`
- Existing skill directory: skipped (unless `--force` is provided)

Restart Codex after installation.

## Installer Options

```bash
bash scripts/install-skills.sh --help
```

- `--dest <path>`: destination directory for installed skills
- `--mode copy|symlink`: copy skill folders or install as symlinks
- `--force`: overwrite existing destination skill directories
- `-h, --help`: show help

Examples:

```bash
# Symlink install for local iteration
bash scripts/install-skills.sh --mode symlink --force

# Install into a custom destination
bash scripts/install-skills.sh --dest ~/.codex/skills --force
```

## Repository Layout

```text
skills/
  git-workflow/
    SKILL.md
    agents/openai.yaml
scripts/
  install-skills.sh
```

## How Skills Are Structured

Each skill directory under `skills/<name>/` must include:
- `SKILL.md` (required): trigger description and execution workflow

Optional:
- `agents/openai.yaml`: UI-facing metadata for skill display and defaults
- `scripts/`, `references/`, `assets/`: bundled resources when needed

## Development

1. Update or add skills under `skills/`.
2. Reinstall locally:

```bash
bash scripts/install-skills.sh --force
```

3. Restart Codex and validate the updated behavior.

## License

MIT. See [LICENSE](LICENSE).
