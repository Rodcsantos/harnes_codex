#!/usr/bin/env python3
"""Stop gate: enforce only the project's explicit verify command.

Runs only when the working tree has changes. Verify command, in order:
HARNESS_VERIFY_CMD, then .harness/verify.sh. No explicit command -> no-op.
Broad ecosystem discovery belongs to deliberate verification, not every Stop.
Blocks at most 2 times per session to avoid loops. Disable: HARNESS_STOP_GATE=off.
"""
import os, shlex, sys, tempfile
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from _common import load_input, run, tail

MAX_BLOCKS = 2


def detect(root: Path):
    env = os.environ.get("HARNESS_VERIFY_CMD")
    if env:
        return ["bash", "-lc", env]
    script = root / ".harness" / "verify.sh"
    if script.exists():
        return ["bash", str(script)]
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
    rc, output = run(cmd, root, timeout=timeout)
    if rc == 0:
        state.unlink(missing_ok=True)
        return
    if blocks >= MAX_BLOCKS:
        return

    state.write_text(str(blocks + 1))
    sys.stderr.write(
        f"[harness-stop-gate] verificação falhou (exit {rc}): {shlex.join(cmd)}\n"
        f"{tail(output, 40)}\nCorrija a causa raiz e rode novamente antes de encerrar "
        f"({blocks + 1}/{MAX_BLOCKS}).\n"
    )
    raise SystemExit(2)


if __name__ == "__main__":
    main()
