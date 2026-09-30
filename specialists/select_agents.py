#!/usr/bin/env python3
"""Resolve the smallest installed agent set from lifecycle profiles + skill stacks."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROFILE_FILE = ROOT / "agent-profiles.json"
MANIFEST_FILE = ROOT / "manifest.json"


def csv(value: str) -> list[str]:
    return [x.strip().lower() for x in value.replace("postgresql", "postgres").split(",") if x.strip()]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profiles", default="auto")
    ap.add_argument("--skills", default="base")
    args = ap.parse_args()

    cfg = json.loads(PROFILE_FILE.read_text())
    manifest = json.loads(MANIFEST_FILE.read_text())
    available = {Path(x).stem for x in manifest["agents"]}
    named = cfg["profiles"]

    requested = csv(args.profiles)
    skills = csv(args.skills)
    if not requested:
        requested = [cfg.get("default", "auto")]

    bad = [x for x in requested if x not in named and x not in {"auto", "all"}]
    if bad:
        raise SystemExit(f"Unknown agent profile(s): {', '.join(bad)}")

    selected: set[str] = set()
    for base in cfg.get("always_include", []):
        selected.update(named[base])

    if "all" in requested:
        selected = set(available)
    else:
        for profile in requested:
            if profile == "auto":
                continue
            selected.update(named[profile])
        for skill in skills:
            if skill in {"base", "all"}:
                if skill == "all":
                    for values in cfg.get("skill_to_agents", {}).values():
                        selected.update(values)
                continue
            selected.update(cfg.get("skill_to_agents", {}).get(skill, []))

    missing = sorted(selected - available)
    if missing:
        raise SystemExit(f"Profile references missing agents: {', '.join(missing)}")

    for name in sorted(selected):
        print(name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
