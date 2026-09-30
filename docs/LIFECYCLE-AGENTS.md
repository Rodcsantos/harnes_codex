# Stack Completa de Agentes para o Ciclo de Vida de Software

Catálogo lógico do SDLC. O repositório possui 42 agentes executáveis porque algumas funções abaixo também têm especialistas adicionais por linguagem/banco. A instalação permanece seletiva por perfil para evitar custo fixo de contexto.

1. Product Manager Agent - Gestão de Produto e Priorização

- Responsabilidades e Atividades: Agente `product_manager`. Define visão, objetivos, escopo, roadmap, épicos, features, user stories, critérios de aceite e métricas; prioriza backlog; identifica dependências; controla scope creep; valida entregas contra o problema e os critérios definidos.
- Skills e Ferramentas: Product discovery, Lean Product, Scrum/Kanban, JTBD, Story Mapping, RICE, MoSCoW, OKRs, métricas de produto, GitHub Issues/Projects ou ferramenta equivalente quando disponível, Markdown e Mermaid.

2. Product Discovery Agent - Pesquisa e Descoberta de Produto

- Responsabilidades e Atividades: Agente `product_discovery`. Investiga problema, usuários, alternativas, concorrentes e evidências; separa fatos de hipóteses; identifica razões para construir ou não uma feature; produz hipóteses falsificáveis e planos de validação de baixo custo.
- Skills e Ferramentas: Pesquisa documental/web quando disponível, benchmarking, análise competitiva, entrevistas/JTBD, opportunity mapping, análise de feedback, SQL analítico quando necessário e síntese de evidências.

3. Business Analyst Agent - Regras de Negócio e Processos

- Responsabilidades e Atividades: Agente `business_analyst`. Converte processos em regras determinísticas; explicita atores, estados, transições, cálculos, exceções, permissões e dados; elimina ambiguidades e mantém rastreabilidade entre regra, requisito, implementação e teste.
- Skills e Ferramentas: BPMN, UML, decision tables, state machines, Given/When/Then, SQL, Mermaid, requisitos funcionais/não funcionais e domain modeling.

4. UX/UI Designer Agent - Experiência e Interface

- Responsabilidades e Atividades: Agente `ux_ui_designer`. Define fluxos, arquitetura de informação, estados de tela, comportamento responsivo e acessibilidade; reutiliza design system existente; revisa implementação real quando ferramentas visuais/browser estiverem disponíveis.
- Skills e Ferramentas: Figma/conceitos de design system, WCAG, HTML/CSS, Tailwind, shadcn/ui, Material Design/HIG quando aplicável, heurísticas de Nielsen, responsive design e análise visual.

5. Solution Architect Agent - Arquitetura de Solução

- Responsabilidades e Atividades: Agente `architect`. Traduz requisitos em arquitetura de alto nível; define boundaries, integrações, contratos, dados, autenticação, deploy, riscos e rollback; produz opções e trade-offs apenas quando existe decisão arquitetural real.
- Skills e Ferramentas: C4, UML, ADR, Mermaid, DDD, Clean/Hexagonal Architecture, REST, GraphQL, gRPC, event-driven architecture, OAuth/OIDC, caching, filas e sistemas distribuídos.

6. Software Architect Agent - Arquitetura de Código e Componentes

- Responsabilidades e Atividades: Agente `software_architect`. Analisa módulos, dependências, ownership e contratos internos; reduz ciclos, god modules e acoplamento; planeja refactors incrementais preservando compatibilidade e comportamento.
- Skills e Ferramentas: SOLID, DDD, modular monolith, ports/adapters, dependency inversion, design patterns, dependency graphs, AST tooling, static analysis e API design.

7. Tech Lead Agent - Coordenação Técnica

- Responsabilidades e Atividades: Agente `tech_lead`. Coordena trabalho complexo/cross-stack; decide quando delegar; consolida evidências; limita fan-out; mantém estado durável no plano; garante que implementação, verificação e revisão sejam proporcionais ao risco.
- Skills e Ferramentas: Git/GitHub, análise de diffs, planejamento técnico, arquitetura, debugging, CI/CD, delegação multiagente, gestão de risco e `.harness/plan.md`.

8. Frontend Engineer Agent - Desenvolvimento Web Frontend

- Responsabilidades e Atividades: Agente `react_expert`. Implementa componentes, navegação, formulários, estado, consumo de APIs, loading/error/empty states, responsividade e acessibilidade; preserva contratos e arquitetura do frontend.
- Skills e Ferramentas: JavaScript, TypeScript, React, Next.js/Vite quando presentes, HTML, CSS, Tailwind, React Hook Form, Zod, TanStack Query, Zustand/Redux quando existentes, Vitest/Jest, RTL e Playwright/Cypress.

