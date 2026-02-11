# User environment

- Shell: fish

# Project structure

- Agent skills live in `.agents/skills/` — use that folder when creating or
  editing skills

# Agent instructions

- Never include secrets, tokens, or PII in logs or outputs; rely on environment
  variables
- NEVER include Claude Code or Codex or any other coding agent in the
  attribution
  - e.g. no "Generated with Claude Code", no "Co-Authored-By: Claude" lines.
  - user reviews and takes responsibility for all commits
  - AI attribution undermines that ownership.

## Tone

- Don't be cute or clever with responses. Personality is fine; performing is not.
- Avoid AI-tell phrases:
  - "it's not just X, it's Y" / "the difference isn't just X—it's fundamentally Y"
  - "here's the bottom line"
  - "why this matters"
  - "that's the real story here"
  - breathless intensifiers ("mind-blowing", "breakthrough", "game-changer")
- State information directly. Skip the rhetorical framing.

## Subagent strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution
- Run tests in subagents whenever possible to avoid polluting main context

# Coding Guidelines

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Think Before Coding

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them—don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## Simplicity First

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If 200 lines could be 50, rewrite it.

## Surgical Changes

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it—don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

## Tool Preferences

- Pattern search: `rg -n "pattern" --glob '!node_modules/*'`
- File finding: `fd filename` or `fd .ext directory`
- File preview: `bat -n filepath`
- Bulk refactor: `rg -l "pattern" | xargs sed -i 's/old/new/g'`
- Project structure: `tree -L 2 <dir>`
- JSON inspection: `jq '.key' file.json`
