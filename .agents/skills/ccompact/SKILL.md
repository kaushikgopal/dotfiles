---
name: ccompact
description:
  Compacts session context into a markdown handoff for future agent ramp-up. Use
  when user says "ccompact", "compact context", "page context", "save context",
  "capture learnings", or before ending a substantial work session. Previously
  called "ppage" command.
compatibility:
  Requires filesystem write access to create `.agents/tmp/*.md` in the current
  repository.
---

# Context Compaction (ccompact)

Synthesize the current session's context, decisions, and current state into a
durable handoff note that a future agent can use to resume work with minimal
re-discovery.

## When to Use

- User explicitly invokes with "ccompact" or similar (legacy: "ppage")
- Before ending a long or complex session
- When switching context to different work
- When user wants to preserve learnings

## Core Principles

- **Synthesize, don't transcript**: Do not include chat logs or lists of user
  messages.
- **Anchor to sources**: Prefer precise file/line/symbol references over pasted
  code. Include small excerpts only when essential.
- **State > chronology**: Capture the best current understanding and how to
  resume, not a play-by-play history.
- **Redact by default**: Never include secrets/tokens/credentials/PII. Use
  placeholders like `<REDACTED>` and refer to environment variables (e.g.,
  `$GITHUB_TOKEN`) when needed.
- **Bootstrap first**: Make it fast for a future agent to find the authoritative
  sources (key files, anchors, commands).

## Process

1. Determine the handoff target: what a future agent must know to continue
   effectively (goal, scope, current state).
2. Capture repo state: branch, HEAD commit, and whether the working tree is
   dirty (do not include secrets from config).
3. Extract the high-signal outcomes:
   - What changed (behavior/structure), and why
   - Decisions and trade-offs (with rationale)
   - Constraints/preferences discovered
   - Errors encountered and how they were resolved
   - Risks/edge cases and mitigations
4. Produce **Bootstrap Instructions**:
   - List the minimum set of file paths to read (required vs optional)
   - Use repo-relative paths (relative to the repo root) to avoid leaking
     home-directory PII
   - Include anchors like `path/to/file:line` and identifiers
     (function/class/target/script name)
5. Generate a succinct filename topic (2-6 words, kebab-case).
6. Open [TEMPLATE.md](TEMPLATE.md) and follow it exactly.
7. Write output to `.agents/tmp/{YYYY-MM-DD}-{topic}.md` (create `.agents/tmp/` if
   missing).

## Output Format

Use [TEMPLATE.md](TEMPLATE.md) as the output structure.

## Guidelines

- **Analysis + Summary**: Include an `<analysis>` block first (coverage
  checklist + unknowns), then a `<summary>` block with the handoff content.
- **Adaptive verbosity (preferred)**: Always include all required sections, but
  keep each section minimal. Expand only when a decision/risk/state would
  otherwise be ambiguous. Prefer adding anchors over adding prose.
- **Be concise**: Target under ~250 lines; if longer, replace prose with anchors
  and "read this file" pointers.
- **Be actionable**: Paths must be exact, next steps must be concrete and
  ordered.
- **Be explicit**: Do not assume the reader has any prior context.
- **Capture decisions**: Include rationale and constraints so decisions aren't
  re-litigated.
- **Preserve constraints**: Record user preferences and environment limitations
  that affect future work.
- **Anchor format**: Use `path/to/file:line` (1-based, relative to repo root)
  plus a symbol/identifier (e.g., `function foo()`, `class Bar`,
  `Makefile target`, `script name`).
- **No full dumps**: Avoid full-file content and long logs. If an excerpt is
  essential, keep it short (<=10 lines) and include its anchor.
- **Omit empty sections**: If a section has no content, omit it (do not leave
  placeholders).
- **Git hygiene**: Prefer `.agents/tmp/` so pages are not accidentally committed;
  add `.agents/tmp/**` to `.gitignore` if needed.

Create the `.agents/tmp/` directory if it doesn't exist.
