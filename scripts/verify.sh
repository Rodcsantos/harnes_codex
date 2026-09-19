#!/usr/bin/env bash
set -u
fail=0

check() {
  local c="$1"
  if command -v "$c" >/dev/null 2>&1; then
    printf '[ok] %-24s %s\n' "$c" "$(command -v "$c")"
  else
    printf '[--] %-24s not installed\n' "$c"
  fi
}

for c in codex git rtk atlas sigmap serena mcp2cli mcpq headroom tokview; do check "$c"; done

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
python3 - "$CODEX_HOME" <<'PY'
from pathlib import Path
import sys
home = Path(sys.argv[1])
agents = list((home / 'agents').glob('*.toml'))
skills = list((home / 'skills').glob('*/SKILL.md'))
print(f'[info] agents installed: {len(agents)}')
print(f'[info] skills installed: {len(skills)}')
PY

if command -v codex-efficient-doctor >/dev/null 2>&1; then codex-efficient-doctor || fail=1; fi
exit "$fail"