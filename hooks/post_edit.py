#!/usr/bin/env python3
"""PostToolUse: format + cheap static checks on edited files. Silent on success.

On failure prints only the tail of the errors to stderr and exits 2 so the
agent fixes them immediately. Disable with HARNESS_POST_EDIT=off.
"""
import json, os, sys, tomllib
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from _common import find_bin, load_input, run, tail, tool_paths

JS_EXT = {".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs", ".css", ".scss"}
ESLINT_CFG = ("eslint.config.js", "eslint.config.mjs", "eslint.config.ts", ".eslintrc", ".eslintrc.js",
              ".eslintrc.json", ".eslintrc.cjs", ".eslintrc.yml")


def check(path: Path, root: Path):
    ext = path.suffix.lower()
    f = str(path)
    if ext == ".py":
        ruff = find_bin("ruff", root)
        if ruff:
            run([ruff, "format", "-q", f], root)
            return run([ruff, "check", "--output-format", "concise", f], root)
        return run([sys.executable, "-m", "py_compile", f], root)
    if ext in JS_EXT:
        prettier = find_bin("prettier", root)
        if prettier:
            run([prettier, "--write", "--log-level", "silent", f], root)
        eslint = find_bin("eslint", root)
        if eslint and ext not in {".css", ".scss"} and any((root / c).exists() for c in ESLINT_CFG):
            return run([eslint, "--quiet", f], root, timeout=60)
        return 0, ""
    if ext == ".php":
        php = find_bin("php", root)
        return run([php, "-l", f], root) if php else (0, "")
    if ext in {".sh", ".bash"}:
        return run(["bash", "-n", f], root)
    if ext == ".json":
        try:
            json.loads(path.read_text())
        except Exception as e:
            return 1, f"JSON inválido: {e}"
    if ext == ".toml":
        try:
            tomllib.loads(path.read_text())
        except Exception as e:
            return 1, f"TOML inválido: {e}"
    return 0, ""


def main():
    if os.environ.get("HARNESS_POST_EDIT", "").lower() == "off":
        return
    data = load_input()
    root = Path(data.get("cwd") or os.getcwd())
    problems = []
    for raw in tool_paths(data.get("tool_input") or {}):
        p = Path(raw) if os.path.isabs(raw) else root / raw
        if not p.is_file():
            continue
        rc, out = check(p, root)
        if rc != 0:
            problems.append(f"{raw}:\n{tail(out, 25)}")
    if problems:
        sys.stderr.write("[harness-post-edit] corrija antes de continuar:\n" + "\n".join(problems) + "\n")
        raise SystemExit(2)


if __name__ == "__main__":
    main()
