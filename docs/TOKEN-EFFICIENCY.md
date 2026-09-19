# Stack de Economia de Tokens

O objetivo é evitar contexto que não ajuda a resposta sem sacrificar correção.

## Componentes
- RTK: compactação de saída de comandos.
- Atlas: mapa de repositório com orçamento de tokens.
- SigMap: assinaturas/evidências estruturais.
- Serena: navegação semântica e refatoração por símbolos.
- mcp2cli/mcpq: descoberta lazy de MCPs locais.
- Headroom: compressão adicional opcional de contexto.
- Tokview: observabilidade de uso/tokens.

## Ordem de contexto
1. grep/range/diff.
2. Atlas.
3. SigMap.
4. Serena.
5. MCP específico sob demanda.
6. Leitura ampla somente quando necessária.

Comandos úteis: atlas . --budget 1024; mcpq list; mcpq search <termo>; mcpq tools <service>; mcpq schema <service> <tool>.