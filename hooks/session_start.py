#!/usr/bin/env python3
"""SessionStart: inject a compact orientation block (branch, status, plan)."""
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
rc, status = run(["git", "status", "-s"], root)
status = status if rc == 0 else ""
rc, log = run(["git", "log", "--oneline", "-3"], root)
log = log if rc == 0 else ""
out = [f"[harness] branch: {branch}"]
if status:
    n = len(status.splitlines())
    out.append(f"alterações locais ({n}):\n{tail(status, 12)}" + (f"\n... +{n - 12}" if n > 12 else ""))
if log:
    out.append(f"últimos commits:\n{log}")
plan = root / ".harness" / "plan.md"
if plan.exists():
    out.append("plano ativo (.harness/plan.md):\n" + "\n".join(plan.read_text().splitlines()[:25]))
print("\n".join(out))
