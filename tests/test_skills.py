"""Quality gate for domain skills (everything except flow-*)."""
import hashlib, re, unittest
from pathlib import Path

SKILLS = Path(__file__).resolve().parent.parent / "specialists" / "skills"
REQUIRED = ("## Use when", "## Diagnose first", "## Verify")
MAX_LINES, MAX_WORDS = 80, 650\nMAX_DESCRIPTION_CHARS = 320


def domain_skills():
    return sorted(p for p in SKILLS.iterdir() if p.is_dir() and not p.name.startswith("flow-"))


def workflow_block(text):
    m = re.search(r"^## Workflow\n(.*?)(?=^## |\Z)", text, re.S | re.M)
    return m.group(1).strip() if m else None


class DomainSkillTests(unittest.TestCase):
    def test_no_shared_workflow_block(self):
        seen = {}
        for d in domain_skills():
            block = workflow_block((d / "SKILL.md").read_text())
            if block is None:
                continue
            h = hashlib.md5(block.encode()).hexdigest()
            seen.setdefault(h, []).append(d.name)
        dup = {h: n for h, n in seen.items() if len(n) > 1}
        if dup:
            self.fail(f"identical '## Workflow' blocks shared by: { {h[:8]: len(n) for h, n in dup.items()} } skills")

    def test_required_sections_and_frontmatter(self):
        problems = []
        for d in domain_skills():
            text = (d / "SKILL.md").read_text()
            m = re.match(r"^---\nname: (.+)\ndescription: \"(.+)\"\n---\n", text)
            if not m:
                problems.append(f"{d.name}: bad frontmatter"); continue
            if m.group(1).strip() != d.name:
                problems.append(f"{d.name}: name mismatch")
            if "Use when" not in m.group(2):
                problems.append(f"{d.name}: description lacks 'Use when'")
            for sec in REQUIRED:
                if not re.search(rf"^{re.escape(sec)}\s*$", text, re.M):
                    problems.append(f"{d.name}: missing '{sec}'")
        if problems:
            self.fail("\n" + "\n".join(problems[:15]) + f"\n({len(problems)} problems)")

    def test_description_budget(self):
        problems = []
        for d in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
            text = (d / "SKILL.md").read_text()
            m = re.search(r'^description:\\s*"?([^\\n"]+)"?\\s*
        for d in domain_skills():
            body = (d / "SKILL.md").read_text().split("\n---\n", 1)[-1]
            lines, words = len(body.strip().splitlines()), len(body.split())
            if lines > MAX_LINES or words > MAX_WORDS:
                problems.append(f"{d.name}: {lines} lines, {words} words")
        if problems:
            self.fail("\n" + "\n".join(problems))


if __name__ == "__main__":
    unittest.main()
, text, re.M)
            if not m:
                problems.append(f"{d.name}: missing description")
                continue
            desc = m.group(1).strip()
            if len(desc) > MAX_DESCRIPTION_CHARS:
                problems.append(f"{d.name}: description has {len(desc)} chars")
        if problems:
            self.fail("\\n" + "\\n".join(problems))

    def test_size_budget(self):
        problems = []
        for d in domain_skills():
            body = (d / "SKILL.md").read_text().split("\n---\n", 1)[-1]
            lines, words = len(body.strip().splitlines()), len(body.split())
            if lines > MAX_LINES or words > MAX_WORDS:
                problems.append(f"{d.name}: {lines} lines, {words} words")
        if problems:
            self.fail("\n" + "\n".join(problems))


if __name__ == "__main__":
    unittest.main()
