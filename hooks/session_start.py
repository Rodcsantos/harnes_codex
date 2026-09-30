#!/usr/bin/env python3
"""SessionStart: inject only volatile orientation that saves later reads."""
import os, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from _common import load_input, run, tail

data = load_input()
root = Path(data.get("cwd") or os.getcwd())
rc, branch = run(["git", "symbolic-ref", "--short", "HEAD"], root)
if rc != 0:
    rc, branch = run(["git", "rev-parse", "--short", "HEAD"], root)
if rc != 0:
    raise SystemExit(0)

out = [f"[harness] branch: {branch}"]
rc, status = run(["git", "status", "-s"], root)
if rc == 0 and status:
    n = len(status.splitlines())
    out.append(
        f"alterações locais ({n}):\n{tail(status, 8)}"
        + (f"\n... +{n - 8}" if n > 8 else "")
    )

plan = root / ".harness" / "plan.md"
if plan.exists():
    lines = plan.read_text().splitlines()
    title = next((x for x in lines if x.startswith("# ")), "# Plan")
    open_steps = [x for x in lines if "- [ ]" in x][:7]
    verify = []
    for i, line in enumerate(lines):
        if line.strip() == "## Verificação":
            verify = lines[i:i + 3]
            break
    compact = [title, *open_steps, *verify]
    out.append("plano ativo (.harness/plan.md):\n" + "\n".join(compact[:11]))

print("\n".join(out))
