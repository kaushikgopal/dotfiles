# Session Context: {Descriptive Title}

Generated: {YYYY-MM-DD HH:MM}
Repo: {repo-name}
Branch: {branch-name}
HEAD: {full-sha} ({short-sha})
Dirty: {Yes/No} - {one-line `git status -sb` summary}

---

<analysis>
- Coverage: [intent] [state] [decisions] [anchors] [commands/tests] [errors] [risks] [next]
- Redaction: [confirmed no secrets/tokens/PII included]
- Unknowns: {any material gaps a future agent should confirm}
</analysis>

<summary>

## Bootstrap Instructions

**To reach full context, read these files in order (paths are repo-relative):**

```
1. path/to/primary-file.ext:line   # {why this is first; include symbol/identifier}
2. path/to/second-file.ext:line    # {role}
3. path/to/third-file.ext:line     # {role}
```

Optional (if applicable):
```
4. path/to/optional-file.ext:line  # {role}
```

After reading, confirm context with user before proceeding.

---

## Primary Request and Intent

- **Goal**: {what the user wanted / what the work is for}
- **Scope**: {what's in-bounds vs out-of-bounds}

## Current State

- **Working on**: {current focus}
- **Completed**: {what is done and verified}
- **Remaining**: {what is left to reach the goal}
- **Blocked by**: {blockers, or "None"}
- **Repo state**: {branch/commit + any critical uncommitted changes}

## Key Learnings

- {Learning}: {brief explanation}
- {Learning}: {brief explanation}

## Key Decisions (with rationale)

- {Decision}: {rationale}
- {Decision}: {rationale}

## Constraints & Preferences

- {Constraint or user preference discovered during session}
- {Constraint or user preference discovered during session}

## Critical References

- {URL, doc link, or external resource}: {why it matters}
- {Key value or config}: {context}
- {Example input/output}: {relevance}

## Key Technical Concepts

- {Concept / tool / framework}: {why it matters here}
- {Concept / tool / framework}: {why it matters here}

## Files & Code Anchors

Prefer anchors over full snippets. Use `path:line` and a symbol/identifier; include only minimal excerpts when essential.

| Anchor | Role / Change | Notes |
|------|------|------|
| `path/to/file.ext:line` `{identifier}` | {what it does / what changed / why it matters} | {impact, gotchas, edge cases} |
| `path/to/file.ext:line` `{identifier}` | {what it does / what changed / why it matters} | {impact, gotchas, edge cases} |

## Commands & Validation

```sh
# Commands run (redact secrets)
{command}
```

Results:
- {tests run, build output, manual checks}

## Errors & Fixes

- **{Error}**: {root cause} -> {fix} (anchor)

## Risks / Edge Cases

- {Risk}: {impact + mitigation}

## Open Questions (if any)

- {Question that remains unresolved}
- {Question that remains unresolved}

## Next Steps

- [ ] {concrete actionable step}
- [ ] {concrete actionable step}

## Resumption Context

{Paragraph explaining what an agent needs to know to continue this work effectively. Include any non-obvious context, gotchas, or important background.}

</summary>
