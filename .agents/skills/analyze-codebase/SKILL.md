---
name: analyze-codebase
description: Use when asked to analyze, audit, or review an unfamiliar codebase — for onboarding, architecture review, tech debt assessment, security audit, or operational readiness evaluation
---

# Analyzing Codebases

## Overview

Comprehensive, evidence-based codebase analysis through systematic exploration. Discover everything from scratch — never assume the tech stack, architecture, or tooling.

**Core principle:** Let the code tell you what it is. Every claim must reference specific files, directories, or code patterns you observed.

## When to Use

- Dropped into an unfamiliar repo and need to understand it
- Asked to perform a codebase audit or architecture review
- Evaluating tech debt, security posture, or operational readiness
- Onboarding to a new project
- Due diligence or vendor code assessment

**Not for:** Quick questions about specific files or functions — use targeted exploration instead.

## Operating Principles

- **Be exhaustive.** Read files fully. Follow references. Trace dependencies.
- **Be autonomous.** Make reasonable decisions and document assumptions. Don't ask the user mid-analysis.
- **Be evidence-based.** Reference specific files and code patterns for every claim.
- **Be opinionated.** State what is good, what is bad, and what should change — with justification.
- **Be technology-neutral.** Discover what's in use before applying domain-specific analysis.

## The Seven Phases

Work sequentially. Each phase builds on the prior.

### Phase 1: Discovery & Inventory

Build a mental map of the entire project from scratch.

1. **Directory tree** — List at least 3 levels deep to understand structure
2. **Tech stack identification** — Inspect file extensions, manifests, configs, and source to determine: languages, frameworks, runtimes, build systems, package managers, databases, external services, infrastructure tooling
3. **Count source files per language** — Produce a quantitative census (e.g., Kotlin, Java, C/C++, Rust, Python, Proto, etc.). Check for native code: CMakeLists.txt, Cargo.toml, Makefiles, `.so`/`.a` libraries, JNI/NDK bindings, WASM modules
4. **Read all documentation** — READMEs, architecture docs, design docs, ADRs, changelogs, contribution guides, API docs, runbooks
5. **Read all configuration** — Dependency manifests, lock files, build configs, env templates, Dockerfiles, CI/CD pipelines, IaC files, linter configs
6. **Produce technology inventory** — Every language, framework, tool, service, and platform dependency with evidencing file(s) and line numbers

### Phase 2: Architecture Analysis

1. **High-level architecture** — Pattern identification (monolith, microservices, serverless, event-driven, layered, hexagonal, pipeline, etc.) and component relationships
2. **Data flow** — How data enters, moves between components, is transformed, persisted, and returned. All data stores and their roles.
3. **API surface & interfaces** — HTTP APIs, RPC, CLIs, message consumers, scheduled jobs, UI entry points, IPC mechanisms (AIDL, shared memory, Unix sockets, intents). Auth patterns.
4. **Key architectural decisions** — Document the "why." Summarize ADRs if they exist; infer and mark as inferred if not.
5. **Component boundaries & coupling** — Modularization, coupling assessment, circular dependencies, boundary violations
6. **Multi-app / multi-process architecture** — If the repo contains multiple applications or processes, map their relationships, communication channels, and shared code

### Phase 3: Dependency & Library Analysis

1. **Locate all dependency declarations** — Every manifest, lock file, vendored dependency
2. **Critical dependencies** — Which libraries are load-bearing vs. superficial?
3. **Risky dependencies** — Unmaintained packages, ancient pinned versions, excessive transitive trees, vendored code with no update path
4. **Dependency hygiene** — Pinned or floating? Lock files committed? Update strategy or tooling?
5. **Vendored and native dependencies** — Check for vendored JARs/AARs/SOs, bundled native libraries, or pre-compiled binaries with no clear update path

### Phase 4: Code Quality & Patterns

