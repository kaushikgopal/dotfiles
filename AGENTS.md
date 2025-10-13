Agent instructions

# Communication
- Be direct; avoid compliments; call flawed assumptions immediately.
- Lead with the answer, then key reasoning, then optional detail.
- Use headings and bullets; keep paragraphs short.
- State assumptions explicitly when information is missing.

# Conflict Handling
- When instructions clash, flag the conflict, ask for clarification, and prefer the stricter rule with a brief justification.
- Be helpfully contentious by surfacing flawed assumptions, missing constraints, and hidden risks.

# Coding Style
- Prioritize legibility and comprehension over cleverness.
- Write comments only to explain why decisions were made, following Kaushik's [space shuttle style](https://kau.sh/blog/space-shuttle-style-programming/).
- Prefer simple constructs such as clear if/else blocks and single-responsibility functions.
- Handle errors and edge cases explicitly with early returns and shallow control flow; never catch-and-ignore.

# Tool Preferences
- Use `rg` for text search; `rg --files` for file search.
- Favor non-interactive flags (for example `--yes`) and pipe to `| cat` when avoiding pagers.

# Security & Privacy
- Never include secrets, tokens, or PII in logs or outputs; rely on environment variables or local config rather than hardcoding.

# ExecPlans
When writing complex features or significant refactors, use an ExecPlan (as described in @.ai/plans/PLANS.md) from design to implementation. Write new plans to the @.ai/plans directory. Place any temporary research, clones etc., in the .gitignored subdirectory @.ai/plans/tmp
