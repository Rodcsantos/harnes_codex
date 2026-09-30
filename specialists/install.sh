#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CODEX_HOME/backups/dev-specialists-$TS"
SKILL_PROFILES="${HARNESS_SKILL_PROFILES:-base}"
AGENT_PROFILES="${HARNESS_AGENT_PROFILES:-auto}"

usage() {
  cat <<'EOF'
Uso:
  specialists/install.sh [--skills base|all|python,django,php,react,mysql,postgres,redis]
                         [--agents auto|all|core,product,architecture,frontend,backend,mobile,data,qa,security,devops,sre,delivery,dx,fullstack]

Padrões:
  --skills base
  --agents auto

"auto" instala core + agentes correspondentes às stacks de skills escolhidas.
Perfis de agentes podem ser combinados por vírgula.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills|--profiles) SKILL_PROFILES="${2:?}"; shift 2 ;;
    --agents|--agent-profiles) AGENT_PROFILES="${2:?}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argumento desconhecido: $1" >&2; usage >&2; exit 2 ;;
  esac
done

normalize_profiles() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/postgresql/postgres/g'
}
SKILL_PROFILES="$(normalize_profiles "$SKILL_PROFILES")"
AGENT_PROFILES="$(normalize_profiles "$AGENT_PROFILES")"

valid_skill_profile() {
  case "$1" in
    base|all|python|django|php|react|mysql|postgres|redis) return 0 ;;
    *) return 1 ;;
  esac
}
IFS=',' read -r -a PROFILE_LIST <<< "$SKILL_PROFILES"
for p in "${PROFILE_LIST[@]}"; do
  valid_skill_profile "$p" || { echo "Perfil de skill inválido: $p" >&2; usage >&2; exit 2; }
done

has_skill_profile() {
  local wanted="$1" p
  for p in "${PROFILE_LIST[@]}"; do [[ "$p" == "$wanted" ]] && return 0; done
  return 1
}

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
  python3 "$SRC/select_agents.py" --profiles "$AGENT_PROFILES" --skills "$SKILL_PROFILES"
)
declare -A AGENT_WANTED=()
for a in "${SELECTED_AGENTS[@]}"; do AGENT_WANTED["$a"]=1; done

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

agents_installed=0
agents_pruned=0
for f in "$SRC"/agents/*.toml; do
  base="$(basename "$f")"
  stem="${base%.toml}"
  dst="$CODEX_HOME/agents/$base"
  if [[ -n "${AGENT_WANTED[$stem]:-}" ]]; then
    copy_with_backup "$f" "$dst" "$BACKUP/agents/$base"
    agents_installed=$((agents_installed + 1))
  elif [[ -e "$dst" ]]; then
    cp -a "$dst" "$BACKUP/agents/$base"
    rm -f "$dst"
    agents_pruned=$((agents_pruned + 1))
  fi
done

skills_installed=0
skills_pruned=0
for d in "$SRC"/skills/*; do
  base="$(basename "$d")"
  dst="$CODEX_HOME/skills/$base"
  if skill_selected "$base"; then
    copy_with_backup "$d" "$dst" "$BACKUP/skills/$base"
    skills_installed=$((skills_installed + 1))
  elif [[ -e "$dst" ]]; then
    cp -a "$dst" "$BACKUP/skills/$base"
    rm -rf "$dst"
    skills_pruned=$((skills_pruned + 1))
  fi
done

python3 "$SRC/verify.py" "$CODEX_HOME"

echo
echo "Installed Codex dev specialists into: $CODEX_HOME"
echo "Agent profiles: $AGENT_PROFILES | installed: $agents_installed | pruned harness agents: $agents_pruned"
echo "Skill profiles: $SKILL_PROFILES | installed: $skills_installed | pruned harness skills: $skills_pruned"
echo "Backup of replaced/pruned entries: $BACKUP"
echo "Optional multi-agent defaults are in: $SRC/config-snippet.toml"
echo "Restart the Codex CLI/IDE session so agent and skill discovery refreshes."
