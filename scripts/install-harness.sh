#!/usr/bin/env bash
# Install selected agents, skills and hooks for Codex CLI and/or Claude Code.
# Usage: install-harness.sh [--engine codex|claude|both] [--skills <profiles>] [--agents <profiles>] [--no-hooks] [--uninstall]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE="both"; HOOKS=1; UNINSTALL=0
SKILL_PROFILES="${HARNESS_SKILL_PROFILES:-base}"
AGENT_PROFILES="${HARNESS_AGENT_PROFILES:-auto}"

usage() {
  cat <<'EOF'
Uso:
  install-harness.sh [--engine codex|claude|both]
                     [--skills base|all|python,django,php,react,mysql,postgres,redis]
                     [--agents auto|all|core,product,architecture,frontend,backend,mobile,data,qa,security,devops,sre,delivery,dx,fullstack]
                     [--no-hooks] [--uninstall]

Padrões: --engine both --skills base --agents auto
EOF
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine) ENGINE="${2:?}"; shift 2 ;;
    --skills|--profiles) SKILL_PROFILES="${2:?}"; shift 2 ;;
    --agents|--agent-profiles) AGENT_PROFILES="${2:?}"; shift 2 ;;
    --no-hooks) HOOKS=0; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

normalize() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/postgresql/postgres/g'
}
SKILL_PROFILES="$(normalize "$SKILL_PROFILES")"
AGENT_PROFILES="$(normalize "$AGENT_PROFILES")"

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
HARNESS_HOME="${HARNESS_HOME:-$HOME/.harness}"
HOOKS_DIR="$HARNESS_HOME/hooks"
log() { printf '\n== %s\n' "$*"; }

IFS=',' read -r -a PROFILE_LIST <<< "$SKILL_PROFILES"
has_skill_profile() {
  local wanted="$1" p
  for p in "${PROFILE_LIST[@]}"; do [[ "$p" == "$wanted" ]] && return 0; done
  return 1
}
for p in "${PROFILE_LIST[@]}"; do
  case "$p" in base|all|python|django|php|react|mysql|postgres|redis) ;; *) echo "Perfil de skill inválido: $p" >&2; exit 2 ;; esac
done
skill_selected() {
  local name="$1"
  has_skill_profile all && return 0
  case "$name" in
    flow-*|shared-*) return 0 ;;
    python-*) has_skill_profile python || has_skill_profile django ;;
    django-*) has_skill_profile django ;;
    php-*) has_skill_profile php ;;
    react-*) has_skill_profile react ;;
    mysql-*) has_skill_profile mysql ;;
    postgres-*) has_skill_profile postgres ;;
    redis-*) has_skill_profile redis ;;
    *) return 1 ;;
  esac
}

mapfile -t SELECTED_AGENTS < <(
  python3 "$ROOT/specialists/select_agents.py" --profiles "$AGENT_PROFILES" --skills "$SKILL_PROFILES"
)
declare -A AGENT_WANTED=()
for a in "${SELECTED_AGENTS[@]}"; do AGENT_WANTED["$a"]=1; done

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
  log "Codex: agentes ($AGENT_PROFILES) + skills ($SKILL_PROFILES)"
  HARNESS_SKILL_PROFILES="$SKILL_PROFILES" HARNESS_AGENT_PROFILES="$AGENT_PROFILES" \
    bash "$ROOT/specialists/install.sh"
fi

if [[ "$ENGINE" == claude || "$ENGINE" == both ]]; then
  log "Claude Code: agentes ($AGENT_PROFILES) + skills ($SKILL_PROFILES)"
  mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"
  agents_installed=0; agents_pruned=0
  for src in "$ROOT"/specialists/agents/*.toml; do
    stem="$(basename "$src" .toml)"
    dst="$CLAUDE_HOME/agents/$stem.md"
    if [[ -n "${AGENT_WANTED[$stem]:-}" ]]; then
      cp -a "$ROOT/claude/agents/$stem.md" "$dst"
      agents_installed=$((agents_installed + 1))
    elif [[ -e "$dst" ]]; then
      rm -f "$dst"
      agents_pruned=$((agents_pruned + 1))
    fi
  done

  skills_installed=0; skills_pruned=0
  for d in "$ROOT"/specialists/skills/*; do
    base="$(basename "$d")"
    dst="$CLAUDE_HOME/skills/$base"
    if skill_selected "$base"; then
      rm -rf "$dst"; cp -a "$d" "$CLAUDE_HOME/skills/"
      skills_installed=$((skills_installed + 1))
    elif [[ -e "$dst" ]]; then
      rm -rf "$dst"
      skills_pruned=$((skills_pruned + 1))
    fi
  done
  echo "Agentes: $agents_installed instalados / $agents_pruned removidos do catálogo global"
  echo "Skills: $skills_installed instaladas / $skills_pruned removidas do catálogo global"
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
  Agent profiles: $AGENT_PROFILES
  Skill profiles: $SKILL_PROFILES

Exemplos:
  # React + PHP, apenas core + especialistas inferidos:
  ./scripts/install-harness.sh --engine both --skills react,php

  # Produto + arquitetura + frontend:
  ./scripts/install-harness.sh --engine both --skills react --agents product,architecture,frontend

  # Backend Django/Postgres com QA e segurança:
  ./scripts/install-harness.sh --engine both --skills django,postgres --agents backend,data,qa,security

  # Infra/SRE:
  ./scripts/install-harness.sh --engine both --agents devops,sre,security

  # Catálogo inteiro (laboratório):
  ./scripts/install-harness.sh --engine both --skills all --agents all

Reinicie as sessões para redescobrir agentes e skills.
EOF
