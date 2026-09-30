#!/usr/bin/env python3
"""Generate Claude Code subagents (claude/agents/*.md) from the Codex TOMLs.

Single source of truth: specialists/agents/*.toml.
Usage: build-claude-agents.py [--check]
"""
import sys, tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "specialists" / "agents"
OUT = ROOT / "claude" / "agents"

# Model tier per agent (Claude aliases). Default: sonnet.
MODEL = {
    # Sonnet is the economical default for coding/subagents. Reserve Opus for
    # architecture work that genuinely needs deeper trade-off reasoning.
    "architect": "opus",
    "explorer": "haiku",
}
READ_ONLY_TOOLS = "Read, Grep, Glob, Bash"
WRITE_TOOLS = "Read, Grep, Glob, Bash, Edit, Write"
# Orchestrators inherit all tools so they can delegate; they are told not to edit.
INHERIT = {"tech_lead", "fullstack_orchestrator"}


def render(d: dict) -> str:
    name = d["name"]
    desc = " ".join(d["description"].split()).replace('"', "'")
    lines = ["---", f"name: {name.replace('_', '-')}", f'description: "{desc}"']
    if name not in INHERIT:
        ro = d.get("sandbox_mode") == "read-only"
        lines.append(f"tools: {READ_ONLY_TOOLS if ro else WRITE_TOOLS}")
    lines += [f"model: {MODEL.get(name, 'sonnet')}", "---", "",
              d["developer_instructions"].strip(), ""]
    return "\n".join(lines)


def main() -> int:
    check = "--check" in sys.argv
    OUT.mkdir(parents=True, exist_ok=True)
    expected = {}
    for p in sorted(SRC.glob("*.toml")):
        d = tomllib.loads(p.read_text())
        expected[f"{d['name'].replace('_', '-')}.md"] = render(d)
    drift = []
    for fname, body in expected.items():
        target = OUT / fname
        if check:
            if not target.exists() or target.read_text() != body:
                drift.append(fname)
        else:
            target.write_text(body)
    if check:
        extra = [p.name for p in OUT.glob("*.md") if p.name not in expected]
        drift += [f"(orphan) {n}" for n in extra]
        if drift:
            print("Claude agents out of date; run scripts/build-claude-agents.py:", *drift, sep="\n - ")
            return 1
        print(f"OK: {len(expected)} Claude agents in sync with TOML sources.")
        return 0
    print(f"Generated {len(expected)} Claude agents in {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
