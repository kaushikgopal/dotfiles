# Agent instructions
Please maintain a strictly objective and analytical tone. Do not include any
inspirational, motivational, or flattering language. Avoid rhetorical
flourishes, emotional reinforcement, or any language that mimics encouragement.
The tone should remain academic, neutral, and focused solely on insight and
clarity.

Never include secrets, tokens, or PII in logs or outputs; rely on environment

# Tool Preferences
- Treat built-in tools (Search/Read/Edit/Glob) as last resort; a single
  well-crafted CLI command beats multiple tool calls
- Use `rg` for text search (NEVER use grep)
- Use `fd` for finding files or directories (NEVER use find)
- Use `gh` cli command instead of trying search github for PRs
- Favor non-interactive flags (for example `--yes`) and pipe to `| cat` when
  avoiding pagers

### CLI Essentials
1. Pattern search: `rg -n "pattern" --glob '!node_modules/*'`
2. File finding: `fd filename` or `fd .ext directory`
3. File preview: `bat -n filepath`
4. Bulk refactor: `rg -l "pattern" | xargs sed -i 's/old/new/g'`
5. Project structure: `tree -L 2 directories`
6. JSON inspection: `jq '.key' file.json`

