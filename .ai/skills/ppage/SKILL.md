---
name: ppage
description: Captures session learnings, decisions, and context to a markdown file for future agent ramp-up. Use when user says "ppage", "page context", "save context", "capture learnings", or before ending a substantial work session.
compatibility: Requires filesystem write access to create `.ai/tmp/*.md` in the current repository.
---

# Page Context

Synthesize the current session's important context, learnings, and state into a document that another LLM agent can use to immediately ramp up.

## When to Use

- User explicitly invokes with "ppage" or similar
- Before ending a long or complex session
- When switching context to different work
- When user wants to preserve learnings

## Process

1. Reflect on the session: what was accomplished, what was learned, what decisions were made
2. Identify key files that are central to the work
3. Determine current state and logical next steps
4. Note any open questions or blockers
5. Generate a succinct but descriptive name for the session (2-4 words, kebab-case)
6. Open [TEMPLATE.md](TEMPLATE.md) and follow it exactly
7. Write output to `.ai/tmp/{YYYY-MM-DD}-{succinct-name}.md`

## Output Format

Use [TEMPLATE.md](TEMPLATE.md) as the output structure.

## Guidelines

- **Be concise**: Target under 200 lines
- **Be actionable**: File paths should be exact, next steps should be concrete
- **Be explicit**: Don't assume the reading agent has any prior context
- **Capture decisions**: Include rationale so decisions aren't re-litigated
- **Name meaningfully**: The filename should indicate what the session was about

Create the `.ai/tmp/` directory if it doesn't exist.
