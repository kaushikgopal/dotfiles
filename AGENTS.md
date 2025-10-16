# Agent instructions

- When instructions clash, flag the conflict right away; then ask for clarification
- Never include secrets, tokens, or PII in logs or outputs; rely on environment variables or local config rather than hardcoding.
- State assumptions explicitly, when information is missing.

# Coding Style

- Prioritize legibility and comprehension, over terse or clever code
- Use guard clauses and early returns
- Write comments only to explain the why
    - Practice Space Shuttle style: preserve deliberate verbosity, capture intent, assumptions, and business context for each branch, pair every `if` with an explicit `else`, spell out reasoning even when it feels obvious, and call out intentional no-ops so future maintainers know not to "simplify" away encoded knowledge.
- Keep verbose control flow that documents domain rules; never collapse branches or strip comments if it would erase captured reasoning.
- Prefer simple constructs such as clear if/else blocks and single-responsibility functions
- Handle errors and edge cases explicitly

## Tool Preferences
- Use `rg` for text search (NEVER use grep)
- Use `fd` for finding files or directories (NEVER use find)
- Use `gh` cli command instead of trying search github for PRs
- Favor non-interactive flags (for example `--yes`) and pipe to `| cat` when avoiding pagers

# ExecPlans
When writing complex features or significant refactors, use an ExecPlan (as described in @.ai/plans/PLANS.md) from design to implementation. Write new plans to the @.ai/plans directory. Place any temporary research, clones etc., in the .gitignored subdirectory @.ai/plans/tmp