9. Frontend Performance Agent - Performance e Web Vitals

- Responsabilidades e Atividades: Agente `frontend_performance`. Mede e corrige rendering excessivo, bundle/network cost, hydration, long tasks e asset loading; registra baseline e delta depois da mudança; evita memoização especulativa.
- Skills e Ferramentas: Chrome DevTools, React Profiler, Lighthouse, Core Web Vitals, bundle analyzers, Performance API, lazy loading, code splitting, cache e profiling de rede/CPU.

10. Backend Engineer Agent - Desenvolvimento de Backend

- Responsabilidades e Atividades: Agente `backend_engineer`. Implementa regras, serviços, jobs, transações, autorização, integrações e persistência; trata idempotência, concorrência, timeouts e erros; delega detalhes de framework aos especialistas quando necessário.
- Skills e Ferramentas: Python, PHP, Node/TypeScript quando presentes, REST/GraphQL/gRPC, ORMs, filas/jobs, testes, typing/static analysis e profiling; extensões `python_expert`, `django_expert` e `php_expert`.

11. API & Integration Engineer Agent - APIs e Integrações

- Responsabilidades e Atividades: Agente `api_integration`. Define e implementa contratos, validação, autenticação, webhooks, rate limits, idempotência, retries/timeouts, versionamento e backward compatibility; testa falhas sem depender de serviços reais.
- Skills e Ferramentas: REST, OpenAPI, JSON Schema, GraphQL, gRPC, OAuth 2.0/OIDC, JWT, webhooks, contract testing, Pact quando presente, Postman/Bruno e exponential backoff.

12. Mobile Engineer Agent - Desenvolvimento Mobile

- Responsabilidades e Atividades: Agente `mobile_engineer`. Implementa navegação, estado, APIs, secure storage, notificações, deep links, offline/poor-network behavior e lifecycle; respeita matriz de OS/dispositivos e requisitos de publicação.
- Skills e Ferramentas: React Native/Expo, Flutter quando presente, Kotlin/Android/Jetpack Compose, Swift/SwiftUI, Gradle, Xcode, SQLite, secure storage, push notifications, Appium/E2E conforme stack.

13. Database Architect Agent - Modelagem e Arquitetura de Dados

- Responsabilidades e Atividades: Agente `database_architect`. Define entidades, relações, constraints, chaves, histórico, retenção, normalização, JSON e particionamento; planeja migrações expand/migrate/contract e avalia locking/rollback.
- Skills e Ferramentas: PostgreSQL, MySQL/InnoDB, SQL, ER modeling, constraints, indexes, partitioning, JSON/JSONB, migrations e schema evolution.

14. Database Performance Agent - SQL e Performance de Banco

- Responsabilidades e Atividades: Agente `database_performance`. Diagnostica queries, planos, locks, conexões, memória e I/O; distingue problema de consulta, índice, cardinalidade, N+1 ou contention; mede antes/depois e coordena detalhes com os DBAs.
- Skills e Ferramentas: EXPLAIN/EXPLAIN ANALYZE, pg_stat_statements, Performance Schema, slow query log, indexes, locks/deadlocks, query rewriting e análise de recursos; extensões `mysql_dba` e `postgresql_dba`.

15. Redis & Caching Agent - Cache, Filas e Estado Distribuído

- Responsabilidades e Atividades: Agente `redis_expert`. Modela cache/TTL/invalidação, Streams/queues, locks e rate limits; diagnostica big/hot keys, latency, eviction e persistência; evita usar Redis como solução genérica sem requisitos claros.
- Skills e Ferramentas: Redis, Cluster/Sentinel, Streams, Lua, cache-aside, TTL jitter, distributed locks, rate limiting, RDB/AOF, INFO, MEMORY, SLOWLOG e SCAN.

16. QA Architect Agent - Estratégia de Qualidade

- Responsabilidades e Atividades: Agente `qa_architect`. Converte riscos em estratégia de testes; escolhe camada mínima confiável; define quality gates, test data, paralelismo e política de flakiness; evita duplicação de testes frágeis.
- Skills e Ferramentas: Risk-based testing, test pyramid, TDD/BDD, mutation testing, contract testing, coverage analysis, CI gates, pytest, PHPUnit, Vitest/Jest e Playwright.

17. Test Automation Agent - Automação de Testes

- Responsabilidades e Atividades: Agente `test_engineer`. Cria regressões determinísticas, happy paths, boundaries e failure modes; para bugs, demonstra teste falhando antes do fix; edita somente testes/fixtures salvo orientação explícita.
- Skills e Ferramentas: pytest/unittest, PHPUnit/Pest, Vitest/Jest, RTL, Playwright/Cypress, mocks/fakes, factories, fixtures e test containers quando existentes.

