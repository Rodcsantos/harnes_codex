#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CODEX_HOME/backups/dev-specialists-$TS"
SKILL_PROFILES="${HARNESS_SKILL_PROFILES:-base}"

usage() {
  cat <<'EOF'
Uso: specialists/install.sh [--skills base|all|python,django,php,react,mysql,postgres,redis]

Padrão: base (flow-* + shared-*).
Perfis podem ser combinados por vírgula. django inclui também python.
HARNESS_SKILL_PROFILES define o mesmo valor por variável de ambiente.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills|--profiles) SKILL_PROFILES="${2:?}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argumento desconhecido: $1" >&2; usage >&2; exit 2 ;;
  esac
done

normalize_profiles() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/postgresql/postgres/g'
}
SKILL_PROFILES="$(normalize_profiles "$SKILL_PROFILES")"

valid_profile() {
  case "$1" in
    base|all|python|django|php|react|mysql|postgres|redis) return 0 ;;
    *) return 1 ;;
  esac
}
IFS=',' read -r -a PROFILE_LIST <<< "$SKILL_PROFILES"
for p in "${PROFILE_LIST[@]}"; do
  valid_profile "$p" || { echo "Perfil de skill inválido: $p" >&2; usage >&2; exit 2; }
done

has_profile() {
  local wanted="$1" p
  for p in "${PROFILE_LIST[@]}"; do [[ "$p" == "$wanted" ]] && return 0; done
  return 1
}

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

installed=0
pruned=0
for d in "$SRC"/skills/*; do
  base="$(basename "$d")"
  dst="$CODEX_HOME/skills/$base"
  if skill_selected "$base"; then
    copy_with_backup "$d" "$dst" "$BACKUP/skills/$base"
    installed=$((installed + 1))
  elif [[ -e "$dst" ]]; then
    mkdir -p "$BACKUP/skills"
    cp -a "$dst" "$BACKUP/skills/$base"
    rm -rf "$dst"
    pruned=$((pruned + 1))
  fi
done

python3 "$SRC/verify.py" "$CODEX_HOME"

echo
echo "Installed Codex dev specialists into: $CODEX_HOME"
echo "Skill profiles: $SKILL_PROFILES | installed: $installed | pruned harness skills: $pruned"
echo "Backup of replaced/pruned entries: $BACKUP"
echo "Optional multi-agent defaults are in: $SRC/config-snippet.toml"
echo "Restart the Codex CLI/IDE session so agent and skill discovery refreshes."
