import json, os, subprocess, sys, tempfile, unittest
from pathlib import Path

HOOKS = Path(__file__).resolve().parent.parent / "hooks"


def run_hook(name, payload, args=(), env=None, cwd=None):
    e = {**os.environ, **(env or {})}
    return subprocess.run([sys.executable, str(HOOKS / name), *args], input=json.dumps(payload),
                          capture_output=True, text=True, cwd=cwd, env=e)


def bash(cmd):
    return {"tool_name": "Bash", "tool_input": {"command": cmd}}


class GuardTests(unittest.TestCase):
    def test_hard_blocks(self):
        for cmd in ["rm -rf /", "sudo rm -rf ~", "rm -fr *", "git push --force origin feat",
                    "git push origin main", "git push origin HEAD:master", "cat .env",
                    "grep KEY ./config/.env.production", "cp ~/.ssh/id_rsa /tmp/x", "chmod -R 777 /var"]:
            r = run_hook("guard.py", bash(cmd))
            self.assertEqual(r.returncode, 2, cmd)

    def test_allows_normal(self):
        for cmd in ["ls -la", "rm -rf ./build", "rm -rf node_modules", "git push -u origin feat/x",
                    "cat .env.example", "pytest -q", "git push --force-with-lease origin feat/x",
                    "psql -c 'select 1'", "delete from t where id=1"]:
            r = run_hook("guard.py", bash(cmd))
            self.assertEqual(r.returncode, 0, cmd + r.stderr)
            self.assertEqual(r.stdout.strip(), "", cmd)

    def test_soft_asks_on_claude_and_blocks_on_codex(self):
        for cmd in ["git reset --hard HEAD~1", "psql -c 'DROP TABLE users'", "kubectl delete pod x",
                    "redis-cli FLUSHALL", "docker system prune -af"]:
            r = run_hook("guard.py", bash(cmd))
            self.assertEqual(r.returncode, 0, cmd)
            out = json.loads(r.stdout)["hookSpecificOutput"]
            self.assertEqual(out["permissionDecision"], "ask")
            self.assertEqual(run_hook("guard.py", bash(cmd), args=["--engine", "codex"]).returncode, 2, cmd)

    def test_secret_paths_for_file_tools_and_patches(self):
        self.assertEqual(run_hook("guard.py", {"tool_input": {"file_path": "/app/.env"}}).returncode, 2)
        self.assertEqual(run_hook("guard.py", {"tool_input": {"file_path": "/app/.env.example"}}).returncode, 0)
        patch = "*** Begin Patch\n*** Update File: config/id_rsa\n*** End Patch"
        self.assertEqual(run_hook("guard.py", {"tool_input": {"input": patch}}).returncode, 2)

    def test_bypass(self):
        self.assertEqual(run_hook("guard.py", bash("rm -rf /"), env={"HARNESS_GUARD": "off"}).returncode, 0)


class PostEditTests(unittest.TestCase):
    def test_reports_errors_and_stays_silent_when_ok(self):
        with tempfile.TemporaryDirectory() as d:
            bad, good, sh = Path(d, "bad.json"), Path(d, "good.json"), Path(d, "x.sh")
            bad.write_text("{oops"); good.write_text("{}"); sh.write_text("if then\n")
            r = run_hook("post_edit.py", {"cwd": d, "tool_input": {"file_path": str(bad)}})
            self.assertEqual(r.returncode, 2); self.assertIn("JSON inválido", r.stderr)
            r = run_hook("post_edit.py", {"cwd": d, "tool_input": {"file_path": str(good)}})
            self.assertEqual((r.returncode, r.stderr), (0, ""))
            r = run_hook("post_edit.py", {"cwd": d, "tool_input": {"file_path": str(sh)}})
            self.assertEqual(r.returncode, 2)


class StopGateTests(unittest.TestCase):
    def repo(self, d, verify):
        subprocess.run(["git", "init", "-q", d], check=True)
        Path(d, ".harness").mkdir()
        Path(d, ".harness", "verify.sh").write_text(verify)
        Path(d, "a.txt").write_text("x")

    def test_blocks_then_releases(self):
        with tempfile.TemporaryDirectory() as d:
            self.repo(d, "echo boom; exit 1\n")
            p = {"cwd": d, "session_id": "t-" + os.path.basename(d)}
            r = run_hook("stop_gate.py", p)
            self.assertEqual(r.returncode, 2); self.assertIn("boom", r.stderr)
            self.assertEqual(run_hook("stop_gate.py", {**p, "stop_hook_active": True}).returncode, 2)
            self.assertEqual(run_hook("stop_gate.py", {**p, "stop_hook_active": True}).returncode, 0)

    def test_passes_and_noop_when_clean(self):
        with tempfile.TemporaryDirectory() as d:
            self.repo(d, "exit 0\n")
            self.assertEqual(run_hook("stop_gate.py", {"cwd": d, "session_id": "ok" + os.path.basename(d)}).returncode, 0)
        with tempfile.TemporaryDirectory() as d:
            subprocess.run(["git", "init", "-q", d], check=True)
            self.assertEqual(run_hook("stop_gate.py", {"cwd": d}, env={"HARNESS_VERIFY_CMD": "exit 1"}).returncode, 0)


class SessionStartTests(unittest.TestCase):
    def test_outputs_branch(self):
        with tempfile.TemporaryDirectory() as d:
            subprocess.run(["git", "init", "-q", d], check=True)
            r = run_hook("session_start.py", {"cwd": d})
            self.assertEqual(r.returncode, 0); self.assertIn("[harness] branch:", r.stdout)


if __name__ == "__main__":
    unittest.main()