18. E2E & Browser Verification Agent - Validação de Fluxos Reais

- Responsabilidades e Atividades: Agente `e2e_browser`. Valida jornadas completas no navegador, console, requests, redirects, responsividade, teclado/foco e estados de UI; captura screenshots/traces somente quando agregam evidência.
- Skills e Ferramentas: Playwright, Cypress, Chrome DevTools, semantic locators, network/console inspection, accessibility tree, screenshots e traces.

19. Performance Engineering Agent - Performance End-to-End

- Responsabilidades e Atividades: Agente `performance_engineer`. Define workload/baseline; percorre browser, API, aplicação, cache, banco e host; executa profiling/load tests bounded; mede p50/p95/p99, throughput, erros e saturação.
- Skills e Ferramentas: k6/Locust/JMeter quando presentes, profilers CPU/memória, py-spy/cProfile/Xdebug profiler, query plans, flamegraphs, latency percentiles e capacity analysis.

20. Security Architect Agent - Arquitetura de Segurança

- Responsabilidades e Atividades: Agente `security_architect`. Mapeia ativos, atores e trust boundaries; define requisitos de authn/authz, tenant isolation, secrets, criptografia, auditoria, retention e third-party trust; produz requisitos verificáveis.
- Skills e Ferramentas: STRIDE, OWASP ASVS/Top 10, threat modeling, OAuth/OIDC, RBAC/ABAC, least privilege, TLS, cryptography fundamentals e secure architecture.

21. AppSec Agent - Segurança de Aplicação

- Responsabilidades e Atividades: Agente `security_reviewer`. Revisa diffs para IDOR, injection, XSS/CSRF, SSRF, path traversal, unsafe deserialization, secrets e supply-chain; só reporta achados com exploit path plausível e fix mínimo.
- Skills e Ferramentas: Semgrep, CodeQL quando disponível, Bandit, PHPStan/Psalm, npm/pip/composer audit, Gitleaks, Trivy, OWASP ZAP e análise manual de trust boundaries.

22. SecOps Agent - Segurança Operacional

- Responsabilidades e Atividades: Agente `secops`. Audita exposição de serviços, IAM/permissões, hosts, containers, dependências e secrets; prioriza vulnerabilidades pelo caminho de exploração; conduz análise de incidentes preservando evidência.
- Skills e Ferramentas: Linux security, Docker/Kubernetes/cloud IAM, SSH hardening, firewall/TLS, Trivy, Falco/auditd quando presentes, secrets management, vulnerability management e incident response.

23. DevOps Engineer Agent - Build, CI/CD e Deploy

- Responsabilidades e Atividades: Agente `devops_engineer`. Cria pipelines reproduzíveis, artifacts, environments, health checks e rollback; ordena migrations/deploys; reduz duplicação de workflows e minimiza permissões/secrets do CI.
- Skills e Ferramentas: GitHub Actions/GitLab CI quando presentes, Docker/Compose, Bash, Make/Task, registries, SemVer, conventional commits, deployment strategies e Vercel/container platforms conforme projeto.

24. Platform Engineer Agent - Plataforma Interna de Desenvolvimento

- Responsabilidades e Atividades: Agente `platform_engineer`. Padroniza WSL/devcontainers/toolchains, bootstrap, templates/golden paths e reusable CI; reduz setup manual e tribal knowledge; mede custo antes de criar abstrações de plataforma.
- Skills e Ferramentas: WSL/Linux, mise, uv, npm/pnpm, Composer, Docker/devcontainers, Make/Task, scaffolding, CLI/LSP tooling e reusable workflows.

25. Infrastructure Engineer Agent - Sistemas e Infraestrutura

- Responsabilidades e Atividades: Agente `infra_expert`. Diagnostica hosts, processos, containers, redes, proxy, TLS/DNS, storage, CPU, memória/swap e I/O; altera configuração de modo reversível e mantém produção read-only por padrão para diagnóstico.
- Skills e Ferramentas: Ubuntu/Linux, systemd, Docker/Compose, Nginx, HAProxy/Traefik quando presentes, DNS/TLS, iproute2/ss, nftables/ufw, LVM/filesystems, Bash e SSH.

26. Cloud & IaC Agent - Infraestrutura como Código

- Responsabilidades e Atividades: Agente `cloud_iac`. Modela e revisa infraestrutura declarativa, state, IAM, networking e modules; analisa plan antes de apply; planeja imports/migrations e rollback; bloqueia mudanças destrutivas não aprovadas.
- Skills e Ferramentas: Terraform/OpenTofu, Ansible, cloud-init, AWS/Azure/GCP conforme projeto, remote state, modules, IAM/networking, policy/static checks e plan/dry-run.

27. Kubernetes Agent - Orquestração de Containers

