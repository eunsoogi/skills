#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"
DEFAULT_DEST="${CODEX_HOME:-$HOME/.codex}/skills"
DEST="$DEFAULT_DEST"
MODE="copy"   # copy | symlink
FORCE="false"

usage() {
  cat <<USAGE
Install local skills from this repository into Codex skills directory.

Usage:
  scripts/install-skills.sh [options]

Options:
  --dest <path>       Destination directory (default: $DEFAULT_DEST)
  --mode <copy|symlink>
                      Install mode (default: copy)
  --force             Overwrite existing destination skill directories
  -h, --help          Show this help

Examples:
  scripts/install-skills.sh
  scripts/install-skills.sh --mode symlink
  scripts/install-skills.sh --dest ~/.codex/skills --force
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)
      DEST="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$MODE" != "copy" && "$MODE" != "symlink" ]]; then
  echo "Invalid --mode: $MODE (use copy or symlink)" >&2
  exit 1
fi

if [[ ! -d "$SKILLS_ROOT" ]]; then
  echo "Skills root not found: $SKILLS_ROOT" >&2
  exit 1
fi

SKILLS_ROOT_REAL="$(cd "$SKILLS_ROOT" && pwd -P)"
if [[ "$DEST" = /* ]]; then
  DEST_ABS="$DEST"
else
  DEST_ABS="$PWD/$DEST"
fi

if [[ -e "$DEST_ABS" || -L "$DEST_ABS" ]]; then
  DEST_REAL="$(cd "$DEST_ABS" && pwd -P)"
else
  DEST_PARENT="$(dirname "$DEST_ABS")"
  if [[ -d "$DEST_PARENT" || -L "$DEST_PARENT" ]]; then
    DEST_PARENT_REAL="$(cd "$DEST_PARENT" && pwd -P)"
    DEST_REAL="$DEST_PARENT_REAL/$(basename "$DEST_ABS")"
  else
    DEST_REAL="$DEST_ABS"
  fi
fi

if [[ "$DEST_REAL" == "$SKILLS_ROOT_REAL" || "$DEST_REAL" == "$SKILLS_ROOT_REAL"/* ]]; then
  echo "Invalid --dest: $DEST (must not be inside source skills tree: $SKILLS_ROOT)" >&2
  exit 1
fi

mkdir -p "$DEST"

SKILL_FILES=()
while IFS= read -r f; do
  SKILL_FILES+=("$f")
done < <(find "$SKILLS_ROOT" -mindepth 2 -maxdepth 2 -type f -name SKILL.md | sort)

if [[ ${#SKILL_FILES[@]} -eq 0 ]]; then
  echo "No skills found in repository: $SKILLS_ROOT" >&2
  exit 1
fi

echo "Repository: $REPO_ROOT"
echo "Skills root: $SKILLS_ROOT"
echo "Destination: $DEST"
echo "Mode: $MODE"

INSTALLED=0
SKIPPED=0

for skill_file in "${SKILL_FILES[@]}"; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  target="$DEST/$skill_name"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$FORCE" == "true" ]]; then
      rm -rf "$target"
    else
      echo "skip: $skill_name (already exists at $target; use --force to overwrite)"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
  fi

  if [[ "$MODE" == "copy" ]]; then
    cp -R "$skill_dir" "$target"
  else
    ln -s "$skill_dir" "$target"
  fi

  echo "installed: $skill_name -> $target"
  INSTALLED=$((INSTALLED + 1))
done

echo
echo "Done. installed=$INSTALLED, skipped=$SKIPPED"
echo "Restart Codex to pick up new skills."
