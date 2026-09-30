#!/usr/bin/env bash
set -Eeuo pipefail

# Codex Efficient Stack v2
# Ubuntu/WSL-first, token-efficient Codex environment.
#
# Installs/configures:
#   - OpenAI Codex CLI
#   - RTK (transparent Bash output compression via Codex PreToolUse hook)
#   - ast-grep (fast syntax-aware structural search/rewrite, no prompt overhead)
#   - Atlas (token-budgeted repository maps)
#   - SigMap (signature/evidence based code retrieval)
#   - Serena (semantic/LSP navigation and refactoring)
#   - mcp2cli (lazy MCP discovery/invocation)
#   - Headroom (optional context compression wrapper)
#   - Tokview (token observability)
#   - A progressive Codex skill + tiny global AGENTS.md policy
#   - Optional migration of compatible native Codex stdio MCPs to mcp2cli
#   - Rollback/report/doctor/update helper commands
#
# Safety policy for MCP migration:
#   * Migration is opt-in (HARNESS_MIGRATE_MCP=1 / codex-mcp-migrate).
#   * Only local stdio MCPs are eligible.
#   * HTTP/OAuth MCPs stay native in Codex.
#   * Required/remote-environment MCPs stay native.
#   * MCPs with explicit Codex approval policies stay native.
#   * Every change is backed up and reversible.

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  command -v sudo >/dev/null 2>&1 || die "sudo não encontrado."
  SUDO="sudo"
fi

HOME_BIN="$HOME/.local/bin"
SRC_DIR="$HOME/.local/src"
STACK_DIR="$HOME/.local/share/codex-efficient-stack"
STACK_VENV="$STACK_DIR/venv"
MCP_WRAPPERS_DIR="$STACK_DIR/mcp-wrappers"
MCP2CLI_DIR="$SRC_DIR/mcp2cli"
MCP2CLI_CFG_DIR="$HOME/.config/mcp2cli"
MCP2CLI_CFG="$MCP2CLI_CFG_DIR/services.json"
MCP2CLI_CREDS="$MCP2CLI_CFG_DIR/credentials.json"
MIGRATION_MANIFEST="$MCP2CLI_CFG_DIR/codex-migration-manifest.json"
MIGRATION_REPORT="$MCP2CLI_CFG_DIR/codex-migration-report.json"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CODEX_CONFIG="$CODEX_HOME_DIR/config.toml"
GLOBAL_AGENTS="$CODEX_HOME_DIR/AGENTS.md"
SKILL_DIR="$HOME/.agents/skills/token-efficient-coding"
SKILL_REFS="$SKILL_DIR/references"

mkdir -p \
  "$HOME_BIN" "$SRC_DIR" "$STACK_DIR" "$MCP_WRAPPERS_DIR" \
  "$MCP2CLI_CFG_DIR" "$CODEX_HOME_DIR" "$SKILL_REFS"

export PATH="$HOME_BIN:$HOME/.bun/bin:$PATH"

ensure_bashrc_line() {
  local line="$1"
  touch "$HOME/.bashrc"
  grep -Fqx "$line" "$HOME/.bashrc" 2>/dev/null || printf '\n%s\n' "$line" >> "$HOME/.bashrc"
}

ensure_bashrc_line 'export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"'

log "Dependências base e ferramentas de busca compacta"
$SUDO apt-get update
$SUDO apt-get install -y --no-install-recommends \
  ca-certificates curl git unzip jq xz-utils build-essential \
  python3 ripgrep fd-find procps

# Ubuntu/Debian ships fd as fdfind. Add a user-local fd alias without touching system files.
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  ln -sfn "$(command -v fdfind)" "$HOME_BIN/fd"
fi
ok "Base pronta: git/jq/rg/fd/python"

log "OpenAI Codex CLI"
if ! command -v codex >/dev/null 2>&1; then
  curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
  export PATH="$HOME_BIN:$PATH"
else
  ok "Codex já instalado: $(command -v codex)"
fi
command -v codex >/dev/null 2>&1 || die "Codex não apareceu no PATH. Abra um novo shell e rode novamente."
codex --version 2>/dev/null || true

log "uv + Python 3.13 isolado"
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME_BIN:$PATH"
fi
command -v uv >/dev/null 2>&1 || die "uv não encontrado após instalação."
uv python install 3.13 >/dev/null 2>&1 || true
uv --version

