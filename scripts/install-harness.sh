#!/usr/bin/env bash
# Install the team (agents), skills and hooks for Codex CLI and/or Claude Code.
# Usage: install-harness.sh [--engine codex|claude|both] [--no-hooks] [--uninstall]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE="both"; HOOKS=1; UNINSTALL=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine) ENGINE="${2:?}"; shift 2 ;;
    --no-hooks) HOOKS=0; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    *) echo "Uso: $0 [--engine codex|claude|both] [--no-hooks] [--uninstall]" >&2; exit 2 ;;
  esac
done

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
HARNESS_HOME="${HARNESS_HOME:-$HOME/.harness}"
HOOKS_DIR="$HARNESS_HOME/hooks"
log() { printf '\n== %s\n' "$*"; }

python3 "$ROOT/scripts/build-claude-agents.py" >/dev/null

if (( UNINSTALL )); then
  [[ "$ENGINE" != claude ]] && { bash "$ROOT/specialists/uninstall.sh"; [[ -f "$CODEX_HOME/hooks.json" ]] && python3 "$ROOT/scripts/merge_hooks.py" "$CODEX_HOME/hooks.json" codex "$HOOKS_DIR" --remove; }
  if [[ "$ENGINE" != codex ]]; then
    for f in "$ROOT"/claude/agents/*.md; do rm -f "$CLAUDE_HOME/agents/$(basename "$f")"; done
    for d in "$ROOT"/specialists/skills/*; do rm -rf "$CLAUDE_HOME/skills/$(basename "$d")"; done
    [[ -f "$CLAUDE_HOME/settings.json" ]] && python3 "$ROOT/scripts/merge_hooks.py" "$CLAUDE_HOME/settings.json" claude "$HOOKS_DIR" --remove
  fi
  rm -rf "$HOOKS_DIR"; echo "Harness removido."; exit 0
fi

if [[ "$ENGINE" == codex || "$ENGINE" == both ]]; then
  log "Codex: agentes + skills"
  bash "$ROOT/specialists/install.sh"
fi

if [[ "$ENGINE" == claude || "$ENGINE" == both ]]; then
  log "Claude Code: agentes + skills"
  mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"
  cp -a "$ROOT"/claude/agents/*.md "$CLAUDE_HOME/agents/"
  for d in "$ROOT"/specialists/skills/*; do
    rm -rf "$CLAUDE_HOME/skills/$(basename "$d")"; cp -a "$d" "$CLAUDE_HOME/skills/"
  done
  echo "Instalados: $(ls "$ROOT"/claude/agents/*.md | wc -l) agentes, $(ls -d "$ROOT"/specialists/skills/* | wc -l) skills em $CLAUDE_HOME"
fi

if (( HOOKS )); then
  log "Hooks"
  mkdir -p "$HOOKS_DIR"
  cp -a "$ROOT"/hooks/*.py "$HOOKS_DIR/"
  [[ "$ENGINE" != codex ]] && python3 "$ROOT/scripts/merge_hooks.py" "$CLAUDE_HOME/settings.json" claude "$HOOKS_DIR"
  [[ "$ENGINE" != claude ]] && python3 "$ROOT/scripts/merge_hooks.py" "$CODEX_HOME/hooks.json" codex "$HOOKS_DIR"
fi

cat <<EOF

Pronto. Próximos passos:
  1. Reinicie as sessões (Codex/Claude Code) para redescobrir agentes e skills.
  2. No projeto: copie templates/project/.harness/ e ajuste verify.sh.
  3. Claude Code: 'claude --agent tech-lead' roda a sessão principal como tech lead.
  4. Codex: verifique se hooks estão habilitados (rtk init --show --codex / config.toml).
  5. Diagnóstico: ./scripts/verify.sh
EOF
