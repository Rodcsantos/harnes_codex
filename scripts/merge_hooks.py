#!/usr/bin/env python3
"""Idempotently merge harness hooks into Claude Code settings.json or Codex hooks.json.

Usage: merge_hooks.py <file> <claude|codex> <hooks_dir> [--remove]
A timestamped .bak is written before any change. Entries are identified by the
hooks_dir path in their command, so re-running never duplicates them.
"""
import json, shutil, sys, time
from pathlib import Path

path, engine, hooks_dir = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
remove = "--remove" in sys.argv


def cmd(script, *extra):
    return " ".join(["python3", f"{hooks_dir}/{script}", *extra])


if engine == "claude":
    spec = {
        "SessionStart": [("startup|resume|clear", cmd("session_start.py"), 10, None)],
        "PreToolUse": [("Bash|Read|Edit|Write|MultiEdit", cmd("guard.py", "--engine", "claude"), 10, None)],
        "PostToolUse": [("Edit|Write|MultiEdit", cmd("post_edit.py"), 60, None)],
        "Stop": [(None, cmd("stop_gate.py"), 330, None)],
    }
else:  # codex
    spec = {
        # Codex supports a per-handler context limit. Keep volatile startup
        # orientation bounded even if a dirty tree or plan grows unexpectedly.
        "SessionStart": [(None, cmd("session_start.py"), 10, 700)],
        "PreToolUse": [("Bash|apply_patch", cmd("guard.py", "--engine", "codex"), 10, None)],
        "PostToolUse": [("apply_patch", cmd("post_edit.py"), 60, None)],
        "Stop": [(None, cmd("stop_gate.py"), 330, None)],
    }

data = json.loads(path.read_text()) if path.exists() and path.read_text().strip() else {}
if path.exists():
    shutil.copy2(path, f"{path}.bak-{time.strftime('%Y%m%d-%H%M%S')}")
hooks = data.setdefault("hooks", {})
for event, entries in spec.items():
    groups = hooks.setdefault(event, [])
    for g in groups:
        g["hooks"] = [h for h in g.get("hooks", []) if hooks_dir not in h.get("command", "")]
    groups[:] = [g for g in groups if g.get("hooks")]
    if remove:
        if not groups:
            del hooks[event]
        continue
    for matcher, command, timeout, context_limit in entries:
        hook = {"type": "command", "command": command, "timeout": timeout}
        if context_limit is not None:
            hook["additionalContextLimit"] = context_limit
        g = {"hooks": [hook]}
        if matcher:
            g["matcher"] = matcher
        groups.append(g)
if not hooks:
    data.pop("hooks", None)
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print(f"{'Removed' if remove else 'Merged'} harness hooks ({engine}) in {path}")
