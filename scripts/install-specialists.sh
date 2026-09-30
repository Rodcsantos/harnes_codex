#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$ROOT/specialists"

if [[ -d "$PACKAGE_DIR/skills" && -f "$PACKAGE_DIR/install.sh" ]]; then
  exec bash "$PACKAGE_DIR/install.sh" "$@"
fi

echo "Pacote specialists incompleto: esperado specialists/install.sh e specialists/skills/." >&2
exit 1
