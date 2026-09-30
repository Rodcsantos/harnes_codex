#!/usr/bin/env bash
# Install language servers used for semantic navigation/diagnostics (idempotent).
# Usage: install-lsp.sh [python] [ts] [php]   (default: python ts)
set -euo pipefail
langs=("$@"); ((${#langs[@]})) || langs=(python ts)
have() { command -v "$1" >/dev/null 2>&1; }
for l in "${langs[@]}"; do
  case "$l" in
    python) have pyright-langserver || { have npm && npm i -g pyright || { have pipx && pipx install pyright; }; }
            have ruff || { have pipx && pipx install ruff || echo "instale ruff: pipx install ruff" >&2; } ;;
    ts)     have typescript-language-server || npm i -g typescript typescript-language-server ;;
    php)    have intelephense || npm i -g intelephense ;;
    *) echo "linguagem desconhecida: $l" >&2; exit 2 ;;
  esac
done
for b in pyright-langserver ruff typescript-language-server intelephense; do
  have "$b" && printf '[ok] %s\n' "$b" || printf '[--] %s\n' "$b"
done
