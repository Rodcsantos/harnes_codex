#!/usr/bin/env python3
"""PreToolUse guard: block destructive commands and secret access.

Hard rules exit 2 (blocked). Soft rules ask for approval on Claude Code
(permissionDecision=ask) and block on Codex. Bypass: HARNESS_GUARD=off.
Usage: guard.py [--engine claude|codex]
"""
import json, os, re, shlex, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from _common import load_input, tool_command, tool_paths

ENGINE = "codex" if "codex" in sys.argv else "claude"

SECRET_RE = re.compile(
    r"(^|/)(\.env(\.[\w.-]+)?|id_rsa[\w.-]*|id_ed25519[\w.-]*|[\w.-]+\.(pem|p12|pfx|key)|"
    r"\.npmrc|\.pypirc|\.netrc|credentials(\.json)?)$|(^|/)\.(aws|ssh|gnupg|kube)/")
SECRET_OK_RE = re.compile(r"\.(example|sample|template|dist)$")
READERS = {"cat", "less", "more", "head", "tail", "bat", "grep", "rg", "sed", "awk",
           "cp", "scp", "base64", "xxd", "strings", "nl", "tac", "od", "source", "."}
DANGEROUS_TARGETS = {"/", "~", "~/", "$HOME", "${HOME}", "/*", "*", ".", "..", "./", "../"}


def is_secret(path: str) -> bool:
    p = path.strip("'\"")
    return bool(SECRET_RE.search(p)) and not SECRET_OK_RE.search(p)


def segments(cmd: str):
    for seg in re.split(r"&&|\|\||;|\||\n", cmd):
        try:
            toks = shlex.split(seg)
        except ValueError:
            toks = seg.split()
        while toks and toks[0] in ("sudo", "env", "command", "time", "nohup"):
            toks = toks[1:]
        if toks:
            yield toks


def hard_reason(cmd: str):
    if re.search(r":\(\)\s*\{.*\|.*&.*\}", cmd):
        return "fork bomb"
    if re.search(r"\b(mkfs(\.\w+)?|dd\b.*\bof=/dev/|chmod\s+-R\s+0?777)\b", cmd) or re.search(r">\s*/dev/sd", cmd):
        return "operação destrutiva de disco/permissões"
    for t in segments(cmd):
        name = t[0].rsplit("/", 1)[-1]
        args = t[1:]
        flags = [a for a in args if a.startswith("-")]
        targets = [a for a in args if not a.startswith("-")]
        if name == "rm":
            short = "".join(f.lstrip("-") for f in flags if not f.startswith("--"))
            rec = "r" in short.lower() or "--recursive" in flags
            frc = "f" in short or "--force" in flags
            if rec and frc and any(x in DANGEROUS_TARGETS for x in targets):
                return "rm -rf em alvo amplo (/, ~, $HOME, *, .)"
        if name == "git" and args[:1] == ["push"]:
            if "--force" in flags or "-f" in flags:
                return "git push --force (use --force-with-lease com aprovação)"
            for x in targets[1:]:
                ref = x.split(":")[-1]
                if ref in ("main", "master"):
                    return "push direto para main/master (abra PR)"
        if name in READERS and any(is_secret(x) for x in targets):
            return "leitura de arquivo de segredo (.env, chaves, credenciais)"
    return None


SOFT = [
    (r"\bgit\s+(reset\s+--hard|clean\s+-\w*[fd]|checkout\s+--\s|restore\s+\.|branch\s+-D|stash\s+(drop|clear))", "git destrutivo (perde trabalho local)"),
    (r"\bdrop\s+(table|database|schema|index)\b", "SQL DROP"),
    (r"\btruncate\s+(table\s+)?\w", "SQL TRUNCATE"),
    (r"\bdelete\s+from\s+\S+\s*(;|\"|'|$)(?!.*\bwhere\b)", "DELETE sem WHERE"),
    (r"\balter\s+table\s+\S+\s+drop\b", "ALTER TABLE ... DROP"),
    (r"\bflush(all|db)\b", "Redis FLUSH"),
    (r"\bdocker\s+(system\s+prune|volume\s+(rm|prune)|rm\s+-\w*f|compose\s+down\s+.*-v)", "Docker destrutivo"),
    (r"\bkubectl\s+(delete|drain|cordon)\b|\bhelm\s+(uninstall|delete)\b", "Kubernetes destrutivo"),
    (r"\bterraform\s+(destroy|apply)\b", "Terraform destroy/apply"),
    (r"\bsystemctl\s+(stop|disable|mask)\b|\bufw\s+(disable|reset)\b|\biptables\s+-F\b", "serviço/firewall"),
    (r"\b(curl|wget)\b[^|]*\|\s*(sudo\s+)?(ba|z)?sh\b", "curl | sh"),
    (r"\bkill\s+-9\s+(-1|1)\b|\bpkill\s+-9\b", "kill -9 amplo"),
]


def soft_reason(cmd: str):
    for pat, why in SOFT:
        if re.search(pat, cmd, re.I):
            return why
    return None


def deny(msg: str):
    sys.stderr.write(f"[harness-guard] bloqueado: {msg}. Peça aprovação explícita ao usuário; não contorne.\n")
    raise SystemExit(2)


def ask(msg: str):
    if ENGINE == "codex":
        deny(f"{msg} (requer aprovação explícita)")
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "ask",
        "permissionDecisionReason": f"[harness-guard] {msg}"}}))
    raise SystemExit(0)


def main():
    if os.environ.get("HARNESS_GUARD", "").lower() == "off":
        return
    data = load_input()
    ti = data.get("tool_input") or {}
    if not isinstance(ti, dict):
        return
    cmd = tool_command(ti)
    if cmd:
        why = hard_reason(cmd)
        if why:
            deny(why)
    for p in tool_paths(ti):
        if is_secret(p):
            deny(f"acesso a arquivo de segredo: {p}")
    if cmd:
        why = soft_reason(cmd)
        if why:
            ask(why)


if __name__ == "__main__":
    main()
