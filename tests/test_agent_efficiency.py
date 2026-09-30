"""Regression gates for the quota/context policy."""
import re
import tomllib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AGENTS = ROOT / "specialists" / "agents"


class AgentEfficiencyTests(unittest.TestCase):
    def test_codex_agents_use_current_right_sized_models(self):
        models = {}
        efforts = {}
        for p in sorted(AGENTS.glob("*.toml")):
            data = tomllib.loads(p.read_text())
            models[p.name] = data.get("model")
            efforts[p.name] = data.get("model_reasoning_effort")

        self.assertNotIn("gpt-5.6", set(models.values()))
        self.assertEqual(models["explorer.toml"], "gpt-6-luna")
        self.assertEqual(models["verifier.toml"], "gpt-6-luna")
        self.assertEqual(models["architect.toml"], "gpt-6-sol")
        self.assertEqual(models["security-reviewer.toml"], "gpt-6-sol")
        self.assertLessEqual(sum(v == "high" for v in efforts.values()), 2)

    def test_codex_default_fanout_is_bounded(self):
        data = tomllib.loads((ROOT / "config" / "codex-config.example.toml").read_text())
        agents = data["agents"]
        self.assertLessEqual(agents["max_concurrent_threads_per_session"], 3)
        self.assertEqual(agents["default_subagent_model"], "gpt-6-luna")
        self.assertEqual(agents["default_subagent_reasoning_effort"], "low")

    def test_selective_skill_install_is_default(self):
        for rel in ("specialists/install.sh", "scripts/install-harness.sh"):
            text = (ROOT / rel).read_text()
            self.assertIn("HARNESS_SKILL_PROFILES:-base", text, rel)
            self.assertIn("--skills", text, rel)

    def test_mcp_migration_is_opt_in(self):
        text = (ROOT / "scripts" / "install-codex-efficient-stack.sh").read_text()
        self.assertIn("HARNESS_MIGRATE_MCP:-0", text)
        self.assertNotIn("Migrando automaticamente MCPs", text)

    def test_full_pipeline_is_not_mandatory_policy(self):
        policy = (ROOT / "AGENTS.md").read_text()
        self.assertNotIn("Default flow for non-trivial work", policy)
        tech = tomllib.loads((AGENTS / "tech-lead.toml").read_text())
        self.assertNotIn("Standard flow:", tech["developer_instructions"])


if __name__ == "__main__":
    unittest.main()
