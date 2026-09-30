"""Validation for selective lifecycle agent profiles."""
import json
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SPECIALISTS = ROOT / "specialists"
SELECTOR = SPECIALISTS / "select_agents.py"


def select(profiles="auto", skills="base"):
    r = subprocess.run(
        [sys.executable, str(SELECTOR), "--profiles", profiles, "--skills", skills],
        check=True,
        capture_output=True,
        text=True,
    )
    return {x for x in r.stdout.splitlines() if x}


class AgentProfileTests(unittest.TestCase):
    def test_profiles_reference_real_agents(self):
        cfg = json.loads((SPECIALISTS / "agent-profiles.json").read_text())
        manifest = json.loads((SPECIALISTS / "manifest.json").read_text())
        available = {Path(x).stem for x in manifest["agents"]}
        referenced = set()
        for values in cfg["profiles"].values():
            referenced.update(values)
        for values in cfg["skill_to_agents"].values():
            referenced.update(values)
        self.assertFalse(referenced - available)

    def test_auto_base_is_small_core(self):
        self.assertEqual(
            select(),
            {"tech-lead", "explorer", "reviewer", "verifier"},
        )

    def test_auto_adds_only_stack_specialists(self):
        selected = select("auto", "django,postgres")
        self.assertEqual(
            selected,
            {
                "tech-lead", "explorer", "reviewer", "verifier",
                "python-expert", "django-expert", "postgresql-dba",
            },
        )

    def test_explicit_lifecycle_profiles_keep_core(self):
        selected = select("product,security", "base")
        expected = {
            "tech-lead", "explorer", "reviewer", "verifier",
            "product-manager", "product-discovery", "business-analyst", "ux-ui-designer",
            "security-architect", "security-reviewer", "secops",
        }
        self.assertEqual(selected, expected)

    def test_all_matches_manifest(self):
        manifest = json.loads((SPECIALISTS / "manifest.json").read_text())
        self.assertEqual(select("all", "base"), {Path(x).stem for x in manifest["agents"]})


if __name__ == "__main__":
    unittest.main()
