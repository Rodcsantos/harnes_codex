#!/usr/bin/env python3
from pathlib import Path
import sys, tomllib, re
home = Path(sys.argv[1] if len(sys.argv)>1 else Path.home()/'.codex')
errors=[]
agent_dir=home/'agents'; skill_dir=home/'skills'
for p in agent_dir.glob('*.toml'):
    try:
        d=tomllib.loads(p.read_text())
        for k in ('name','description','developer_instructions'):
            if not isinstance(d.get(k),str) or not d[k].strip(): errors.append(f'{p}: missing {k}')
    except Exception as e: errors.append(f'{p}: TOML error: {e}')
for p in skill_dir.glob('*/SKILL.md'):
    txt=p.read_text()
    m=re.match(r'^---\n(.*?)\n---',txt,re.S)
    if not m: errors.append(f'{p}: missing YAML frontmatter'); continue
    fm=m.group(1)
    if not re.search(r'^name:\s*[^\n]+',fm,re.M): errors.append(f'{p}: missing name')
    if not re.search(r'^description:\s*[^\n]+',fm,re.M): errors.append(f'{p}: missing description')
if errors:
    print('VALIDATION FAILED')
    print('\n'.join(' - '+e for e in errors))
    raise SystemExit(1)
print(f'OK: {len(list(agent_dir.glob("*.toml")))} agent TOMLs and {len(list(skill_dir.glob("*/SKILL.md")))} skills validated.')
