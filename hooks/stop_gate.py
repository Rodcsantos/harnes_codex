#!/usr/bin/env python3
"""Stop gate: refuse to finish while the project's verify command fails.

Runs only when the working tree has changes. Verify command, in order:
HARNESS_VERIFY_CMD, .harness/verify.sh, then ecosystem defaults (pytest,
npm test, composer test). No command found -> gate is a no-op.
Blocks at most 2 times per session to avoid loops. Disable: HARNESS_STOP_GATE=off.
"""
import json, os, shlex, sys, tempfile
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from _common import find_bin, load_input, run, tail

MAX_BLOCKS = 2


def has_pytest(root: Path) -> bool:
    if (root / "pytest.ini").exists() or (root / "tests").is_dir():
        return True
    pp = root / "pyproject.toml"
    return pp.exists() and "[tool.pytest" in pp.read_text()


def detect(root: Path):
    env = os.environ.get("HARNESS_VERIFY_CMD")
    if env:
        return ["bash", "-lc", env]
    script = root / ".harness" / "verify.sh"
    if script.exists():
        return ["bash", str(script)]
    if has_pytest(root):
        pytest = find_bin("pytest", root)
        base = [pytest] if pytest else [sys.executable, "-m", "pytest"]
        return base + ["-q", "-x", "--tb=short"]
    pkg = root / "package.json"
    if pkg.exists():
        try:
            test = (json.loads(pkg.read_text()).get("scripts") or {}).get("test", "")
        except Exception:
            test = ""
        if test and "no test specified" not in test:
            return ["npm", "test", "--silent"]
    comp = root / "composer.json"
    if comp.exists():
        try:
            if "test" in (json.loads(comp.read_text()).get("scripts") or {}):
                return ["composer", "test", "--no-interaction"]
        except Exception:
            pass
    return None


def main():
    if os.environ.get("HARNESS_STOP_GATE", "").lower() == "off":
        return
    data = load_input()
    root = Path(data.get("cwd") or os.getcwd())
    rc, dirty = run(["git", "status", "--porcelain"], root)
    if rc != 0 or not dirty.strip():
        return
    cmd = detect(root)
    if not cmd:
        return
    state = Path(tempfile.gettempdir()) / f"harness-stop-{data.get('session_id', 'default')}"
    blocks = int(state.read_text() or 0) if state.exists() else 0
    if data.get("stop_hook_active") and blocks >= MAX_BLOCKS:
        return
    timeout = int(os.environ.get("HARNESS_VERIFY_TIMEOUT", "300"))
    rc, out = run(cmd, root, timeout=timeout)
    if rc == 0:
        state.unlink(missing_ok=True)
        return
    if blocks >= MAX_BLOCKS:
        return
    state.write_text(str(blocks + 1))
    sys.stderr.write(
        f"[harness-stop-gate] verificação falhou (exit {rc}): {shlex.join(cmd)}\n"
        f"{tail(out, 40)}\nCorrija a causa raiz e rode novamente antes de encerrar "
        f"({blocks + 1}/{MAX_BLOCKS}).\n")
    raise SystemExit(2)


if __name__ == "__main__":
    main()