log "ast-grep - busca estrutural rápida sem carregar MCP/LSP"
if command -v ast-grep >/dev/null 2>&1; then
  uv tool upgrade ast-grep-cli >/dev/null 2>&1 || true
else
  uv tool install --python 3.13 ast-grep-cli
fi
command -v ast-grep >/dev/null 2>&1 || die "ast-grep não encontrado."
ast-grep --version 2>/dev/null || true

log "Runtime auxiliar do stack (tomlkit para migração reversível do config.toml)"
if [[ ! -x "$STACK_VENV/bin/python" ]]; then
  uv venv --python 3.13 "$STACK_VENV"
fi
uv pip install --python "$STACK_VENV/bin/python" --upgrade tomlkit >/dev/null
STACK_PY="$STACK_VENV/bin/python"

log "Bun (build do mcp2cli)"
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.com/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
fi
command -v bun >/dev/null 2>&1 || die "Bun não encontrado após instalação."
bun --version

log "RTK - compressão transparente de saída do terminal"
if command -v rtk >/dev/null 2>&1 && rtk gain >/dev/null 2>&1; then
  ok "RTK correto já está instalado"
else
  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
  export PATH="$HOME_BIN:$PATH"
fi
command -v rtk >/dev/null 2>&1 || die "rtk não encontrado."
rtk gain >/dev/null 2>&1 || die "O rtk no PATH não parece ser o Rust Token Killer (rtk-ai/rtk)."
# Current RTK Codex adapter uses a native Codex PreToolUse hook and an awareness block.
if ! rtk init -g --codex --auto-patch; then
  warn "RTK não aceitou --auto-patch; tentando integração Codex padrão."
  rtk init -g --codex || warn "RTK instalado, mas a integração automática com Codex falhou. Rode depois: rtk init -g --codex"
fi
rtk init --show --codex 2>/dev/null || true

log "Atlas - mapa de repositório com orçamento de tokens"
if command -v atlas >/dev/null 2>&1; then
  uv tool upgrade atlas-map >/dev/null 2>&1 || true
else
  uv tool install --python 3.13 --prerelease allow atlas-map
fi
command -v atlas >/dev/null 2>&1 || die "atlas não encontrado."
atlas --version

log "SigMap - assinaturas/evidências em vez de leituras integrais"
case "$(uname -m)" in
  x86_64|amd64) SIGMAP_ASSET="sigmap-linux-x64" ;;
  aarch64|arm64) SIGMAP_ASSET="sigmap-linux-arm64" ;;
  *) die "Arquitetura não suportada automaticamente para SigMap: $(uname -m)" ;;
esac
if ! command -v sigmap >/dev/null 2>&1; then
  curl -fL "https://github.com/manojmallick/sigmap/releases/latest/download/${SIGMAP_ASSET}" -o "$HOME_BIN/sigmap.tmp"
  chmod +x "$HOME_BIN/sigmap.tmp"
  mv -f "$HOME_BIN/sigmap.tmp" "$HOME_BIN/sigmap"
else
  # Refresh to latest; if asset naming changes, keep the working installed copy.
  if curl -fL "https://github.com/manojmallick/sigmap/releases/latest/download/${SIGMAP_ASSET}" -o "$HOME_BIN/sigmap.tmp"; then
    chmod +x "$HOME_BIN/sigmap.tmp"
    mv -f "$HOME_BIN/sigmap.tmp" "$HOME_BIN/sigmap"
  else
    rm -f "$HOME_BIN/sigmap.tmp"
    warn "Não foi possível atualizar SigMap; mantendo a versão instalada."
  fi
fi
sigmap --version

log "Serena - navegação semântica/LSP sob demanda"
if command -v serena >/dev/null 2>&1; then
  uv tool upgrade serena-agent >/dev/null 2>&1 || true
else
  uv tool install --python 3.13 serena-agent
fi
command -v serena >/dev/null 2>&1 || die "serena não encontrado."
# Initialise, but never block the whole installer if a language backend needs local interaction.
timeout 120 serena init >/dev/null 2>&1 || warn "Serena instalada; inicialização automática não concluiu. O uso via MCP ainda será configurado."

log "Headroom - compressão opcional do contexto"
if command -v headroom >/dev/null 2>&1; then
  headroom update >/dev/null 2>&1 || uv tool upgrade headroom-ai >/dev/null 2>&1 || true
