# Central do Projeto WSL / Codex + Claude Code

Atualizado em 2026-09-30.

Este repositório centraliza o harness de desenvolvimento WSL com foco em qualidade de engenharia, contexto mínimo suficiente e uso previsível de cota.

## Frentes consolidadas
1. WSL limpo e reproduzível para desenvolvimento.
2. Codex CLI e Claude Code com política comum, especialistas, skills progressivas, hooks e diagnósticos determinísticos.
3. Economia de contexto: RTK para stdout; ast-grep para busca estrutural; Atlas **ou** SigMap para orientação; LSP/Serena para símbolos; MCP lazy/deferred somente quando necessário; Headroom experimental; Tokview para medir.
4. Especialistas para Python, Django, PHP, React, MySQL, PostgreSQL, Redis e infraestrutura.
5. Fluxo adaptativo por risco: trabalho rotineiro fica no agente principal; subagentes e revisão independente entram somente quando trazem ganho mensurável.
6. Catálogo completo versionado, instalação global de skills seletiva por stack.

## Convenção
- `archive/`: pesquisa e artefatos históricos, não política atual.
- `scripts/`: automação executável.
- `specialists/`: fonte canônica de agentes/skills.
- `docs/`: decisões e instruções humanas.
- `config/`: exemplos seguros sem segredos.

A prioridade é reduzir **contexto por tarefa concluída**, sem trocar correção por uma métrica de tokens menor.
