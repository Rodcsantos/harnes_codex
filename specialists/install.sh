#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CODEX_HOME/backups/dev-specialists-$TS"
mkdir -p "$CODEX_HOME/agents" "$CODEX_HOME/skills" "$BACKUP/agents" "$BACKUP/skills"

copy_with_backup() {
  local src="$1" dst="$2" backup="$3"
  if [[ -e "$dst" ]]; then
    mkdir -p "$(dirname "$backup")"
    cp -a "$dst" "$backup"
  fi
  rm -rf "$dst"
  cp -a "$src" "$dst"
}

for f in "$SRC"/agents/*.toml; do
  base="$(basename "$f")"
  copy_with_backup "$f" "$CODEX_HOME/agents/$base" "$BACKUP/agents/$base"
done

for d in "$SRC"/skills/*; do
  base="$(basename "$d")"
  copy_with_backup "$d" "$CODEX_HOME/skills/$base" "$BACKUP/skills/$base"
done

python3 "$SRC/verify.py" "$CODEX_HOME"

echo
echo "Installed Codex dev specialists into: $CODEX_HOME"
echo "Backup of replaced entries: $BACKUP"
echo "Optional multi-agent defaults are in: $SRC/config-snippet.toml"
echo "Restart the Codex CLI/IDE session so agent and skill discovery refreshes."
