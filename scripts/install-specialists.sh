#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$ROOT/specialists"

if [[ -d "$PACKAGE_DIR/skills" && -x "$PACKAGE_DIR/install.sh" ]]; then
  exec "$PACKAGE_DIR/install.sh"
fi

echo "A árvore specialists/skills ainda não está expandida neste checkout." >&2
echo "Use o pacote original recuperado ou restaure-o conforme docs/SOURCE-MANIFEST.md." >&2
exit 1