else
  uv tool install --python 3.13 'headroom-ai[all]'
fi
command -v headroom >/dev/null 2>&1 || warn "Headroom não ficou disponível; o restante do stack continuará funcional."

log "Tokview - observabilidade de tokens"
if command -v tokview >/dev/null 2>&1; then
  uv tool upgrade token-viewer >/dev/null 2>&1 || true
else
  uv tool install --python 3.13 token-viewer
fi
command -v tokview >/dev/null 2>&1 || warn "Tokview não ficou disponível."
tokview version 2>/dev/null || true

log "mcp2cli - MCPs como CLI lazy, sem schemas permanentes no prompt"
if [[ -d "$MCP2CLI_DIR/.git" ]]; then
  git -C "$MCP2CLI_DIR" fetch --all --prune
  git -C "$MCP2CLI_DIR" pull --ff-only
else
  rm -rf "$MCP2CLI_DIR"
  git clone https://github.com/rodaddy/mcp2cli.git "$MCP2CLI_DIR"
fi
(
  cd "$MCP2CLI_DIR"
  bun install
  bun run build
)
[[ -e "$MCP2CLI_DIR/dist/mcp2cli" ]] || die "Build do mcp2cli não gerou dist/mcp2cli."
ln -sfn "$MCP2CLI_DIR/dist/mcp2cli" "$HOME_BIN/mcp2cli"
chmod +x "$MCP2CLI_DIR/dist/mcp2cli" 2>/dev/null || true

if [[ -f "$MCP2CLI_CFG" ]]; then
  jq empty "$MCP2CLI_CFG" || die "$MCP2CLI_CFG existe mas não contém JSON válido."
  cp -a "$MCP2CLI_CFG" "$MCP2CLI_CFG.bak.$(date +%Y%m%d%H%M%S)"
else
  printf '{"services":{}}\n' > "$MCP2CLI_CFG"
fi
chmod 600 "$MCP2CLI_CFG"

log "Registrando SigMap e Serena atrás do mcp2cli"
SIGMAP_CMD="$(command -v sigmap)"
SERENA_CMD="$(command -v serena)"
TMP_CFG="$(mktemp)"
jq \
  --arg sigmap "$SIGMAP_CMD" \
  --arg serena "$SERENA_CMD" \
  '.services = (.services // {})
   | .services.sigmap = {
       "description": "[codex-efficient] SigMap signatures/evidence; invoke only on demand",
       "backend": "stdio",
       "command": $sigmap,
       "args": ["--mcp"]
     }
   | .services.serena = {
       "description": "[codex-efficient] Serena semantic navigation/refactoring; invoke only on demand",
       "backend": "stdio",
       "command": $serena,
       "args": ["start-mcp-server", "--project-from-cwd", "--context=codex"]
     }' \
  "$MCP2CLI_CFG" > "$TMP_CFG"
mv "$TMP_CFG" "$MCP2CLI_CFG"
chmod 600 "$MCP2CLI_CFG"

log "Criando migrador seguro Codex MCP -> mcp2cli"
cat > "$STACK_DIR/migrate_codex_mcps.py" <<'PY'
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shlex
import shutil
import stat
from datetime import datetime, timezone
from pathlib import Path

import tomlkit


def unwrap(value):
    return value.unwrap() if hasattr(value, "unwrap") else value


def now():
    return datetime.now(timezone.utc).isoformat()


