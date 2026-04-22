#!/bin/zsh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
SKILLS=("runner" "orchestrator" "continuity-handoff")

mkdir -p "$SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  src="$REPO_DIR/$skill"
  dest="$SKILLS_DIR/$skill"

  if [[ ! -d "$src" ]]; then
    echo "Missing skill directory: $src" >&2
    exit 1
  fi

  if [[ -L "$dest" ]]; then
    current_target="$(readlink "$dest")"
    if [[ "$current_target" == "$src" ]]; then
      echo "Already linked: $dest -> $src"
      continue
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    echo "Destination already exists and is not a symlink: $dest" >&2
    echo "Move or remove it first, then run this script again." >&2
    exit 1
  fi

  ln -s "$src" "$dest"
  echo "Linked: $dest -> $src"
done

echo ""
echo "Installed skills into: $SKILLS_DIR"
echo "Restart Codex to pick up new skills."
