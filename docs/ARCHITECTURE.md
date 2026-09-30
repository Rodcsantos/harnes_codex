# Arquitetura do Harness

WSL -> Codex/Claude -> policy + specialists/skills sob demanda + hooks + diagnostics + ferramentas externas lazy.

## Responsabilidades
- `AGENTS.md`: regras estáveis, curtas e normativas.
- Agents: especialização/isolamento/paralelismo quando o ganho supera o custo de um novo contexto.
- Skills: procedimentos progressivos; catálogo fonte completo, instalação global seletiva por stack.
- MCP/ferramentas: capacidades externas; descoberta deferred/lazy e CLI direta antes de schemas residentes.
- Hooks e CI: enforcement determinístico com saída mínima.
- LSP/code intelligence: definição, referências e diagnósticos sem leituras amplas.
- Memory: opcional; nunca requisito ou única fonte de políticas críticas.

## Fluxo adaptativo
`pedido -> evidência mínima -> mudança focada -> verificação proporcional ao risco -> conclusão`.

Somente quando necessário:
`unknowns -> explorer`; `trade-off arquitetural -> architect`; `cross-stack -> specialist/orchestrator`; `PR/alto risco -> reviewer`; `trust boundary -> security_reviewer`.

O pipeline completo não é a unidade padrão de trabalho.

## Contexto
- Local conhecido: `rg`, range, diff ou símbolo.
- Repo desconhecido: Atlas **ou** SigMap.
- Navegação/refactor semântico: LSP/Serena.
- Ferramentas externas: descoberta nativa deferred quando disponível; mcp2cli como compatibilidade medida.
- Subagentes: independentes e limitados; cada um custa contexto/cota próprios.

## Produção
Produção privilegia inspeção read-only, dry-run, backup, rollback e aprovação explícita para operações destrutivas.

## Dois CLIs, uma fonte
`specialists/agents/*.toml` alimenta os agentes Codex e gera `claude/agents/*.md`. `specialists/skills/` é o catálogo fonte; o instalador seleciona packs por stack para os dois CLIs. `AGENTS.md` é a política comum e `CLAUDE.md` contém apenas ajustes do cliente.
