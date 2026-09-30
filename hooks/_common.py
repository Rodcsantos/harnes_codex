"""Shared helpers for harness hooks (Claude Code and Codex CLI)."""
import json, os, re, shutil, subprocess, sys
from pathlib import Path


def load_input() -> dict:
    try:
        data = json.load(sys.stdin)
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}


def tool_command(tool_input: dict) -> str:
    cmd = tool_input.get("command") or tool_input.get("cmd") or ""
    if isinstance(cmd, list):
        cmd = " ".join(str(c) for c in cmd)
    return str(cmd)


PATCH_RE = re.compile(r"^\*\*\* (?:Update|Add|Delete) File: (.+?)\s*$", re.M)


def tool_paths(tool_input: dict) -> list:
    """File paths touched by Edit/Write/Read tools or an apply_patch payload."""
    paths = []
    for key in ("file_path", "path", "notebook_path"):
        v = tool_input.get(key)
        if isinstance(v, str) and v:
            paths.append(v)
    for key in ("input", "patch", "diff", "command"):
        v = tool_input.get(key)
        if isinstance(v, list):
            v = " ".join(str(x) for x in v)
        if isinstance(v, str) and "*** " in v:
            paths += PATCH_RE.findall(v)
    return list(dict.fromkeys(paths))


def find_bin(name: str, root: Path):
    for cand in (root / "node_modules" / ".bin" / name, root / ".venv" / "bin" / name):
        if cand.exists():
            return str(cand)
    return shutil.which(name)


def run(cmd, cwd, timeout=30):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, (p.stdout + p.stderr).strip()
    except subprocess.TimeoutExpired:
        return 124, f"timeout after {timeout}s: {' '.join(map(str, cmd))}"
    except FileNotFoundError as e:
        return 127, str(e)


def tail(text: str, n: int) -> str:
    lines = text.splitlines()
    return "\n".join(lines[-n:])
