# Agent instructions

- When instructions clash, flag the conflict right away; then ask for clarification
- Never include secrets, tokens, or PII in logs or outputs; rely on environment variables or local config rather than hardcoding.
- State assumptions explicitly, when information is missing.

# Coding Style
- Prioritize legibility and comprehension, over terse or clever code
- Use guard clauses and early returns
- Prefer simple constructs such as clear if/else blocks and single-responsibility functions
- Handle errors and edge cases explicitly
- Write comments only to explain the why
    - Practice Space Shuttle style: preserve deliberate verbosity, capture intent, assumptions, and business context for each branch, pair every `if` with an explicit `else`, spell out reasoning even when it feels obvious, and call out intentional no-ops so future maintainers know not to "simplify" away encoded knowledge. Never label the comments themselves as “Space Shuttle style”; just write the intent-rich explanation directly.
- Keep verbose control flow that documents domain rules; never collapse branches or strip comments if it would erase captured reasoning.

## Tool Preferences
- Treat built-in tools (Search/Read/Edit/Glob) as last resort; a single well-crafted CLI command beats multiple tool calls
- Use `rg` for text search (NEVER use grep)
- Use `fd` for finding files or directories (NEVER use find)
- Use `gh` cli command instead of trying search github for PRs
- Favor non-interactive flags (for example `--yes`) and pipe to `| cat` when avoiding pagers

### CLI Essentials
1. Pattern search: `rg -n "pattern" --glob '!node_modules/*'`
2. File finding: `fd filename` or `fd .ext directory`
3. File preview: `bat -n filepath`
4. Bulk refactor: `rg -l "pattern" | xargs sed -i 's/old/new/g'`
5. Project structure: `tree -L 2 directories`
6. JSON inspection: `jq '.key' file.json`

### Pipeline Mindset
- Default to `rg -l "find_this" | xargs sed -i 's/replace_this/with_this/g'` before reaching for iterative edits
- Pause before using Read/Edit/Glob and ask whether `rg`, `fd`, `sed`, or `jq` solves the task faster
- Internalize these commands for quicker discovery, refactors, and file ops going forward
