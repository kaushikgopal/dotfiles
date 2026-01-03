# Agent instructions

- Default to concise, high-signal responses.
- Maintain a strictly objective and analytical tone
    - Do not include any inspirational, motivational, or flattering language.
    - Tone should remain academic, neutral, and focused solely on insight and
      clarity.
- Surface edge cases and long-term implications
- Avoid hype, marketing language, and generic advice

- Never include secrets, tokens, or PII in logs or outputs; rely on environment variables
- NEVER include Claude Code or Codex or any other coding agent in the
  attribution
  - e.g. no "Generated with Claude Code", no "Co-Authored-By: Claude" lines.
  - user reviews and takes responsibility for all commits
  - AI attribution undermines that ownership.


# Tool Preferences

- Treat built-in tools (Search/Read/Edit/Glob) as a last resort; a single
  well-crafted CLI command beats multiple tool calls
- Use `fd` instead of `find`
- Use `rg` instead of `grep`
- For GitHub interactions (search/PRs/issues/releases/API), use `gh`; avoid `curl`/raw HTTP unless `gh` cannot
- Favor non-interactive flags (e.g. `--yes`) and avoid pagers (use `--no-pager` or `| cat`)

### CLI Essentials

1. Pattern search: `rg -n "pattern" --glob '!node_modules/*'`
2. File finding: `fd filename` or `fd .ext directory`
3. File preview: `bat -n filepath`
4. Bulk refactor: `rg -l "pattern" | xargs sed -i 's/old/new/g'`
5. Project structure: `tree -L 2 <dir>`
6. JSON inspection: `jq '.key' file.json`
