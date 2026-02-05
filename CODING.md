# CODING.md

## Think Before Coding

- If multiple approaches exist, present tradeoffs — don't pick silently.
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- If 200 lines could be 50, rewrite it.

## Surgical Changes

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated issues (dead code, bugs), mention them — don't fix them.
- Remove imports/variables/functions that YOUR changes made unused.
- Every changed line should trace directly to the request.

## Error Handling

- Handle errors at boundaries: I/O, network, user input, external APIs.
- Let programming errors crash. Don't catch-and-log bugs that should be fixed.
- No error handling for impossible scenarios.
- Don't swallow errors silently. If you catch it, do something useful with it.

## Testing

- Run existing tests after changes. Don't commit broken tests.
- Write tests when adding new behavior. Don't write tests for trivial glue code.
- If no test infrastructure exists, say so — don't invent one.
- Tests should verify behavior, not implementation details.

## Commits

- Commit messages: imperative mood, concise subject line, body if non-obvious.
- One logical change per commit. Don't bundle unrelated changes.
- No merge commits in feature branches — rebase.

<!-- 
## Project-Specific Overrides
Uncomment and fill in per-repo:

- Language/framework:
- Package manager:
- Test runner:
- Lint/format commands:
- Build commands:
- Branch naming convention:
- Any architectural constraints:
-->
