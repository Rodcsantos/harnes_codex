#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
for f in "$SRC"/agents/*.toml; do rm -f "$CODEX_HOME/agents/$(basename "$f")"; done
for d in "$SRC"/skills/*; do rm -rf "$CODEX_HOME/skills/$(basename "$d")"; done
echo "Removed this package's agents and skills from $CODEX_HOME. Existing backup folders were not touched."