1. **Dominant patterns** — OOP/functional/procedural/reactive? Error handling? Logging? Configuration management? Convention consistency?
2. **Testing strategy** — Test types present (unit, integration, e2e, contract, property-based). Meaningful or superficial?
3. **Linting & formatting** — Static analysis configured? Enforced via hooks or CI?
4. **Code churn hotspots** — Use git history if available; infer from complexity and coupling if not
5. **Tech debt indicators** — Search for TODO, FIXME, HACK, XXX, WORKAROUND. Note excessive complexity, duplication, dead code.

### Phase 5: Security Assessment

Adapt to the specific technologies identified in Phase 1.

1. **Authentication & authorization** — Methods, permission enforcement, gaps, overly permissive defaults
2. **Secrets management** — Hardcoded secrets? Credential management approach? Sensitive files in version control?
3. **Input validation** — Validated at boundaries? Injection, deserialization, or input-driven attack risks?
4. **Dependency vulnerabilities** — Audit tooling configured? Run audit if possible.
5. **Data protection** — Encryption at rest/in transit? Data handling and privacy concerns?
6. **Stack-specific pitfalls** — Misconfigured access controls, debug modes in prod configs, exposed internal endpoints, missing rate limiting

### Phase 6: Operational Readiness

1. **Observability** — Structured logging, metrics, distributed tracing? Which platforms?
2. **Error handling & resilience** — Retries, circuit breakers, fallbacks, graceful degradation, timeouts?
3. **Build & deployment** — CI/CD pipeline? Reproducible builds?
4. **Scalability & performance** — Bottlenecks? Scaling design? Caching, connection pooling, resource management?
5. **Deployment topology** — Infrastructure dependencies, fleet management, network topology, VPN/tunneling, device provisioning (if applicable)

### Phase 7: Report Generation

Output a comprehensive Markdown report as `codebase_analysis_report.md`. See `report-template.md` in this directory for the full report structure.

## Execution Rules

| Rule | Detail |
|------|--------|
| **Start immediately** | Begin Phase 1 upon receiving the repo |
| **Discover before assuming** | Let files tell you the stack. Adapt analysis to what you find. |
| **Read broadly, then deeply** | Directory listings and configs first, then drill into source |
| **Use tools aggressively** | List dirs, read files, search patterns (TODOs, secrets, error handling), inspect git history |
| **Prioritize for large codebases** | Entry points, core business logic, config, security-sensitive areas first. Note what you couldn't fully review. |
| **No questions** | If you must assume, state it explicitly in the report |

## Quick Reference

| Phase | Focus | Key Activities |
|-------|-------|---------------|
| 1. Discovery | What exists? | Tree, stack ID, read docs + configs, inventory |
| 2. Architecture | How does it fit together? | Patterns, data flow, APIs, decisions, coupling |
| 3. Dependencies | What does it rely on? | Critical libs, risks, hygiene |
| 4. Code Quality | How good is the code? | Patterns, tests, linting, churn, debt |
| 5. Security | Is it safe? | Auth, secrets, input validation, vulns |
| 6. Operations | Is it production-ready? | Observability, resilience, CI/CD, scaling |
| 7. Report | Synthesize everything | Structured markdown with recommendations |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Assuming the tech stack before reading files | Always discover from file extensions, manifests, and source |
| Skimming documentation | Read fully — docs contain architectural decisions and context |
| Ignoring config files | Configs reveal more about a project than source code |
| Missing git history analysis | `git log --stat`, `git shortlog -sn` reveal churn and ownership |
| Generic recommendations | Every finding must reference specific files and evidence |
| Skipping the report template | Use the structured template — it ensures comprehensive coverage |
| Missing native/cross-language code | Check for C/C++, Rust, Go, WASM — look for CMakeLists.txt, Cargo.toml, Makefiles, `.so` files |
| Not counting files per language | Quantitative census gives immediate sense of codebase shape and dominant languages |
| Ignoring IPC and multi-process boundaries | AIDL, sockets, shared memory, message queues are critical architecture surfaces |