def load_json(path: Path, default):
    if not path.exists():
        return default
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def write_json(path: Path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(value, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.chmod(tmp, 0o600)
    tmp.replace(path)


def write_cwd_wrapper(wrappers_dir: Path, name: str, cwd: str, command: str) -> Path:
    wrappers_dir.mkdir(parents=True, exist_ok=True)
    safe_name = "".join(c if c.isalnum() or c in "-_" else "_" for c in name)
    path = wrappers_dir / f"{safe_name}.sh"
    content = (
        "#!/usr/bin/env bash\n"
        "set -euo pipefail\n"
        f"cd -- {shlex.quote(cwd)}\n"
        f"exec {shlex.quote(command)} \"$@\"\n"
    )
    path.write_text(content, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR)
    return path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--services", required=True)
    ap.add_argument("--manifest", required=True)
    ap.add_argument("--report", required=True)
    ap.add_argument("--wrappers", required=True)
    args = ap.parse_args()

    config_path = Path(args.config).expanduser()
    services_path = Path(args.services).expanduser()
    manifest_path = Path(args.manifest).expanduser()
    report_path = Path(args.report).expanduser()
    wrappers_dir = Path(args.wrappers).expanduser()

    report = {
        "timestamp": now(),
        "config": str(config_path),
        "migrated": [],
        "copied_disabled": [],
        "skipped": [],
        "backup": None,
    }

    if not config_path.exists():
        report["skipped"].append({"name": "*", "reason": "Codex config.toml ainda não existe"})
        write_json(report_path, report)
        print(json.dumps(report, indent=2, ensure_ascii=False))
        return

    text = config_path.read_text(encoding="utf-8")
    doc = tomlkit.parse(text)
    servers = doc.get("mcp_servers")
    if not servers:
        report["skipped"].append({"name": "*", "reason": "Nenhum mcp_servers encontrado no Codex"})
        write_json(report_path, report)
        print(json.dumps(report, indent=2, ensure_ascii=False))
        return

    services_doc = load_json(services_path, {"services": {}})
    services_doc.setdefault("services", {})
    manifest = load_json(manifest_path, {"version": 1, "entries": {}, "history": []})
    manifest.setdefault("entries", {})
    manifest.setdefault("history", [])

    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    backup = config_path.with_name(config_path.name + f".pre-lazy-mcp.{timestamp}.bak")
    shutil.copy2(config_path, backup)
    report["backup"] = str(backup)

    changed_codex = False
    changed_services = False

    for name, server in list(servers.items()):
        try:
            enabled = bool(unwrap(server.get("enabled", True)))
            command = unwrap(server.get("command")) if server.get("command") is not None else None
            url = unwrap(server.get("url")) if server.get("url") is not None else None

            if url:
                report["skipped"].append({
                    "name": name,
                    "reason": "HTTP/Streamable HTTP mantido nativo para preservar OAuth/bearer/header helpers do Codex",
                })
                continue

            if not command:
                report["skipped"].append({"name": name, "reason": "Transporte não reconhecido/sem command"})
                continue

            if str(unwrap(server.get("experimental_environment", ""))).lower() == "remote":
                report["skipped"].append({"name": name, "reason": "Servidor stdio remoto não é equivalente no mcp2cli local"})
                continue

            if bool(unwrap(server.get("required", False))):
                report["skipped"].append({"name": name, "reason": "required=true; mantido nativo para preservar semântica de inicialização"})
                continue

            if server.get("default_tools_approval_mode") is not None or server.get("tools") is not None:
                report["skipped"].append({"name": name, "reason": "Política explícita de aprovação por MCP/tool; não migrada para não alterar segurança"})
                continue

            # Avoid clobbering an unrelated existing mcp2cli service with the same name.
            existing = services_doc["services"].get(name)
            managed_existing = (
                isinstance(existing, dict)
                and str(existing.get("description", "")).startswith("[codex-efficient]")
            )
            if existing is not None and not managed_existing and name not in {"sigmap", "serena"}:
                report["skipped"].append({"name": name, "reason": "Já existe serviço mcp2cli com mesmo nome; preservado sem sobrescrever"})
                continue

            service_command = str(command)
            cwd = unwrap(server.get("cwd")) if server.get("cwd") is not None else None
            if cwd:
                service_command = str(write_cwd_wrapper(wrappers_dir, name, str(cwd), str(command)))

            service = {
                "description": f"[codex-efficient] Migrated from Codex stdio MCP '{name}' for lazy loading",
                "backend": "stdio",
                "command": service_command,
                "args": list(unwrap(server.get("args", [])) or []),
            }

            env = unwrap(server.get("env", {})) if server.get("env") is not None else {}
            if env:
                service["env"] = dict(env)

            enabled_tools = unwrap(server.get("enabled_tools", [])) if server.get("enabled_tools") is not None else []
            disabled_tools = unwrap(server.get("disabled_tools", [])) if server.get("disabled_tools") is not None else []
            if enabled_tools:
                service["allowTools"] = list(enabled_tools)
            if disabled_tools:
                service["blockTools"] = list(disabled_tools)

            services_doc["services"][name] = service
            changed_services = True

            entry = {
                "name": name,
                "transport": "stdio",
                "previous_enabled": enabled,
                "migrated_at": now(),
                "codex_config": str(config_path),
                "service_managed": True,
            }
            manifest["entries"][name] = entry

            if enabled:
                server["enabled"] = False
                changed_codex = True
                report["migrated"].append({
                    "name": name,
                    "action": "copiado para mcp2cli e desativado no catálogo MCP nativo do Codex",
                })
            else:
                report["copied_disabled"].append({
                    "name": name,
                    "action": "copiado para mcp2cli; já estava disabled no Codex",
                })

        except Exception as exc:
            report["skipped"].append({"name": name, "reason": f"erro ao migrar: {exc}"})

    if changed_codex:
        tmp = config_path.with_suffix(config_path.suffix + ".tmp")
        tmp.write_text(tomlkit.dumps(doc), encoding="utf-8")
        tmp.replace(config_path)

    if changed_services:
        write_json(services_path, services_doc)

    manifest["history"].append({
        "timestamp": now(),
        "backup": str(backup),
        "migrated": [x["name"] for x in report["migrated"]],
        "copied_disabled": [x["name"] for x in report["copied_disabled"]],
    })
    write_json(manifest_path, manifest)
    write_json(report_path, report)
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
PY
chmod +x "$STACK_DIR/migrate_codex_mcps.py"

cat > "$STACK_DIR/restore_codex_mcps.py" <<'PY'
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shutil
from datetime import datetime
from pathlib import Path

import tomlkit


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--services", required=True)
    ap.add_argument("--manifest", required=True)
    args = ap.parse_args()

    config_path = Path(args.config).expanduser()
    services_path = Path(args.services).expanduser()
    manifest_path = Path(args.manifest).expanduser()

    if not manifest_path.exists():
        print("Nenhum manifesto de migração encontrado; nada a restaurar.")
        return
    if not config_path.exists():
        raise SystemExit(f"Config Codex não encontrado: {config_path}")

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    entries = manifest.get("entries", {})
    if not entries:
        print("Manifesto sem MCPs migrados; nada a restaurar.")
        return

    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    backup = config_path.with_name(config_path.name + f".pre-restore-lazy-mcp.{timestamp}.bak")
    shutil.copy2(config_path, backup)

    doc = tomlkit.parse(config_path.read_text(encoding="utf-8"))
    servers = doc.get("mcp_servers")
    restored = []
    if servers:
        for name, entry in entries.items():
            if name in servers:
                servers[name]["enabled"] = bool(entry.get("previous_enabled", True))
                restored.append(name)

    tmp = config_path.with_suffix(config_path.suffix + ".tmp")
    tmp.write_text(tomlkit.dumps(doc), encoding="utf-8")
    tmp.replace(config_path)

    if services_path.exists():
        services = json.loads(services_path.read_text(encoding="utf-8"))
        svc = services.get("services", {})
        for name in restored:
            # Keep core on-demand tools even after restoring native MCPs.
            if name in {"sigmap", "serena"}:
                continue
            value = svc.get(name)
            if isinstance(value, dict) and str(value.get("description", "")).startswith("[codex-efficient] Migrated from Codex"):
                svc.pop(name, None)
        temp = services_path.with_suffix(services_path.suffix + ".tmp")
        temp.write_text(json.dumps(services, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        os.chmod(temp, 0o600)
        temp.replace(services_path)

    print("MCPs restaurados no catálogo nativo do Codex:", ", ".join(restored) if restored else "nenhum")
    print("Backup antes do restore:", backup)


if __name__ == "__main__":
    main()
PY
chmod +x "$STACK_DIR/restore_codex_mcps.py"

log "Criando comandos de gerenciamento MCP lazy"
cat > "$HOME_BIN/codex-mcp-migrate" <<EOF2
#!/usr/bin/env bash
set -euo pipefail
exec "$STACK_PY" "$STACK_DIR/migrate_codex_mcps.py" \\
  --config "${CODEX_CONFIG}" \\
  --services "${MCP2CLI_CFG}" \\
  --manifest "${MIGRATION_MANIFEST}" \\
  --report "${MIGRATION_REPORT}" \\
  --wrappers "${MCP_WRAPPERS_DIR}"
EOF2
chmod +x "$HOME_BIN/codex-mcp-migrate"

cat > "$HOME_BIN/codex-mcp-restore" <<EOF2
#!/usr/bin/env bash
set -euo pipefail
exec "$STACK_PY" "$STACK_DIR/restore_codex_mcps.py" \\
  --config "${CODEX_CONFIG}" \\
  --services "${MCP2CLI_CFG}" \\
  --manifest "${MIGRATION_MANIFEST}"
EOF2
chmod +x "$HOME_BIN/codex-mcp-restore"

cat > "$HOME_BIN/codex-mcp-report" <<EOF2
#!/usr/bin/env bash
set -euo pipefail
REPORT="${MIGRATION_REPORT}"
if [[ ! -f "\$REPORT" ]]; then
  echo "Nenhum relatório ainda. Rode: codex-mcp-migrate"
  exit 0
fi
jq . "\$REPORT"
EOF2
chmod +x "$HOME_BIN/codex-mcp-report"

cat > "$HOME_BIN/mcpq" <<'EOF2'
#!/usr/bin/env bash
set -euo pipefail
usage() {
  cat <<'TXT'
Uso:
  mcpq list
  mcpq search <regex>
  mcpq tools <service>
  mcpq schema <service> <tool>
  mcpq call <service> <tool> '<json>' [--fields 'a,b,c']
  mcpq cache

Atalhos para mcp2cli com descoberta lazy.
TXT
}
[[ $# -gt 0 ]] || { usage; exit 0; }
case "$1" in
  list)   exec mcp2cli services ;;
  search) shift; exec mcp2cli grep "$@" ;;
  tools)  [[ $# -eq 2 ]] || { usage; exit 2; }; exec mcp2cli "$2" --help ;;
  schema) [[ $# -eq 3 ]] || { usage; exit 2; }; exec mcp2cli schema "$2.$3" ;;
  call)
    [[ $# -ge 4 ]] || { usage; exit 2; }
    service="$2"; tool="$3"; params="$4"; shift 4
    exec mcp2cli "$service" "$tool" --params "$params" "$@"
    ;;
  cache) exec mcp2cli cache status ;;
  *) usage; exit 2 ;;
esac
EOF2
chmod +x "$HOME_BIN/mcpq"

log "Migração MCP lazy (opt-in)"
if [[ "${HARNESS_MIGRATE_MCP:-0}" == "1" ]]; then
  "$HOME_BIN/codex-mcp-migrate" || warn "Migração encontrou um problema; configuração original foi preservada/backupeada. Veja codex-mcp-report."
else
  ok "MCPs nativos preservados. Para migrar stdio compatível após medir necessidade: HARNESS_MIGRATE_MCP=1 codex-mcp-migrate"
fi

log "Skill progressiva: token-efficient-coding"
cat > "$SKILL_DIR/SKILL.md" <<'SKILL'
---
name: token-efficient-coding
description: Use only when explicitly optimizing or diagnosing Codex context/token usage, repository-read overhead, or MCP/tool-schema overhead. Do not invoke for ordinary coding tasks.
---

Minimize context without sacrificing correctness.

1. Shell output
- RTK is installed through Codex PreToolUse; let it compact supported commands automatically.
- Prefer `rg`, targeted ranges, diffs, summaries, and failing-test output over full dumps.
- Never use broad `cat`, recursive log dumps, or huge `find` output when a narrower query answers the task.

2. Repository orientation
- In an unfamiliar/large repo, choose **Atlas or SigMap**, not both by default.
- Use Atlas for a small token-budgeted structural map; use SigMap when signatures/evidence answer the question more directly.
- Raise budgets only when the task requires it; treat generated maps as indexes, not source-of-truth code.

3. Code retrieval
- Prefer Serena only when semantic symbol/reference/LSP operations materially help beyond grep/Atlas/SigMap.
- Both are available lazily through `mcpq`/`mcp2cli`; do not register or dump their schemas into context preemptively.

4. External MCPs
- Native stdio MCPs are preserved by default. Use `mcpq` only for services you explicitly migrated because native discovery was measured to cost more context.
- Then use `mcpq search <term>` or `mcpq tools <service>`.
- Inspect only the chosen tool with `mcpq schema <service> <tool>`.
- Call it with `mcpq call <service> <tool> '<json>'` and use `--fields` when only a few output fields matter.
- HTTP/OAuth MCPs that need Codex authentication remain native and can be used normally.

5. Context hygiene
- Read the smallest useful line/symbol range.
- Do not reread unchanged content already present in the active context.
- After edits, inspect the diff and affected tests instead of reopening entire files.
- Keep final output concise unless detail is requested.

See `references/mcp-lazy.md` only when you need detailed mcp2cli syntax or migration behavior.
SKILL

cat > "$SKILL_REFS/mcp-lazy.md" <<'REF'
# Lazy MCP reference

The stack uses `mcp2cli` so local stdio MCP tool schemas do not sit permanently in Codex context.

Commands:

```bash
mcpq list
mcpq search 'github|docs|browser'
mcpq tools <service>
mcpq schema <service> <tool>
mcpq call <service> <tool> '{"key":"value"}'
mcpq call <service> <tool> '{}' --fields 'id,name,status'
mcpq cache
```

Migration helpers:

```bash
codex-mcp-migrate   # discover new compatible stdio MCPs in ~/.codex/config.toml
codex-mcp-report    # show exactly what was migrated/skipped and the backup path
codex-mcp-restore   # re-enable migrated native MCPs and remove migration copies
```

Migration intentionally leaves these native:
- Streamable HTTP/HTTP MCPs, to preserve Codex OAuth/bearer/header-helper behavior.
- `required=true` servers.
- stdio servers using a remote execution environment.
- servers with explicit Codex per-tool/default approval policies.

`enabled_tools` and `disabled_tools` on compatible stdio servers map to mcp2cli `allowTools` and `blockTools`.
REF
ok "Skill criada em $SKILL_DIR"

log "Política global mínima do Codex (sem inflar AGENTS.md)"
touch "$GLOBAL_AGENTS"
# Remove only our own previous managed block, preserving the user's existing instructions.
"$STACK_PY" - "$GLOBAL_AGENTS" <<'PY'
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8') if p.exists() else ''
s = re.sub(r'\n?# BEGIN CODEX-EFFICIENT\n.*?# END CODEX-EFFICIENT\n?', '\n', s, flags=re.S)
block = '''# BEGIN CODEX-EFFICIENT
## Efficient development context
- Keep repository reads targeted: exact symbols/ranges/diffs first; use Atlas or SigMap only when orientation is actually needed.
- Prefer native deferred tool discovery when available. Use `mcpq` only for services intentionally migrated after measuring schema/context overhead.
# END CODEX-EFFICIENT
'''
s = s.rstrip() + ('\n\n' if s.strip() else '') + block
p.write_text(s, encoding='utf-8')
PY

log "Wrappers de uso e métricas"
cat > "$HOME_BIN/codex-lean" <<'EOF2'
#!/usr/bin/env bash
set -euo pipefail
if ! command -v headroom >/dev/null 2>&1; then
  echo "headroom não está disponível; iniciando codex normal." >&2
  exec codex "$@"
fi
if [[ $# -eq 0 ]]; then
  exec headroom wrap codex
else
  exec headroom wrap codex -- "$@"
fi
EOF2
chmod +x "$HOME_BIN/codex-lean"

cat > "$HOME_BIN/codex-metrics" <<'EOF2'
#!/usr/bin/env bash
set -euo pipefail
if ! command -v tokview >/dev/null 2>&1; then
  echo "tokview não está disponível." >&2
  exit 1
fi
exec tokview wrap codex "$@"
EOF2
chmod +x "$HOME_BIN/codex-metrics"

cat > "$HOME_BIN/codex-savings" <<'EOF2'
#!/usr/bin/env bash
set -u
printf '\n=== RTK ===\n'
rtk gain --history 2>/dev/null || rtk gain 2>/dev/null || true
printf '\n=== Headroom ===\n'
headroom savings 2>/dev/null || headroom perf 2>/dev/null || true
printf '\n=== Tokview ===\n'
if command -v tokview >/dev/null 2>&1; then
  tokview import codex >/dev/null 2>&1 || true
  tokview show --latest 2>/dev/null || tokview status 2>/dev/null || true
fi
EOF2
chmod +x "$HOME_BIN/codex-savings"

cat > "$HOME_BIN/codex-efficient-doctor" <<EOF2
#!/usr/bin/env bash
set -u
fail=0
check() {
  local cmd="\$1"
  if command -v "\$cmd" >/dev/null 2>&1; then
    printf '[ok] %-18s %s\n' "\$cmd" "\$(command -v "\$cmd")"
  else
    printf '[x]  %-18s missing\n' "\$cmd"
    fail=1
  fi
}
for c in codex rtk ast-grep atlas sigmap serena mcp2cli mcpq headroom tokview rg fd; do check "\$c"; done
printf '\n-- RTK/Codex hook --\n'
rtk init --show --codex 2>/dev/null || true
printf '\n-- MCP lazy services --\n'
mcp2cli services 2>/dev/null || true
printf '\n-- MCP migration report --\n'
if [[ -f "${MIGRATION_REPORT}" ]]; then
  jq '{migrated, copied_disabled, skipped, backup}' "${MIGRATION_REPORT}" 2>/dev/null || true
else
  echo 'No migration report yet.'
fi
printf '\n-- Codex native MCP catalog --\n'
codex mcp list 2>/dev/null || true
printf '\n-- Atlas --\n'
atlas doctor 2>/dev/null || true
exit "\$fail"
EOF2
chmod +x "$HOME_BIN/codex-efficient-doctor"

# Save a copy of this installer for easy refreshes when rerun from the downloaded artifact.
SELF_PATH="$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")"
if [[ -f "$SELF_PATH" ]]; then
  cp -f "$SELF_PATH" "$STACK_DIR/install.sh"
  chmod +x "$STACK_DIR/install.sh"
fi
cat > "$HOME_BIN/codex-efficient-update" <<EOF2
#!/usr/bin/env bash
set -euo pipefail
INSTALLER="${STACK_DIR}/install.sh"
if [[ ! -x "\$INSTALLER" ]]; then
  echo "Instalador salvo não encontrado: \$INSTALLER" >&2
  exit 1
fi
exec "\$INSTALLER"
EOF2
chmod +x "$HOME_BIN/codex-efficient-update"

log "Verificação final"
printf '%-22s %s\n' "codex" "$(command -v codex || echo MISSING)"
printf '%-22s %s\n' "rtk" "$(command -v rtk || echo MISSING)"
printf '%-22s %s\n' "atlas" "$(command -v atlas || echo MISSING)"
printf '%-22s %s\n' "sigmap" "$(command -v sigmap || echo MISSING)"
printf '%-22s %s\n' "serena" "$(command -v serena || echo MISSING)"
printf '%-22s %s\n' "mcp2cli" "$(command -v mcp2cli || echo MISSING)"
printf '%-22s %s\n' "mcpq" "$(command -v mcpq || echo MISSING)"
printf '%-22s %s\n' "headroom" "$(command -v headroom || echo MISSING)"
printf '%-22s %s\n' "tokview" "$(command -v tokview || echo MISSING)"
printf '%-22s %s\n' "codex-lean" "$(command -v codex-lean || echo MISSING)"
printf '%-22s %s\n' "codex-metrics" "$(command -v codex-metrics || echo MISSING)"
printf '%-22s %s\n' "codex-mcp-migrate" "$(command -v codex-mcp-migrate || echo MISSING)"
printf '%-22s %s\n' "codex-efficient-doctor" "$(command -v codex-efficient-doctor || echo MISSING)"

printf '\nMCP migration summary:\n'
if [[ -f "$MIGRATION_REPORT" ]]; then
  jq -r '
    "  migrated:        \(.migrated|length)",
    "  copied disabled: \(.copied_disabled|length)",
    "  kept native:     \(.skipped|length)",
    "  backup:          \(.backup // "none")"
  ' "$MIGRATION_REPORT" || true
fi

cat <<'DONE'

Instalação completa concluída.

Uso diário:
  codex                     Codex + RTK; optimization skill and lazy MCP remain on-demand
  codex-lean                Codex também passando pelo Headroom
  codex-metrics             Codex observado ao vivo pelo Tokview
  codex-savings             resumo de economia/uso

MCP lazy:
  mcpq list                 serviços disponíveis sob demanda
  mcpq search <termo>       procura ferramenta em schemas em cache
  mcpq tools <serviço>      descobre ferramentas só daquele serviço
  mcpq schema <svc> <tool>  carrega apenas um schema
  mcpq call ...             executa a ferramenta

Manutenção:
  codex-mcp-report          relatório de migração e backup
  codex-mcp-migrate         opcional: migra MCPs stdio após medir necessidade
  codex-mcp-restore         rollback dos MCPs migrados
  codex-efficient-doctor    valida todo o ambiente
  codex-efficient-update    reaplica/atualiza todo o stack

Abra um novo shell ou rode:
  source ~/.bashrc

Depois valide:
  codex-efficient-doctor
DONE