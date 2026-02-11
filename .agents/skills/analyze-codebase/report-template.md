# Codebase Analysis Report Template

Use this structure for the final `codebase_analysis_report.md` output.

```markdown
# [Project Name] — Codebase Analysis Report

## Executive Summary
(2-3 paragraphs: what this project is, its current state, and the most important findings)

## Table of Contents

## 1. Project Overview
  - Purpose & scope
  - Tech stack summary (all languages, frameworks, tools, services identified)
  - Repository structure overview

## 2. Architecture
  - High-level architecture (described in text and/or mermaid diagram)
  - Component breakdown
  - Data flow
  - Interfaces & API surface
  - Key architectural decisions (documented and inferred)

## 3. Dependency & Library Analysis
  - Critical dependencies
  - Most-used libraries
  - Dependency risks & hygiene

## 4. Code Quality & Patterns
  - Dominant patterns & conventions
  - Testing strategy & coverage
  - Code churn hotspots
  - Tech debt inventory

## 5. Security Assessment
  - Authentication & authorization
  - Secrets management
  - Input validation & boundary trust
  - Vulnerability surface
  - Data protection

## 6. Operational Readiness
  - Observability
  - Error handling & resilience
  - Build & deployment pipeline
  - Scalability considerations

## 7. Findings & Recommendations
  - [CRITICAL] issues (fix immediately)
  - [IMPORTANT] improvements (fix soon)
  - [OPPORTUNITY] nice to have
  - [STRENGTH] keep doing this

## 8. Appendix
  - Full technology inventory with evidence
  - Full dependency list
  - File & directory inventory
  - Glossary of project-specific terms
```

## Severity Classification Guide

| Severity | Criteria | Examples |
|----------|----------|---------|
| [CRITICAL] | Actively causes harm, data loss, or security breach risk | Hardcoded secrets, SQL injection, no auth on admin endpoints |
| [IMPORTANT] | Increases risk, slows development, or degrades reliability | No tests, floating dependency versions, no CI/CD |
| [OPPORTUNITY] | Would improve quality but not blocking | Better logging, code organization, documentation gaps |
| [STRENGTH] | Well-implemented patterns worth preserving | Consistent error handling, good test coverage, clean architecture |