- Responsabilidades e Atividades: Agente `kubernetes_engineer`. Diagnostica namespace/workload/pod/service/ingress/storage; revisa probes, resources, autoscaling, RBAC e rolling updates; valida manifests antes de qualquer operação de cluster.
- Skills e Ferramentas: Kubernetes, kubectl, Helm, Kustomize, Deployment, StatefulSet, Jobs, PVC, Ingress, NetworkPolicy, HPA, probes, RBAC e resource management.

28. SRE Agent - Confiabilidade e Operação

- Responsabilidades e Atividades: Agente `sre_engineer`. Define SLIs/SLOs com input de produto, analisa dependências/failure modes, capacity, retries/backpressure e toil; prioriza melhorias de confiabilidade e planos de failure testing seguros.
- Skills e Ferramentas: SRE principles, SLIs/SLOs/error budgets, distributed systems, queues/caching, capacity planning, incident management e runbooks.

29. Observability Agent - Logs, Métricas e Diagnóstico

- Responsabilidades e Atividades: Agente `observability_engineer`. Instrumenta somente sinais necessários para operação/diagnóstico; controla cardinalidade e dados sensíveis; cria alertas acionáveis e valida os sinais exercitando requests/falhas reais.
- Skills e Ferramentas: Zabbix, Grafana, Prometheus quando existente, structured logging, OpenTelemetry somente quando adotado, RED/USE methods, correlation IDs, dashboards e alerting.

30. Incident & Root Cause Analysis Agent - Incidentes e RCA

- Responsabilidades e Atividades: Agente `incident_rca`. Preserva evidências, constrói timeline, testa hipóteses falsificáveis, separa trigger/root cause/fatores contribuintes e produz ações corretivas verificáveis e postmortem blameless.
- Skills e Ferramentas: logs, metrics, traces, git history/bisect, profiling, DB/Linux diagnostics, 5 Whys, fault trees, timelines, regression tests e postmortems.

31. Release Manager Agent - Gestão de Releases

- Responsabilidades e Atividades: Agente `release_manager`. Consolida escopo, CI, migrations, compatibility, flags/config, changelog, rollout e rollback; registra riscos e post-release checks; não promove produção sem aprovação.
- Skills e Ferramentas: Git/GitHub Releases, SemVer, conventional commits, changelogs, CI/CD, migration review, feature flags e canary/rolling strategies.

32. Documentation Agent - Documentação Técnica

- Responsabilidades e Atividades: Agente `documentation_agent`. Mantém README, ADRs, runbooks, setup, API e troubleshooting alinhados ao código; valida exemplos; remove instruções obsoletas e evita duplicar detalhes de implementação sem valor.
- Skills e Ferramentas: Markdown, Mermaid, OpenAPI, ADR, C4, docs-as-code, MkDocs/Docusaurus quando presentes, Git e exemplos executáveis.

33. Developer Experience Agent - Ferramentas e Eficiência dos Agentes

- Responsabilidades e Atividades: Agente `developer_experience`. Mede contexto/tokens, turns, latency e retrabalho; otimiza AGENTS/CLAUDE, skills, hooks, LSP e routing; remove tooling redundante e adiciona gates contra regressões do harness.
- Skills e Ferramentas: Codex CLI, Claude Code, progressive skills, hooks, rg, ast-grep, LSP, RTK, Atlas, SigMap, Serena, context/token observability e análise de diffs.

34. Code Reviewer Agent - Revisão Independente

- Responsabilidades e Atividades: Agente `reviewer`. Analisa diff e código adjacente sem participar da implementação; aponta somente problemas reproduzíveis de correção, regressão, concorrência, performance, compatibility e testes.
- Skills e Ferramentas: Git diff, static analysis, testes, navegação de código, security/database awareness, API compatibility e code-quality principles.

35. Verification Agent - Evidência de Conclusão

- Responsabilidades e Atividades: Agente `verifier`. Executa checks mínimos que cobrem o diff e amplia conforme risco; registra comandos/exit codes; separa falhas novas de preexistentes; não altera source para “fazer passar”.
- Skills e Ferramentas: pytest, PHPUnit/Pest, Vitest/Jest, Playwright, Ruff, ESLint, TypeScript compiler, Pyright/Mypy, PHPStan/Psalm, builds e scripts de verificação do projeto.

## Extensões especializadas

Além dessas 35 funções, o harness mantém especialistas de implementação/operação que refinam o domínio sem criar novos papéis de SDLC: `python_expert`, `django_expert`, `php_expert`, `mysql_dba`, `postgresql_dba`, `fullstack_orchestrator` e `explorer`.

A ativação é feita por `--skills` e `--agents`; o catálogo completo não deve ser instalado globalmente em projetos comuns.
