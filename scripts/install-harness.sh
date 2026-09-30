#!/usr/bin/env bash
# Install the team (agents), selected skills and hooks for Codex CLI and/or Claude Code.
# Usage: install-harness.sh [--engine codex|claude|both] [--skills <profiles>] [--no-hooks] [--uninstall]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE="both"; HOOKS=1; UNINSTALL=0
SKILL_PROFILES="${HARNESS_SKILL_PROFILES:-base}"

usage() {
  echo "Uso: $0 [--engine codex|claude|both] [--skills base|all|python,django,php,react,mysql,postgres,redis] [--no-hooks] [--uninstall]"
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine) ENGINE="${2:?}"; shift 2 ;;
    --skills|--profiles) SKILL_PROFILES="${2:?}"; shift 2 ;;
    --no-hooks) HOOKS=0; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
SKILL_PROFILES="$(printf '%s' "$SKILL_PROFILES" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/postgresql/postgres/g')"

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
HARNESS_HOME="${HARNESS_HOME:-$HOME/.harness}"
HOOKS_DIR="$HARNESS_HOME/hooks"
log() { printf '\n== %s\n' "$*"; }

IFS=',' read -r -a PROFILE_LIST <<< "$SKILL_PROFILES"
has_profile() {
  local wanted="$1" p
  for p in "${PROFILE_LIST[@]}"; do [[ "$p" == "$wanted" ]] && return 0; done
  return 1
}
for p in "${PROFILE_LIST[@]}"; do
  case "$p" in base|all|python|django|php|react|mysql|postgres|redis) ;; *) echo "Perfil de skill inválido: $p" >&2; exit 2 ;; esac
done
skill_selected() {
  local name="$1"
  has_profile all && return 0
  case "$name" in
    flow-*|shared-*) return 0 ;;
    python-*) has_profile python || has_profile django ;;
    django-*) has_profile django ;;
    php-*) has_profile php ;;
    react-*) has_profile react ;;
    mysql-*) has_profile mysql ;;
    postgres-*) has_profile postgres ;;
    redis-*) has_profile redis ;;
    *) return 1 ;;
  esac
}

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
  log "Codex: agentes + skills ($SKILL_PROFILES)"
  HARNESS_SKILL_PROFILES="$SKILL_PROFILES" bash "$ROOT/specialists/install.sh"
fi

if [[ "$ENGINE" == claude || "$ENGINE" == both ]]; then
  log "Claude Code: agentes + skills ($SKILL_PROFILES)"
  mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"
  cp -a "$ROOT"/claude/agents/*.md "$CLAUDE_HOME/agents/"
  installed=0; pruned=0
  for d in "$ROOT"/specialists/skills/*; do
    base="$(basename "$d")"
    dst="$CLAUDE_HOME/skills/$base"
    if skill_selected "$base"; then
      rm -rf "$dst"; cp -a "$d" "$CLAUDE_HOME/skills/"
      installed=$((installed + 1))
    elif [[ -e "$dst" ]]; then
      rm -rf "$dst"
      pruned=$((pruned + 1))
    fi
  done
  echo "Instalados: $(ls "$ROOT"/claude/agents/*.md | wc -l) agentes, $installed skills; removidos do catálogo global: $pruned"
fi

if (( HOOKS )); then
  log "Hooks"
  mkdir -p "$HOOKS_DIR"
  cp -a "$ROOT"/hooks/*.py "$HOOKS_DIR/"
  [[ "$ENGINE" != codex ]] && python3 "$ROOT/scripts/merge_hooks.py" "$CLAUDE_HOME/settings.json" claude "$HOOKS_DIR"
  [[ "$ENGINE" != claude ]] && python3 "$ROOT/scripts/merge_hooks.py" "$CODEX_HOME/hooks.json" codex "$HOOKS_DIR"
fi

cat <<EOF

Pronto.
  Skills instaladas por perfil: $SKILL_PROFILES
  Exemplos:
    ./scripts/install-harness.sh --engine both --skills react,php
    ./scripts/install-harness.sh --engine codex --skills django,postgres,redis
    ./scripts/install-harness.sh --engine both --skills all   # só para projeto realmente multi-stack/lab

Próximos passos:
  1. Reinicie as sessões para redescobrir agentes e skills.
  2. No projeto, copie templates/project/.harness/ e ajuste verify.sh se quiser Stop gate determinístico.
  3. Diagnóstico: ./scripts/verify.sh
EOF
